defmodule TMC7300.CHOPCONF do
  defstruct [
    diss2vs: 0,
    diss2g: 0,
    tbl: 1,
    enabledrv: 1
  ]

  def encode(%__MODULE__{} = chopconf) do
    <<
      chopconf.diss2vs :: 1,
      chopconf.diss2g :: 1,
      0 :: 13,
      chopconf.tbl :: 2,
      0 :: 14,
      chopconf.enabledrv :: 1,
    >>
  end

  def decode(<<
    diss2vs :: 1,
    diss2g :: 1,
    _ :: 13,
    tbl :: 2,
    _ :: 14,
    enabledrv :: 1,
  >>) do
    %__MODULE__{diss2vs: diss2vs, diss2g: diss2g, tbl: tbl, enabledrv: enabledrv}
  end
end
