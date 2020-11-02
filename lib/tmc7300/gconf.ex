defmodule TMC7300.GCONF do
  defstruct [
    pwm_direct: 0,
    extcap: 0,
    par_mode: 0,
    test_mode: 0
  ]

  def encode(%__MODULE__{} = gconf) do
    <<
      0 :: 3 * 8,
      gconf.test_mode :: 1,
      0 :: 4,
      gconf.par_mode :: 1,
      gconf.extcap :: 1,
      gconf.pwm_direct :: 1,
    >>
  end

  def decode(<<
    _ :: binary-3,
    test_mode :: 1,
    _ :: 4,
    par_mode :: 1,
    extcap :: 1,
    pwm_direct :: 1,
    >>) do
    %__MODULE__{pwm_direct: pwm_direct, extcap: extcap, par_mode: par_mode, test_mode: test_mode}
  end
end
