#!/usr/bin/env python3
"""Pin the final qualified Phase192 evidence; execute no compiler products."""
import argparse
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase192'
def pin(file):
 file=Path(file);data=file.read_bytes()
 return dict(file=str(file.relative_to(ROOT)),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert not a.out.exists(),'Fresh evidence file required'
names=['source-check01','controls01','controls02','recursive-controls05','recursive-workers03',
 'scoped-reentry02','selected-api01','selected-build01','native-image01','native-self01',
 'native-reproduction01','native64-01','runtime10-01','native45-01','native45-02',
 'hosted-native-compare01','native-generations-compare01','runtime-combined01','profile02']
reports={}
for name in names:
 path=BUILD/name/'report.json';value=json.loads(path.read_text())
 assert value.get('complete') is True and not value.get('error') and not value.get('changedInputs'),name
 if name in ['native64-01','runtime10-01']:assert value.get('passed') is True,name
 reports[name]=pin(path)
for name in ['native-self01','native-reproduction01']:
 value=json.loads((BUILD/name/'report.json').read_text())
 assert value.get('complete') is True
assert (BUILD/'native-self01/program.o').read_bytes()==(BUILD/'native-reproduction01/program.o').read_bytes(),'N2/N3 object differs'
execution=json.loads((BUILD/'qualification-execution01.json').read_text())
assert execution['complete'] and all(x['complete'] and x['returncode']==0 for x in execution['steps'])
files=['selected-source01/compiler.bend','selected-source01/source-map.json','native-self01/program',
 'native-self01/program.o','runtime-summary01.json','family-summary01.json','region-coverage01.json',
 'selection01.json','qualification-execution01.json','profile-analysis02/report.json',
 'profile-analysis02/comparison.json','profile-analysis02/contrast.json','maintained-identity01.json']
result=dict(kind='phase192-qualified-evidence',version=1,complete=True,
 baselineCommit='aa7cfa4',selectedSourceCommit='21918bf',installedSelectionChanged=False,
 method=pin(__file__),reports=reports,artifacts={name:pin(BUILD/name) for name in files},
 qualification='Independent source checking; finite controls and all45 oracles; exact B1/N1 and N1/N2 products; N2/N3 object fixed point; native64/runtime10. No whole-compiler theorem.',
 profileBoundary='Individual captures remain below500 samples; all six exact-workload pooled comparisons admitted, unknown PCs retained. Python metadata recomputation is not an independent Bend proof.',
 scope='Program-runtime gains transfer through exact objects/linked sections. Generated-program speed, compiler execution and research productivity remain distinct; no installed promotion or recursive-acceleration claim.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,reports=len(reports),out=str(a.out))))
