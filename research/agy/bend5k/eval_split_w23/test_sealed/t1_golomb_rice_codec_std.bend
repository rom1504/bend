import Base
# t1_golomb_rice_codec (std): Delta + ZigZag + Golomb-Rice (k=3) bitstream codec
# Sealed-Test family 1: 50 rounds x 1024 samples, bit-level encode + decode round-trip.

type GenSt is Type:
  GS{sig: Array<U32>, cur: U32, seed: U32}

type BitWr is Type:
  BW{words: Array<U32>, widx: U32, bitbuf: U32, bitcnt: U32, total_bits: U32}

type EncSt is Type:
  ES{sig: Array<U32>, bw: BitWr, prev: U32}

type BitRd is Type:
  BR{words: Array<U32>, rwidx: U32, rbuf: U32, rcnt: U32}

type RdBit is Type:
  RB{br: BitRd, bit: U32}

type UnarySt is Type:
  US{br: BitRd, q: U32, done: Bool}

type RemSt is Type:
  RS{br: BitRd, r: U32}

type DecSt is Type:
  DS{br: BitRd, dec: Array<U32>, dprev: U32}

type ChkSt is Type:
  CS{dec: Array<U32>, acc: U32}

type CodecSt is Type:
  TS{sig: Array<U32>, words: Array<U32>, dec: Array<U32>, acc: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def sel_sub(gt: Bool, +cur: U32, +mag: U32) -> U32:
  match gt:
    case True{}:
      U32.sub(cur, mag)
    case False{}:
      U32.add(cur, mag)

def step_cur(even: Bool, +cur: U32, +mag: U32) -> U32:
  match even:
    case True{}:
      U32.add(cur, mag)
    case False{}:
      sel_sub(U32.is_gt(cur, mag), cur, mag)

def gen_sig(+rem: Nat, +i: U32, gs: GenSt) -> GenSt:
  match rem:
    case 0n:
      gs
    case 1n+p:
      GS{sig, +cur, +seed} = gs
      +ns = prng(seed)
      +mag = U32.and(U32.shrn(ns, 4n), 15)
      +ncur = step_cur(U32.is_zero(U32.and(ns, 1)), cur, mag)
      gen_sig(p, U32.inc(i), GS{Array.set(U32, sig, i, ncur), ncur, ns})

def flush_if_full(full: Bool, words: Array<U32>, +widx: U32, +bitbuf: U32, +bitcnt: U32, +total_bits: U32) -> BitWr:
  match full:
    case True{}:
      BW{Array.set(U32, words, widx, bitbuf), U32.inc(widx), 0, 0, total_bits}
    case False{}:
      BW{words, widx, bitbuf, bitcnt, total_bits}

def emit_bit(+bit: U32, bw: BitWr) -> BitWr:
  BW{words, +widx, +bitbuf, +bitcnt, +total_bits} = bw
  +nbuf = U32.or(bitbuf, U32.shln(bit, U32.to_nat(bitcnt)))
  +ncnt = U32.inc(bitcnt)
  +ntot = U32.inc(total_bits)
  flush_if_full(U32.is_eq(ncnt, 32), words, widx, nbuf, ncnt, ntot)

def emit_ones(+rem: Nat, bw: BitWr) -> BitWr:
  match rem:
    case 0n:
      bw
    case 1n+p:
      emit_ones(p, emit_bit(1, bw))

def emit_rem(+rem: Nat, +b: Nat, +r: U32, bw: BitWr) -> BitWr:
  match rem:
    case 0n:
      bw
    case 1n+p:
      +bit = U32.and(U32.shrn(r, b), 1)
      emit_rem(p, 1n+b, r, emit_bit(bit, bw))

def zigzag(ge: Bool, +v: U32, +prev: U32) -> U32:
  match ge:
    case True{}:
      U32.shln(U32.sub(v, prev), 1n)
    case False{}:
      U32.sub(U32.shln(U32.sub(prev, v), 1n), 1)

def enc_sample(r: Array<U32> & U32, bw: BitWr, +prev: U32) -> EncSt:
  (sig, +v) = r
  +zz = zigzag(U32.is_ge(v, prev), v, prev)
  +q = U32.shrn(zz, 3n)
  +rm = U32.and(zz, 7)
  bw1 = emit_ones(U32.to_nat(q), bw)
  bw2 = emit_bit(0, bw1)
  bw3 = emit_rem(3n, 0n, rm, bw2)
  ES{sig, bw3, v}

def enc_loop(+rem: Nat, +i: U32, es: EncSt) -> EncSt:
  match rem:
    case 0n:
      es
    case 1n+p:
      ES{sig, bw, +prev} = es
      enc_loop(p, U32.inc(i), enc_sample(Array.get(U32, sig, i), bw, prev))

def flush_tail(nz: Bool, words: Array<U32>, +widx: U32, +bitbuf: U32) -> Array<U32>:
  match nz:
    case True{}:
      Array.set(U32, words, widx, bitbuf)
    case False{}:
      words

def rd_refill_pack(+nwidx: U32, +bit: U32, r: Array<U32> & U32) -> RdBit:
  (words, +nbuf) = r
  RB{BR{words, nwidx, nbuf, 0}, bit}

def rd_refill(full: Bool, words: Array<U32>, +rwidx: U32, +rbuf: U32, +ncnt: U32, +bit: U32) -> RdBit:
  match full:
    case True{}:
      +nwidx = U32.inc(rwidx)
      rd_refill_pack(nwidx, bit, Array.get(U32, words, nwidx))
    case False{}:
      RB{BR{words, rwidx, rbuf, ncnt}, bit}

def read_bit(br: BitRd) -> RdBit:
  BR{words, +rwidx, +rbuf, +rcnt} = br
  +bit = U32.and(U32.shrn(rbuf, U32.to_nat(rcnt)), 1)
  +ncnt = U32.inc(rcnt)
  rd_refill(U32.is_eq(ncnt, 32), words, rwidx, rbuf, ncnt, bit)

def unary_check(is_z: Bool, br: BitRd, +q: U32) -> UnarySt:
  match is_z:
    case True{}:
      US{br, q, True{}}
    case False{}:
      US{br, U32.inc(q), False{}}

def unary_step(+q: U32, rb: RdBit) -> UnarySt:
  RB{br1, +bit} = rb
  unary_check(U32.is_zero(bit), br1, q)

def read_unary(+rem: Nat, us: UnarySt) -> UnarySt:
  match rem:
    case 0n:
      us
    case 1n+p:
      US{br, +q, done} = us
      match done:
        case True{}:
          US{br, q, True{}}
        case False{}:
          read_unary(p, unary_step(q, read_bit(br)))

def rem_step(+b: Nat, +r: U32, rb: RdBit) -> RemSt:
  RB{br1, +bit} = rb
  RS{br1, U32.or(r, U32.shln(bit, b))}

def read_rem(+rem: Nat, +b: Nat, rs: RemSt) -> RemSt:
  match rem:
    case 0n:
      rs
    case 1n+p:
      RS{br, +r} = rs
      read_rem(p, 1n+b, rem_step(b, r, read_bit(br)))

def unzigzag(even: Bool, +dprev: U32, +zz: U32) -> U32:
  match even:
    case True{}:
      U32.add(dprev, U32.shrn(zz, 1n))
    case False{}:
      U32.sub(dprev, U32.shrn(U32.inc(zz), 1n))

def dec_after_rem(+i: U32, +q: U32, +dprev: U32, dec: Array<U32>, rs: RemSt) -> DecSt:
  RS{br2, +r} = rs
  +zz = U32.or(U32.shln(q, 3n), r)
  +v = unzigzag(U32.is_zero(U32.and(zz, 1)), dprev, zz)
  DS{br2, Array.set(U32, dec, i, v), v}

def dec_after_unary(+i: U32, +dprev: U32, dec: Array<U32>, us: UnarySt) -> DecSt:
  US{br1, +q, done} = us
  dec_after_rem(i, q, dprev, dec, read_rem(3n, 0n, RS{br1, 0}))

def dec_loop(+rem: Nat, +i: U32, ds: DecSt) -> DecSt:
  match rem:
    case 0n:
      ds
    case 1n+p:
      DS{br, dec, +dprev} = ds
      dec_loop(p, U32.inc(i), dec_after_unary(i, dprev, dec, read_unary(64n, US{br, 0, False{}})))

def chk_step(+acc: U32, r: Array<U32> & U32) -> ChkSt:
  (dec, +v) = r
  CS{dec, U32.xor(U32.mul(acc, 16777619), v)}

def chk_loop(+rem: Nat, +i: U32, cs: ChkSt) -> ChkSt:
  match rem:
    case 0n:
      cs
    case 1n+p:
      CS{dec, +acc} = cs
      chk_loop(p, U32.inc(i), chk_step(acc, Array.get(U32, dec, i)))

def rd_after_chk(sig: Array<U32>, words: Array<U32>, +seed1: U32, cs: ChkSt) -> CodecSt:
  CS{dec2, +acc2} = cs
  TS{sig, words, dec2, acc2, seed1}

def rd_after_dec(sig: Array<U32>, +acc1: U32, +seed1: U32, ds: DecSt) -> CodecSt:
  DS{br_fin, dec1, +dp} = ds
  BR{words2, +rw, +rb, +rc} = br_fin
  rd_after_chk(sig, words2, seed1, chk_loop(1024n, 0, CS{dec1, acc1}))

def rd_start_dec(sig: Array<U32>, dec: Array<U32>, +base_v: U32, +acc1: U32, +seed1: U32, rw0: Array<U32> & U32) -> CodecSt:
  (words1, +w0) = rw0
  rd_after_dec(sig, acc1, seed1, dec_loop(1024n, 0, DS{BR{words1, 0, w0, 0}, dec, base_v}))

def rd_after_enc(dec: Array<U32>, +base_v: U32, +acc: U32, +seed1: U32, es: EncSt) -> CodecSt:
  ES{sig1, bw_fin, +pv} = es
  BW{words0, +widx, +bitbuf, +bitcnt, +total_bits} = bw_fin
  words1 = flush_tail(U32.is_gt(bitcnt, 0), words0, widx, bitbuf)
  +acc1 = U32.xor(U32.mul(acc, 2654435761), total_bits)
  rd_start_dec(sig1, dec, base_v, acc1, seed1, Array.get(U32, words1, 0))

def rd_after_gen(words: Array<U32>, dec: Array<U32>, +base_v: U32, +acc: U32, gs: GenSt) -> CodecSt:
  GS{sig1, +cur, +seed1} = gs
  rd_after_enc(dec, base_v, acc, seed1, enc_loop(1024n, 0, ES{sig1, BW{words, 0, 0, 0, 0}, base_v}))

def run_rounds(+rem: Nat, +rd: U32, st: CodecSt) -> U32:
  match rem:
    case 0n:
      TS{sig, words, dec, +acc, +seed} = st
      acc
    case 1n+p:
      TS{sig, words, dec, +acc, +seed} = st
      +base_v = U32.add(1000, U32.and(rd, 63))
      st1 = rd_after_gen(words, dec, base_v, acc, gen_sig(1024n, 0, GS{sig, base_v, seed}))
      run_rounds(p, U32.inc(rd), st1)

def main() -> U32:
  sig = Array.new(U32, 10n, 0)
  words = Array.new(U32, 11n, 0)
  dec = Array.new(U32, 10n, 0)
  run_rounds(140n, 0, TS{sig, words, dec, 2166136261, 192837465})
