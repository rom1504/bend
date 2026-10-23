#!/usr/bin/env python3
"""Produce the source-connected safe algorithm candidate; never executes Bend.

Only removes local A./P. import qualifications from proved declarations and
replaces the corresponding helper-recursive declarations. The rest of the
usage analyzer remains byte-identical. This is not a proof of that remainder.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
PAT=re.compile(r'(?m)^(?:@unsafe\n)?(?:def|type) ([A-Za-z_][A-Za-z_0-9.]*)')

def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def declarations(text):
    hits=list(PAT.finditer(text)); result={}
    for i,hit in enumerate(hits):
        end=hits[i+1].start() if i+1<len(hits) else len(text)
        block=text[hit.start():end].rstrip()
        lines=block.splitlines()
        while lines and (not lines[-1].strip() or lines[-1].lstrip().startswith('#')): lines.pop()
        assert hit[1] not in result
        result[hit[1]]='\n'.join(lines)
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); out=a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase131') and not out.exists()
    source=HERE.parent/'usage/summary-v02.bend'
    original=declarations(source.read_text())
    absent=declarations((HERE/'absent-production.bend').read_text())
    merge=declarations((HERE/'merge-production-v01.bend').read_text())
    lookup=declarations((HERE/'lookup-production-v02.bend').read_text())
    safe={**absent,**merge,**lookup}
    safe={k:v.replace('A.','').replace('P.','') for k,v in safe.items()}
    assert safe['P131UEntry']==original['P131UEntry']
    assert original['p131u_absent'].removeprefix('@unsafe\n')==safe['p131u_absent']
    replaced={'p131u_absent','p131u_merge','p131u_max','p131u_min'}
    removed={'p131u_merge_heads','p131u_max_order','p131u_min_order'}
    result=[]
    for name,body in original.items():
        if name=='p131u_merge': result.append(safe['p131u_merge_choose'])
        if name=='p131u_max': result.append(safe['p131u_choose'])
        if name not in removed: result.append(safe[name] if name in replaced else body)
    text='# Safe executable usage-summary candidate; not selected until independent performance gates.\n\n'+'\n\n'.join(result)+'\n'
    final=declarations(text)
    for name,body in original.items():
        if name not in replaced|removed: assert final[name]==body,name
    for name,body in safe.items(): assert final[name]==body,name
    out.mkdir(parents=True)
    (out/'summary.bend').write_text(text)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    report=dict(complete=True,targetsRun=False,selected=False,source=pin(out/'summary.bend'),
                inputs=[pin(source),*[pin(HERE/f) for f in ['absent-production.bend','merge-production-v01.bend','lookup-production-v02.bend']],pin(__file__)],
                exactSafeDeclarations=list(safe),changedDeclarations=sorted(replaced),removedDeclarations=sorted(removed),
                qualifierMapping={'A.':'','P.':''},unchangedDeclarations=[k for k in original if k not in replaced|removed],
                sourceLines=len(text.splitlines()),originalLines=len(source.read_text().splitlines()),
                limits='Only safe algorithm bodies are connected to their laws. Generic KTerm traversal and disjoint-key merge lookup remain unproved. Closure dispatch profitability is unmeasured.')
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report['source']))

if __name__=='__main__': main()
