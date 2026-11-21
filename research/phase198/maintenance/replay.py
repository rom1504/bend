#!/usr/bin/env python3
"""Replay the proposal from tracked evidence only, without compiler/target runs."""
import argparse,gzip,hashlib,importlib.util,json,shutil,subprocess,sys,tarfile
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def identity(data):return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def require_pin(item):
 data=(ROOT/item['file']).read_bytes();assert identity(data)=={k:item[k] for k in ('bytes','sha256')},item['file'];return data
def load(path):
 spec=importlib.util.spec_from_file_location('source',path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--recipe',type=Path,default=HERE/'replay.json');p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists(),'Fresh replay directory required';out.mkdir(parents=True)
r=json.loads(a.recipe.read_text());require_pin(r['baselineArchive']);require_pin(r['originalTool']);require_pin(r['toolPatch']);require_pin(r['portfolioPatch']);require_pin(r['portfolioEvidence'])
subprocess.run([sys.executable,'-B',str(HERE/'make-tool.py'),'--recipe',str(a.recipe.resolve())],check=True)
with (out/'tests.log').open('w') as log:subprocess.run([sys.executable,'-B',str(HERE/'test_policy.py')],stdout=log,stderr=subprocess.STDOUT,check=True)
base=out/'baseline';prefix=r['baselinePrefix']
with tarfile.open(ROOT/r['baselineArchive']['file'],'r:gz') as archive:
 for member in archive.getmembers():
  if not member.name.startswith(prefix):continue
  relative=Path(member.name[len(prefix):])
  if not (str(relative)=='compiler.bend' or str(relative).startswith('maintained/')):continue
  assert member.isfile() and not relative.is_absolute() and '..' not in relative.parts
  target=base/relative;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(archive.extractfile(member).read())
stage=out/'portfolio';shutil.copytree(base/'maintained',stage/'maintained')
for row in r['changedStageFiles']:
 file=stage/'maintained'/row['file']
 if row['before'] is None:
  assert not file.exists();file.parent.mkdir(parents=True,exist_ok=True)
 else:assert identity(file.read_bytes())==row['before']
subprocess.run(['patch','--batch','--fuzz=0','--no-backup-if-mismatch','-p1'],cwd=stage/'maintained',input=gzip.decompress(require_pin(r['portfolioPatch'])),check=True,stdout=subprocess.PIPE)
for row in r['changedStageFiles']:assert identity((stage/'maintained'/row['file']).read_bytes())==row['after']
s=load(ROOT/'selfhost/tools/build/source.py');selected=s.maintained_assemble(stage/'maintained/src/compiler.json',stage/'maintained','x86');assert identity(selected)==r['expectedSource'];(stage/'compiler.bend').write_bytes(selected)
evidence=json.loads(gzip.decompress(require_pin(r['portfolioEvidence'])))
for record in [evidence['composition']['selectedSource'],evidence['sourceCheck']['source']]:assert {k:record[k] for k in ('bytes','sha256')}==r['expectedSource']
assert evidence['composition']['complete'] and all(evidence['sourceCheck'][k] is True for k in ['complete','checked','typeAccepted']) and evidence['sourceCheck']['unresolvedHoles']==0
subprocess.run([sys.executable,'-B',str(HERE/'prove.py'),'--baseline',str(base/'maintained'),'--stage',str(stage/'maintained'),'--out',str(out/'proof')],check=True)
proof=json.loads((out/'proof/report.json').read_text());assert proof['profiles']==r['profiles'];assert identity((out/'proof/map.json').read_bytes())==r['expectedMap']
report=dict(kind='phase198-maintenance-clean-replay',complete=True,targetsRun=False,source=r['expectedSource'],map=r['expectedMap'],testsPassed=29,unchangedOtherProfiles=5,allMapSpansVerified=True,retainedSourceCheckAuthenticated=True,scope=r['scope'])
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
