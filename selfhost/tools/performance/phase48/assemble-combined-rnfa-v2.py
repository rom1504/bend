#!/usr/bin/env python3
"""Prepare only a frozen RNFA source composition; never execute a target."""
from pathlib import Path
import difflib, hashlib, json, shutil, subprocess, sys
ROOT=Path(__file__).resolve().parents[4]
RAW=ROOT/'selfhost/build/phase48'
BASE=ROOT/'selfhost/build/phase47/checked-array06'
WORK=RAW/'integration-rnfa02'
OUT=RAW/'source-combined-rnfa02'
CONFIG=RAW/'combined-rnfa02-config.json'
VARIANTS=['composite01','native01','float01','arrays03']
def identity(p):
 p=p.resolve(strict=True)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
assert not WORK.exists() and not OUT.exists() and not CONFIG.exists()
WORK.mkdir()
merged=WORK/'merged'
shutil.copytree(BASE/'snapshot/src',merged/'src')
inputs=[identity(Path(__file__)),identity(BASE/'attempt.json')]
logs=[]
for name in VARIANTS:
 variant=RAW/('source-'+name)
 inputs.append(identity(variant/'snapshot-receipt.json'))
 for p in sorted((variant/'src').rglob('*')):
  if not p.is_file():continue
  rel=p.relative_to(variant)
  b=BASE/'snapshot'/rel
  if b.exists() and b.read_bytes()==p.read_bytes():continue
  inputs.append(identity(p))
  if rel.as_posix()=='src/compiler.json':continue
  target=merged/rel
  if not b.exists():
   assert not target.exists()
   target.parent.mkdir(parents=True,exist_ok=True)
   shutil.copyfile(p,target)
  else:
   diff=''.join(difflib.unified_diff(b.read_text().splitlines(True),p.read_text().splitlines(True),fromfile='a/'+str(rel),tofile='b/'+str(rel)))
   patchfile=WORK/(name+'-'+str(rel).replace('/','_')+'.patch')
   patchfile.write_text(diff)
   run=subprocess.run(['patch','--no-backup-if-mismatch','--batch','--forward','--fuzz=0','-p1','-d',str(merged)],input=diff,text=True,capture_output=True)
   logs.append(dict(variant=name,file=str(rel),stdout=run.stdout,stderr=run.stderr,exitCode=run.returncode))
   assert run.returncode==0,(name,rel,run.stdout,run.stderr)
 # Each reviewed snapshot's tool/test trees must equal the frozen foundation.
 for top in ['tools','tests']:
  for p in (variant/top).rglob('*'):
   if p.is_file():assert p.read_bytes()==(BASE/'snapshot'/p.relative_to(variant)).read_bytes(),p
config=json.loads((BASE/'snapshot/src/compiler.json').read_text())
for name in VARIANTS:
 modules=json.loads((RAW/('source-'+name)/'src/compiler.json').read_text())['modules']
 for i,module in enumerate(modules):
  if module not in config['modules']:
   previous=modules[i-1]
   assert previous in config['modules']
   config['modules'].insert(config['modules'].index(previous)+1,module)
assert len(config['modules'])==len(set(config['modules']))
(merged/'src/compiler.json').write_text(json.dumps(config,indent=2)+'\n')
composition=ROOT/'experiments/phase48/patches/private-float-array-composition-v1.patch'
inputs.append(identity(composition))
run=subprocess.run(['patch','--no-backup-if-mismatch','--batch','--forward','--fuzz=0','-p2','-d',str(merged)],input=composition.read_text(),text=True,capture_output=True)
logs.append(dict(variant='JF32-array-composition',stdout=run.stdout,stderr=run.stderr,exitCode=run.returncode))
assert run.returncode==0,(run.stdout,run.stderr)
changed=[]
for p in sorted((merged/'src').rglob('*')):
 if p.is_file():
  rel=p.relative_to(merged);b=BASE/'snapshot'/rel
  if not b.exists() or b.read_bytes()!=p.read_bytes():changed.append((rel,p))
command=[sys.executable,str(ROOT/'selfhost/tools/performance/phase48/snapshot-candidate.py'),'--baseline-attempt',str(BASE),'--out',str(OUT),'--config',str(CONFIG)]
for rel,p in changed:command.extend(['--overlay',str(rel)+'='+str(p)])
run=subprocess.run(command,text=True,capture_output=True)
assert run.returncode==0,(run.stdout,run.stderr)
for row in inputs:assert identity(Path(row['file']))==row
receipt=dict(kind='phase48-rnfa-source-composition',complete=True,targetExecuted=False,variants=VARIANTS,excluded=['V','H'],inputs=inputs,patchApplications=logs,outputs=[dict(target=str(rel),identity=identity(OUT/rel),baseline=None if not (BASE/'snapshot'/rel).exists() else identity(BASE/'snapshot'/rel)) for rel,p in changed],snapshotReceipt=identity(OUT/'snapshot-receipt.json'),config=identity(CONFIG))
(WORK/'composition-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(project=str(OUT),config=str(CONFIG),changedFiles=len(changed),compositionReceipt=identity(WORK/'composition-receipt.json')),indent=2))
