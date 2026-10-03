"""Exact isolated native owned constructor emission patch. No canonical edits."""
from pathlib import Path
import hashlib,json,difflib
root=Path(__file__).resolve().parents[5]
p=root/'src/back/js/emit.bend'
# tools/performance/phase42/calls -> selfhost is parents[4]
p=Path('selfhost/src/back/js/emit.bend').resolve()
out=Path(__file__).with_name('native-owned-v1');assert not out.exists();out.mkdir()
s=p.read_text();needle='def j_constructor_literal(book, env, t, ty, literal):\n  kc(String, String.eq(literal, ""), u =>'
replace='def j_constructor_literal(book, env, t, ty, literal):\n  +native = j_owned_native_literal(book, env, t, ty)\n  kc(String, Bool.not(String.eq(native, "")), u => native, u =>\n  kc(String, String.eq(literal, ""), u =>'
assert s.count(needle)==1;s=s.replace(needle,replace)
end=' ++ "])"), u => literal)\n\n'
# exact tail of this single function, preserve all existing branches.
start=s.index('def j_constructor_literal(');finish=s.index('\nlaw j_io_type:',start)
body=s[start:finish];assert body.endswith('u => literal)\n');s=s[:start]+body[:-2]+')\n'+s[finish:]
helper='''# Only owned private eager constructors use canonical closed native layouts.
# Preserve original typed field emission, erased slots, order and aliases.
@unsafe
def j_owned_native_literal(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  kc(String, String.eq(tg(t), "Ctr") && has_name(rm(t), "$private.owned.ctor"),
    u => j_owned_native_head(book, env, t, wnf(book, ty)), u => "")

@unsafe
def j_owned_native_head(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +head: KTerm) -> String:
  +c = j_layout_ctor(book, head, nm(t))
  kc(String, String.eq(nm(t), "Tuple") && U32.is_eq(terms_len(ks(t)), 2) &&
    j_pure_closed_sigma(book, head) && j_pure_native_ctor(c, "Tuple", 2),
    u => "[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(c), ks(head))) ++ "]", u =>
  kc(String, ((String.eq(nm(t), "Nil") && U32.is_eq(terms_len(ks(t)), 0) && j_pure_native_ctor(c, "Nil", 0)) ||
    (String.eq(nm(t), "Con") && U32.is_eq(terms_len(ks(t)), 2) && j_pure_native_ctor(c, "Con", 2))) &&
    j_pure_closed_list(book, head),
    u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(c), ks(head))) ++ "]})", u =>
  kc(String, U32.is_eq(terms_len(ks(t)), 0) && j_primitive_type(book, head, "Bool") &&
    ((String.eq(nm(t), "True") && j_pure_native_ctor(c, "True", 0)) ||
     (String.eq(nm(t), "False") && j_pure_native_ctor(c, "False", 0))),
    u => kc(String, String.eq(nm(t), "True"), u => "true", u => "false"), u => "")))

'''
s=s[:finish+1] if False else s
pos=s.index('\nlaw j_io_type:',s.index('def j_constructor_literal('));s=s[:pos]+'\n'+helper+s[pos:]
original=p.read_text();patch=''.join(difflib.unified_diff(original.splitlines(True),s.splitlines(True),fromfile='a/selfhost/src/back/js/emit.bend',tofile='b/selfhost/src/back/js/emit.bend'))
(out/'source.patch').write_text(patch);(out/'emit.bend').write_text(s)
def sha(x):return hashlib.sha256(x.encode()).hexdigest()
(out/'identity.json').write_text(json.dumps({'kind':'phase42-native-owned-literal-source','checked':False,'source':str(p),'before':sha(original),'after':sha(s),'patch':sha(patch),'producer':sha(Path(__file__).read_text()),'scope':'Only eager marked canonical closed Sigma/List/Bool Ctr; unchanged deferred tail and public constructor paths'},indent=2)+'\n')
print(str(out/'source.patch'))
