#!/usr/bin/env python3
"""Optional actual-request cold metadata seam on frozen certified composition."""
import argparse,hashlib,importlib.util,json,subprocess,sys
from pathlib import Path
from types import SimpleNamespace
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
PREVIOUS=Path(__file__).with_name('prepare-ordinary-composition.py')
def pin(path):
 path=Path(path).resolve();raw=path.read_bytes()
 return dict(file=str(path),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--cold-constructors',action='store_true')
 args,forwarded=parser.parse_known_args()
 previous=pin(PREVIOUS)
 assert previous['sha256']=='2459a3ea7e32d31110134559003db2c0636d8c86a5391bb2f6c930fec948cc2a'
 spec=importlib.util.spec_from_file_location('phase169_ordinary',PREVIOUS)
 old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
 invocations=[]
 def extract(command,*,cwd):
  assert not invocations
  original=list(command)
  if args.cold_constructors:
   for name in ('cold-emission','cold-emission-controls'):
    command+=['--module',str(ROOT/('selfhost/tests/phase169/'+name+'.bend'))]
   command+=['--export','p169c_controls']
  invocations.append(dict(original=original,extended=list(command)))
  return subprocess.call(command,cwd=cwd)
 old.subprocess=SimpleNamespace(call=extract)
 sys.argv=[str(PREVIOUS),*forwarded]
 result=old.main()
 if result==0:
  command=invocations[0]['extended'];out=Path(command[command.index('--out')+1]).resolve()
  derivation=out/'cold-emission-derivation.json'
  derivation.write_text(json.dumps(dict(targetsRun=False,productionChanged=False,
   enabled=args.cold_constructors,method=pin(__file__),previousMethod=previous,
   invocation=invocations[0]),indent=2)+'\n')
  path=out/'manifest.json';document=json.loads(path.read_text())
  document['inputs'] += [pin(__file__),pin(derivation)]
  path.write_text(json.dumps(document,indent=2)+'\n')
 assert pin(PREVIOUS)==previous
 return result
if __name__=='__main__':raise SystemExit(main())
