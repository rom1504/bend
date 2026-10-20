#!/usr/bin/env python3
"""Compose exact optional scalar-operand renderer onto frozen final source."""
import argparse,hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
DECL=re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b',re.M)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def check(row):
 if pin(row['file'])!=row:raise ValueError('Changed frozen input: '+row['file'])
def blocks(source):
 hits=list(DECL.finditer(source));out={}
 for i,m in enumerate(hits):
  k=(m[1],m[2]);assert k not in out
  out[k]=source[m.start():hits[i+1].start() if i+1<len(hits) else len(source)]
 return out
def normalized(s):return '\n'.join(x.rstrip() for x in s.splitlines() if x.strip() and not x.lstrip().startswith('#'))
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True);args=ap.parse_args()
 out=args.out.resolve()
 if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase114'):raise ValueError('Fresh Phase114 output required')
 inventory=HERE/'modules01.json';m=json.loads(inventory.read_text())
 if m['overrides']!=['p113e_private']:raise ValueError('Only private renderer override allowed')
 for row in [m['base'],m['baseAdmission'],m['baseApi'],m['runtimeSource'],m['runtimeObject'],*m['modules']]:check(row)
 admission=json.loads(Path(m['baseAdmission']['file']).read_text())
 if not admission.get('complete') or not admission.get('admitted') or admission['compiler']!=m['base']:raise ValueError('Qualified parent source admission required')
 source=Path(m['base']['file']).read_text();before=blocks(source);actual=dict(before);edits=[]
 for row in m['modules']:
  for key,body in blocks(Path(row['file']).read_text()).items():
   if key in before:
    if key!=('def','p113e_private'):raise ValueError('Unexpected override '+key[1])
   elif not key[1].startswith(('p114so_','P114SO')):raise ValueError('Unexpected new declaration '+key[1])
   if any(x['name']==key[1] for x in edits):raise ValueError('Duplicate module declaration')
   actual[key]=body;edits.append(dict(kind=key[0],name=key[1],action='replace' if key in before else 'append'))
 fallback=actual['def','p114so_private_original'].replace('def p114so_private_original(','def p113e_private(',1)
 if normalized(fallback)!=normalized(before['def','p113e_private']):raise ValueError('Changed original fallback')
 for key,body in before.items():
  if key!=('def','p113e_private') and normalized(actual[key])!=normalized(body):raise ValueError('Changed parent declaration')
 prefix=source[:DECL.search(source).start()]
 if prefix.splitlines()[0]!='import Base':raise ValueError('Expected exact parent Base prelude')
 composed=prefix+'\n\n'.join(body.rstrip() for body in actual.values())+'\n'
 if composed[:DECL.search(composed).start()]!=prefix:raise ValueError('Changed parent prelude')
 out.mkdir(parents=True);(out/'modules').mkdir();snapshots=[]
 for i,row in enumerate(m['modules']):
  path=out/'modules'/f'{i:02d}-{Path(row["file"]).name}';path.write_bytes(Path(row['file']).read_bytes());snapshots.append(dict(original=row,snapshot=pin(path)))
 (out/'compiler.bend').write_text(composed);(out/'method.py').write_bytes(Path(__file__).read_bytes())
 report=dict(kind='phase114-scalar-operands-source-composition',prepared=True,checked=False,targetsRun=False,source=pin(out/'compiler.bend'),baseline=m['base'],inventory=pin(inventory),moduleSnapshots=snapshots,edits=edits,overrides=m['overrides'],inputs=[pin(Path(__file__)),pin(inventory),m['base'],m['baseAdmission'],m['baseApi'],m['runtimeSource'],m['runtimeObject'],*m['modules']],scope='Exact source composition only. Original IR/verifier and every other selected parent declaration unchanged; no compiler/native qualification inferred.')
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(source=report['source'],declarations=len(actual),overrides=m['overrides'])))
if __name__=='__main__':main()
