import Base
# s1_embench_crc32: Port of Embench-IoT crc32 (crc_32.c)
# Table-driven IEEE 802.3 CRC-32 (polynomial 0xEDB88320), 3000 rounds x 1024 bytes.

type CrcSt is Type:
  CS{tab: Array<U32>, crc: U32, seed: U32}

type RoundSt is Type:
  RS{tab: Array<U32>, acc: U32}

def crc_bit_xor(bit: Bool, +half: U32) -> U32:
  match bit:
    case True{}:
      U32.xor(half, 3988292384)
    case False{}:
      half

def crc_bit(+rem: Nat, +c: U32) -> U32:
  match rem:
    case 0n:
      c
    case 1n+p:
      +half = U32.shrn(c, 1n)
      crc_bit(p, crc_bit_xor(U32.is_ne(U32.and(c, 1), 0), half))

def init_tab(+rem: Nat, +i: U32, tab: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      tab
    case 1n+p:
      init_tab(p, U32.inc(i), Array.set(U32, tab, i, crc_bit(8n, i)))

def step_crc(+crc: U32, +seed: U32, r: Array<U32> & U32) -> CrcSt:
  (tab, +tv) = r
  CS{tab, U32.xor(tv, U32.shrn(crc, 8n)), seed}

def crc_bytes(+rem: Nat, st: CrcSt) -> CrcSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      CS{tab, +crc, +seed} = st
      +seed1 = U32.and(U32.add(U32.mul(seed, 1103515245), 12345), 2147483647)
      +octet = U32.and(U32.shrn(seed1, 16n), 255)
      +idx = U32.and(U32.xor(crc, octet), 255)
      crc_bytes(p, step_crc(crc, seed1, Array.get(U32, tab, idx)))

def finish_round(+acc: U32, cs: CrcSt) -> RoundSt:
  CS{tab1, +crc1, +s1} = cs
  +res = U32.xor(crc1, 4294967295)
  +acc1 = U32.mul(U32.xor(acc, res), 16777619)
  RS{tab1, acc1}

def run_rounds(+rem: Nat, +r: U32, st: RoundSt) -> U32:
  match rem:
    case 0n:
      RS{tab, +acc} = st
      acc
    case 1n+p:
      RS{tab, +acc} = st
      run_rounds(p, U32.inc(r), finish_round(acc, crc_bytes(1024n, CS{tab, 4294967295, r})))

def main() -> U32:
  tab = init_tab(256n, 0, Array.new(U32, 8n, 0))
  run_rounds(3000n, 0, RS{tab, 2166136261})
