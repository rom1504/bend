"""Freeze the consuming-equality ablation over the measured closed lookup proxy."""
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
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
    base=HERE/'read-proxy-candidate.bend';change=HERE/'bucket-consuming-v01.bend'
    source=base.read_text();extra=change.read_text();replacement=extra[PAT.search(extra).start():]
    hits=list(PAT.finditer(source));out=[source[:hits[0].start()]];count=0
    for i,h in enumerate(hits):
        body=source[h.start():hits[i+1].start() if i+1<len(hits) else len(source)]
        if h[1]=='index_bucket' and not body.startswith('law '):
            out.append(replacement+'\n');count+=1
        else:out.append(body)
    assert count==1
    candidate=write('bucket-proxy-candidate.bend',''.join(out))
    build=ROOT/'selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/report.json'
    emission=ROOT/'selfhost/build/phase130/p131-read-lookup01-identity-candidate-emit/report.json'
    br=json.loads(build.read_text());er=json.loads(emission.read_text())
    assert br['complete'] and br['outputExact'] and er['complete'] and er['source']==pin(base)
    expected=pin(HERE/'proxy-v02-expected.json')
    rows=[dict(name='identity-bucket-original',source=pin(base),expected=expected,expectedStdoutEvidence=expected),
          dict(name='identity-bucket-candidate',source=candidate,expected=expected,expectedStdoutEvidence=expected)]
    write('bucket-proxy-cases.json',json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
    write('bucket-proxy-manifest.json',json.dumps(dict(complete=True,targetsRun=False,
        inputs=[pin(Path(__file__)),pin(base),pin(change),expected,pin(HERE/'timing-oracle.py'),pin(build),pin(emission)],
        baselineReuse=dict(source=pin(base),build=pin(build),emission=pin(emission),binary=br['binary'],qbe=er['product']),
        cases=rows,overrides=['index_bucket'],
        scope='Same measured closed lookup proxy and immutable index. Only index_bucket invokes the consuming equality directly. Reuse the independently checked closed-loop baseline binary; one new candidate build suffices. No compiler selection change.'),indent=2)+'\n')


if __name__=='__main__':main()
