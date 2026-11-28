import Base
# s5_embench_huffbench: Port of Embench-IoT huffbench (libhuffbench.c)
# 80 rounds x 500 bytes: freq count -> Huffman tree -> code table -> bitstream encode -> tree decode.

type HTree is Data:
  HLeaf{sym: U32}
  HNode{l: HTree, r: HTree}

type PQ is Data:
  PQNil{}
  PQCons{freq: U32, tree: HTree, next: PQ}

type InsReq is Data:
  IGo{f: U32, t: HTree, q: PQ}
  ICmp{le: Bool, f: U32, t: HTree, qf: U32, qt: HTree, qr: PQ}

def pq_insert(+fuel: Nat, req: InsReq) -> PQ:
  match fuel:
    case 0n:
      PQNil{}
    case 1n+p:
      match req:
        case IGo{+f, t, q}:
          match q:
            case PQNil{}:
              PQCons{f, t, PQNil{}}
            case PQCons{+qf, qt, qr}:
              pq_insert(p, ICmp{U32.is_le(f, qf), f, t, qf, qt, qr})
        case ICmp{le, +f, t, +qf, qt, qr}:
          match le:
            case True{}:
              PQCons{f, t, PQCons{qf, qt, qr}}
            case False{}:
              PQCons{qf, qt, pq_insert(p, IGo{f, t, qr})}

def build_htree(+fuel: Nat, q: PQ) -> HTree:
  match fuel:
    case 0n:
      HLeaf{0}
    case 1n+p:
      match q:
        case PQNil{}:
          HLeaf{0}
        case PQCons{+f1, t1, rest1}:
          match rest1:
            case PQNil{}:
              t1
            case PQCons{+f2, t2, rest2}:
              build_htree(p, pq_insert(260n, IGo{U32.add(f1, f2), HNode{t1, t2}, rest2}))

type FreqSt is Type:
  FS{data: Array<U32>, freq: Array<U32>}

def clear_u32(+rem: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      clear_u32(p, U32.inc(i), Array.set(U32, a, i, 0))

def cnt_step2(+ch: U32, d1: Array<U32>, rf: Array<U32> & U32) -> FreqSt:
  (f1, +v) = rf
  FS{d1, Array.set(U32, f1, ch, U32.inc(v))}

def cnt_step1(freq: Array<U32>, rd: Array<U32> & U32) -> FreqSt:
  (d1, +ch) = rd
  cnt_step2(ch, d1, Array.get(U32, freq, ch))

def count_freqs(+rem: Nat, +i: U32, st: FreqSt) -> FreqSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      FS{data, freq} = st
      count_freqs(p, U32.inc(i), cnt_step1(freq, Array.get(U32, data, i)))

type PqBuild is Type:
  PB{freq: Array<U32>, q: PQ}

def pq_add_nz(nz: Bool, +sym: U32, +fv: U32, freq: Array<U32>, q: PQ) -> PqBuild:
  match nz:
    case True{}:
      PB{freq, pq_insert(260n, IGo{fv, HLeaf{sym}, q})}
    case False{}:
      PB{freq, q}

def pq_step(+sym: U32, q: PQ, rf: Array<U32> & U32) -> PqBuild:
  (f1, +fv) = rf
  pq_add_nz(U32.is_ne(fv, 0), sym, fv, f1, q)

def build_pq(+rem: Nat, +i: U32, st: PqBuild) -> PqBuild:
  match rem:
    case 0n:
      st
    case 1n+p:
      PB{freq, q} = st
      build_pq(p, U32.inc(i), pq_step(i, q, Array.get(U32, freq, i)))

type CodeTab is Type:
  CT{code: Array<U32>, clen: Array<U32>}

def fill_codes(t: HTree, +bits: U32, +len: U32, ct: CodeTab) -> CodeTab:
  match t:
    case HLeaf{+sym}:
      CT{code, clen} = ct
      CT{Array.set(U32, code, sym, bits), Array.set(U32, clen, sym, len)}
    case HNode{l, r}:
      +b0 = U32.shln(bits, 1n)
      ct1 = fill_codes(l, b0, U32.inc(len), ct)
      fill_codes(r, U32.or(b0, 1), U32.inc(len), ct1)

type EncSt is Type:
  ES{comp: Array<U32>, cpos: U32, bout: U32, nbits: U32}

def emit_flush(full: Bool, comp: Array<U32>, +cpos: U32, +bout: U32, +nbits: U32) -> EncSt:
  match full:
    case True{}:
      ES{Array.set(U32, comp, cpos, bout), U32.inc(cpos), 0, 0}
    case False{}:
      ES{comp, cpos, bout, nbits}

def emit_bits(+rem: Nat, +code: U32, +mask: U32, st: EncSt) -> EncSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      ES{comp, +cpos, +bout, +nbits} = st
      +bit = Bool.to_u32(U32.is_ne(U32.and(code, mask), 0))
      +bout1 = U32.or(U32.shln(bout, 1n), bit)
      +nb1 = U32.inc(nbits)
      emit_bits(p, code, U32.shrn(mask, 1n), emit_flush(U32.is_eq(nb1, 8), comp, cpos, bout1, nb1))

type EncAll is Type:
  EA{data: Array<U32>, code: Array<U32>, clen: Array<U32>, es: EncSt}

def enc_byte3(+cd: U32, data: Array<U32>, code: Array<U32>, es: EncSt, rl: Array<U32> & U32) -> EncAll:
  (clen1, +ln) = rl
  +mask = U32.shln(1, U32.to_nat(U32.sub(ln, 1)))
  EA{data, code, clen1, emit_bits(U32.to_nat(ln), cd, mask, es)}

def enc_byte2(+ch: U32, data: Array<U32>, clen: Array<U32>, es: EncSt, rc: Array<U32> & U32) -> EncAll:
  (code1, +cd) = rc
  enc_byte3(cd, data, code1, es, Array.get(U32, clen, ch))

def enc_byte1(code: Array<U32>, clen: Array<U32>, es: EncSt, rd: Array<U32> & U32) -> EncAll:
  (data1, +ch) = rd
  enc_byte2(ch, data1, clen, es, Array.get(U32, code, ch))

def enc_loop(+rem: Nat, +i: U32, st: EncAll) -> EncAll:
  match rem:
    case 0n:
      st
    case 1n+p:
      EA{data, code, clen, es} = st
      enc_loop(p, U32.inc(i), enc_byte1(code, clen, es, Array.get(U32, data, i)))

def flush_tail_br(has: Bool, comp: Array<U32>, +cpos: U32, +bout: U32, +nbits: U32) -> Array<U32>:
  match has:
    case True{}:
      Array.set(U32, comp, cpos, U32.shln(bout, U32.to_nat(U32.sub(8, nbits))))
    case False{}:
      comp

def flush_tail(es: EncSt) -> Array<U32>:
  ES{comp, +cpos, +bout, +nbits} = es
  flush_tail_br(U32.is_gt(nbits, 0), comp, cpos, bout, nbits)

# Bit-by-bit decode walking HTree
type DecOne is Type:
  DO{comp: Array<U32>, cpos: U32, mask: U32, sym: U32}

type DecReq is Type:
  DGo{t: HTree, comp: Array<U32>, cpos: U32, mask: U32}
  DGot{l: HTree, r: HTree, cpos: U32, mask: U32, rb: Array<U32> & U32}
  DBr{bit: Bool, l: HTree, r: HTree, comp: Array<U32>, cpos: U32, mask: U32}

def dec_sym(+fuel: Nat, req: DecReq) -> DecOne:
  match fuel:
    case 0n:
      match req:
        case DGo{t, comp, +cpos, +mask}: DO{comp, cpos, mask, 0}
        case DGot{l, r, +cpos, +mask, rb}:
          (comp, +v) = rb
          DO{comp, cpos, mask, 0}
        case DBr{b, l, r, comp, +cpos, +mask}: DO{comp, cpos, mask, 0}
    case 1n+p:
      match req:
        case DGo{t, comp, +cpos, +mask}:
          match t:
            case HLeaf{+sym}:
              DO{comp, cpos, mask, sym}
            case HNode{l, r}:
              dec_sym(p, DGot{l, r, cpos, mask, Array.get(U32, comp, cpos)})
        case DGot{l, r, +cpos, +mask, rb}:
          (comp1, +byte) = rb
          +bit = U32.is_ne(U32.and(byte, mask), 0)
          +is1 = U32.is_eq(mask, 1)
          +nmask = Bool.pick(U32, is1, 128, U32.shrn(mask, 1n))
          +ncpos = Bool.pick(U32, is1, U32.inc(cpos), cpos)
          dec_sym(p, DBr{bit, l, r, comp1, ncpos, nmask})
        case DBr{bit, l, r, comp, +cpos, +mask}:
          match bit:
            case True{}:
              dec_sym(p, DGo{r, comp, cpos, mask})
            case False{}:
              dec_sym(p, DGo{l, comp, cpos, mask})

type DecAll is Type:
  DA{comp: Array<U32>, out: Array<U32>, cpos: U32, mask: U32, acc: U32}

def dec_store(+i: U32, out: Array<U32>, +acc: U32, d: DecOne) -> DecAll:
  DO{comp1, +cpos1, +mask1, +sym} = d
  DA{comp1, Array.set(U32, out, i, sym), cpos1, mask1, U32.mul(U32.xor(acc, sym), 16777619)}

def dec_loop(+rem: Nat, +i: U32, +root: HTree, st: DecAll) -> DecAll:
  match rem:
    case 0n:
      st
    case 1n+p:
      DA{comp, out, +cpos, +mask, +acc} = st
      dec_loop(p, U32.inc(i), root, dec_store(i, out, acc, dec_sym(64n, DGo{root, comp, cpos, mask})))

type WorkSt is Type:
  WS{orig: Array<U32>, data: Array<U32>, freq: Array<U32>, code: Array<U32>, clen: Array<U32>, comp: Array<U32>, acc: U32}

def copy_step(+i: U32, dst: Array<U32>, r: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (src1, +v) = r
  (src1, Array.set(U32, dst, i, v))

type CopyPair is Type:
  CP{src: Array<U32>, dst: Array<U32>}

def copy_step2(+i: U32, dst: Array<U32>, r: Array<U32> & U32) -> CopyPair:
  (src1, +v) = r
  CP{src1, Array.set(U32, dst, i, v)}

def copy_arr(+rem: Nat, +i: U32, cp: CopyPair) -> CopyPair:
  match rem:
    case 0n:
      cp
    case 1n+p:
      CP{src, dst} = cp
      copy_arr(p, U32.inc(i), copy_step2(i, dst, Array.get(U32, src, i)))

def after_dec(orig: Array<U32>, freq: Array<U32>, code: Array<U32>, clen: Array<U32>, da: DecAll) -> WorkSt:
  DA{comp1, out1, +cp, +mk, +acc1} = da
  WS{orig, out1, freq, code, clen, comp1, acc1}

def after_enc(orig: Array<U32>, freq: Array<U32>, +root: HTree, +acc: U32, ea: EncAll) -> WorkSt:
  EA{data1, code1, clen1, es1} = ea
  comp1 = flush_tail(es1)
  after_dec(orig, freq, code1, clen1, dec_loop(500n, 0, root, DA{comp1, data1, 0, 128, acc}))

def after_ct(orig: Array<U32>, data: Array<U32>, freq: Array<U32>, comp: Array<U32>, +root: HTree, +acc: U32, ct: CodeTab) -> WorkSt:
  CT{code1, clen1} = ct
  after_enc(orig, freq, root, acc, enc_loop(500n, 0, EA{data, code1, clen1, ES{comp, 0, 0, 0}}))

def after_pq(orig: Array<U32>, data: Array<U32>, code: Array<U32>, clen: Array<U32>, comp: Array<U32>, +acc: U32, pb: PqBuild) -> WorkSt:
  PB{freq1, q} = pb
  +root = build_htree(300n, q)
  after_ct(orig, data, freq1, comp, root, acc, fill_codes(root, 0, 0, CT{code, clen}))

def after_cnt(orig: Array<U32>, code: Array<U32>, clen: Array<U32>, comp: Array<U32>, +acc: U32, fs: FreqSt) -> WorkSt:
  FS{data1, freq1} = fs
  after_pq(orig, data1, code, clen, comp, acc, build_pq(256n, 0, PB{freq1, PQNil{}}))

def after_copy(+r: U32, freq: Array<U32>, code: Array<U32>, clen: Array<U32>, comp: Array<U32>, +acc: U32, cp: CopyPair) -> WorkSt:
  CP{orig1, data1} = cp
  data2 = Array.set(U32, data1, 0, U32.add(97, U32.mod(r, 26)))
  freq0 = clear_u32(256n, 0, freq)
  after_cnt(orig1, code, clen, comp, acc, count_freqs(500n, 0, FS{data2, freq0}))

def run_rounds(+rem: Nat, +r: U32, ws: WorkSt) -> U32:
  match rem:
    case 0n:
      WS{orig, data, freq, code, clen, comp, +acc} = ws
      acc
    case 1n+p:
      WS{orig, data, freq, code, clen, comp, +acc} = ws
      run_rounds(p, U32.inc(r), after_copy(r, freq, code, clen, comp, acc, copy_arr(500n, 0, CP{orig, data})))

def init_orig(a: Array<U32>) -> Array<U32>:
  a = Array.set(U32, a, 0, 74)
  a = Array.set(U32, a, 1, 50)
  a = Array.set(U32, a, 2, 79)
  a = Array.set(U32, a, 3, 90)
  a = Array.set(U32, a, 4, 70)
  a = Array.set(U32, a, 5, 53)
  a = Array.set(U32, a, 6, 48)
  a = Array.set(U32, a, 7, 70)
  a = Array.set(U32, a, 8, 89)
  a = Array.set(U32, a, 9, 76)
  a = Array.set(U32, a, 10, 68)
  a = Array.set(U32, a, 11, 53)
  a = Array.set(U32, a, 12, 85)
  a = Array.set(U32, a, 13, 84)
  a = Array.set(U32, a, 14, 86)
  a = Array.set(U32, a, 15, 89)
  a = Array.set(U32, a, 16, 89)
  a = Array.set(U32, a, 17, 82)
  a = Array.set(U32, a, 18, 77)
  a = Array.set(U32, a, 19, 84)
  a = Array.set(U32, a, 20, 48)
  a = Array.set(U32, a, 21, 86)
  a = Array.set(U32, a, 22, 88)
  a = Array.set(U32, a, 23, 79)
  a = Array.set(U32, a, 24, 48)
  a = Array.set(U32, a, 25, 49)
  a = Array.set(U32, a, 26, 86)
  a = Array.set(U32, a, 27, 67)
  a = Array.set(U32, a, 28, 53)
  a = Array.set(U32, a, 29, 70)
  a = Array.set(U32, a, 30, 78)
  a = Array.set(U32, a, 31, 73)
  a = Array.set(U32, a, 32, 66)
  a = Array.set(U32, a, 33, 49)
  a = Array.set(U32, a, 34, 67)
  a = Array.set(U32, a, 35, 71)
  a = Array.set(U32, a, 36, 49)
  a = Array.set(U32, a, 37, 50)
  a = Array.set(U32, a, 38, 77)
  a = Array.set(U32, a, 39, 84)
  a = Array.set(U32, a, 40, 73)
  a = Array.set(U32, a, 41, 80)
  a = Array.set(U32, a, 42, 84)
  a = Array.set(U32, a, 43, 50)
  a = Array.set(U32, a, 44, 67)
  a = Array.set(U32, a, 45, 73)
  a = Array.set(U32, a, 46, 86)
  a = Array.set(U32, a, 47, 48)
  a = Array.set(U32, a, 48, 48)
  a = Array.set(U32, a, 49, 66)
  a = Array.set(U32, a, 50, 79)
  a = Array.set(U32, a, 51, 85)
  a = Array.set(U32, a, 52, 87)
  a = Array.set(U32, a, 53, 70)
  a = Array.set(U32, a, 54, 68)
  a = Array.set(U32, a, 55, 82)
  a = Array.set(U32, a, 56, 65)
  a = Array.set(U32, a, 57, 89)
  a = Array.set(U32, a, 58, 84)
  a = Array.set(U32, a, 59, 65)
  a = Array.set(U32, a, 60, 51)
  a = Array.set(U32, a, 61, 65)
  a = Array.set(U32, a, 62, 73)
  a = Array.set(U32, a, 63, 52)
  a = Array.set(U32, a, 64, 50)
  a = Array.set(U32, a, 65, 75)
  a = Array.set(U32, a, 66, 70)
  a = Array.set(U32, a, 67, 88)
  a = Array.set(U32, a, 68, 72)
  a = Array.set(U32, a, 69, 82)
  a = Array.set(U32, a, 70, 75)
  a = Array.set(U32, a, 71, 80)
  a = Array.set(U32, a, 72, 65)
  a = Array.set(U32, a, 73, 51)
  a = Array.set(U32, a, 74, 76)
  a = Array.set(U32, a, 75, 67)
  a = Array.set(U32, a, 76, 71)
  a = Array.set(U32, a, 77, 65)
  a = Array.set(U32, a, 78, 51)
  a = Array.set(U32, a, 79, 65)
  a = Array.set(U32, a, 80, 66)
  a = Array.set(U32, a, 81, 76)
  a = Array.set(U32, a, 82, 85)
  a = Array.set(U32, a, 83, 89)
  a = Array.set(U32, a, 84, 81)
  a = Array.set(U32, a, 85, 88)
  a = Array.set(U32, a, 86, 74)
  a = Array.set(U32, a, 87, 82)
  a = Array.set(U32, a, 88, 81)
  a = Array.set(U32, a, 89, 50)
  a = Array.set(U32, a, 90, 82)
  a = Array.set(U32, a, 91, 78)
  a = Array.set(U32, a, 92, 50)
  a = Array.set(U32, a, 93, 90)
  a = Array.set(U32, a, 94, 77)
  a = Array.set(U32, a, 95, 89)
  a = Array.set(U32, a, 96, 69)
  a = Array.set(U32, a, 97, 82)
  a = Array.set(U32, a, 98, 80)
  a = Array.set(U32, a, 99, 76)
  a = Array.set(U32, a, 100, 67)
  a = Array.set(U32, a, 101, 48)
  a = Array.set(U32, a, 102, 48)
  a = Array.set(U32, a, 103, 67)
  a = Array.set(U32, a, 104, 88)
  a = Array.set(U32, a, 105, 70)
  a = Array.set(U32, a, 106, 69)
  a = Array.set(U32, a, 107, 51)
  a = Array.set(U32, a, 108, 71)
  a = Array.set(U32, a, 109, 66)
  a = Array.set(U32, a, 110, 51)
  a = Array.set(U32, a, 111, 72)
  a = Array.set(U32, a, 112, 77)
  a = Array.set(U32, a, 113, 83)
  a = Array.set(U32, a, 114, 53)
  a = Array.set(U32, a, 115, 51)
  a = Array.set(U32, a, 116, 74)
  a = Array.set(U32, a, 117, 73)
  a = Array.set(U32, a, 118, 79)
  a = Array.set(U32, a, 119, 90)
  a = Array.set(U32, a, 120, 69)
  a = Array.set(U32, a, 121, 53)
  a = Array.set(U32, a, 122, 72)
  a = Array.set(U32, a, 123, 66)
  a = Array.set(U32, a, 124, 89)
  a = Array.set(U32, a, 125, 84)
  a = Array.set(U32, a, 126, 90)
  a = Array.set(U32, a, 127, 50)
  a = Array.set(U32, a, 128, 69)
  a = Array.set(U32, a, 129, 74)
  a = Array.set(U32, a, 130, 72)
  a = Array.set(U32, a, 131, 71)
  a = Array.set(U32, a, 132, 68)
  a = Array.set(U32, a, 133, 66)
  a = Array.set(U32, a, 134, 73)
  a = Array.set(U32, a, 135, 48)
  a = Array.set(U32, a, 136, 72)
  a = Array.set(U32, a, 137, 77)
  a = Array.set(U32, a, 138, 89)
  a = Array.set(U32, a, 139, 78)
  a = Array.set(U32, a, 140, 79)
  a = Array.set(U32, a, 141, 86)
  a = Array.set(U32, a, 142, 85)
  a = Array.set(U32, a, 143, 48)
  a = Array.set(U32, a, 144, 72)
  a = Array.set(U32, a, 145, 85)
  a = Array.set(U32, a, 146, 88)
  a = Array.set(U32, a, 147, 82)
  a = Array.set(U32, a, 148, 50)
  a = Array.set(U32, a, 149, 70)
  a = Array.set(U32, a, 150, 75)
  a = Array.set(U32, a, 151, 66)
  a = Array.set(U32, a, 152, 69)
  a = Array.set(U32, a, 153, 82)
  a = Array.set(U32, a, 154, 67)
  a = Array.set(U32, a, 155, 51)
  a = Array.set(U32, a, 156, 69)
  a = Array.set(U32, a, 157, 49)
  a = Array.set(U32, a, 158, 90)
  a = Array.set(U32, a, 159, 73)
  a = Array.set(U32, a, 160, 69)
  a = Array.set(U32, a, 161, 66)
  a = Array.set(U32, a, 162, 79)
  a = Array.set(U32, a, 163, 72)
  a = Array.set(U32, a, 164, 67)
  a = Array.set(U32, a, 165, 87)
  a = Array.set(U32, a, 166, 67)
  a = Array.set(U32, a, 167, 74)
  a = Array.set(U32, a, 168, 68)
  a = Array.set(U32, a, 169, 48)
  a = Array.set(U32, a, 170, 87)
  a = Array.set(U32, a, 171, 82)
  a = Array.set(U32, a, 172, 80)
  a = Array.set(U32, a, 173, 76)
  a = Array.set(U32, a, 174, 76)
  a = Array.set(U32, a, 175, 88)
  a = Array.set(U32, a, 176, 53)
  a = Array.set(U32, a, 177, 68)
  a = Array.set(U32, a, 178, 73)
  a = Array.set(U32, a, 179, 49)
  a = Array.set(U32, a, 180, 73)
  a = Array.set(U32, a, 181, 83)
  a = Array.set(U32, a, 182, 50)
  a = Array.set(U32, a, 183, 78)
  a = Array.set(U32, a, 184, 69)
  a = Array.set(U32, a, 185, 52)
  a = Array.set(U32, a, 186, 75)
  a = Array.set(U32, a, 187, 73)
  a = Array.set(U32, a, 188, 48)
  a = Array.set(U32, a, 189, 68)
  a = Array.set(U32, a, 190, 82)
  a = Array.set(U32, a, 191, 52)
  a = Array.set(U32, a, 192, 69)
  a = Array.set(U32, a, 193, 53)
  a = Array.set(U32, a, 194, 71)
  a = Array.set(U32, a, 195, 72)
  a = Array.set(U32, a, 196, 87)
  a = Array.set(U32, a, 197, 73)
  a = Array.set(U32, a, 198, 81)
  a = Array.set(U32, a, 199, 90)
  a = Array.set(U32, a, 200, 67)
  a = Array.set(U32, a, 201, 72)
  a = Array.set(U32, a, 202, 75)
  a = Array.set(U32, a, 203, 82)
  a = Array.set(U32, a, 204, 83)
  a = Array.set(U32, a, 205, 86)
  a = Array.set(U32, a, 206, 73)
  a = Array.set(U32, a, 207, 82)
  a = Array.set(U32, a, 208, 89)
  a = Array.set(U32, a, 209, 81)
  a = Array.set(U32, a, 210, 77)
  a = Array.set(U32, a, 211, 66)
  a = Array.set(U32, a, 212, 68)
  a = Array.set(U32, a, 213, 74)
  a = Array.set(U32, a, 214, 79)
  a = Array.set(U32, a, 215, 72)
  a = Array.set(U32, a, 216, 72)
  a = Array.set(U32, a, 217, 89)
  a = Array.set(U32, a, 218, 80)
  a = Array.set(U32, a, 219, 66)
  a = Array.set(U32, a, 220, 49)
  a = Array.set(U32, a, 221, 65)
  a = Array.set(U32, a, 222, 65)
  a = Array.set(U32, a, 223, 65)
  a = Array.set(U32, a, 224, 65)
  a = Array.set(U32, a, 225, 71)
  a = Array.set(U32, a, 226, 72)
  a = Array.set(U32, a, 227, 87)
  a = Array.set(U32, a, 228, 79)
  a = Array.set(U32, a, 229, 88)
  a = Array.set(U32, a, 230, 80)
  a = Array.set(U32, a, 231, 81)
  a = Array.set(U32, a, 232, 52)
  a = Array.set(U32, a, 233, 90)
  a = Array.set(U32, a, 234, 66)
  a = Array.set(U32, a, 235, 81)
  a = Array.set(U32, a, 236, 79)
  a = Array.set(U32, a, 237, 75)
  a = Array.set(U32, a, 238, 66)
  a = Array.set(U32, a, 239, 72)
  a = Array.set(U32, a, 240, 48)
  a = Array.set(U32, a, 241, 79)
  a = Array.set(U32, a, 242, 73)
  a = Array.set(U32, a, 243, 51)
  a = Array.set(U32, a, 244, 88)
  a = Array.set(U32, a, 245, 87)
  a = Array.set(U32, a, 246, 69)
  a = Array.set(U32, a, 247, 52)
  a = Array.set(U32, a, 248, 79)
  a = Array.set(U32, a, 249, 85)
  a = Array.set(U32, a, 250, 65)
  a = Array.set(U32, a, 251, 74)
  a = Array.set(U32, a, 252, 85)
  a = Array.set(U32, a, 253, 65)
  a = Array.set(U32, a, 254, 74)
  a = Array.set(U32, a, 255, 85)
  a = Array.set(U32, a, 256, 71)
  a = Array.set(U32, a, 257, 81)
  a = Array.set(U32, a, 258, 75)
  a = Array.set(U32, a, 259, 85)
  a = Array.set(U32, a, 260, 73)
  a = Array.set(U32, a, 261, 90)
  a = Array.set(U32, a, 262, 69)
  a = Array.set(U32, a, 263, 71)
  a = Array.set(U32, a, 264, 83)
  a = Array.set(U32, a, 265, 70)
  a = Array.set(U32, a, 266, 88)
  a = Array.set(U32, a, 267, 66)
  a = Array.set(U32, a, 268, 80)
  a = Array.set(U32, a, 269, 89)
  a = Array.set(U32, a, 270, 73)
  a = Array.set(U32, a, 271, 75)
  a = Array.set(U32, a, 272, 71)
  a = Array.set(U32, a, 273, 81)
  a = Array.set(U32, a, 274, 72)
  a = Array.set(U32, a, 275, 51)
  a = Array.set(U32, a, 276, 71)
  a = Array.set(U32, a, 277, 77)
  a = Array.set(U32, a, 278, 50)
  a = Array.set(U32, a, 279, 85)
  a = Array.set(U32, a, 280, 65)
  a = Array.set(U32, a, 281, 50)
  a = Array.set(U32, a, 282, 51)
  a = Array.set(U32, a, 283, 85)
  a = Array.set(U32, a, 284, 50)
  a = Array.set(U32, a, 285, 72)
  a = Array.set(U32, a, 286, 74)
  a = Array.set(U32, a, 287, 67)
  a = Array.set(U32, a, 288, 88)
  a = Array.set(U32, a, 289, 84)
  a = Array.set(U32, a, 290, 87)
  a = Array.set(U32, a, 291, 53)
  a = Array.set(U32, a, 292, 78)
  a = Array.set(U32, a, 293, 48)
  a = Array.set(U32, a, 294, 71)
  a = Array.set(U32, a, 295, 53)
  a = Array.set(U32, a, 296, 53)
  a = Array.set(U32, a, 297, 51)
  a = Array.set(U32, a, 298, 65)
  a = Array.set(U32, a, 299, 80)
  a = Array.set(U32, a, 300, 86)
  a = Array.set(U32, a, 301, 73)
  a = Array.set(U32, a, 302, 90)
  a = Array.set(U32, a, 303, 50)
  a = Array.set(U32, a, 304, 89)
  a = Array.set(U32, a, 305, 65)
  a = Array.set(U32, a, 306, 90)
  a = Array.set(U32, a, 307, 52)
  a = Array.set(U32, a, 308, 77)
  a = Array.set(U32, a, 309, 86)
  a = Array.set(U32, a, 310, 83)
  a = Array.set(U32, a, 311, 77)
  a = Array.set(U32, a, 312, 82)
  a = Array.set(U32, a, 313, 81)
  a = Array.set(U32, a, 314, 66)
  a = Array.set(U32, a, 315, 78)
  a = Array.set(U32, a, 316, 88)
  a = Array.set(U32, a, 317, 75)
  a = Array.set(U32, a, 318, 80)
  a = Array.set(U32, a, 319, 79)
  a = Array.set(U32, a, 320, 51)
  a = Array.set(U32, a, 321, 70)
  a = Array.set(U32, a, 322, 79)
  a = Array.set(U32, a, 323, 75)
  a = Array.set(U32, a, 324, 53)
  a = Array.set(U32, a, 325, 85)
  a = Array.set(U32, a, 326, 75)
  a = Array.set(U32, a, 327, 53)
  a = Array.set(U32, a, 328, 82)
  a = Array.set(U32, a, 329, 75)
  a = Array.set(U32, a, 330, 79)
  a = Array.set(U32, a, 331, 71)
  a = Array.set(U32, a, 332, 84)
  a = Array.set(U32, a, 333, 72)
  a = Array.set(U32, a, 334, 67)
  a = Array.set(U32, a, 335, 76)
  a = Array.set(U32, a, 336, 72)
  a = Array.set(U32, a, 337, 50)
  a = Array.set(U32, a, 338, 75)
  a = Array.set(U32, a, 339, 85)
  a = Array.set(U32, a, 340, 82)
  a = Array.set(U32, a, 341, 50)
  a = Array.set(U32, a, 342, 65)
  a = Array.set(U32, a, 343, 68)
  a = Array.set(U32, a, 344, 77)
  a = Array.set(U32, a, 345, 66)
  a = Array.set(U32, a, 346, 81)
  a = Array.set(U32, a, 347, 68)
  a = Array.set(U32, a, 348, 76)
  a = Array.set(U32, a, 349, 65)
  a = Array.set(U32, a, 350, 83)
  a = Array.set(U32, a, 351, 74)
  a = Array.set(U32, a, 352, 70)
  a = Array.set(U32, a, 353, 65)
  a = Array.set(U32, a, 354, 84)
  a = Array.set(U32, a, 355, 70)
  a = Array.set(U32, a, 356, 85)
  a = Array.set(U32, a, 357, 51)
  a = Array.set(U32, a, 358, 69)
  a = Array.set(U32, a, 359, 70)
  a = Array.set(U32, a, 360, 73)
  a = Array.set(U32, a, 361, 83)
  a = Array.set(U32, a, 362, 76)
  a = Array.set(U32, a, 363, 49)
  a = Array.set(U32, a, 364, 90)
  a = Array.set(U32, a, 365, 79)
  a = Array.set(U32, a, 366, 71)
  a = Array.set(U32, a, 367, 65)
  a = Array.set(U32, a, 368, 75)
  a = Array.set(U32, a, 369, 81)
  a = Array.set(U32, a, 370, 85)
  a = Array.set(U32, a, 371, 49)
  a = Array.set(U32, a, 372, 78)
  a = Array.set(U32, a, 373, 86)
  a = Array.set(U32, a, 374, 52)
  a = Array.set(U32, a, 375, 90)
  a = Array.set(U32, a, 376, 87)
  a = Array.set(U32, a, 377, 80)
  a = Array.set(U32, a, 378, 51)
  a = Array.set(U32, a, 379, 67)
  a = Array.set(U32, a, 380, 80)
  a = Array.set(U32, a, 381, 80)
  a = Array.set(U32, a, 382, 76)
  a = Array.set(U32, a, 383, 85)
  a = Array.set(U32, a, 384, 80)
  a = Array.set(U32, a, 385, 52)
  a = Array.set(U32, a, 386, 90)
  a = Array.set(U32, a, 387, 68)
  a = Array.set(U32, a, 388, 50)
  a = Array.set(U32, a, 389, 51)
  a = Array.set(U32, a, 390, 73)
  a = Array.set(U32, a, 391, 69)
  a = Array.set(U32, a, 392, 80)
  a = Array.set(U32, a, 393, 84)
  a = Array.set(U32, a, 394, 53)
  a = Array.set(U32, a, 395, 73)
  a = Array.set(U32, a, 396, 66)
  a = Array.set(U32, a, 397, 70)
  a = Array.set(U32, a, 398, 74)
  a = Array.set(U32, a, 399, 76)
  a = Array.set(U32, a, 400, 87)
  a = Array.set(U32, a, 401, 51)
  a = Array.set(U32, a, 402, 72)
  a = Array.set(U32, a, 403, 68)
  a = Array.set(U32, a, 404, 83)
  a = Array.set(U32, a, 405, 70)
  a = Array.set(U32, a, 406, 50)
  a = Array.set(U32, a, 407, 74)
  a = Array.set(U32, a, 408, 85)
  a = Array.set(U32, a, 409, 90)
  a = Array.set(U32, a, 410, 76)
  a = Array.set(U32, a, 411, 68)
  a = Array.set(U32, a, 412, 73)
  a = Array.set(U32, a, 413, 87)
  a = Array.set(U32, a, 414, 89)
  a = Array.set(U32, a, 415, 88)
  a = Array.set(U32, a, 416, 85)
  a = Array.set(U32, a, 417, 82)
  a = Array.set(U32, a, 418, 48)
  a = Array.set(U32, a, 419, 81)
  a = Array.set(U32, a, 420, 80)
  a = Array.set(U32, a, 421, 67)
  a = Array.set(U32, a, 422, 85)
  a = Array.set(U32, a, 423, 52)
  a = Array.set(U32, a, 424, 87)
  a = Array.set(U32, a, 425, 84)
  a = Array.set(U32, a, 426, 72)
  a = Array.set(U32, a, 427, 88)
  a = Array.set(U32, a, 428, 90)
  a = Array.set(U32, a, 429, 81)
  a = Array.set(U32, a, 430, 68)
  a = Array.set(U32, a, 431, 80)
  a = Array.set(U32, a, 432, 78)
  a = Array.set(U32, a, 433, 75)
  a = Array.set(U32, a, 434, 83)
  a = Array.set(U32, a, 435, 65)
  a = Array.set(U32, a, 436, 80)
  a = Array.set(U32, a, 437, 79)
  a = Array.set(U32, a, 438, 74)
  a = Array.set(U32, a, 439, 69)
  a = Array.set(U32, a, 440, 73)
  a = Array.set(U32, a, 441, 85)
  a = Array.set(U32, a, 442, 72)
  a = Array.set(U32, a, 443, 81)
  a = Array.set(U32, a, 444, 75)
  a = Array.set(U32, a, 445, 53)
  a = Array.set(U32, a, 446, 73)
  a = Array.set(U32, a, 447, 52)
  a = Array.set(U32, a, 448, 82)
  a = Array.set(U32, a, 449, 67)
  a = Array.set(U32, a, 450, 80)
  a = Array.set(U32, a, 451, 65)
  a = Array.set(U32, a, 452, 70)
  a = Array.set(U32, a, 453, 68)
  a = Array.set(U32, a, 454, 52)
  a = Array.set(U32, a, 455, 49)
  a = Array.set(U32, a, 456, 88)
  a = Array.set(U32, a, 457, 70)
  a = Array.set(U32, a, 458, 83)
  a = Array.set(U32, a, 459, 81)
  a = Array.set(U32, a, 460, 86)
  a = Array.set(U32, a, 461, 86)
  a = Array.set(U32, a, 462, 53)
  a = Array.set(U32, a, 463, 68)
  a = Array.set(U32, a, 464, 53)
  a = Array.set(U32, a, 465, 82)
  a = Array.set(U32, a, 466, 68)
  a = Array.set(U32, a, 467, 80)
  a = Array.set(U32, a, 468, 53)
  a = Array.set(U32, a, 469, 77)
  a = Array.set(U32, a, 470, 84)
  a = Array.set(U32, a, 471, 72)
  a = Array.set(U32, a, 472, 65)
  a = Array.set(U32, a, 473, 48)
  a = Array.set(U32, a, 474, 89)
  a = Array.set(U32, a, 475, 75)
  a = Array.set(U32, a, 476, 48)
  a = Array.set(U32, a, 477, 65)
  a = Array.set(U32, a, 478, 73)
  a = Array.set(U32, a, 479, 76)
  a = Array.set(U32, a, 480, 67)
  a = Array.set(U32, a, 481, 88)
  a = Array.set(U32, a, 482, 76)
  a = Array.set(U32, a, 483, 72)
  a = Array.set(U32, a, 484, 49)
  a = Array.set(U32, a, 485, 74)
  a = Array.set(U32, a, 486, 67)
  a = Array.set(U32, a, 487, 83)
  a = Array.set(U32, a, 488, 80)
  a = Array.set(U32, a, 489, 86)
  a = Array.set(U32, a, 490, 67)
  a = Array.set(U32, a, 491, 69)
  a = Array.set(U32, a, 492, 75)
  a = Array.set(U32, a, 493, 66)
  a = Array.set(U32, a, 494, 72)
  a = Array.set(U32, a, 495, 75)
  a = Array.set(U32, a, 496, 83)
  a = Array.set(U32, a, 497, 75)
  a = Array.set(U32, a, 498, 90)
  a = Array.set(U32, a, 499, 82)
  a

def main() -> U32:
  orig = init_orig(Array.new(U32, 9n, 0))
  data = Array.new(U32, 9n, 0)
  freq = Array.new(U32, 8n, 0)
  code = Array.new(U32, 8n, 0)
  clen = Array.new(U32, 8n, 0)
  comp = Array.new(U32, 9n, 0)
  run_rounds(80n, 0, WS{orig, data, freq, code, clen, comp, 2166136261})
