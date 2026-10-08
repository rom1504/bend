#!/usr/bin/env python3
"""Inspect emitted C only: worker references, scheduler isolation, and DAG depth."""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser=argparse.ArgumentParser()
parser.add_argument('source',type=Path)
parser.add_argument('--out',type=Path)
parser.add_argument('--require-workers',action='store_true')
args=parser.parse_args()
raw=args.source.read_bytes()
src=raw.decode()
workers={}
for match in re.finditer(r'^INLINE Term (NF_[A-Za-z0-9_]+)\([^\n]*\) \{',src,re.M):
    at=match.end(); start=at; depth=1; quoted=False; char=False
    while depth:
        c=src[at]
        if quoted or char:
            if c=='\\':at+=1
            elif quoted and c=='"':quoted=False
            elif char and c=="'":char=False
        elif c=='"':quoted=True
        elif c=="'":char=True
        elif c=='{':depth+=1
        elif c=='}':depth-=1
        at+=1
    body=src[start:at-1]
    workers[match[1]]={'line':src[:match.start()].count('\n')+1,
      'bodyBytes':len(body.encode()),'calls':sorted(set(re.findall(r'\b(NF_[A-Za-z0-9_]+)\(',body))),
      'schedulerTokens':sorted(set(re.findall(r'\bWL_[A-Za-z0-9_]+',body))),
      'heapAllocSites':body.count('heap_alloc('),
      'selfLoop':bool(re.search(r'goto nf_again;',body)),
      'unboundSentinel':'NATIVE_UNBOUND_VARIABLE' in body}
errors=[]
depths={}
def depth(name,active=()):
    if name not in workers:
        errors.append('worker call has no definition: '+name); return 0
    if name in active:
        errors.append('C worker recursion cycle: '+' -> '.join((*active,name))); return 0
    if name not in depths:
        depths[name]=1+max((depth(c,(*active,name)) for c in workers[name]['calls']),default=0)
    return depths[name]
for name,w in workers.items():
    if w['schedulerTokens']:errors.append(name+' uses scheduler tokens')
    if w['unboundSentinel']:errors.append(name+' contains an unbound variable')
    depth(name)
if args.require_workers and not workers:errors.append('no ordinary C workers emitted')
report={'kind':'phase68-emitted-worker-source-gate','source':str(args.source.resolve()),
  'sha256':hashlib.sha256(raw).hexdigest(),'workerCount':len(workers),
  'maxCallDagDepth':max(depths.values(),default=0),'workers':workers,'errors':errors,'pass':not errors,
  'scope':'Static C-source inspection only; no parser/compiler/program was executed.'}
encoded=json.dumps(report,indent=2)+'\n'
if args.out:
    if args.out.exists():raise SystemExit('refusing to replace existing receipt: '+str(args.out))
    args.out.write_text(encoded)
print(json.dumps({k:v for k,v in report.items() if k!='workers'}))
raise SystemExit(0 if report['pass'] else 1)
