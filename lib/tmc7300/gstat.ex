defmodule TMC7300.GSTAT do
  defstruct [
    reset: 0,
    drv_err: 0,
    u3v5: 0
  ]

  def encode() do
    <<0x00, 0x00, 0x00, 0x01>>
  end

  def decode(<<
    _ :: 29,
    u3v5 :: 1,
    drv_err :: 1,
    reset :: 1
  >>) do
    %__MODULE__{
      reset: reset,
      drv_err: drv_err,
      u3v5: u3v5
    }
  end
end
