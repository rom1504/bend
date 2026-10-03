#!/usr/bin/env python3
"""Exact Nat.add residual admission and native snapshot registration only."""
from pathlib import Path
import difflib,hashlib,json,sys
root=Path(__file__).resolve().parents[6]
files=['selfhost/src/back/js/jpure.bend','selfhost/src/runtime/js/core.mjs']
source={f:(root/f).read_text() for f in files};new=dict(source)
p=files[0]
x='  j_pure_bool_native(book, d) || (String.eq(dn(d), "F32.to_u32")'
y='  j_pure_bool_native(book, d) || j_pure_nat_native(book, d) || (String.eq(dn(d), "F32.to_u32")'
assert new[p].count(x)==1;new[p]=new[p].replace(x,y)
new[p]+='''
# Residual Nat addition keeps its original checkedNat runtime call and range
# errors. Native registration captures exactly that immutable descriptor; no
# direct/flat native emitter is widened by this source-signature proof.
@unsafe
def j_pure_nat_native(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +ty = wnf(book, dt(d))
  +rest = wnf(book, kid(ty, 1))
  String.eq(dn(d), "Nat.add") && String.eq(dk(d), "Def") && db(d) && U32.is_eq(da(d), 2) && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")) && String.eq(tg(ty), "All") && U32.is_eq(qt(ty), 1) &&
    j_primitive_type(book, wnf(book, kid(ty, 0)), "Nat") && String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) &&
    j_primitive_type(book, wnf(book, kid(rest, 0)), "Nat") && j_primitive_type(book, wnf(book, kid(rest, 1)), "Nat")
'''
p=files[1]
x="const scalarSnapshots=Object.create(null), scalarObjectPrototype=Object.prototype;"
y=x+"\nlet scalarNatAddSnapshot=null;"
assert new[p].count(x)==1;new[p]=new[p].replace(x,y)
x="const s=scalarSnapshots[name],g=Object.getOwnPropertyDescriptor(G,name);"
y="const s=name==='Nat.add'?scalarNatAddSnapshot:scalarSnapshots[name],g=Object.getOwnPropertyDescriptor(G,name);"
assert new[p].count(x)==1;new[p]=new[p].replace(x,y)
x="  const value=fn(n,a=>f(...a));\n  return G[name]="
y="  const value=fn(n,a=>f(...a));\n  // The factory owns these fresh fields; snapshot without calling host hooks.\n  if(name==='Nat.add')scalarNatAddSnapshot={original:value,arity:n,code:value.code,bound:value.bound};\n  return G[name]="
assert new[p].count(x)==1;new[p]=new[p].replace(x,y)
out=Path(sys.argv[1]);out.mkdir();patch='';ids={}
for f in files:
 (out/Path(f).name).write_text(new[f]);patch+=''.join(difflib.unified_diff(source[f].splitlines(True),new[f].splitlines(True),fromfile='a/'+f,tofile='b/'+f))
 ids[f]={'sourceSha256':hashlib.sha256(source[f].encode()).hexdigest(),'candidateSha256':hashlib.sha256(new[f].encode()).hexdigest(),'netLines':len(new[f].splitlines())-len(source[f].splitlines())}
(out/'candidate.patch').write_text(patch)
(out/'identity.json').write_text(json.dumps({'kind':'unexecuted-exact-native-Nat-add-inert-metadata-candidate','files':ids,'noProductionEdits':True,'runtimeArithmeticBodyUnchanged':True,'ordinaryRuntimeCallUnchanged':True,'directFlatBoolOnlyGatesUnchanged':True},indent=2)+'\n')
