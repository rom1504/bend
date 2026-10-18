#!/usr/bin/env python3
"""Root-run checked synthetic wide-ABI API acquisition; an outer serial guard is required."""
import argparse,hashlib,json,os,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','admission','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--seconds',type=float,default=60)
a=p.parse_args();prepared=a.source.resolve();prepared=prepared if prepared.is_dir() else prepared.parent;source_manifest=prepared/'manifest.json';admission_file=a.admission.resolve();admission_file=admission_file/'manifest.json' if admission_file.is_dir() else admission_file;out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
source=json.loads(source_manifest.read_text());admission=json.loads(admission_file.read_text())
if source.get('kind')!='phase110-context-wide-source' or not source['complete']:raise ValueError('complete prepared context source required')
if admission.get('kind')!='phase110-context-call-admission' or not admission['complete'] or not all(row['ok'] for row in admission['controls']):raise ValueError('complete exact source/runtime admission required')
if not any(row==source['source'] for row in admission['inputs']):raise ValueError('admission belongs to another source')
upstream=ROOT/'selfhost/.bootstrap/upstream-phase66';bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun';stage0=ROOT/'selfhost/tools/stage0-library.mjs';source_path=verify(source['source'])
expected=[str(bun),str(stage0),str(source_path),str(prepared/'api.mjs'),*source['exports']]
if source['command']!=expected:raise ValueError('prepared API command is not the exact admitted stage0 command')
command=[*expected[:3],str(out/'api.mjs'),*expected[4:]]
inputs=[pin(Path(__file__)),pin(source_manifest),pin(admission_file),source['source'],*source['inputs'],*admission['inputs'],*admission['runtimeChain'],pin(bun),pin(stage0),*[pin(upstream/'bend2'/name) for name in ['bend.ts','comp.ts','base.bend']],pin(Path(sys.executable))]
for row in inputs:verify(row)
out.mkdir();record=dict(kind='phase110-checked-api',complete=False,source=source['source'],method=pin(Path(__file__)),admission=pin(admission_file),inputs=inputs,command=command,exports=source['exports'],environment=dict(BEND_UPSTREAM=str(upstream)))
save=lambda:(out/'report.json').write_text(json.dumps(record,indent=2)+'\n');save();start=time.monotonic();stdout=out/'build.stdout';stderr=out/'build.stderr'
try:
 env=dict(os.environ);env['BEND_UPSTREAM']=str(upstream)
 with stdout.open('xb') as so,stderr.open('xb') as se:child=subprocess.run(command,cwd=ROOT,env=env,stdout=so,stderr=se,timeout=a.seconds)
 record.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(stdout),stderr=pin(stderr));save()
 if child.returncode:raise RuntimeError('checked API build failed; see '+str(stderr))
 if not (out/'api.mjs').is_file():raise ValueError('successful checker omitted API artifact')
 for row in inputs:verify(row)
 record.update(complete=True,api=pin(out/'api.mjs'));save();print(json.dumps(dict(complete=True,api=record['api'],exports=len(source['exports']),seconds=record['seconds'])))
except BaseException as error:
 record.update(error=repr(error),seconds=time.monotonic()-start)
 if stdout.exists():record['stdout']=pin(stdout)
 if stderr.exists():record['stderr']=pin(stderr)
 save();raise
