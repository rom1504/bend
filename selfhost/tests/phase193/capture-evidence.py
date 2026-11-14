#!/usr/bin/env python3
"""Pin the final qualified Phase193 evidence; execute no compiler products."""
import argparse
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase193'
def pin(file):
 file=Path(file);data=file.read_bytes()
 return dict(file=str(file.relative_to(ROOT)),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert not a.out.exists(),'Fresh evidence file required'
names=['source-check01','ready-controls03','candidate-api02','dev-build01',
 'native-image01','native-self01','native-reproduction01','native64-01','runtime10-01',
 'native45-01','native45-02','hosted-native-products01','native-generations-compare01',
 'runtime-combined01','compiler-profile01','compiler-hot-timing01','compiler-cost-n1-01','compiler-cost-n2-01']
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
comparison=json.loads((BUILD/'native-generations-compare01/report.json').read_text())
assert comparison['objectsIdentical']==45 and comparison['linkedSectionsIdentical']==135
repro=json.loads((BUILD/'native-reproduction01/report.json').read_text())
assert repro['comparedToReference'] is True
source=json.loads((BUILD/'source-check01/report.json').read_text())
assert source['checked'] and source['unresolvedHoles']==0
files=['selected-source01/compiler.bend','selected-source01/source-map.json','native-self01/program',
 'native-self01/program.o','assets.json','profile-source-audit02/report.json',
 'compiler-profile01/findings.json','compiler-profile01/independent-output.json']
result=dict(kind='phase193-qualified-evidence',version=1,complete=True,
 baselineCommit='dc413be',designCommit='f31d219',installedSelectionChanged=False,
 method=pin(__file__),reports=reports,artifacts={name:pin(BUILD/name) for name in files},
 qualification='Independent source checking; finite controls and all45 oracles; exact four-case B1/N1 and45-case N1/N2 products; N2/N3 object fixed point; native64/runtime10. No whole-compiler theorem.',
 profileBoundary='Same-source request profile pools two periods; clean timings and sampling overhead remain separate, unknown PCs retained. Extracted compiler kernel timing is not whole-compiler throughput.',
 scope='Program-runtime gains transfer through exact objects/linked sections. Generated-program speed, compiler execution and research productivity remain distinct; no installed promotion or recursive-acceleration claim.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,reports=len(reports),out=str(a.out))))
