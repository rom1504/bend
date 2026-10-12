#!/usr/bin/env python3
"""Data-only descendant attribution within named observer call contexts."""
import argparse
import hashlib
import json
import os
import re
from collections import Counter
from pathlib import Path


def pin(path):
    path=Path(path).resolve(strict=True)
    data=path.read_bytes()
    return dict(file=str(path),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))


def name(raw):
    if raw.startswith('$jd$'):
        raw=re.sub(r'_(\d+)_',lambda match:chr(int(match[1])),raw[4:])
    else:
        raw=raw.strip('$')
    return raw.removesuffix('$scc')


def main():
    assert os.sched_getaffinity(0)=={0}
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--summary',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args()
    assert not args.out.exists()
    identity=pin(args.summary);summary=json.loads(args.summary.read_text())
    assert summary['complete'] and summary['dataOnly'] and not summary['targetExecuted']
    inputs={row['file']:row for row in summary['inputs']};rows=[]
    contexts=['no_wrapper_nodes','no_adapter','noa_analyze','no_route_names']
    for row in summary['profiles']:
        p=Path(row['report']['file']).parent/'request.cpuprofile';profile_pin=pin(p)
        assert profile_pin==inputs[str(p)]
        data=json.loads(p.read_text());nodes={n['id']:n for n in data['nodes']}
        parent={child:n['id'] for n in nodes.values() for child in n.get('children',[])}
        names={i:name(n['callFrame']['functionName']) for i,n in nodes.items()}
        sums={x:Counter() for x in contexts};cached={}
        assert len(data['samples'])==len(data['timeDeltas'])
        for leaf,delta in zip(data['samples'],data['timeDeltas']):
            if leaf not in cached:
                stack=[];node=leaf
                while node in nodes:
                    stack.append(names[node]);node=parent.get(node)
                cached[leaf]=stack
            stack=cached[leaf]
            for context in contexts:
                if context in stack:
                    for child in set(stack[:stack.index(context)]):
                        sums[context][child]+=delta
        rows.append(dict(job=row['job']['name'],profile=profile_pin,
            descendantUnionMs={context:{n:value/1000 for n,value in counts.most_common()} for context,counts in sums.items()}))
    result=dict(kind='phase70-observer-descendant-unions',dataOnly=True,targetExecuted=False,
        summary=identity,producer=pin(__file__),contexts=contexts,rows=rows,
        scope='Named-frame sample unions below the innermost selected context. Descendants overlap; do not add them. B1 trampoline/inlining can hide function names, so absent named attribution is not zero cost. Diagnostic timing only.')
    args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(output=pin(args.out),rows=len(rows))))


if __name__=='__main__':
    main()
