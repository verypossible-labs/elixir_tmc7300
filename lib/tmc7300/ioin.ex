defmodule TMC7300.IOIN do
  defstruct [
    en: 0,
    nstdby: 0,
    ad0: 0,
    ad1: 0,
    diag: 0,
    uart_en: 0,
    uart_io: 0,
    mode_io: 0,
    a2: 0,
    a1: 0,
    comp_a1a2: 0,
    comp_b1b2: 0,
    version: 0
  ]

  def decode(<<
    version :: integer-8,
    _,
    _ :: 4,
    comp_b1b2 :: 1,
    comp_a1a2 :: 1,
    a1 :: 1,
    a2 :: 1,
    mode_io :: 1,
    uart_io :: 1,
    uart_en :: 1,
    diag :: 1,
    ad1 :: 1,
    ad0 :: 1,
    nstdby :: 1,
    en :: 1,
  >>) do
    %__MODULE__ {
      en: en,
      nstdby: nstdby,
      ad0: ad0,
      ad1: ad1,
      diag: diag,
      uart_en: uart_en,
      uart_io: uart_io,
      mode_io: mode_io,
      a2: a2,
      a1: a1,
      comp_a1a2: comp_a1a2,
      comp_b1b2: comp_b1b2,
      version: version
    }
  end
end
