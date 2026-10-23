"""Freeze exact original/single-loop lookup source proxies; no target execution."""
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
PAT=re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)


def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def declarations(text):
    hits=list(PAT.finditer(text));out={}
    for i,h in enumerate(hits):
        out[h[1]]=out.get(h[1],'')+text[h.start():hits[i+1].start() if i+1<len(hits) else len(text)]
    return out


def replace(text,extras,expected):
    hits=list(PAT.finditer(text));present={h[1] for h in hits}
    assert set(extras)&present==set(expected)
    out=[text[:hits[0].start()]]
    for i,h in enumerate(hits):
        old=text[h.start():hits[i+1].start() if i+1<len(hits) else len(text)]
        out.append(extras.get(h[1],old))
    out.extend('\n'+body for name,body in extras.items() if name not in present)
    return ''.join(out)


def write(name,text):
    p=HERE/name
    if p.exists() and p.read_text()!=text:raise ValueError('Changed frozen output '+str(p))
    if not p.exists():p.write_text(text)
    return pin(p)


def main():
    base=HERE/'proxy-v02-baseline.bend'
    original=base.read_text()
    workload=HERE/'read-workload.bend';change=HERE/'read-loop-v01.bend'
    common=replace(original,declarations(workload.read_text()),['p131ip_execute'])
    next_source=replace(common,declarations(change.read_text()),['index_find'])
    expected=pin(HERE/'proxy-v02-expected.json')
    rows=[]
    for name,source in [('baseline',common),('candidate',next_source)]:
        p=write('read-proxy-'+name+'.bend',source)
        rows.append(dict(name='identity-read-'+name,source=p,expected=expected,expectedStdoutEvidence=expected))
    write('read-proxy-cases.json',json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
    write('read-proxy-manifest.json',json.dumps(dict(complete=True,targetsRun=False,
        inputs=[pin(Path(__file__)),pin(base),pin(workload),pin(change),pin(HERE/'proxy-v02-manifest.json'),expected,pin(HERE/'timing-oracle.py')],
        cases=rows,overrides=['index_find'],
        scope='Same constructed immutable index held across reads; exact256actual compiler names. Original selected lookup versus closed-self-loop lookup, compiled by same qualified compiler. Build/update/reclamation outside IO.now timing window, identical whole ordinary controls. No full compiler throughput claim.'),indent=2)+'\n')


if __name__=='__main__':main()
