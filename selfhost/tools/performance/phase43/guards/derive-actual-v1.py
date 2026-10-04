#!/usr/bin/env python3
"""Receipt-bound actual compiler emission; only add diagnostic counters/exports."""
import argparse,hashlib,json,pathlib,re,shutil
p=argparse.ArgumentParser();p.add_argument('--candidate',required=True);p.add_argument('--receipt');p.add_argument('--baseline',required=True);p.add_argument('--baseline-receipt');p.add_argument('--out',required=True);a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[5];inputs={}
def identify(path,expected=None):
 path=pathlib.Path(path).resolve();data=path.read_bytes();h=hashlib.sha256(data).hexdigest()
 if expected:assert h==expected['sha256'],('identity mismatch',str(path),h,expected['sha256'])
 record={'path':str(path),'sha256':h,'bytes':len(data)};inputs[str(path)]=record;return record
def pointer(v):return identify(v.get('canonicalPath',v.get('file',v.get('path'))),v)
def receipt(path,module):
 identify(path);r=json.loads(pathlib.Path(path).read_text());assert r['complete'] and r['observation']['checked'] and r['observation']['status']=='ok'
 assert pointer(r['output'])['sha256']==identify(module)['sha256']
 for key in ['input','producer','catalog']:pointer(r[key])
 for v in r.get('verifiers',[]):pointer(v)
 if r.get('attempt'):pointer(r['attempt'])
 for key in ['api','runtime','base','driver']:pointer(r['compiler'][key])
 return r
candidate=pathlib.Path(a.candidate);cr=receipt(a.receipt or str(candidate)+'.json',candidate);baseline=pathlib.Path(a.baseline)
if a.baseline_receipt:
 br=receipt(a.baseline_receipt,baseline);assert br['input']['sha256']==cr['input']['sha256']
else:
 manifest=root/'selfhost/tools/performance/phase42/current/manifest.json';identify(manifest);m=json.loads(manifest.read_text());case=next(c for c in m['cases'] if c['id']=='coverage-list-pipeline-512')
 assert case['sourceSha256']==cr['input']['sha256'];identify(baseline,case['modules']['candidate'])
cs=candidate.read_text();bs=baseline.read_text()
# Refuse the checked05 assembler omission: true flag without actual host domain.
assert 'function regionHostGuard(u32Fusion=false){' in cs
assert 'const hooks=u32Fusion?regionU32FusionHooks:regionNumericHooks;' in cs
clause='if($entered&&regionHostGuard(true)&&(typeof $s0==="number"&&Number.isInteger($s0)&&$s0>=0&&$s0<=4294967295)&&(typeof $s1==="number"&&Number.isInteger($s1)&&$s1>=0&&$s1<=4294967295)&&true&&localGuard($guards))'
assert cs.count(clause)==1,'actual full U32 guard clause absent/duplicated'
marker='/* private total scalar fusion */';assert cs.count(marker)==bs.count(marker)==1
body=cs.split(marker,1)[1].split('}finally{regionProofClose',1)[0]
assert 'return $f_acc;' in body and 'while($f_n!==0)' in body
assert set(re.findall(r'Math\.([A-Za-z0-9_]+)',body))<={'imul'}
assert not re.search(r'\b(?:call|callOwned|get|ctor|force|apply|fields|project|DataView|floatView|G|Number|Array|Object)\b',body),'residual/generic/float code in selected full fusion'
assert 'const $guards=["bench","p37.list","keep_gt1","keep_gt1.at","dbl","suma"]' in cs
# Checked proof code is bound through its immutable snapshot source, not the active tree.
snapshot=pathlib.Path(cr['compiler']['driver']['canonicalPath']).parents[1]/'src/back/js/region.bend'
source=snapshot.read_text();identify(snapshot)
assert 'j_region_root_selected(book, d, s, j_fusion_root_prefix' in source
assert 'u => "regionHostGuard(true)&&"' in source
assert 'try{" ++ fusion ++ "}finally{regionProofClose' in source
out=pathlib.Path(a.out);out.mkdir(parents=True,exist_ok=False)
extra='\nconst __p43stats={fusion:0};\nexport const __p43={stats:__p43stats,force,scalarGuard,localGuard,regionHostGuard,regionProofOpen,regionProofClose,regionProofCovers,scalarSnapshots,floatView,regionNumericHooks,regionProtocolPairs,regionPrimitivePrototypes:scalarPrimitivePrototypes};\n'
for role,text in [('control',bs),('candidate',cs)]:
 (out/(role+'.mjs')).write_text(text)
 (out/(role+'.oracle.mjs')).write_text(text.replace(marker,marker+'__p43stats.fusion++;')+extra)
assert identify(out/'candidate.mjs')['sha256']==identify(candidate)['sha256'];assert identify(out/'control.mjs')['sha256']==identify(baseline)['sha256']
shutil.copy2(__file__,out/'consumed-derive-actual-v1.py')
report={'kind':'phase43-actual-u32-fusion-guards-v1','complete':True,'checked':True,'handRewrittenGuardFlags':False,'sourceProofSnapshot':str(snapshot),'fullFusionKernel':body,'inputs':list(inputs.values()),'files':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in out.iterdir() if f.is_file()}}
(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'candidate':identify(candidate),'baseline':identify(baseline),'fullFusionMarkers':1,'proofSnapshot':str(snapshot)}))
