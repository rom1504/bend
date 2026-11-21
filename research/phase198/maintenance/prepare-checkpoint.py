#!/usr/bin/env python3
"""Freeze a checked portfolio into a compact source-only maintenance replay.

No target execution, installation, inference of generation, or native qualification.
The caller supplies the exact agreed source hash and complete source-check receipt.
"""
import argparse,difflib,gzip,hashlib,json,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def identity(data):return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def pin(path):return dict(file=str(path.resolve().relative_to(ROOT)),**identity(path.read_bytes()))
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline',type=Path,required=True)
p.add_argument('--stage',type=Path,required=True,help='Frozen maintained directory with adjacent compiler.bend')
p.add_argument('--source-check',type=Path,required=True)
p.add_argument('--audit',type=Path,required=True)
p.add_argument('--sha256',required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();a.out=a.out.resolve();assert a.out.is_relative_to(HERE) and not a.out.exists(),'Fresh maintenance checkpoint directory required'
source=identity((a.stage.parent/'compiler.bend').read_bytes());assert source['sha256']==a.sha256
check=json.loads(a.source_check.read_text());audit=json.loads(a.audit.read_text())
assert all(check.get(k) is True for k in ('complete','checked','typeAccepted')) and check.get('unresolvedHoles')==0 and not check.get('changedInputs')
assert check['kind']=='bend-independent-source-check' and audit['complete']
for record in [check['source'],audit['selectedSource']]:assert {k:record[k] for k in ('bytes','sha256')}==source
original=json.loads((HERE/'replay.json').read_text())
# The unchanged baseline archive must own this exact maintained input tree.
import tarfile
archive=ROOT/original['baselineArchive']['file'];assert identity(archive.read_bytes())=={k:original['baselineArchive'][k] for k in ('bytes','sha256')}
prefix=original['baselinePrefix']+'maintained/'
with tarfile.open(archive,'r:gz') as bundle:
 members={x.name[len(prefix):]:x for x in bundle.getmembers() if x.name.startswith(prefix)}
 files={str(x.relative_to(a.baseline)):x for x in a.baseline.rglob('*') if x.is_file()}
 assert members.keys()==files.keys()
 for name,member in members.items():assert member.isfile() and bundle.extractfile(member).read()==files[name].read_bytes(),name
a.out.mkdir(parents=True)
subprocess.run([sys.executable,'-B',str(HERE/'make-tool.py')],check=True)
subprocess.run([sys.executable,'-B',str(HERE/'prove.py'),'--baseline',str(a.baseline.resolve()),'--stage',str(a.stage.resolve()),'--out',str(a.out/'validation')],check=True)
proof=json.loads((a.out/'validation/report.json').read_text());diff='';changed=[]
for file in sorted(a.stage.rglob('*')):
 if not file.is_file():continue
 relative=file.relative_to(a.stage);prior=a.baseline/relative
 before=prior.read_bytes() if prior.exists() else b'';after=file.read_bytes()
 if prior.exists() and before==after:continue
 diff+=''.join(difflib.unified_diff(before.decode().splitlines(True),after.decode().splitlines(True),fromfile='a/'+str(relative) if prior.exists() else '/dev/null',tofile='b/'+str(relative)))
 changed.append(dict(file=str(relative),before=identity(before) if prior.exists() else None,after=identity(after)))
assert all((a.stage/x.relative_to(a.baseline)).exists() for x in a.baseline.rglob('*') if x.is_file()),'File removals require a new explicit recipe'
patch=a.out/'portfolio.patch.gz';patch.write_bytes(gzip.compress(diff.encode(),mtime=0))
evidence=a.out/'source-evidence.json.gz';evidence.write_bytes(gzip.compress((json.dumps(dict(composition=audit,sourceCheck=check),indent=2)+'\n').encode(),mtime=0))
recipe=dict(original,portfolioPatch=pin(patch),portfolioEvidence=pin(evidence),changedStageFiles=changed,expectedSource=source,expectedMap=identity((a.out/'validation/map.json').read_bytes()),profiles=proof['profiles'])
(a.out/'replay.json').write_text(json.dumps(recipe,indent=2)+'\n')
summary=dict(kind='phase198-checked-candidate-source-checkpoint',complete=True,installed=False,nativeQualificationClaim=False,targetsRun=False,selectedSource=source,sourceCheck=pin(a.source_check),audit=pin(a.audit),replay=pin(a.out/'replay.json'),exactStagedX86Bytes=True,unchangedOtherProfiles=5,allSourceMapSpansVerified=True,protectedDeclarationsUnchanged=True)
(a.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary))
