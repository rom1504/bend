#!/usr/bin/env python3
"""Small artifact-admission checks; no compiler or native target is executed."""
import copy, json, sys
from pathlib import Path
from native_support import ROOT, DEFAULT_CACHE, authenticate, pin

out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
image=ROOT/'selfhost/build/phase88/compiler-native02'
canonical=json.loads(DEFAULT_CACHE.read_text());rows=[]
auth=authenticate(image,DEFAULT_CACHE)
rows.append(dict(name='canonical',accepted=True))
def refuse(name,receipt,consumer=image):
    file=out/(name+'.json');file.write_text(json.dumps(receipt,indent=2)+'\n')
    try:authenticate(consumer,file)
    except (ValueError,KeyError,TypeError,OSError) as error:
        rows.append(dict(name=name,accepted=False,error=str(error)));return
    raise AssertionError('admitted '+name)
r=copy.deepcopy(canonical);r['stamp']+='!';refuse('stamp',r)
r=copy.deepcopy(canonical);r['stampBinding']['spanAbi']=2;refuse('stamp-abi',r)
r=copy.deepcopy(canonical);r['cacheHeader']['termAbi']=2;refuse('header-abi',r)
r=copy.deepcopy(canonical);r['cacheHeader']['validatedBy']='caller';refuse('producer',r)
r=copy.deepcopy(canonical);r['cacheHeader']['sourcePath']='/different/base.bend';refuse('header-path',r)
changed=out/'changed.p88';changed.write_bytes(Path(canonical['carrier']['file']).read_bytes()+b'\n')
r=copy.deepcopy(canonical);r['carrier']=pin(changed);refuse('self-declared-carrier-hash',r)
base=out/'base.bend';base.write_bytes(Path(canonical['inputPins']['base']['file']).read_bytes())
r=copy.deepcopy(canonical);r['inputPins']['base']=pin(base);refuse('same-bytes-different-base-path',r)
r=copy.deepcopy(canonical);r['inputPins']['api']['sha256']='0'*64;refuse('api',r)
refuse('unqualified-consumer',canonical,ROOT/'selfhost/build/phase88/compiler-native01')
assert authenticate(image,DEFAULT_CACHE)==auth
(out/'report.json').write_text(json.dumps(dict(complete=True,passed=True,method=pin(__file__),rows=rows),indent=2)+'\n')
print(json.dumps(dict(passed=True,cases=len(rows))))
