defmodule TMC7300.DRV_STATUS do
  defstruct [
    t150: 0,
    t120: 0,
    lib: 0,
    lia: 0,
    s2vsb: 0,
    s2vsa: 0,
    s2gb: 0,
    s2ga: 0,
    ot: 0,
    otpw: 0,
  ]

  def decode(<<
    _ :: 22,
    t150 :: 1,
    t120 :: 1,
    lib :: 1,
    lia :: 1,
    s2vsb :: 1,
    s2vsa :: 1,
    s2gb :: 1,
    s2ga :: 1,
    ot :: 1,
    otpw :: 1,
  >>) do
    %__MODULE__{
      t150: t150,
      t120: t120,
      lib: lib,
      lia: lia,
      s2vsb: s2vsb,
      s2vsa: s2vsa,
      s2gb: s2gb,
      s2ga: s2ga,
      ot: ot,
      otpw: otpw
    }
  end
end
