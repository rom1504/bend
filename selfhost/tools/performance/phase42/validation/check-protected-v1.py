#!/usr/bin/env python3
"""Check exact103 protected input files and index; run only in root final queue."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('start',type=Path);p.add_argument('out',type=Path);a=p.parse_args();assert not a.out.exists();data=json.loads(a.start.read_text());rows=data.get('files',data.get('protectedPreexisting'));assert len(rows)==103 and len({r['path'] for r in rows})==103
 changed=[]
 for r in rows:
  f=ROOT/r['path']
  if not f.is_file() or ident(f)['sha256']!=r['sha256'] or f.stat().st_size!=r['bytes']:changed.append(r['path'])
 staged=subprocess.check_output(['git','diff','--cached','--name-only','-z'],cwd=ROOT).decode().split('\0');protectedStaged=sorted(set(staged)&{r['path'] for r in rows});result=dict(kind='phase42-protected-final',complete=not changed and not protectedStaged,checked=103,changed=changed,protectedStaged=protectedStaged,start=ident(a.start),producer=ident(__file__))
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));assert result['complete']
if __name__=='__main__':main()
