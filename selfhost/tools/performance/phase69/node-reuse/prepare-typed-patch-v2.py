#!/usr/bin/env python3
"""Prepare an unapplied typed-worker Bend patch against exact live source pins."""
import difflib
import hashlib
import json
import os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
OUT=Path(__file__).resolve().parent/'typed-worker-candidate-v2'


def pin(path):
 p=Path(path);return dict(path=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)


def once(text, old, new):
 assert text.count(old)==1,(old,text.count(old));return text.replace(old,new)


def main():
 assert os.sched_getaffinity(0)=={0};OUT.mkdir(exist_ok=False)
 files=['flat.bend','product.bend','scalar-array.bend'];original={n:(ROOT/'selfhost/src/back/native'/n).read_text() for n in files};texts=dict(original)
 text=texts['flat.bend']
 text=once(text,'NF_Worker{+name: String, +params: List<&2, NC_Binding>,','NF_Worker{+name: String, +params: List<&2, N_Param>,')
 old='''def nf_param_c(params: List<&2, NC_Binding>) -> String:
  match params:
    case Nil{}: ""
    case Con{NC_Binding{id, word}, rest}: ", Term " ++ word ++ nf_param_c(rest)'''
 new='''def nf_param_c(params: List<&2, N_Param>) -> String:
  match params:
    case Nil{}: ""
    case Con{N_Param{word, kind}, rest}: ", " ++ nf_param_type(kind) ++ " " ++ word ++ nf_param_c(rest)

@unsafe
def nf_param_type(kind: N_WordKind) -> String:
  match kind:
    case N_W32{}: "NF_SCALAR"
    case _: "Term"

# Private C argument facts come from the original telescope, before erasure.
# The checked-entry macro enables narrowing; raw lowering keeps full Terms.
@unsafe
def nf_scalar_kind(+book: List<&2, KDef>, +ty: KTerm) -> N_WordKind:
  +head = nq_layout_type(book, ty)
  +owner = lookup(book, nm(head))
  nt_choose(N_WordKind, String.eq(tg(head), "ADT") && String.eq(dk(owner), "ADT") && db(owner) && List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head)) && nb_contains(["U32", "F32", "Char", "Bool"], nm(head)), u => N_W32{}, u => N_W64{})

@unsafe
def nf_opaque_kinds(+left: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{}, u => Con{N_W64{}, nf_opaque_kinds(U32.sub(left, 1))})

@unsafe
def nf_kind_tele(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{}, u =>
    nt_choose(List<&2, N_WordKind>, U32.is_eq(fuel, 0), v => nf_opaque_kinds(left), v => nf_kind_head(book, nq_layout_type(book, ty), left, U32.sub(fuel, 1))))

@unsafe
def nf_kind_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, String.eq(tg(head), "All"),
    u => nt_choose(List<&2, N_WordKind>, U32.is_eq(qt(head), 0), v => nf_kind_tele(book, kid(head, 1), left, fuel), v => Con{nf_scalar_kind(book, kid(head, 0)), nf_kind_tele(book, kid(head, 1), U32.sub(left, 1), fuel)}),
    u => nf_opaque_kinds(left))

@unsafe
def nf_worker_kinds(+book: List<&2, KDef>, +name: String, +arity: U32) -> List<&2, N_WordKind>:
  +d = lookup(book, name)
  nt_choose(List<&2, N_WordKind>, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))), u => nf_kind_tele(book, dt(d), arity, 256), u => nf_opaque_kinds(arity))

@unsafe
def nf_typed_params(+params: List<&2, NC_Binding>, +kinds: List<&2, N_WordKind>) -> List<&2, N_Param>:
  nt_choose(List<&2, N_Param>, U32.is_eq(nt_count(NC_Binding, params), nt_count(N_WordKind, kinds)), u => nf_params_zip(params, kinds), u => nc_params(params))

@unsafe
def nf_params_zip(params: List<&2, NC_Binding>, kinds: List<&2, N_WordKind>) -> List<&2, N_Param>:
  match params, kinds:
    case Nil{}, _: Nil{}
    case Con{NC_Binding{id, word}, rest}, Con{kind, more}: Con{N_Param{word, kind}, nf_params_zip(rest, more)}
    case Con{NC_Binding{id, word}, rest}, Nil{}: Con{N_Param{word, N_W64{}}, nf_params_zip(rest, Nil{})}

# A shell's fields remain opaque. Only nonflattened scalar arguments inherit
# the original argument kind; expanding a product must not shift later slots.
@unsafe
def nf_expand_kinds(shapes: List<&2, KTerm>, kinds: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match shapes, kinds:
    case Con{shape, rest}, Con{kind, more}: nt_append(N_WordKind, nt_choose(List<&2, N_WordKind>, String.eq(tg(shape), "NQShape"), u => nf_opaque_kinds(ix(shape)), u => [kind]), nf_expand_kinds(rest, more))
    case _, _: Nil{}'''
 text=once(text,old,new)
 text=once(text,'NF_Worker{name, params, code, nc_calls(code), shape}','NF_Worker{name, nf_typed_params(params, nf_worker_kinds(book, name, nt_count(NC_Binding, params))), code, nc_calls(code), shape}')
 old='nt_choose(String, List.is_empty(&2, NC_Binding, params), v => name, v => nd_name(name)), "NFWorker", nt_count(NC_Binding, params)'
 new='nt_choose(String, List.is_empty(&2, N_Param, params), v => name, v => nd_name(name)), "NFWorker", nt_count(N_Param, params)'
 text=once(text,old,new)
 old='"#if !DEVICE\\n#if defined(__GNUC__) || defined(__clang__)\\n#define NF_INLINE INLINE __attribute__((always_inline))'
 new='"#if !DEVICE\\n#if NATIVE_TYPED_SCALARS\\n#define NF_SCALAR u32\\n#else\\n#define NF_SCALAR Term\\n#endif\\n#if defined(__GNUC__) || defined(__clang__)\\n#define NF_INLINE INLINE __attribute__((always_inline))'
 text=once(text,old,new)
 text=once(text,'++ "#undef NF_INLINE\\n#endif\\n", image)','++ "#undef NF_INLINE\\n#undef NF_SCALAR\\n#endif\\n", image)')
 texts['flat.bend']=text
 texts['product.bend']=once(texts['product.bend'],'NF_Worker{route, params, code, nc_calls(code), shape}','NF_Worker{route, nf_typed_params(params, nf_expand_kinds(ks(dv(info)), nf_worker_kinds(book, name, da(info)))), code, nc_calls(code), shape}')
 texts['scalar-array.bend']=once(texts['scalar-array.bend'],'nc_compile(book, "#define NATIVE_COLD_USER_CTORS "','nc_compile(book, "#define NATIVE_TYPED_SCALARS " ++ nt_choose(String, packed, u => "1", u => "0") ++ "\\n#define NATIVE_COLD_USER_CTORS "')
 patches=[];pins=[]
 for name in files:
  logical='selfhost/src/back/native/'+name
  before=OUT/(name+'.before');after=OUT/(name+'.after');before.write_text(original[name]);after.write_text(texts[name])
  pins.append(dict(logical=logical,before=pin(before),after=pin(after)))
  patches.extend(difflib.unified_diff(original[name].splitlines(True),texts[name].splitlines(True),fromfile='a/'+logical,tofile='b/'+logical))
 patch=OUT/'source.patch';patch.write_text(''.join(patches))
 report=dict(status='prepared-not-applied-not-checked',producer=pin(__file__),patch=pin(patch),sources=pins,hypothesis=pin(ROOT/'experiments/phase69/P69-008-typed-native-worker-parameters.md'),scope='Reviewable checked-only scalar parameter metadata proposal; source/data work, no compiler or native execution. Narrowing macro uses packed safe-effects/layout permission; raw falls back to Term.')
 (OUT/'plan.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(plan=pin(OUT/'plan.json'),addedLines=sum(len(texts[n].splitlines())-len(original[n].splitlines()) for n in files))))

if __name__=='__main__':main()
