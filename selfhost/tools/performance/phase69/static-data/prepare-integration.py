#!/usr/bin/env python3
"""Prepare exact native static-image source hooks; does not apply them."""
import difflib, json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
changes=[]
def edit(file, old, new):
    changes.append(dict(file='selfhost/src/back/native/'+file,old=old,new=new))
edit('book.bend',
'def nc_definition(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:\n  +prim =',
'def nc_definition(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:\n  +fact = ns_body(book, dn(d))\n  nt_choose(KTerm, String.eq(dk(fact), "NativeStaticBody"), u => dv(fact), u => nc_definition_plain(book, d, n))\n\n@unsafe\ndef nc_definition_plain(+book: List<&2, KDef>, +d: KDef, +n: U32) -> KTerm:\n  +prim =')
edit('book.bend',
'd: NC_Show, workers: String) -> NC_Result:',
'd: NC_Show, workers: String, +image: List<&2, String>) -> NC_Result:')
edit('book.bend','N_Program{ss, cs, Nil{}, requests,','N_Program{ss, cs, image, requests,')
edit('book.bend',
'nc_finish(book, runtime, requests, nc_compile_defs(book, ["main"], Nil{}, 0, nc_bangs_book(book)))',
'ns_compile(book, runtime, requests)')
edit('bridge.bend',
'nt_choose(String, String.eq(tg(value), "NOp"), u => nd_scalar_word(nm(value), nc_values(ks(value), env)), u => nm(value) ++ "ull")',
'nt_choose(String, String.eq(tg(value), "NOp"), u => nd_scalar_word(nm(value), nc_values(ks(value), env)), u => nt_choose(String, String.eq(tg(value), "NStatic"), v => ns_word(value), v => nm(value) ++ "ull"))')
edit('bridge.bend',
'String.eq(tg(value), "Var") || String.eq(tg(value), "NWord") || (String.eq(tg(value), "NOp")',
'String.eq(tg(value), "Var") || String.eq(tg(value), "NWord") || (String.eq(tg(value), "NStatic") && String.eq(dk(ns_context(book)), "NativeStaticContext")) || (String.eq(tg(value), "NOp")')
edit('bridge.bend',
'def nc_compact(t):\n  kc(KTerm, core_literal(t),',
'def nc_compact(t):\n  nt_choose(KTerm, String.eq(tg(t), "NStatic"), u => t, u => nc_compact_plain(t))\n\n@unsafe\ndef nc_compact_plain(+t: KTerm) -> KTerm:\n  kc(KTerm, core_literal(t),')
edit('bridge.bend',
'nt_choose(NC_Code, String.eq(tag, "NWord"), u => nf_return(nm(t) ++ "ull", n, target), u =>',
'nt_choose(NC_Code, String.eq(tag, "NWord") || String.eq(tag, "NStatic"), u => nt_choose(NC_Code, String.eq(tag, "NStatic"), v => ns_return(book, t, n, target), v => nf_return(nm(t) ++ "ull", n, target)), u =>')
edit('product.bend',
'String.eq(tg(value), "Ctr") || String.eq(tg(value), "NCtr"), u => nq_ctor_shape(value, target)',
'String.eq(tg(value), "Ctr") || String.eq(tg(value), "NCtr") || String.eq(tg(value), "NStatic"), u => nq_ctor_shape(value, target)')
edit('flat.bend',
'def nf_finish_ready(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>, +ready: List<&2, String>)',
'def nf_finish_ready(+ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +image: List<&2, String>)')
edit('flat.bend',
'++ "#undef NF_INLINE\\n#endif\\n")',
'++ "#undef NF_INLINE\\n#endif\\n", image)')
edit('flat.bend',
'nf_finish_ready(ss, cs, runtime, requests, pure, show, retried, nf_admit(book, retried, ready, nt_count(NF_Worker, retried)))',
'nf_finish_ready(ss, cs, runtime, requests, pure, show, retried, nf_admit(book, retried, ready, nt_count(NF_Worker, retried)), ns_image(book))')
edit('manifest.txt','book.bend\nforeign.bend','book.bend\nstatic.bend\nforeign.bend')
(HERE/'integration.json').write_text(json.dumps(dict(base='c84246e',requires='root nc_bangs_names(book,names) helper',changes=changes,newFiles=[dict(source=str(HERE.relative_to(ROOT)/'static.bend'),target='selfhost/src/back/native/static.bend')]),indent=2)+'\n')
patch=[]
for file in dict.fromkeys(c['file'] for c in changes):
    old=subprocess.check_output(['git','show',f'c84246e:{file}'],cwd=ROOT,text=True)
    new=old
    for c in changes:
        if c['file']==file:
            assert new.count(c['old'])==1,(file,c['old'],new.count(c['old']))
            new=new.replace(c['old'],c['new'])
    patch.extend(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+file,tofile='b/'+file))
patch.extend(difflib.unified_diff([], (HERE/'static.bend').read_text().splitlines(True),fromfile='/dev/null',tofile='b/selfhost/src/back/native/static.bend'))
(HERE/'integration.patch').write_text(''.join(patch))
print(json.dumps(dict(replacements=len(changes),patchBytes=(HERE/'integration.patch').stat().st_size)))
