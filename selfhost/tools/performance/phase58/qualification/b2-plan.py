#!/usr/bin/env python3
"""Write bounded, serial B2 qualification commands only; execute no targets."""
import argparse
import hashlib
import json
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--image-pins',type=Path,required=True)
p.add_argument('--out-base',type=Path,required=True)
p.add_argument('--plan-file',type=Path,required=True)
a=p.parse_args()
here=Path(__file__).resolve().parent
root=here.parents[4]
tools=root/'selfhost/tools/performance'
out=a.out_base.resolve()
assert out.is_relative_to(root/'selfhost/build/phase58') and not out.exists()
assert not a.plan_file.exists()
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
emission=a.image_pins.resolve(strict=True)
inputs={}
def pin(file):
    file=Path(file).resolve(strict=True)
    row=dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if str(file) in inputs:assert inputs[str(file)]==row
    inputs[str(file)]=row
    return row
for file in [__file__,node,emission,here/'acquire.mjs',here/'image-provenance.mjs',
             here/'b2-methods-derivation.json',here.parent/'bootstrap/setup.mjs',tools/'phase32/bounded-run.py']:
    pin(file)
origin=json.loads(emission.read_text());assert origin['kind']=='phase56-direct-image-pins'
for key in ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference']:assert pin(origin[key]['file'])==origin[key]
for key in ['emission','comparison']:
    evidence=json.loads(Path(origin[key]['file']).read_text());assert evidence['complete'] and evidence['pass']
pin(tools/'phase56/qualification/plan-v2.py')
commands=[]
def bounded(name,script,args,seconds):
    pin(script)
    commands.append(dict(name=name,guard='one outer ExecutionGuard; parent unpinned',
        command=list(map(str,['python3','-B',tools/'phase32/bounded-run.py','--seconds',seconds,
            '--rss-mib',2048,'--available-mib',4096,out/(name+'-supervisor'),'--','taskset','-c',3,
            node,'--max-old-space-size=1024','--stack-size=4096',script,*args]))))

groups=[
 ('composition','phase53/semantic-composition-catalog-v8.json','phase53/semantic-composition-reference-rebind01.json',60,18),
 ('overapplication','phase53/semantic-overapplication-catalog-v1.json','phase53/semantic-overapplication-upstream01/manifest.json',60,2),
 ('source','phase52/semantic-catalog-v8.json','phase55/semantic-final-host02/source-join.json',110,96),
 ('numeric','phase53/semantic-numeric-catalog-v3.json','phase53/semantic-numeric-reference-rebind01.json',60,34)]
for name,catalog_name,reference_name,seconds,count in groups:
    catalog=tools/catalog_name;reference=root/'selfhost/build'/reference_name
    pin(catalog);pin(reference)
    acquisition=out/(name+'-acquisition')
    bounded('acquire-'+name,here/'acquire.mjs',[emission,catalog,reference,acquisition],300)
    args=[acquisition/'manifest.json',reference,out/(name+'-controls')]
    if name=='source':args=[acquisition/'manifest.json',out/'source-controls']
    if name=='numeric':args.insert(0,out/'source-acquisition/manifest.json')
    bounded(name+'-controls',here/(name+'-controls.mjs'),args,seconds)
    commands[-1]['requiredCandidateObservations']=count
for row in list(inputs.values()):assert pin(row['file'])==row
plan=dict(kind='phase56-b2-semantic-launch-plan',executed=False,cwd=str(root),outBase=str(out),
    producer=pin(__file__),imagePins=pin(emission),image=origin['b2'],commands=commands,inputs=list(inputs.values()),
    resources=dict(cpu=3,heapMiB=1024,treeRssMiB=2048,availableMiB=4096,stackKiB=4096,serial=True),
    scope='Eight serial jobs: fresh B2 checked emissions and unchanged independent semantic oracles. Source96/numeric34/composition18/overapplication2 overlap. TS known defects remain explicit. No compiler bootstrap check or runtime benchmark is inferred; fresh own-source check is a separate gate.')
a.plan_file.parent.mkdir(parents=True,exist_ok=True)
with a.plan_file.open('x') as f:json.dump(plan,f,indent=2);f.write('\n')
print(json.dumps(dict(executed=False,commands=len(commands),plan=pin(a.plan_file))))
