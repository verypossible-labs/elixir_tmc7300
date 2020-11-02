defmodule TMC7300Test do
  use ExUnit.Case
  doctest TMC7300

  test "crc8" do
    assert TMC7300.crc8(<<5, 0, 6>>) == 0x6F
    assert TMC7300.crc8(<<5, 0, 0>>) == 0x48
    assert TMC7300.crc8(<<5, 0, 0, 0, 0, 0, 0>>) == 0x2B
  end
end
