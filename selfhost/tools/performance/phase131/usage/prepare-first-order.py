"""Compose exact first-order safe algorithm bodies into the frozen summary proxy."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
PAT=re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)


def pin(file):
    file=Path(file).resolve();data=file.read_bytes()
    return dict(file=str(file),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def blocks(text):
    hits=list(PAT.finditer(text))
    return {h[1]:text[h.start():hits[i+1].start() if i+1<len(hits) else len(text)] for i,h in enumerate(hits)}


def norm(text):
    return '\n'.join(x.rstrip() for x in text.splitlines() if x.strip() and not x.lstrip().startswith('#'))


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    parent_file=ROOT/'selfhost/build/phase131/usage-safe-proxy02/manifest.json';parent=json.loads(parent_file.read_text())
    assert parent['complete'];original_file=Path(parent['source']['file'])
    summary_file=ROOT/'selfhost/build/phase131/laws-safe-summary01/summary.bend'
    modules=[HERE.parent/'laws/merge-first-order-v01.bend',HERE.parent/'laws/lookup-first-order-v02.bend']
    replacements={}
    for module in modules:
        replacements.update({k:v.replace('A.','').replace('P.','') for k,v in blocks(module.read_text()).items()})
    old=blocks(summary_file.read_text());summary=[]
    for name,body in old.items():
        if name in ['p131u_choose','p131u_merge_choose']:continue
        if name in ['p131u_merge','p131u_max','p131u_min']:
            summary.extend([replacements[name+'_loop'],replacements[name]])
        else:summary.append(body)
    summary_text='\n'.join(summary);new=blocks(summary_text)
    for name,body in old.items():
        if name not in ['p131u_choose','p131u_merge_choose','p131u_merge','p131u_max','p131u_min']:
            assert norm(new[name])==norm(body),name
    for name,body in replacements.items():assert norm(new[name])==norm(body)
    original=original_file.read_text();before=blocks(original);hits=list(PAT.finditer(original));parts=[original[:hits[0].start()]]
    for name,body in old.items():assert norm(before[name])==norm(body)
    for i,h in enumerate(hits):
        if h[1] in old:
            if h[1]=='P131UEntry':parts.append(summary_text.rstrip()+'\n\n')
        else:parts.append(original[h.start():hits[i+1].start() if i+1<len(hits) else len(original)])
    source=''.join(parts);after=blocks(source)
    for name,body in before.items():
        if name not in old:assert norm(after[name])==norm(body)
    inputs=[pin(__file__),pin(parent_file),parent['source'],parent['expected'],*parent['inputs'],pin(summary_file),*[pin(m) for m in modules]]
    for row in inputs:assert pin(row['file'])==row
    out.mkdir(parents=True);(out/'summary.bend').write_text(summary_text);(out/'main.bend').write_text(source)
    (out/'expected.stdout').write_bytes(Path(parent['expected']['file']).read_bytes())
    report=dict(complete=True,targetsRun=False,checked=False,inputs=inputs,source=pin(out/'main.bend'),summary=pin(out/'summary.bend'),
                expected=pin(out/'expected.stdout'),oracle=parent['oracle'],parent=parent['source'],
                qualifierMapping={'A.':'','P.':''},replaced=['p131u_merge','p131u_max','p131u_min'],
                removed=['p131u_choose','p131u_merge_choose'],added=['p131u_merge_loop','p131u_max_loop','p131u_min_loop'],
                scope='Only exact safe first-order algorithm bodies replace deferred branch callbacks. Other summary traversal and workload unchanged. Source safety/proof receipts are separate; no runtime gain or full-compiler qualification is asserted.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['source']))


if __name__=='__main__':main()
