defmodule TMC7300 do
  use GenServer
  use Bitwise

  alias Circuits.UART
  alias TMC7300.{GCONF, IOIN, DRV_STATUS, CHOPCONF, GSTAT}

  @send_delay 8

  @gconf 0x00
  @gstat 0x01
  @ifcnt 0x02
  @slaveconf 0x03
  @ioin 0x06
  @current_limit 0x10
  @pwm_ab 0x22
  @chopconf 0x6C
  @drv_status 0x6F
  @pwm_conf 0x70

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def gconf(pid, %GCONF{} = gconf) do
    GenServer.call(pid, {:gconf, gconf})
  end

  def gconf(pid) do
    GenServer.call(pid, :gconf)
  end

  def gstat_reset(pid) do
    GenServer.call(pid, :gstat_reset)
  end

  def gstat(pid) do
    GenServer.call(pid, :gstat)
  end

  def chopconf(pid) do
    GenServer.call(pid, :chopconf)
  end

  def chopconf(pid, %CHOPCONF{} = chopconf) do
    GenServer.call(pid, {:chopconf, chopconf})
  end

  def current_limit(pid, motorrun, irun) do
    GenServer.call(pid, {:current_limit, motorrun, irun})
  end

  def pwm_ab(pid, pwm_a, pwm_b) do
    GenServer.call(pid, {:pwm_ab, pwm_a, pwm_b})
  end

  def ioin(pid) do
    GenServer.call(pid, :ioin)
  end

  def drv_status(pid) do
    GenServer.call(pid, :drv_status)
  end

  def init(opts) do
    address = opts[:address] || 0x00
    port = opts[:port]
    speed = opts[:speed] || 115200

    {:ok, pid} = UART.start_link()
    :ok = UART.open(pid, port, speed: speed)

    {:ok, %{
      timeout: (speed / 60) * @send_delay,
      speed: speed,
      address: address,
      uart: pid,
      seq: 0
    }, {:continue, nil}}
  end

  def handle_continue(_ ,state) do
    {:ok, <<seq :: integer-32>>} = read(@ifcnt, state)
    {:noreply, %{state | seq: seq}}
  end

  def handle_call(:chopconf, _from, state) do
    case read(@chopconf, state) do
      {:ok, resp} ->
        {:reply, {:ok, resp}, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:chopconf, chopconf}, _from, state) do
    case write(@chopconf, CHOPCONF.encode(chopconf), state) do
      {:ok, state} ->
        {:reply, :ok, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:gstat, _from, state) do
    case read(@gstat, state) do
      {:ok, resp} ->
        {:reply, {:ok, resp}, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:gconf, _from, state) do
    case read(@gconf, state) do
      {:ok, resp} ->
        {:reply, {:ok, resp}, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:gconf, gconf}, _from, state) do
    case write(@gconf, GCONF.encode(gconf), state) do
      {:ok, state} ->
        {:reply, :ok, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:pwm_ab, pwm_a, pwm_b}, _from, state) do
    case write(@pwm_ab, <<pwm_b :: integer-signed-16, pwm_a :: integer-signed-big-16>>, state) do
      {:ok, state} ->
        {:reply, :ok, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:current_limit, motorrun, irun}, _from, state) do
    case write(@current_limit, <<0 :: 20, irun :: 4,  0 :: 7, motorrun :: 1>>, state) do
      {:ok, state} ->
        {:reply, :ok, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:drv_status, _from, state) do
    case read(@drv_status, state) do
      {:ok, resp} ->
        {:reply, {:ok, resp}, state}
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:ioin, _from, state) do
    case read(@ioin, state) do
      {:ok, resp} ->
        {:reply, {:ok, resp}, state}
      error ->
        {:reply, error, state}
    end
  end

  def read(register, %{uart: uart, address: address}) do
    data = read_datagram(address, register)
    len = byte_size(data)
    UART.write(uart, data)

    read_bytes(uart, len)
    resp = read_bytes(uart, 8)
    case checksum?(resp) do
      true -> {:ok, decode_value(register, resp)}
      false -> {:error, :crc}
    end
  end

  def read_bytes(uart, bytes, buffer \\ <<>>)
  def read_bytes(_, bytes, buffer) when byte_size(buffer) >= bytes, do: buffer
  def read_bytes(uart, bytes, buffer) do
    receive do
      {:circuits_uart, _uart, data} ->

        read_bytes(uart, bytes, buffer <> data)
      after
        5000 ->
          {:error, :timeout}
    end
  end

  def write(register, data, %{uart: uart, address: address} = state) do
    data = write_datagram(address, register, data)
    len = byte_size(data)
    UART.write(uart, data)
    read_bytes(uart, len)
    case read(@ifcnt, state) do
      {:ok, <<seq :: integer-32>>} ->
        if seq != state.seq do
          {:ok, %{state | seq: seq}}
        else
          {:error, :invalid_seq}
        end
      error -> error
    end
  end

  def write_datagram(address, register, data) do
    data =
      <<
        0x05,
        address,
        1 :: 1,
        register :: 7,
        data :: binary-4
      >>
    <<data :: binary, crc8(data)>>
  end

  def read_datagram(address, register) do
    data =
      <<
        0x05,
        address,
        register
      >>
    <<data :: binary, crc8(data)>>
  end

  def decode_value(register, <<_ :: binary-3, value :: binary-4, _crc :: binary>>) do
    case register do
      @gconf -> GCONF.decode(value)
      @gstat -> GSTAT.decode(value)
      @ioin -> IOIN.decode(value)
      @drv_status -> DRV_STATUS.decode(value)
      @chopconf -> CHOPCONF.decode(value)
      _ -> value
    end
  end

  def checksum?(<<data :: binary-7, crc :: integer>>) do
    crc8(data) == crc
  end

  def crc8(data) when is_binary(data),
    do: :erlang.binary_to_list(data) |> crc8()
  def crc8(data) when is_list(data) do
    Enum.reduce(data, 0, fn(byte, crc) ->
      {crc, _} =
        Enum.reduce(0..7, {crc, byte}, fn(_bit, {crc, byte}) ->
          crc =
            if ((crc >>> 7) ^^^ (byte &&& 0x01)) == 0x01 do
              ((crc <<< 1) &&& 0xFF) ^^^ 0x07
            else
              (crc <<< 1) &&& 0xFF
            end
          {crc, byte >>> 1}
        end)
      crc
    end)
  end
end
