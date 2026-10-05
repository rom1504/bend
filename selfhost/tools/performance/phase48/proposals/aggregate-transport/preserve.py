#!/usr/bin/env python3
"""Original data-only proposal capture, with exact sequential patch reconstruction."""
import difflib
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[5]
RAW=ROOT/'selfhost/build/phase48'
BASE=ROOT/'selfhost/build/phase47/source-array06'
NAMES={'compiler.json':'src/compiler.json','jpure.bend':'src/back/js/jpure.bend',
       **{n:'src/back/js/ir/'+n for n in ['worker-model.bend','worker-values.bend','worker-emit.bend','worker-graph.bend','worker-nat.bend']}}

def identity(p):
    b=p.read_bytes();return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def put(name,data):
    p=HERE/name;p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('xb') as f:f.write(data)

def patch_one(name,left,right):
    return ''.join(difflib.unified_diff(left.splitlines(True),right.splitlines(True),
        fromfile='a/selfhost/'+name,tofile='b/selfhost/'+name))

def check_one(left,delta):
    # Independent application of generated unified hunks, including new-file hunks.
    if not delta:return left
    old=left.splitlines(True);lines=delta.splitlines(True);out=[];cursor=0;i=2
    while i<len(lines):
        m=re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',lines[i]);assert m,lines[i]
        at=max(0,int(m[1])-1);out.extend(old[cursor:at]);cursor=at;i+=1
        while i<len(lines) and not lines[i].startswith('@@'):
            line=lines[i];i+=1
            assert line[0] in ' +-'
            if line[0] in ' -':assert old[cursor]==line[1:];cursor+=1
            if line[0] in ' +':out.append(line[1:])
    out.extend(old[cursor:]);return ''.join(out)

inputs=[identity(Path(__file__)),identity(HERE/'materialize.py')]
states={'baseline':{}}
for name,relative in NAMES.items():
    src=BASE/relative
    states['baseline'][relative]=src.read_text() if src.exists() else ''
    if src.exists():inputs.append(identity(src))
for variant in ['scalar01','scalar02','scalar03','vector01']:
    directory=RAW/('integration-values-vector01' if variant=='vector01' else 'integration-values'+variant[-2:])
    states[variant]={}
    for name,relative in NAMES.items():
        src=directory/name;inputs.append(identity(src));states[variant][relative]=src.read_text()
    inputs.append(identity(directory/'receipt.json'))
for variant in ['scalar03','vector01']:
    for relative,data in states[variant].items():
        if variant=='scalar03' or data!=states['scalar03'][relative]:
            put('payloads/'+variant+'/'+relative,data.encode())
steps=[('baseline','scalar01','baseline-to-scalar01-failed'),
       ('scalar01','scalar02','scalar01-to-scalar02-terminal-case'),
       ('scalar02','scalar03','scalar02-to-scalar03-clear'),
       ('scalar03','vector01','scalar03-to-vector01'),
       ('baseline','scalar03','baseline-to-scalar03'),
       ('baseline','vector01','baseline-to-vector01')]
proofs=[]
for left,right,label in steps:
    patches=[]
    for relative in NAMES.values():
        delta=patch_one(relative,states[left][relative],states[right][relative])
        assert check_one(states[left][relative],delta)==states[right][relative]
        patches.append(delta)
    put('patches/'+label+'.patch',''.join(patches).encode())
    proofs.append(dict(parent=left,result=right,patch='patches/'+label+'.patch',exactReconstruction=True))
assert all(identity(Path(x['path']))==x for x in inputs)
files=[dict(path=str(p.relative_to(HERE)),**{k:v for k,v in identity(p).items() if k!='path'})
       for p in sorted(HERE.rglob('*')) if p.is_file()]
manifest=dict(kind='phase48-deferred-aggregate-proposals',status='unselected',targetExecuted=False,
    baseline=dict(commit='ee54723f87db81cce64b9f762fdd116805068c8a',
        upstreamCommit='018751270e800bc222a93dad7f257083ee53a5f7',
        apiSha256='28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f',
        runtimeSha256='880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'),
    inputs=inputs,files=files,patchReconstruction=proofs,
    history='scalar01 preserves the failed nonterminal-Case version; scalar02 adds whole-graph structural refusal; scalar03 clears return registers after capture; vector01 replaces physical result transport only. Neither final convention is selected.')
with (HERE/'manifest.json').open('x') as f:json.dump(manifest,f,indent=2);f.write('\n')
print(json.dumps(dict(files=len(files),patches=len(proofs),manifest=identity(HERE/'manifest.json'))))
