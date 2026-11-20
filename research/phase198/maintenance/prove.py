#!/usr/bin/env python3
"""Isolated exact-byte reconstruction of an x86-only maintained policy block."""
import argparse, bisect, hashlib, importlib.util, json, shutil, sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def load(path,name):
 spec=importlib.util.spec_from_file_location(name,path); module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
def identity(data):return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def pin(path):return dict(file=str(path.resolve()),**identity(path.read_bytes()))
def map_bytes(value):return (json.dumps(value,indent=2)+'\n').encode()
def check_maps(data,mapping,root):
 cache={};generated_newlines=[i for i,b in enumerate(data) if b==10]
 for row in mapping:
  if row['file'] not in cache:
   source=(root/row['file']).read_bytes()
   cache[row['file']]=(source,[i for i,b in enumerate(source) if b==10])
  source,newlines=cache[row['file']]
  assert source[row['sourceStartByte']:row['sourceStartByte']+row['spanBytes']]==data[row['generatedStartByte']:row['generatedStartByte']+row['spanBytes']],row
  assert bisect.bisect_left(newlines,row['sourceByte'])+1==row['sourceLine'],row
  assert bisect.bisect_left(generated_newlines,row['generatedByte'])+1==row['generatedLine'],row
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline',type=Path,default=ROOT/'selfhost/build/phase198/selected-source01/maintained')
p.add_argument('--stage',type=Path,default=ROOT/'selfhost/build/phase198/portfolio03/maintained')
p.add_argument('--out',type=Path,required=True)
a=p.parse_args(); old=load(ROOT/'selfhost/tools/build/source.py','original_source'); new=load(HERE/'source-proposed.py','proposed_source')
assert not a.out.exists(),'Fresh output required'
base=json.loads((a.baseline/'src/compiler.json').read_text()); staged=json.loads((a.stage/'src/compiler.json').read_text())
owner=Path('src/back/qbe/construction-elimination.bend'); target='p121f_selected'
basebody=(a.baseline/owner).read_bytes(); stagebody=(a.stage/owner).read_bytes()
_,before=old.blocks(basebody);_,after=old.blocks(stagebody)
before_by={(x['kind'],x['name']):x for x in before}
added={(x['kind'],x['name']) for x in after}-before_by.keys()
assert added and all(x['name'].startswith(('p198e_','P198E')) for x in after if (x['kind'],x['name']) in added)
indices=[i for i,x in enumerate(after) if (x['kind'],x['name']) in added or x['name']==target]
assert indices==list(range(min(indices),max(indices)+1)),'Scoped block must be contiguous'
span=b''.join(after[i]['data'] for i in indices)
original=before_by[('def',target)]['data']
assert b''.join(original if i==indices[0] else b'' if i in indices else x['data'] for i,x in enumerate(after))==basebody,'Other shared-module changes'
# Copy final x86-only edits, then restore the original shared body/inventory.
shutil.copytree(a.stage,a.out/'maintained')
maintained=a.out/'maintained';(maintained/owner).write_bytes(basebody)
block=Path('src/back/x86/semantic-policy.bend');(maintained/block).write_bytes(span)
config=json.loads(json.dumps(base));config['profiles']['x86']=json.loads(json.dumps(staged['profiles']['x86']))
config['profiles']['x86']['policyBlock']={'replace':target,'module':str(block)}
(maintained/'src/compiler.json').write_text(json.dumps(config,indent=2)+'\n')
assert config['protectedDeclarations']==base['protectedDeclarations']==staged['protectedDeclarations']
expected,expected_map=old.maintained_assemble(a.stage/'src/compiler.json',a.stage,'x86',True)
assert expected==(a.stage.parent/'compiler.bend').read_bytes(),'Stage source pin does not match its maintained tree'
profiles=[]
for profile in base['profiles']:
 baseline_data,baseline_map=old.maintained_assemble(a.baseline/'src/compiler.json',a.baseline,profile,True)
 actual,actual_map=new.maintained_assemble(maintained/'src/compiler.json',maintained,profile,True)
 check_maps(actual,actual_map,maintained)
 if profile=='x86':
  assert actual==expected,'x86 staged source differs'
  (a.out/'compiler.bend').write_bytes(actual);(a.out/'map.json').write_bytes(map_bytes(actual_map))
 else:
  assert actual==baseline_data,(profile,'changed bytes')
  assert actual_map==baseline_map,(profile,'changed map')
 profiles.append(dict(profile=profile,bytesIdenticalToBaseline=actual==baseline_data,mapsIdenticalToBaseline=actual_map==baseline_map,source=identity(actual),map=identity(map_bytes(actual_map)),mapEntries=len(actual_map)))
# Shadow/guard logic must never change canonical protection identities.
report={'kind':'phase198-x86-policy-maintenance-proof','complete':True,'targetsRun':False,'stage':pin(a.stage.parent/'compiler.bend'),'baselineManifest':pin(a.baseline/'src/compiler.json'),'stageManifest':pin(a.stage/'src/compiler.json'),'tool':pin(HERE/'source-proposed.py'),'patch':pin(HERE/'source-policy.patch'),'policy':pin(maintained/block),'replacement':target,'newDeclarations':len(added),'protectedDeclarationsUnchanged':True,'exactStagedX86Bytes':True,'allSourceMapSpansVerified':True,'profiles':profiles,'scope':'Byte transport and map regression only; stage checking/qualification belongs to separately pinned receipts.'}
(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'report':str(a.out/'report.json'),'exactStagedX86Bytes':True,'unchangedOtherProfiles':len(profiles)-1,'newDeclarations':len(added)}))
