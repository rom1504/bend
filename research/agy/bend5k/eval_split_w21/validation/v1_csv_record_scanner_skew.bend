import Base
# v1_csv_record_scanner (skew): RFC-4180 CSV quoted-field structural parser over Array<U32>
# Validation family 1: N = 32768 heavy-quote/escape CSV bytes, 220 rounds.

type CsvSt is Data:
  SStart{}
  SUnq{}
  SQuote{}
  SQEnd{}
  SCr{}

type ScanAcc is Type:
  SAcc{buf: Array<U32>, st: CsvSt, fhash: U32, h: U32, fields: U32, rows: U32, qfields: U32, escapes: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def gen_byte_sel4(c: Bool, +r: U32) -> U32:
  match c:
    case True{}:
      13
    case False{}:
      U32.add(48, U32.and(U32.shrn(r, 6n), 31))

def gen_byte_sel3(c: Bool, +m: U32, +r: U32) -> U32:
  match c:
    case True{}:
      10
    case False{}:
      gen_byte_sel4(U32.is_lt(m, 28), r)

def gen_byte_sel2(c: Bool, +m: U32, +r: U32) -> U32:
  match c:
    case True{}:
      44
    case False{}:
      gen_byte_sel3(U32.is_lt(m, 25), m, r)

def gen_byte_sel1(c: Bool, +m: U32, +r: U32) -> U32:
  match c:
    case True{}:
      34
    case False{}:
      gen_byte_sel2(U32.is_lt(m, 22), m, r)

def gen_byte(+i: U32) -> U32:
  +r = prng(U32.add(U32.mul(U32.inc(i), 2654435761), 73))
  +m = U32.and(r, 63)
  gen_byte_sel1(U32.is_lt(m, 14), m, r)

def fill_bytes(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      fill_bytes(p, U32.inc(i), Array.swap(U32, a, i, gen_byte(i)))

def step_start_cr(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SCr{}, fhash, h, fields, rows, qfields, escapes}
    case False{}:
      SAcc{buf, SUnq{}, U32.xor(U32.mul(fhash, 16777619), b), h, fields, rows, qfields, escapes}

def step_start_nl(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      +nr = U32.inc(rows)
      SAcc{buf, SStart{}, 2166136261, U32.xor(U32.xor(U32.mul(h, 2654435761), fhash), nr), U32.inc(fields), nr, qfields, escapes}
    case False{}:
      step_start_cr(U32.is_eq(b, 13), b, fhash, h, fields, rows, qfields, escapes, buf)

def step_start_comma(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SStart{}, 2166136261, U32.xor(U32.mul(h, 2654435761), fhash), U32.inc(fields), rows, qfields, escapes}
    case False{}:
      step_start_nl(U32.is_eq(b, 10), b, fhash, h, fields, rows, qfields, escapes, buf)

def step_start_q(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SQuote{}, fhash, h, fields, rows, U32.inc(qfields), escapes}
    case False{}:
      step_start_comma(U32.is_eq(b, 44), b, fhash, h, fields, rows, qfields, escapes, buf)

def step_qend_q(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SQuote{}, U32.xor(U32.mul(fhash, 16777619), 34), h, fields, rows, qfields, U32.inc(escapes)}
    case False{}:
      step_start_comma(U32.is_eq(b, 44), b, fhash, h, fields, rows, qfields, escapes, buf)

def step_quote_q(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SQEnd{}, fhash, h, fields, rows, qfields, escapes}
    case False{}:
      SAcc{buf, SQuote{}, U32.xor(U32.mul(fhash, 16777619), b), h, fields, rows, qfields, escapes}

def step_cr_comma(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SStart{}, 2166136261, U32.xor(U32.mul(h, 2654435761), fhash), U32.add(fields, 2), U32.inc(rows), qfields, escapes}
    case False{}:
      SAcc{buf, SUnq{}, U32.xor(U32.mul(2166136261, 16777619), b), U32.xor(U32.mul(h, 2654435761), fhash), U32.inc(fields), U32.inc(rows), qfields, escapes}

def step_cr_q(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      SAcc{buf, SQuote{}, 2166136261, U32.xor(U32.mul(h, 2654435761), fhash), U32.inc(fields), U32.inc(rows), U32.inc(qfields), escapes}
    case False{}:
      step_cr_comma(U32.is_eq(b, 44), b, fhash, h, fields, rows, qfields, escapes, buf)

def step_cr_nl(c: Bool, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match c:
    case True{}:
      +nr = U32.inc(rows)
      SAcc{buf, SStart{}, 2166136261, U32.xor(U32.xor(U32.mul(h, 2654435761), fhash), nr), U32.inc(fields), nr, qfields, escapes}
    case False{}:
      step_cr_q(U32.is_eq(b, 34), b, fhash, h, fields, rows, qfields, escapes, buf)

def csv_dispatch(st: CsvSt, +b: U32, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32, buf: Array<U32>) -> ScanAcc:
  match st:
    case SStart{}:
      step_start_q(U32.is_eq(b, 34), b, fhash, h, fields, rows, qfields, escapes, buf)
    case SUnq{}:
      step_start_comma(U32.is_eq(b, 44), b, fhash, h, fields, rows, qfields, escapes, buf)
    case SQuote{}:
      step_quote_q(U32.is_eq(b, 34), b, fhash, h, fields, rows, qfields, escapes, buf)
    case SQEnd{}:
      step_qend_q(U32.is_eq(b, 34), b, fhash, h, fields, rows, qfields, escapes, buf)
    case SCr{}:
      step_cr_nl(U32.is_eq(b, 10), b, fhash, h, fields, rows, qfields, escapes, buf)

def csv_step(r: Array<U32> & U32, st: CsvSt, +fhash: U32, +h: U32, +fields: U32, +rows: U32, +qfields: U32, +escapes: U32) -> ScanAcc:
  (buf, +b) = r
  csv_dispatch(st, b, fhash, h, fields, rows, qfields, escapes, buf)

def scan_csv(+rem: Nat, +i: U32, acc: ScanAcc) -> ScanAcc:
  match rem:
    case 0n:
      acc
    case 1n+p:
      SAcc{buf, st, +fhash, +h, +fields, +rows, +qfields, +escapes} = acc
      scan_csv(p, U32.inc(i), csv_step(Array.get(U32, buf, i), st, fhash, h, fields, rows, qfields, escapes))

def finish_round(acc: ScanAcc) -> ScanAcc:
  SAcc{buf, st, +fhash, +h, +fields, +rows, +qfields, +escapes} = acc
  SAcc{buf, SStart{}, 2166136261, U32.xor(U32.mul(h, 2654435761), fhash), fields, rows, qfields, escapes}

def run_rounds(+rem: Nat, acc: ScanAcc) -> U32:
  match rem:
    case 0n:
      SAcc{buf, st, +fhash, +h, +fields, +rows, +qfields, +escapes} = acc
      U32.add(
        U32.add(U32.xor(h, U32.mul(fields, 2654435761)), U32.mul(rows, 2246822519)),
        U32.add(U32.mul(qfields, 3266489917), U32.mul(escapes, 668265263))
      )
    case 1n+p:
      run_rounds(p, finish_round(scan_csv(32768n, 0, acc)))

def main() -> U32:
  buf = fill_bytes(32768n, 0, (Array.new(U32, 15n, 0), 0))
  run_rounds(220n, SAcc{buf, SStart{}, 2166136261, 2166136261, 0, 0, 0, 0})
