@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Chunks arrive in reverse output order. Only each new chunk is traversed by
# append; the growing suffix stays on its right.
@unsafe
def nt_text_finish(xs: List<&2, String>, acc: String) -> String:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_text_finish(t, h ++ acc)

@unsafe
def nt_join_chunks(xs: List<&2, String>, +sep: String, +first: Bool, acc: List<&2, String>) -> String:
  match xs:
    case Nil{}: nt_text_finish(acc, "")
    case Con{h, t}: nt_join_chunks(t, sep, False{}, Con{h, Con{nt_choose(String, first, u => "", u => sep), acc}})

@unsafe
def nt_join_go(xs: List<&2, String>, +sep: String, +acc: String, +first: Bool) -> String:
  acc ++ nt_join_chunks(xs, sep, first, Nil{})

@unsafe
def nt_join(xs: List<&2, String>, sep: String) -> String:
  nt_join_go(xs, sep, "", True{})

@unsafe
def nt_count_go(-A: Data, xs: List<&2, A>, +n: U32) -> U32:
  match xs:
    case Nil{}: n
    case Con{h, t}: nt_count_go(A, t, U32.inc(n))

@unsafe
def nt_count(-A: Data, xs: List<&2, A>) -> U32:
  nt_count_go(A, xs, 0)

@unsafe
def nt_reverse(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: nt_reverse(A, t, Con{h, acc})

@unsafe
def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)

@unsafe
def nt_clean(s: String) -> String:
  match s:
    case SNil{}: ""
    case SCon{+h, t}:
      nt_choose(String, Char.is_alpha(h) || Char.is_digit(h) || Char.is_eq(h, '_'), u => SCon{h, ""}, u => "_") ++ nt_clean(t)

@unsafe
def nt_fid(k: String) -> String:
  "FID_" ++ nc_ctor_codes(k)

@unsafe
def nt_cid(k: String) -> String:
  "CID_" ++ String.to_upper(nt_clean(k))

@unsafe
def nt_local(k: String, n: U32) -> String:
  nt_clean(k) ++ "_" ++ U32.show(n)

@unsafe
def nt_bool(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

law nt_replace_go:
  for +s: String
  for +key: String
  for +value: String
  for +acc: String
  String

@unsafe
def nt_replace_step(
  +s: String,
  +key: String,
  +value: String,
  +acc: String,
) -> String:
  match s:
    case SNil{}: acc
    case SCon{h, t}: nt_replace_go(t, key, value, acc ++ SCon{h, ""})

@unsafe
def nt_replace_go(s, key, value, acc):
  nt_choose(String, String.starts_with(s, key), u => acc ++ value ++ String.drop(s, String.length(key)), u => nt_replace_step(s, key, value, acc))

@unsafe
def nt_replace(s: String, key: String, value: String) -> String:
  nt_replace_go(s, key, value, "")

@unsafe
def nt_lines_rev(s: String, +acc: String) -> String:
  match s:
    case SNil{}: String.reverse(acc)
    case SCon{+h, t}:
      nt_lines_char(t, h, acc, Char.is_eq(h, '\n'))

@unsafe
def nt_lines_char(s: String, h: Char, acc: String, newline: Bool) -> String:
  match newline:
    case True{}: nt_lines_rev(s, SCon{' ', SCon{' ', SCon{' ', SCon{' ', SCon{'\n', acc}}}}})
    case False{}: nt_lines_rev(s, SCon{h, acc})

@unsafe
def nt_lines_go(s: String, +acc: String) -> String:
  acc ++ nt_lines_rev(s, "")

@unsafe
def nt_lines(s: String) -> String:
  nt_lines_go(s, "")

@unsafe
def nt_indent(s: String) -> String:
  "    " ++ nt_lines(s)
