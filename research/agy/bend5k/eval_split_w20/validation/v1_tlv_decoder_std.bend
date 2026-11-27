import Base
# v1_tlv_decoder (std): Binary TLV/packet protocol decoder over List<&2, Packet>
# Validation family 1: uniform 8-tag distribution, 320 packets, 70,000 passes.

type Packet is Data:
  TlvHdr{ver: U32, flags: U32}
  TlvU32{tag: U32, val: U32}
  TlvPair{a: U32, b: U32}
  TlvXor{mask: U32, payload: U32}
  TlvShift{sh: Nat, val: U32}
  TlvCrc{seed: U32, word: U32}
  TlvSkip{pad: U32}
  TlvEnd{magic: U32}

type DecState is Data:
  DSt{crc: U32, seq: U32, acc: U32, err: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def mk_pkt.go(tag: Nat, +a: U32, +b: U32) -> Packet:
  match tag:
    case 0n:
      TlvHdr{U32.inc(U32.and(a, 15)), U32.and(b, 255)}
    case 1n:
      TlvU32{a, b}
    case 2n:
      TlvPair{a, b}
    case 3n:
      TlvXor{a, b}
    case 4n:
      TlvShift{U32.to_nat(U32.inc(U32.and(a, 7))), b}
    case 5n:
      TlvCrc{a, b}
    case 6n:
      TlvSkip{a}
    case 7n+p:
      TlvEnd{a}

def build_pkts(+n: Nat, +seed: U32, acc: List<&2, Packet>) -> List<&2, Packet>:
  match n:
    case 0n:
      acc
    case 1n+p:
      +s1 = prng(seed)
      +s2 = prng(s1)
      +s3 = prng(s2)
      build_pkts(p, s3, Con{mk_pkt.go(U32.to_nat(U32.and(s1, 7)), s2, s3), acc})

def decode_pass(pkts: List<&2, Packet>, +crc: U32, +seq: U32, +acc: U32, +err: U32) -> DecState:
  match pkts:
    case Nil{}:
      DSt{crc, seq, acc, err}
    case Con{pkt, rest}:
      match pkt:
        case TlvHdr{ver, flags}:
          decode_pass(rest, U32.mul(U32.xor(crc, ver), 16777619), U32.inc(U32.add(seq, flags)), acc, err)
        case TlvU32{tag, val}:
          +nacc = U32.add(acc, U32.xor(tag, val))
          decode_pass(rest, U32.xor(crc, U32.mul(nacc, 2654435761)), seq, nacc, err)
        case TlvPair{a, b}:
          decode_pass(rest, crc, U32.inc(seq), U32.add(U32.xor(acc, a), b), err)
        case TlvXor{mask, +payload}:
          decode_pass(rest, U32.xor(crc, U32.and(mask, payload)), seq, U32.xor(acc, payload), err)
        case TlvShift{+sh, +val}:
          +mixed = U32.xor(U32.shrn(val, sh), U32.shln(val, sh))
          decode_pass(rest, crc, seq, U32.xor(acc, mixed), err)
        case TlvCrc{seed, word}:
          decode_pass(rest, U32.xor(U32.mul(U32.xor(crc, seed), 2654435761), word), seq, acc, err)
        case TlvSkip{pad}:
          decode_pass(rest, crc, seq, acc, U32.add(err, U32.and(pad, 3)))
        case TlvEnd{magic}:
          decode_pass(rest, U32.xor(U32.xor(U32.xor(crc, magic), seq), err), U32.add(seq, 7), acc, err)

def run_decode(+iters: Nat, +pkts: List<&2, Packet>, st: DecState) -> U32:
  match iters:
    case 0n:
      DSt{crc, seq, acc, err} = st
      U32.xor(U32.xor(crc, acc), U32.add(seq, err))
    case 1n+p:
      DSt{crc, seq, acc, err} = st
      run_decode(p, pkts, decode_pass(pkts, crc, seq, acc, err))

def main() -> U32:
  +pkts = build_pkts(320n, 123456789, Nil{})
  run_decode(18000n, pkts, DSt{2166136261, 1, 7, 0})
