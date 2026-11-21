"""Count complete public assembly bodies after normalizing their own label only."""
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import re
import sys

def census(directory):
    raw=hashlib.sha256()
    families=Counter()
    samples={}
    owner=None
    with gzip.open(directory/'program.s.gz','rb') as source:
        for line in source:
            raw.update(line)
            if owner is None:
                if line.startswith(b'.type p111_FID_'):
                    owner=line.split()[1].rstrip(b',')
                    body=hashlib.sha256()
                    ops=0
                    targets=[]
                continue
            if line.startswith(b'.size '):
                assert line.split()[1].rstrip(b',')==owner
                key=body.hexdigest();families[key]+=1
                if key not in samples:
                    numbers=owner.decode().split('_FID_')[1].strip('_').split('_')
                    samples[key]=dict(example=''.join(chr(int(n)) for n in numbers),
                                      instructions=ops,callExamples=targets)
                owner=None
                continue
            if owner in line:
                # A longer FID continues with the next decimal digit. Such a
                # target denotes another function and keeps its full identity.
                first,*tails=line.split(owner)
                line=first+b''.join((owner if tail[:1].isdigit() else b'@self')+tail for tail in tails)
            body.update(line)
            if line.startswith(b'  '):
                ops+=1
                m=re.match(rb'\s*call[q]?\s+(\S+)',line)
                if m and len(targets)<6:
                    target=m[1].decode()
                    targets.append(target if len(target)<80 else target[:76]+'...')
    sha=raw.hexdigest()
    assert owner is None and sha==json.loads((directory/'report.json').read_text())['sha256']
    return dict(listing=sha,public=sum(families.values()),distinct=len(families),
                description='Phase202 compiler assembly. Only references to the function being compared are canonicalized. External call identities, instructions and constants are retained.',
                families=[dict(sha256=k,members=n,**samples[k]) for k,n in families.most_common(18)])
if __name__=='__main__':print(json.dumps(census(Path(sys.argv[1])),indent=2))
