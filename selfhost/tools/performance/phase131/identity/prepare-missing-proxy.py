"""Expose a closed sentinel to existing static preparation; never run targets."""
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
PAT=re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)

def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def write(name,text):
    p=HERE/name
    if p.exists() and p.read_text()!=text:raise ValueError('Changed frozen output '+str(p))
    if not p.exists():p.write_text(text)
    return pin(p)

def main():
    base=HERE/'read-proxy-candidate.bend';change=HERE/'missing-static-v01.bend'
    source=base.read_text();extra=change.read_text();replacement=extra[PAT.search(extra).start():]
    hits=list(PAT.finditer(source));out=[source[:hits[0].start()]];count=0
    for i,h in enumerate(hits):
        body=source[h.start():hits[i+1].start() if i+1<len(hits) else len(source)]
        if h[1]=='missing':out.append(replacement+'\n');count+=1
        else:out.append(body)
    assert count==1
    candidate=write('missing-proxy-candidate.bend',''.join(out))
    expected=pin(HERE/'proxy-v02-expected.json')
    cases=[dict(name='identity-missing-original',source=pin(base),expected=expected),
           dict(name='identity-missing-candidate',source=candidate,expected=expected)]
    write('missing-proxy-cases.json',json.dumps(dict(complete=True,cases=cases),indent=2)+'\n')
    write('missing-proxy-manifest.json',json.dumps(dict(complete=True,targetsRun=False,
        inputs=[pin(Path(__file__)),pin(base),pin(change),expected],cases=cases,overrides=['missing'],
        scope='Frozen exact same closed index proxy with only syntactic inlining of the immutable missing sentinel. First gate is emitted-code evidence that existing static preparation eliminates construction. Successful lookup timing alone is not a useful test of missed-lookup performance.'),indent=2)+'\n')

if __name__=='__main__':main()
