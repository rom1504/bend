"""Replace only summary algorithms in the already checked native summary proxy."""
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
    a=p.parse_args();out=a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    parent_file=ROOT/'selfhost/build/phase131/usage-proxy02/manifest.json'
    parent=json.loads(parent_file.read_text());assert parent['complete']
    safe_file=ROOT/'selfhost/build/phase131/laws-safe-summary01/report.json'
    safe=json.loads(safe_file.read_text());assert safe['complete'] and not safe['targetsRun']
    original_file=Path(parent['variants']['summary']['source']['file'])
    inputs=[pin(__file__),pin(parent_file),*parent['inputs'],parent['variants']['summary']['source'],parent['expected'],
            pin(safe_file),safe['source'],*safe['inputs']]
    for row in inputs:assert pin(row['file'])==row
    original=original_file.read_text();before=blocks(original)
    old=blocks((HERE/'summary-v02.bend').read_text());new=blocks(Path(safe['source']['file']).read_text())
    for name,body in old.items():assert norm(before[name])==norm(body),name
    assert set(old)-set(new)==set(safe['removedDeclarations'])
    assert not ((set(new)-set(old)) & set(before))
    hits=list(PAT.finditer(original));parts=[original[:hits[0].start()]]
    for i,h in enumerate(hits):
        if h[1] in old:
            if h[1] in new:parts.append(new[h[1]].rstrip()+'\n\n')
        else:parts.append(original[h.start():hits[i+1].start() if i+1<len(hits) else len(original)])
    parts.extend('\n'+body for name,body in new.items() if name not in before)
    result=''.join(parts);after=blocks(result)
    for name,body in before.items():
        if name not in old:assert norm(after[name])==norm(body),name
    for name,body in new.items():assert norm(after[name])==norm(body),name
    out.mkdir(parents=True);(out/'main.bend').write_text(result)
    (out/'expected.stdout').write_bytes(Path(parent['expected']['file']).read_bytes())
    report=dict(complete=True,targetsRun=False,checked=False,inputs=inputs,source=pin(out/'main.bend'),
                expected=pin(out/'expected.stdout'),oracle=parent['oracle'],parent=parent['variants']['summary']['source'],
                safeSource=safe['source'],safeSourceBridge=pin(safe_file),changed=safe['changedDeclarations'],
                removed=safe['removedDeclarations'],added=sorted(set(new)-set(old)),
                scope='Same repeated64-ID summary proxy and ordinary oracle; replaces only exact source-connected safe summary algorithm bodies. No proof of full generic KTerm summary, performance claim or selection.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['source']))


if __name__=='__main__':main()
