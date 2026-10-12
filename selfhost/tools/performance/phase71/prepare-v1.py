#!/usr/bin/env python3
"""Freeze one saved-C virtual-product experiment and fresh emission recipe."""
import json,hashlib,difflib,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase71'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
source=ROOT/'selfhost/build/phase70/compiler02-array-map/array-map-selfhost/program.c'
s=source.read_text();assert pin(source)['sha256']=='1297ec3492260a9ad692edffa489163367ab4f24f19ce8bb791c6c033acf3043'
original=s;changes=[]
for suffix in [48,49]:
 name='NF_FID_65_114_114_97_121_46_109_97_112_46_103_111_126_'+str(suffix)+'_'
 pattern=r'NF_INLINE Term '+name+r'\([^;]+?\n}\n(?=NF_INLINE Term)'
 matches=list(re.finditer(pattern,s));assert len(matches)==1
 old=matches[0].group();new=old
 replacements=[
 ('u32 nf_poll = 0;','u32 nf_poll = 0;\nbool p71_pending = false;\nTerm p71_first = 0, p71_second = 0;'),
 ('term_sink(e, v_4294967288);','if (p71_pending) { term_sink(e, p71_first); term_sink(e, p71_second); } else { term_sink(e, v_4294967288); }'),
 ('if ((term_aux(v_4294967280) == CID_TUPLE)) {','if (p71_pending || (term_aux(v_4294967280) == CID_TUPLE)) {'),
 ('spare_free(e, cls_fit(2), ctr_take(e, v_4294967280, 2, fields));','if (p71_pending) { fields[0] = p71_first; fields[1] = p71_second; p71_pending = false; } else { spare_free(e, cls_fit(2), ctr_take(e, v_4294967280, 2, fields)); }'),
 ('u64 nd_38 = heap_alloc(e, cls_fit(2));\ne.mem[nd_38 + 0] = rfc_seal(e, v_4294967264);\ne.mem[nd_38 + 1] = rfc_seal(e, v_4294967263);\nv_4294967262 = term_ctr(CID_TUPLE, nd_38);','p71_first = v_4294967264;\np71_second = v_4294967263;\np71_pending = true;\nv_4294967262 = 0;')]
 for a,b in replacements:assert new.count(a)==1,(name,a);new=new.replace(a,b)
 assert new.count('heap_alloc(')==0 and new.count('rfc_seal(')==0
 changes.append(dict(function=name,beforeSha256=hashlib.sha256(old.encode()).hexdigest(),afterSha256=hashlib.sha256(new.encode()).hexdigest()))
 s=s[:matches[0].start()]+new+s[matches[0].end():]
out=RAW/'array-map-virtual.c';out.write_text(s)
(RAW/'array-map-virtual.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),s.splitlines(True),fromfile=str(source),tofile=str(out))))
recipe=json.loads((ROOT/'selfhost/build/phase70/compiler02-coverage-recipe.json').read_text());oldapi=recipe['api'];recipe['api']=str(ROOT/'selfhost/dist/typed-api.mjs');recipe['verifyInstalled']=True
recipe['inputs']=[pin(recipe['api'] if i['path']==oldapi else i['path']) for i in recipe['inputs']]
recipe['inputs'] += [pin(__file__),pin(ROOT/'selfhost/tools/performance/phase71/balanced.bend')]
(RAW/'recipe.json').write_text(json.dumps(recipe,indent=2)+'\n')
# Independent arithmetic: compose affine LCG maps modulo2^32 by squaring.
a,b=1664525,1013904223;ra,rb=1,0;n=250000;mask=2**32-1
while n:
 if n&1:ra,rb=a*ra&mask,(a*rb+b)&mask
 a,b=a*a&mask,(a*b+b)&mask;n//=2
oracle=sum((ra*x+rb)&mask for x in range(17*1024,18*1024))&mask
(RAW/'preparation.json').write_text(json.dumps(dict(producer=pin(__file__),original=pin(source),candidate=pin(out),changes=changes,balancedOracle=oracle,recipe=pin(RAW/'recipe.json')),indent=2)+'\n')
print(json.dumps(dict(changedLoops=len(changes),balancedOracle=oracle)))
