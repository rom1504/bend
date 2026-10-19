#!/usr/bin/env python3
"""Authenticate paired QBE products and count syntax; never execute or lower code."""
import argparse, collections, hashlib, json, re
from pathlib import Path

def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def verify(row):
    if pin(row['file']) != row: raise ValueError('Changed input: '+row['file'])
def read(path): return json.loads(Path(path).read_text())
def source_pin(receipt):
    jobs=[j for j in receipt['jobs'] if j['label']=='native-request']
    if len(jobs)!=1 or jobs[0].get('exitCode')!=0: raise ValueError('Successful native request required')
    command=jobs[0]['command']
    if len(command)!=12 or command[6]!='phase111': raise ValueError('Unexpected native protocol')
    file=str(Path(command[7]).resolve())
    rows=[x for x in receipt['inputs'] if x['file']==file]
    if len(rows)!=1: raise ValueError('Source lacks exact input binding')
    verify(rows[0]);return rows[0]
def shape(product):
    verify(product); text=Path(product['file']).read_text()
    headers=re.findall(r'(?m)^(?:export )?function\s+\w+\s+\$([^ (]+)',text)
    return dict(bytes=product['bytes'],lines=text.count('\n'),functions=len(headers),
                privateWorkers=sum(x.startswith('p112w_') for x in headers),
                helperCallSites=dict(sorted(collections.Counter(re.findall(r'call \$p111_rt_(\w+)\(',text)).items())),
                localLoopLabels=len(re.findall(r'(?m)^@p112_again$',text)))
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--before',type=Path,required=True);p.add_argument('--after',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
if a.out.exists(): raise ValueError('fresh output required')
left,right=read(a.before),read(a.after)
if set(left)!=set(right): raise ValueError('Exact same requested case set required')
r=dict(kind='phase112-authenticated-qbe-syntax-comparison',complete=False,targetsRun=False,
       inputs=[pin(__file__),pin(a.before),pin(a.after)],cases=[],
       scope='Static whole-product syntax counts, including retained fallback and private workers. Not dynamic events, hot-code counts, machine instructions or speed predictions.')
for name in left:
    before,after=read(left[name]),read(right[name])
    if not before.get('complete') or not after.get('complete'): raise ValueError('Incomplete producer')
    source=source_pin(before)
    if source!=source_pin(after): raise ValueError('Different exact source: '+name)
    r['cases'].append(dict(name=name,source=source,beforeReceipt=pin(left[name]),afterReceipt=pin(right[name]),
                          beforeProduct=before['product'],afterProduct=after['product'],before=shape(before['product']),after=shape(after['product'])))
r['complete']=True
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(dict(complete=True,cases=len(r['cases']),targetsRun=False)))
