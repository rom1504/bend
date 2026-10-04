"""Write a reviewable general compiler patch without editing production."""
from pathlib import Path
import difflib
root=Path(__file__).resolve().parents[5]
p=root/'selfhost/src/back/js/tree.bend'
s=p.read_text()
if 'def j_linear_prefix_alias(' in s:
    p=root/'selfhost/build/phase42/checked16/snapshot/src/back/js/tree.bend'
    s=p.read_text()
helper='''# A computed scalar prefix is evaluated once, at the same original let site.
# This gate belongs only to complete-JPure structural workers; keep the legacy
# field-atom rule for flat audits and demand-sensitive scalar islands.
@unsafe
def j_linear_prefix_alias(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +name: String) -> Bool:
  kc(Bool, j_linear_alias(t, name), u => True{}, u =>
    kc(Bool, String.eq(tg(t), "Let") && U32.is_eq(terms_len(ks(t)), 2) &&
      String.eq(tg(kid(t, 0)), "Bind") && U32.is_eq(terms_len(ks(kid(t, 0))), 1) &&
      Bool.not(U32.is_eq(qt(kid(t, 0)), 0)) &&
      U32.is_eq(j_component_refs([kid(t, 0)], name, 1024, 0), 0), u =>
      j_linear_u32_prefix(book, env, kid(kid(t, 0), 0), 128), u => False{}))

@unsafe
def j_linear_u32_prefix(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +fuel: U32) -> Bool:
  +h = j_strip(t)
  +s = j_call_spine(h, Nil{})
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(h), "Var"), u => j_primitive_type(book, wnf(book, j_env(env, ix(h))), "U32"), u =>
      kc(Bool, String.eq(tg(h), "Lit"), u => String.eq(nm(h), "U32"), u =>
        kc(Bool, String.eq(tg(s), "Call") && j_primitive_call(book, s) && U32.is_eq(terms_len(ks(s)), 2) &&
        (String.eq(nm(s), "U32.add") || String.eq(nm(s), "U32.sub") ||
         String.eq(nm(s), "U32.mul") || String.eq(nm(s), "U32.mod")), u =>
        j_linear_u32_prefix(book, env, terms_at(ks(s), 0), U32.sub(fuel, 1)) &&
        j_linear_u32_prefix(book, env, terms_at(ks(s), 1), U32.sub(fuel, 1)), u => False{}))), u => False{})

'''
needle='@unsafe\ndef j_linear_spine('
assert s.count(needle)==1
new=s.replace(needle,helper+needle)
old='kc(Bool, j_linear_alias(t, dn(d)), u => j_linear_leaf('
assert new.count(old)==1
new=new.replace(old,'kc(Bool, j_linear_prefix_alias(book, env, t, dn(d)), u => j_linear_leaf(')
old='kc(String, j_linear_alias(t, dn(d)), u =>'
assert new.count(old)==1
new=new.replace(old,'kc(String, j_linear_prefix_alias(book, env, t, dn(d)), u =>')
out=Path(__file__).with_name('computed-u32-prefix.patch')
out.write_text(''.join(difflib.unified_diff(s.splitlines(True),new.splitlines(True),fromfile='a/selfhost/src/back/js/tree.bend',tofile='b/selfhost/src/back/js/tree.bend')))
print(out)
