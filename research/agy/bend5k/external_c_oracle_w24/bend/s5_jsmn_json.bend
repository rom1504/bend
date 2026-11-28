import Base
# s5_jsmn_json: Port of zserge/jsmn (jsmn.h) JSON tokenizer
# Parses 448-byte nested JSON document 4000 times, hashing token types, start, end, size.

type JsmnSt is Type:
  JS{buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, pos: U32, toknext: U32, toksuper: U32}

type RoundSt is Type:
  RS{buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, acc: U32}

def inc_super_set(+sup: U32, r: Array<U32> & U32) -> Array<U32>:
  (sz1, +v) = r
  Array.set(U32, sz1, sup, U32.inc(v))

def inc_super_br(has: Bool, +sup: U32, sz: Array<U32>) -> Array<U32>:
  match has:
    case True{}:
      inc_super_set(sup, Array.get(U32, sz, sup))
    case False{}:
      sz

def inc_super(+sup: U32, sz: Array<U32>) -> Array<U32>:
  inc_super_br(U32.is_ne(sup, 4294967295), sup, sz)

# Scan backwards from idx down to 0 for first token with end == -1 (4294967295)
type FindUnclosed is Type:
  FU{en: Array<U32>, found: U32}

type FuReq is Type:
  FUGo{i: U32, en: Array<U32>}
  FUGot{i: U32, r: Array<U32> & U32}
  FUChk{ok: Bool, is_z: Bool, i: U32, en: Array<U32>}

def find_unclosed(+fuel: Nat, req: FuReq) -> FindUnclosed:
  match fuel:
    case 0n:
      match req:
        case FUGo{+i, en}: FU{en, 4294967295}
        case FUGot{+i, r}:
          (en, +v) = r
          FU{en, 4294967295}
        case FUChk{ok, is_z, +i, en}: FU{en, 4294967295}
    case 1n+f:
      match req:
        case FUGo{+i, en}:
          find_unclosed(f, FUGot{i, Array.get(U32, en, i)})
        case FUGot{+i, r}:
          (en1, +ev) = r
          find_unclosed(f, FUChk{U32.is_eq(ev, 4294967295), U32.is_eq(i, 0), i, en1})
        case FUChk{ok, is_z, +i, en}:
          match ok:
            case True{}:
              FU{en, i}
            case False{}:
              match is_z:
                case True{}:
                  FU{en, 4294967295}
                case False{}:
                  find_unclosed(f, FUGo{U32.sub(i, 1), en})

# Scan string starting at pos+1 until unescaped '"' (34)
type StrRes is Type:
  STR{buf: Array<U32>, end_pos: U32}

type StrReq is Type:
  SGo{pos: U32, esc: Bool, buf: Array<U32>}
  SGot{pos: U32, esc: Bool, r: Array<U32> & U32}
  SChk{is_q: Bool, is_bs: Bool, pos: U32, buf: Array<U32>}

def scan_str(+fuel: Nat, req: StrReq) -> StrRes:
  match fuel:
    case 0n:
      match req:
        case SGo{+pos, esc, buf}: STR{buf, pos}
        case SGot{+pos, esc, r}:
          (buf, +v) = r
          STR{buf, pos}
        case SChk{q, bs, +pos, buf}: STR{buf, pos}
    case 1n+f:
      match req:
        case SGo{+pos, esc, buf}:
          scan_str(f, SGot{pos, esc, Array.get(U32, buf, pos)})
        case SGot{+pos, esc, r}:
          match esc:
            case True{}:
              (buf1, +ch) = r
              scan_str(f, SGo{U32.inc(pos), False{}, buf1})
            case False{}:
              (buf1, +ch) = r
              scan_str(f, SChk{U32.is_eq(ch, 34), U32.is_eq(ch, 92), pos, buf1})
        case SChk{is_q, is_bs, +pos, buf}:
          match is_q:
            case True{}:
              STR{buf, pos}
            case False{}:
              scan_str(f, SGo{U32.inc(pos), is_bs, buf})

# Scan primitive starting at pos until delimiter (space, tab, cr, lf, ',', ']', '}') or end
def is_prim_delim(+ch: U32) -> Bool:
  +a = Bool.or(Bool.or(U32.is_eq(ch, 32), U32.is_eq(ch, 9)), Bool.or(U32.is_eq(ch, 10), U32.is_eq(ch, 13)))
  +b = Bool.or(Bool.or(U32.is_eq(ch, 44), U32.is_eq(ch, 93)), U32.is_eq(ch, 125))
  Bool.or(a, b)

type PrimReq is Type:
  PGo{pos: U32, buf: Array<U32>}
  PGot{pos: U32, r: Array<U32> & U32}
  PChk{done: Bool, pos: U32, buf: Array<U32>}

def scan_prim(+fuel: Nat, +len: U32, req: PrimReq) -> StrRes:
  match fuel:
    case 0n:
      match req:
        case PGo{+pos, buf}: STR{buf, pos}
        case PGot{+pos, r}:
          (buf, +v) = r
          STR{buf, pos}
        case PChk{done, +pos, buf}: STR{buf, pos}
    case 1n+f:
      match req:
        case PGo{+pos, buf}:
          scan_prim(f, len, PGot{pos, Array.get(U32, buf, pos)})
        case PGot{+pos, r}:
          (buf1, +ch) = r
          +done = Bool.or(U32.is_ge(pos, len), is_prim_delim(ch))
          scan_prim(f, len, PChk{done, pos, buf1})
        case PChk{done, +pos, buf}:
          match done:
            case True{}:
              STR{buf, pos}
            case False{}:
              scan_prim(f, len, PGo{U32.inc(pos), buf})

def close_fin2(buf: Array<U32>, ty: Array<U32>, st: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, fu2: FindUnclosed) -> JsmnSt:
  FU{en2, +new_sup} = fu2
  JS{buf, ty, st, en2, sz, U32.inc(pos), tn, new_sup}

def close_fin1(buf: Array<U32>, ty: Array<U32>, st: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, fu1: FindUnclosed) -> JsmnSt:
  FU{en1, +idx} = fu1
  en2 = Array.set(U32, en1, idx, U32.inc(pos))
  close_fin2(buf, ty, st, sz, pos, tn, find_unclosed(260n, FUGo{idx, en2}))

def comma_fin(buf: Array<U32>, ty: Array<U32>, st: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, fu: FindUnclosed) -> JsmnSt:
  FU{en1, +new_sup} = fu
  JS{buf, ty, st, en1, sz, U32.inc(pos), tn, new_sup}

def comma_chk(need: Bool, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match need:
    case True{}:
      comma_fin(buf, ty, st, sz, pos, tn, find_unclosed(260n, FUGo{U32.sub(tn, 1), en}))
    case False{}:
      JS{buf, ty, st, en, sz, U32.inc(pos), tn, sup}

def comma_ty(buf: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32, r: Array<U32> & U32) -> JsmnSt:
  (ty1, +t) = r
  +is_cont = Bool.or(U32.is_eq(t, 1), U32.is_eq(t, 2))
  comma_chk(Bool.not(is_cont), buf, ty1, st, en, sz, pos, tn, sup)

def handle_comma(has_sup: Bool, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match has_sup:
    case True{}:
      comma_ty(buf, st, en, sz, pos, tn, sup, Array.get(U32, ty, sup))
    case False{}:
      JS{buf, ty, st, en, sz, U32.inc(pos), tn, sup}

def str_done(ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +start: U32, +tn: U32, +sup: U32, sr: StrRes) -> JsmnSt:
  STR{buf1, +ep} = sr
  ty1 = Array.set(U32, ty, tn, 4)
  st1 = Array.set(U32, st, tn, U32.inc(start))
  en1 = Array.set(U32, en, tn, ep)
  sz1 = inc_super(sup, Array.set(U32, sz, tn, 0))
  JS{buf1, ty1, st1, en1, sz1, U32.inc(ep), U32.inc(tn), sup}

def prim_done(ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +start: U32, +tn: U32, +sup: U32, sr: StrRes) -> JsmnSt:
  STR{buf1, +ep} = sr
  ty1 = Array.set(U32, ty, tn, 8)
  st1 = Array.set(U32, st, tn, start)
  en1 = Array.set(U32, en, tn, ep)
  sz1 = inc_super(sup, Array.set(U32, sz, tn, 0))
  JS{buf1, ty1, st1, en1, sz1, ep, U32.inc(tn), sup}

def dispatch_ws(is_ws: Bool, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match is_ws:
    case True{}:
      JS{buf, ty, st, en, sz, U32.inc(pos), tn, sup}
    case False{}:
      prim_done(ty, st, en, sz, pos, tn, sup, scan_prim(100n, 448, PGo{pos, buf}))

def dispatch_comma(is_cm: Bool, +ch: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match is_cm:
    case True{}:
      handle_comma(U32.is_ne(sup, 4294967295), buf, ty, st, en, sz, pos, tn, sup)
    case False{}:
      +ws = Bool.or(Bool.or(U32.is_eq(ch, 32), U32.is_eq(ch, 9)), Bool.or(U32.is_eq(ch, 10), U32.is_eq(ch, 13)))
      dispatch_ws(ws, buf, ty, st, en, sz, pos, tn, sup)

def dispatch_colon(is_col: Bool, +ch: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match is_col:
    case True{}:
      JS{buf, ty, st, en, sz, U32.inc(pos), tn, U32.sub(tn, 1)}
    case False{}:
      dispatch_comma(U32.is_eq(ch, 44), ch, buf, ty, st, en, sz, pos, tn, sup)

def dispatch_str(is_q: Bool, +ch: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match is_q:
    case True{}:
      str_done(ty, st, en, sz, pos, tn, sup, scan_str(120n, SGo{U32.inc(pos), False{}, buf}))
    case False{}:
      dispatch_colon(U32.is_eq(ch, 58), ch, buf, ty, st, en, sz, pos, tn, sup)

def dispatch_close(is_cl: Bool, +ch: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match is_cl:
    case True{}:
      close_fin1(buf, ty, st, sz, pos, tn, find_unclosed(260n, FUGo{U32.sub(tn, 1), en}))
    case False{}:
      dispatch_str(U32.is_eq(ch, 34), ch, buf, ty, st, en, sz, pos, tn, sup)

def dispatch_open(is_op: Bool, +ch: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32) -> JsmnSt:
  match is_op:
    case True{}:
      +t = Bool.pick(U32, U32.is_eq(ch, 123), 1, 2)
      ty1 = Array.set(U32, ty, tn, t)
      st1 = Array.set(U32, st, tn, pos)
      en1 = Array.set(U32, en, tn, 4294967295)
      sz1 = inc_super(sup, Array.set(U32, sz, tn, 0))
      JS{buf, ty1, st1, en1, sz1, U32.inc(pos), U32.inc(tn), tn}
    case False{}:
      +cl = Bool.or(U32.is_eq(ch, 125), U32.is_eq(ch, 93))
      dispatch_close(cl, ch, buf, ty, st, en, sz, pos, tn, sup)

def parse_step(ty: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, +pos: U32, +tn: U32, +sup: U32, r: Array<U32> & U32) -> JsmnSt:
  (buf1, +ch) = r
  +op = Bool.or(U32.is_eq(ch, 123), U32.is_eq(ch, 91))
  dispatch_open(op, ch, buf1, ty, st, en, sz, pos, tn, sup)

def parse_chk(in_b: Bool, js: JsmnSt) -> JsmnSt:
  match in_b:
    case True{}:
      JS{buf, ty, st, en, sz, +pos, +tn, +sup} = js
      parse_step(ty, st, en, sz, pos, tn, sup, Array.get(U32, buf, pos))
    case False{}:
      js

def parse_loop(+rem: Nat, js: JsmnSt) -> JsmnSt:
  match rem:
    case 0n:
      js
    case 1n+p:
      JS{buf, ty, st, en, sz, +pos, +tn, +sup} = js
      parse_loop(p, parse_chk(U32.is_lt(pos, 448), JS{buf, ty, st, en, sz, pos, tn, sup}))

def hash_tok4(+acc: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, en: Array<U32>, r: Array<U32> & U32) -> RoundSt:
  (sz1, +v) = r
  RS{buf, ty, st, en, sz1, U32.mul(U32.xor(acc, v), 16777619)}

def hash_tok3(+i: U32, +acc: U32, buf: Array<U32>, ty: Array<U32>, st: Array<U32>, sz: Array<U32>, r: Array<U32> & U32) -> RoundSt:
  (en1, +v) = r
  hash_tok4(U32.mul(U32.xor(acc, v), 16777619), buf, ty, st, en1, Array.get(U32, sz, i))

def hash_tok2(+i: U32, +acc: U32, buf: Array<U32>, ty: Array<U32>, en: Array<U32>, sz: Array<U32>, r: Array<U32> & U32) -> RoundSt:
  (st1, +v) = r
  hash_tok3(i, U32.mul(U32.xor(acc, v), 16777619), buf, ty, st1, sz, Array.get(U32, en, i))

def hash_tok1(+i: U32, +acc: U32, buf: Array<U32>, st: Array<U32>, en: Array<U32>, sz: Array<U32>, r: Array<U32> & U32) -> RoundSt:
  (ty1, +v) = r
  hash_tok2(i, U32.mul(U32.xor(acc, v), 16777619), buf, ty1, en, sz, Array.get(U32, st, i))

def hash_toks(+rem: Nat, +i: U32, rs: RoundSt) -> RoundSt:
  match rem:
    case 0n:
      rs
    case 1n+p:
      RS{buf, ty, st, en, sz, +acc} = rs
      hash_toks(p, U32.inc(i), hash_tok1(i, acc, buf, st, en, sz, Array.get(U32, ty, i)))

def finish_parse(+acc: U32, js: JsmnSt) -> RoundSt:
  JS{buf, ty, st, en, sz, +pos, +tn, +sup} = js
  +acc1 = U32.mul(U32.xor(acc, tn), 16777619)
  hash_toks(U32.to_nat(tn), 0, RS{buf, ty, st, en, sz, acc1})

def run_rounds(+rem: Nat, +r: U32, rs: RoundSt) -> U32:
  match rem:
    case 0n:
      RS{buf, ty, st, en, sz, +acc} = rs
      acc
    case 1n+p:
      RS{buf, ty, st, en, sz, +acc} = rs
      buf1 = Array.set(U32, buf, 38, U32.add(48, U32.mod(r, 10)))
      rs1 = finish_parse(acc, parse_loop(448n, JS{buf1, ty, st, en, sz, 0, 0, 4294967295}))
      run_rounds(p, U32.inc(r), rs1)

def init_json(buf: Array<U32>) -> Array<U32>:
  buf = Array.set(U32, buf, 0, 123)
  buf = Array.set(U32, buf, 1, 34)
  buf = Array.set(U32, buf, 2, 115)
  buf = Array.set(U32, buf, 3, 101)
  buf = Array.set(U32, buf, 4, 114)
  buf = Array.set(U32, buf, 5, 118)
  buf = Array.set(U32, buf, 6, 105)
  buf = Array.set(U32, buf, 7, 99)
  buf = Array.set(U32, buf, 8, 101)
  buf = Array.set(U32, buf, 9, 34)
  buf = Array.set(U32, buf, 10, 58)
  buf = Array.set(U32, buf, 11, 34)
  buf = Array.set(U32, buf, 12, 98)
  buf = Array.set(U32, buf, 13, 101)
  buf = Array.set(U32, buf, 14, 110)
  buf = Array.set(U32, buf, 15, 100)
  buf = Array.set(U32, buf, 16, 53)
  buf = Array.set(U32, buf, 17, 107)
  buf = Array.set(U32, buf, 18, 45)
  buf = Array.set(U32, buf, 19, 111)
  buf = Array.set(U32, buf, 20, 114)
  buf = Array.set(U32, buf, 21, 97)
  buf = Array.set(U32, buf, 22, 99)
  buf = Array.set(U32, buf, 23, 108)
  buf = Array.set(U32, buf, 24, 101)
  buf = Array.set(U32, buf, 25, 34)
  buf = Array.set(U32, buf, 26, 44)
  buf = Array.set(U32, buf, 27, 34)
  buf = Array.set(U32, buf, 28, 118)
  buf = Array.set(U32, buf, 29, 101)
  buf = Array.set(U32, buf, 30, 114)
  buf = Array.set(U32, buf, 31, 115)
  buf = Array.set(U32, buf, 32, 105)
  buf = Array.set(U32, buf, 33, 111)
  buf = Array.set(U32, buf, 34, 110)
  buf = Array.set(U32, buf, 35, 34)
  buf = Array.set(U32, buf, 36, 58)
  buf = Array.set(U32, buf, 37, 50)
  buf = Array.set(U32, buf, 38, 52)
  buf = Array.set(U32, buf, 39, 44)
  buf = Array.set(U32, buf, 40, 34)
  buf = Array.set(U32, buf, 41, 97)
  buf = Array.set(U32, buf, 42, 99)
  buf = Array.set(U32, buf, 43, 116)
  buf = Array.set(U32, buf, 44, 105)
  buf = Array.set(U32, buf, 45, 118)
  buf = Array.set(U32, buf, 46, 101)
  buf = Array.set(U32, buf, 47, 34)
  buf = Array.set(U32, buf, 48, 58)
  buf = Array.set(U32, buf, 49, 116)
  buf = Array.set(U32, buf, 50, 114)
  buf = Array.set(U32, buf, 51, 117)
  buf = Array.set(U32, buf, 52, 101)
  buf = Array.set(U32, buf, 53, 44)
  buf = Array.set(U32, buf, 54, 34)
  buf = Array.set(U32, buf, 55, 114)
  buf = Array.set(U32, buf, 56, 97)
  buf = Array.set(U32, buf, 57, 116)
  buf = Array.set(U32, buf, 58, 105)
  buf = Array.set(U32, buf, 59, 111)
  buf = Array.set(U32, buf, 60, 34)
  buf = Array.set(U32, buf, 61, 58)
  buf = Array.set(U32, buf, 62, 110)
  buf = Array.set(U32, buf, 63, 117)
  buf = Array.set(U32, buf, 64, 108)
  buf = Array.set(U32, buf, 65, 108)
  buf = Array.set(U32, buf, 66, 44)
  buf = Array.set(U32, buf, 67, 34)
  buf = Array.set(U32, buf, 68, 109)
  buf = Array.set(U32, buf, 69, 101)
  buf = Array.set(U32, buf, 70, 116)
  buf = Array.set(U32, buf, 71, 114)
  buf = Array.set(U32, buf, 72, 105)
  buf = Array.set(U32, buf, 73, 99)
  buf = Array.set(U32, buf, 74, 115)
  buf = Array.set(U32, buf, 75, 34)
  buf = Array.set(U32, buf, 76, 58)
  buf = Array.set(U32, buf, 77, 91)
  buf = Array.set(U32, buf, 78, 49)
  buf = Array.set(U32, buf, 79, 48)
  buf = Array.set(U32, buf, 80, 44)
  buf = Array.set(U32, buf, 81, 50)
  buf = Array.set(U32, buf, 82, 48)
  buf = Array.set(U32, buf, 83, 44)
  buf = Array.set(U32, buf, 84, 51)
  buf = Array.set(U32, buf, 85, 48)
  buf = Array.set(U32, buf, 86, 44)
  buf = Array.set(U32, buf, 87, 52)
  buf = Array.set(U32, buf, 88, 48)
  buf = Array.set(U32, buf, 89, 44)
  buf = Array.set(U32, buf, 90, 53)
  buf = Array.set(U32, buf, 91, 48)
  buf = Array.set(U32, buf, 92, 44)
  buf = Array.set(U32, buf, 93, 54)
  buf = Array.set(U32, buf, 94, 48)
  buf = Array.set(U32, buf, 95, 44)
  buf = Array.set(U32, buf, 96, 55)
  buf = Array.set(U32, buf, 97, 48)
  buf = Array.set(U32, buf, 98, 44)
  buf = Array.set(U32, buf, 99, 56)
  buf = Array.set(U32, buf, 100, 48)
  buf = Array.set(U32, buf, 101, 44)
  buf = Array.set(U32, buf, 102, 57)
  buf = Array.set(U32, buf, 103, 48)
  buf = Array.set(U32, buf, 104, 44)
  buf = Array.set(U32, buf, 105, 49)
  buf = Array.set(U32, buf, 106, 48)
  buf = Array.set(U32, buf, 107, 48)
  buf = Array.set(U32, buf, 108, 93)
  buf = Array.set(U32, buf, 109, 44)
  buf = Array.set(U32, buf, 110, 34)
  buf = Array.set(U32, buf, 111, 105)
  buf = Array.set(U32, buf, 112, 116)
  buf = Array.set(U32, buf, 113, 101)
  buf = Array.set(U32, buf, 114, 109)
  buf = Array.set(U32, buf, 115, 115)
  buf = Array.set(U32, buf, 116, 34)
  buf = Array.set(U32, buf, 117, 58)
  buf = Array.set(U32, buf, 118, 91)
  buf = Array.set(U32, buf, 119, 123)
  buf = Array.set(U32, buf, 120, 34)
  buf = Array.set(U32, buf, 121, 105)
  buf = Array.set(U32, buf, 122, 100)
  buf = Array.set(U32, buf, 123, 34)
  buf = Array.set(U32, buf, 124, 58)
  buf = Array.set(U32, buf, 125, 49)
  buf = Array.set(U32, buf, 126, 44)
  buf = Array.set(U32, buf, 127, 34)
  buf = Array.set(U32, buf, 128, 110)
  buf = Array.set(U32, buf, 129, 97)
  buf = Array.set(U32, buf, 130, 109)
  buf = Array.set(U32, buf, 131, 101)
  buf = Array.set(U32, buf, 132, 34)
  buf = Array.set(U32, buf, 133, 58)
  buf = Array.set(U32, buf, 134, 34)
  buf = Array.set(U32, buf, 135, 99)
  buf = Array.set(U32, buf, 136, 114)
  buf = Array.set(U32, buf, 137, 99)
  buf = Array.set(U32, buf, 138, 51)
  buf = Array.set(U32, buf, 139, 50)
  buf = Array.set(U32, buf, 140, 34)
  buf = Array.set(U32, buf, 141, 44)
  buf = Array.set(U32, buf, 142, 34)
  buf = Array.set(U32, buf, 143, 116)
  buf = Array.set(U32, buf, 144, 97)
  buf = Array.set(U32, buf, 145, 103)
  buf = Array.set(U32, buf, 146, 115)
  buf = Array.set(U32, buf, 147, 34)
  buf = Array.set(U32, buf, 148, 58)
  buf = Array.set(U32, buf, 149, 91)
  buf = Array.set(U32, buf, 150, 34)
  buf = Array.set(U32, buf, 151, 98)
  buf = Array.set(U32, buf, 152, 105)
  buf = Array.set(U32, buf, 153, 116)
  buf = Array.set(U32, buf, 154, 34)
  buf = Array.set(U32, buf, 155, 44)
  buf = Array.set(U32, buf, 156, 34)
  buf = Array.set(U32, buf, 157, 99)
  buf = Array.set(U32, buf, 158, 114)
  buf = Array.set(U32, buf, 159, 121)
  buf = Array.set(U32, buf, 160, 112)
  buf = Array.set(U32, buf, 161, 116)
  buf = Array.set(U32, buf, 162, 111)
  buf = Array.set(U32, buf, 163, 34)
  buf = Array.set(U32, buf, 164, 44)
  buf = Array.set(U32, buf, 165, 34)
  buf = Array.set(U32, buf, 166, 101)
  buf = Array.set(U32, buf, 167, 109)
  buf = Array.set(U32, buf, 168, 98)
  buf = Array.set(U32, buf, 169, 101)
  buf = Array.set(U32, buf, 170, 110)
  buf = Array.set(U32, buf, 171, 99)
  buf = Array.set(U32, buf, 172, 104)
  buf = Array.set(U32, buf, 173, 34)
  buf = Array.set(U32, buf, 174, 93)
  buf = Array.set(U32, buf, 175, 44)
  buf = Array.set(U32, buf, 176, 34)
  buf = Array.set(U32, buf, 177, 111)
  buf = Array.set(U32, buf, 178, 107)
  buf = Array.set(U32, buf, 179, 34)
  buf = Array.set(U32, buf, 180, 58)
  buf = Array.set(U32, buf, 181, 116)
  buf = Array.set(U32, buf, 182, 114)
  buf = Array.set(U32, buf, 183, 117)
  buf = Array.set(U32, buf, 184, 101)
  buf = Array.set(U32, buf, 185, 125)
  buf = Array.set(U32, buf, 186, 44)
  buf = Array.set(U32, buf, 187, 123)
  buf = Array.set(U32, buf, 188, 34)
  buf = Array.set(U32, buf, 189, 105)
  buf = Array.set(U32, buf, 190, 100)
  buf = Array.set(U32, buf, 191, 34)
  buf = Array.set(U32, buf, 192, 58)
  buf = Array.set(U32, buf, 193, 50)
  buf = Array.set(U32, buf, 194, 44)
  buf = Array.set(U32, buf, 195, 34)
  buf = Array.set(U32, buf, 196, 110)
  buf = Array.set(U32, buf, 197, 97)
  buf = Array.set(U32, buf, 198, 109)
  buf = Array.set(U32, buf, 199, 101)
  buf = Array.set(U32, buf, 200, 34)
  buf = Array.set(U32, buf, 201, 58)
  buf = Array.set(U32, buf, 202, 34)
  buf = Array.set(U32, buf, 203, 103)
  buf = Array.set(U32, buf, 204, 101)
  buf = Array.set(U32, buf, 205, 109)
  buf = Array.set(U32, buf, 206, 109)
  buf = Array.set(U32, buf, 207, 34)
  buf = Array.set(U32, buf, 208, 44)
  buf = Array.set(U32, buf, 209, 34)
  buf = Array.set(U32, buf, 210, 116)
  buf = Array.set(U32, buf, 211, 97)
  buf = Array.set(U32, buf, 212, 103)
  buf = Array.set(U32, buf, 213, 115)
  buf = Array.set(U32, buf, 214, 34)
  buf = Array.set(U32, buf, 215, 58)
  buf = Array.set(U32, buf, 216, 91)
  buf = Array.set(U32, buf, 217, 34)
  buf = Array.set(U32, buf, 218, 102)
  buf = Array.set(U32, buf, 219, 51)
  buf = Array.set(U32, buf, 220, 50)
  buf = Array.set(U32, buf, 221, 34)
  buf = Array.set(U32, buf, 222, 44)
  buf = Array.set(U32, buf, 223, 34)
  buf = Array.set(U32, buf, 224, 98)
  buf = Array.set(U32, buf, 225, 108)
  buf = Array.set(U32, buf, 226, 97)
  buf = Array.set(U32, buf, 227, 115)
  buf = Array.set(U32, buf, 228, 34)
  buf = Array.set(U32, buf, 229, 44)
  buf = Array.set(U32, buf, 230, 34)
  buf = Array.set(U32, buf, 231, 112)
  buf = Array.set(U32, buf, 232, 111)
  buf = Array.set(U32, buf, 233, 108)
  buf = Array.set(U32, buf, 234, 121)
  buf = Array.set(U32, buf, 235, 98)
  buf = Array.set(U32, buf, 236, 101)
  buf = Array.set(U32, buf, 237, 110)
  buf = Array.set(U32, buf, 238, 99)
  buf = Array.set(U32, buf, 239, 104)
  buf = Array.set(U32, buf, 240, 34)
  buf = Array.set(U32, buf, 241, 93)
  buf = Array.set(U32, buf, 242, 44)
  buf = Array.set(U32, buf, 243, 34)
  buf = Array.set(U32, buf, 244, 111)
  buf = Array.set(U32, buf, 245, 107)
  buf = Array.set(U32, buf, 246, 34)
  buf = Array.set(U32, buf, 247, 58)
  buf = Array.set(U32, buf, 248, 116)
  buf = Array.set(U32, buf, 249, 114)
  buf = Array.set(U32, buf, 250, 117)
  buf = Array.set(U32, buf, 251, 101)
  buf = Array.set(U32, buf, 252, 125)
  buf = Array.set(U32, buf, 253, 44)
  buf = Array.set(U32, buf, 254, 123)
  buf = Array.set(U32, buf, 255, 34)
  buf = Array.set(U32, buf, 256, 105)
  buf = Array.set(U32, buf, 257, 100)
  buf = Array.set(U32, buf, 258, 34)
  buf = Array.set(U32, buf, 259, 58)
  buf = Array.set(U32, buf, 260, 51)
  buf = Array.set(U32, buf, 261, 44)
  buf = Array.set(U32, buf, 262, 34)
  buf = Array.set(U32, buf, 263, 110)
  buf = Array.set(U32, buf, 264, 97)
  buf = Array.set(U32, buf, 265, 109)
  buf = Array.set(U32, buf, 266, 101)
  buf = Array.set(U32, buf, 267, 34)
  buf = Array.set(U32, buf, 268, 58)
  buf = Array.set(U32, buf, 269, 34)
  buf = Array.set(U32, buf, 270, 106)
  buf = Array.set(U32, buf, 271, 115)
  buf = Array.set(U32, buf, 272, 109)
  buf = Array.set(U32, buf, 273, 110)
  buf = Array.set(U32, buf, 274, 34)
  buf = Array.set(U32, buf, 275, 44)
  buf = Array.set(U32, buf, 276, 34)
  buf = Array.set(U32, buf, 277, 116)
  buf = Array.set(U32, buf, 278, 97)
  buf = Array.set(U32, buf, 279, 103)
  buf = Array.set(U32, buf, 280, 115)
  buf = Array.set(U32, buf, 281, 34)
  buf = Array.set(U32, buf, 282, 58)
  buf = Array.set(U32, buf, 283, 91)
  buf = Array.set(U32, buf, 284, 34)
  buf = Array.set(U32, buf, 285, 106)
  buf = Array.set(U32, buf, 286, 115)
  buf = Array.set(U32, buf, 287, 111)
  buf = Array.set(U32, buf, 288, 110)
  buf = Array.set(U32, buf, 289, 34)
  buf = Array.set(U32, buf, 290, 44)
  buf = Array.set(U32, buf, 291, 34)
  buf = Array.set(U32, buf, 292, 112)
  buf = Array.set(U32, buf, 293, 97)
  buf = Array.set(U32, buf, 294, 114)
  buf = Array.set(U32, buf, 295, 115)
  buf = Array.set(U32, buf, 296, 101)
  buf = Array.set(U32, buf, 297, 114)
  buf = Array.set(U32, buf, 298, 34)
  buf = Array.set(U32, buf, 299, 44)
  buf = Array.set(U32, buf, 300, 34)
  buf = Array.set(U32, buf, 301, 99)
  buf = Array.set(U32, buf, 302, 34)
  buf = Array.set(U32, buf, 303, 93)
  buf = Array.set(U32, buf, 304, 44)
  buf = Array.set(U32, buf, 305, 34)
  buf = Array.set(U32, buf, 306, 111)
  buf = Array.set(U32, buf, 307, 107)
  buf = Array.set(U32, buf, 308, 34)
  buf = Array.set(U32, buf, 309, 58)
  buf = Array.set(U32, buf, 310, 102)
  buf = Array.set(U32, buf, 311, 97)
  buf = Array.set(U32, buf, 312, 108)
  buf = Array.set(U32, buf, 313, 115)
  buf = Array.set(U32, buf, 314, 101)
  buf = Array.set(U32, buf, 315, 125)
  buf = Array.set(U32, buf, 316, 44)
  buf = Array.set(U32, buf, 317, 123)
  buf = Array.set(U32, buf, 318, 34)
  buf = Array.set(U32, buf, 319, 105)
  buf = Array.set(U32, buf, 320, 100)
  buf = Array.set(U32, buf, 321, 34)
  buf = Array.set(U32, buf, 322, 58)
  buf = Array.set(U32, buf, 323, 52)
  buf = Array.set(U32, buf, 324, 44)
  buf = Array.set(U32, buf, 325, 34)
  buf = Array.set(U32, buf, 326, 110)
  buf = Array.set(U32, buf, 327, 97)
  buf = Array.set(U32, buf, 328, 109)
  buf = Array.set(U32, buf, 329, 101)
  buf = Array.set(U32, buf, 330, 34)
  buf = Array.set(U32, buf, 331, 58)
  buf = Array.set(U32, buf, 332, 34)
  buf = Array.set(U32, buf, 333, 104)
  buf = Array.set(U32, buf, 334, 117)
  buf = Array.set(U32, buf, 335, 102)
  buf = Array.set(U32, buf, 336, 102)
  buf = Array.set(U32, buf, 337, 34)
  buf = Array.set(U32, buf, 338, 44)
  buf = Array.set(U32, buf, 339, 34)
  buf = Array.set(U32, buf, 340, 116)
  buf = Array.set(U32, buf, 341, 97)
  buf = Array.set(U32, buf, 342, 103)
  buf = Array.set(U32, buf, 343, 115)
  buf = Array.set(U32, buf, 344, 34)
  buf = Array.set(U32, buf, 345, 58)
  buf = Array.set(U32, buf, 346, 91)
  buf = Array.set(U32, buf, 347, 34)
  buf = Array.set(U32, buf, 348, 99)
  buf = Array.set(U32, buf, 349, 111)
  buf = Array.set(U32, buf, 350, 100)
  buf = Array.set(U32, buf, 351, 101)
  buf = Array.set(U32, buf, 352, 99)
  buf = Array.set(U32, buf, 353, 34)
  buf = Array.set(U32, buf, 354, 44)
  buf = Array.set(U32, buf, 355, 34)
  buf = Array.set(U32, buf, 356, 116)
  buf = Array.set(U32, buf, 357, 114)
  buf = Array.set(U32, buf, 358, 101)
  buf = Array.set(U32, buf, 359, 101)
  buf = Array.set(U32, buf, 360, 34)
  buf = Array.set(U32, buf, 361, 44)
  buf = Array.set(U32, buf, 362, 34)
  buf = Array.set(U32, buf, 363, 98)
  buf = Array.set(U32, buf, 364, 105)
  buf = Array.set(U32, buf, 365, 116)
  buf = Array.set(U32, buf, 366, 115)
  buf = Array.set(U32, buf, 367, 34)
  buf = Array.set(U32, buf, 368, 93)
  buf = Array.set(U32, buf, 369, 44)
  buf = Array.set(U32, buf, 370, 34)
  buf = Array.set(U32, buf, 371, 111)
  buf = Array.set(U32, buf, 372, 107)
  buf = Array.set(U32, buf, 373, 34)
  buf = Array.set(U32, buf, 374, 58)
  buf = Array.set(U32, buf, 375, 116)
  buf = Array.set(U32, buf, 376, 114)
  buf = Array.set(U32, buf, 377, 117)
  buf = Array.set(U32, buf, 378, 101)
  buf = Array.set(U32, buf, 379, 125)
  buf = Array.set(U32, buf, 380, 93)
  buf = Array.set(U32, buf, 381, 44)
  buf = Array.set(U32, buf, 382, 34)
  buf = Array.set(U32, buf, 383, 110)
  buf = Array.set(U32, buf, 384, 101)
  buf = Array.set(U32, buf, 385, 115)
  buf = Array.set(U32, buf, 386, 116)
  buf = Array.set(U32, buf, 387, 101)
  buf = Array.set(U32, buf, 388, 100)
  buf = Array.set(U32, buf, 389, 34)
  buf = Array.set(U32, buf, 390, 58)
  buf = Array.set(U32, buf, 391, 123)
  buf = Array.set(U32, buf, 392, 34)
  buf = Array.set(U32, buf, 393, 97)
  buf = Array.set(U32, buf, 394, 34)
  buf = Array.set(U32, buf, 395, 58)
  buf = Array.set(U32, buf, 396, 123)
  buf = Array.set(U32, buf, 397, 34)
  buf = Array.set(U32, buf, 398, 98)
  buf = Array.set(U32, buf, 399, 34)
  buf = Array.set(U32, buf, 400, 58)
  buf = Array.set(U32, buf, 401, 123)
  buf = Array.set(U32, buf, 402, 34)
  buf = Array.set(U32, buf, 403, 99)
  buf = Array.set(U32, buf, 404, 34)
  buf = Array.set(U32, buf, 405, 58)
  buf = Array.set(U32, buf, 406, 91)
  buf = Array.set(U32, buf, 407, 49)
  buf = Array.set(U32, buf, 408, 44)
  buf = Array.set(U32, buf, 409, 50)
  buf = Array.set(U32, buf, 410, 44)
  buf = Array.set(U32, buf, 411, 51)
  buf = Array.set(U32, buf, 412, 44)
  buf = Array.set(U32, buf, 413, 34)
  buf = Array.set(U32, buf, 414, 104)
  buf = Array.set(U32, buf, 415, 101)
  buf = Array.set(U32, buf, 416, 108)
  buf = Array.set(U32, buf, 417, 108)
  buf = Array.set(U32, buf, 418, 111)
  buf = Array.set(U32, buf, 419, 92)
  buf = Array.set(U32, buf, 420, 110)
  buf = Array.set(U32, buf, 421, 119)
  buf = Array.set(U32, buf, 422, 111)
  buf = Array.set(U32, buf, 423, 114)
  buf = Array.set(U32, buf, 424, 108)
  buf = Array.set(U32, buf, 425, 100)
  buf = Array.set(U32, buf, 426, 34)
  buf = Array.set(U32, buf, 427, 44)
  buf = Array.set(U32, buf, 428, 116)
  buf = Array.set(U32, buf, 429, 114)
  buf = Array.set(U32, buf, 430, 117)
  buf = Array.set(U32, buf, 431, 101)
  buf = Array.set(U32, buf, 432, 44)
  buf = Array.set(U32, buf, 433, 102)
  buf = Array.set(U32, buf, 434, 97)
  buf = Array.set(U32, buf, 435, 108)
  buf = Array.set(U32, buf, 436, 115)
  buf = Array.set(U32, buf, 437, 101)
  buf = Array.set(U32, buf, 438, 44)
  buf = Array.set(U32, buf, 439, 110)
  buf = Array.set(U32, buf, 440, 117)
  buf = Array.set(U32, buf, 441, 108)
  buf = Array.set(U32, buf, 442, 108)
  buf = Array.set(U32, buf, 443, 93)
  buf = Array.set(U32, buf, 444, 125)
  buf = Array.set(U32, buf, 445, 125)
  buf = Array.set(U32, buf, 446, 125)
  buf = Array.set(U32, buf, 447, 125)
  buf

def main() -> U32:
  buf = init_json(Array.new(U32, 9n, 0))
  ty = Array.new(U32, 7n, 0)
  st = Array.new(U32, 7n, 0)
  en = Array.new(U32, 7n, 0)
  sz = Array.new(U32, 7n, 0)
  run_rounds(4000n, 0, RS{buf, ty, st, en, sz, 2166136261})
