#!/usr/bin/env python3
"""Count existing QBE syntax; does not compile or transform programs."""
import argparse,collections,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--sources',type=Path,nargs='+',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
def pin(f):
 f=f.resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def name(s):
 for prefix in ['p111_FID_','p112w_FID_']:
  if s.startswith(prefix):
   try:return ''.join(chr(int(x)) for x in s[len(prefix):].split('_') if x)
   except ValueError:pass
 return s
rows=[]
for f in a.sources:
 text=f.read_text();functions=[]
 for m in re.finditer(r'(?m)^(?:export )?function [^$]*\$([^ (]+)\([^\n]*\) \{\n(.*?)^\}',text,re.S|re.M):
  symbol,body=m.groups();calls=collections.Counter(re.findall(r'call \$([A-Za-z0-9_]+)',body));functions.append(dict(symbol=symbol,name=name(symbol),lines=len(body.splitlines()),calls=dict(calls),loopEdges=body.count('jmp @p112_again')))
 calls=collections.Counter()
 for x in functions:calls.update(x['calls'])
 rows.append(dict(source=pin(f),functions=len(functions),privateWorkers=sum(x['symbol'].startswith('p112w_') for x in functions),loopEdges=sum(x['loopEdges'] for x in functions),callSites=dict(calls),largest=sorted(functions,key=lambda x:x['lines'],reverse=True)[:20]))
a.out.write_text(json.dumps(dict(kind='phase112-static-qbe-shapes',complete=True,method=pin(Path(__file__)),scope='Static call sites and instruction lines, not dynamic counts or runtime costs.',rows=rows),indent=2)+'\n')
