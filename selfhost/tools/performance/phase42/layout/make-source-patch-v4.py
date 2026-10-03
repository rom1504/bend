#!/usr/bin/env python3
"""Create a proposed diff only; never edit production sources."""
import difflib, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
support=HERE/'flat-support-v4.bend'
paths=['tree','region','finite','emit']
inputs={}
patch=[]
def replace_once(text,old,new):
    assert text.count(old)==1, (old[:120],text.count(old))
    return text.replace(old,new)
for name in paths:
    path=ROOT/'selfhost/src/back/js'/f'{name}.bend'
    before=path.read_text();after=before
    if name=='tree':
        after=replace_once(after,'u => j_finite_fields(arg, 0, da(c), rest)), d, phase)', 'u => j_flat_fields(book, input, arg, 0, da(c), rest)), d, phase)')
        after=replace_once(after, 'u => kc(String, j_owned_ctor(book, t, ty), u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "]})",', 'u => kc(String, j_owned_ctor(book, t, ty), u => kc(String, j_flat_data(book, ty), u => "({$:" ++ j_quote(nm(t)) ++ "," ++ j_flat_linear_args(book, env, ks(spine), tel, child, 0) ++ "})", u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_producer_unary_resume(book, env, ks(spine), tel, child, 0) ++ "]})"),')
        after+='\n'+support.read_text()
    elif name=='finite':
        after=replace_once(after,'j_arm_type(book, ty, nm(t)), j_finite_fields(arg, 0, da(c), rest))', 'j_arm_type(book, ty, nm(t)), j_flat_fields(book, input, arg, 0, da(c), rest))')
    elif name=='region':
        after=replace_once(after,'j_tree_scope(book, d, j_region_helpers(s), j_fusion_root_body(book, d, j_nat_loop_generic(book, Nil{}, j_region_term(s), dt(d), 0)))', 'j_flat_root_scope(book, d, s)')
        after=replace_once(after,'kc(String, String.eq(tg(t), "JUnpack"), u => "{const $unpack=$p" ++ U32.show(ix(t)) ++\n    kc(String, j_region_local_vector(book, kid(t, 1)), u => "", u => ".a") ++ ";{" ++\n    j_region_field_bindings(ix(t), 0, qt(t)) ++ j_region_return(book, env, kid(t, 0), ty) ++ "}}", u =>', 'kc(String, String.eq(tg(t), "JUnpack"), u => "{const $unpack=" ++ j_flat_unpack(book, kid(t, 1), "$p" ++ U32.show(ix(t))) ++ ";{" ++\n    j_flat_bindings(book, kid(t, 1), ix(t), 0, qt(t)) ++ j_region_return(book, env, kid(t, 0), ty) ++ "}}", u =>')
    elif name=='emit':
        after=replace_once(after,'u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "]})",', 'u => kc(String, j_flat_data(book, ty),\n        u => "({$:" ++ j_quote(nm(t)) ++ "," ++ j_flat_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty))), 0) ++ "})",\n        u => "({$:" ++ j_quote(nm(t)) ++ ",a:[" ++ j_ctor_args(book, env, ks(t), j_specialize(book, dt(j_layout_ctor(book, wnf(book, ty), nm(t))), ks(wnf(book, ty)))) ++ "]})"),')
        after=replace_once(after,'j_expr(book, env, kid(t, 0), ty, tail) ++ ")(" ++ j_region_field_reads("$p" ++ U32.show(ix(t)) ++ kc(String, j_region_local_vector(book, kid(t, 1)), u => "", u => ".a"), 0, qt(t)) ++ ")",', 'j_expr(book, env, kid(t, 0), ty, tail) ++ ")(" ++ j_flat_reads(book, kid(t, 1), "$p" ++ U32.show(ix(t)), 0, qt(t)) ++ ")",')
    rel=str(path.relative_to(ROOT));inputs[rel]=hashlib.sha256(before.encode()).hexdigest()
    patch.extend(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+rel,tofile='b/'+rel))
text=''.join(patch);target=HERE/'source-v4.patch';assert not target.exists();target.write_text(text)
(HERE/'source-v4.json').write_text(json.dumps({'kind':'phase42-flat-source-proposal','checked':False,'complete':True,'inputs':inputs,'supportSha256':hashlib.sha256(support.read_bytes()).hexdigest(),'patchSha256':hashlib.sha256(text.encode()).hexdigest(),'addedLines':sum(x.startswith('+') and not x.startswith('+++') for x in patch),'removedLines':sum(x.startswith('-') and not x.startswith('---') for x in patch)},indent=2)+'\n')
print(target)
