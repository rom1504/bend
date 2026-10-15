#!/usr/bin/env python3
"""Extract actual retained-root ix/qt and original projection bodies; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
RECEIPT=ROOT/'selfhost/build/phase98/scalar-source01/changes.json'


def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def extract(source,name):
    matches=list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b',source))
    hits=[(i,m)for i,m in enumerate(matches)if m.group(1)==name];assert len(hits)==1
    i,m=hits[0];end=matches[i+1].start()if i+1<len(matches)else len(source)
    original=source[m.start():end];extracted=original.removeprefix('@unsafe\n');assert '@unsafe'not in extracted
    return dict(name=name,startByte=m.start(),endByte=end,original=original,extracted=extracted,removedUnsafe=original!=extracted)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT)and not out.exists()
    receipt=json.loads(RECEIPT.read_text());assert receipt['complete']
    for key in ['source','candidate']:assert pin(receipt[key]['file'])==receipt[key]
    original=Path(receipt['source']['file']).read_text();candidate=Path(receipt['candidate']['file']).read_text();replay=original
    for change in receipt['changes']:
        start=change['offset'];end=start+len(change['old']);assert replay[start:end]==change['old']
        replay=replay[:start]+change['new']+replay[end:]
    assert replay==candidate
    current=[extract(candidate,name)for name in ['KTerm','p98_term_scalar_finish','p98_ix_read','p98_qt_read','ix','qt']]
    references=[]
    for name in ['ix','qt']:
        row=extract(original,name)
        needle='def '+name+'(';replacement='def p98_original_'+name+'('
        assert row['extracted'].count(needle)==1
        row['reference']=row['extracted'].replace(needle,replacement,1)
        assert row['reference'].replace(replacement,needle,1)==row['extracted']
        row['renamedOnlyDeclaration']=True;references.append(row)
    assert current[0]['original']==extract(original,'KTerm')['original']
    out.mkdir(parents=True)
    (out/'candidate.bend').write_text('import Base\n\n'+''.join(row['extracted']for row in current)+''.join(row['reference']for row in references))
    for name in ['scalars.bend','prepare-scalars.py']:(out/name).write_bytes((HERE/name).read_bytes())
    manifest=dict(kind='phase98-exact-retained-scalar-proof-source',targetsRun=False,method=pin(__file__),
                  source=receipt['source'],candidate=receipt['candidate'],receipt=pin(RECEIPT),
                  candidateDefinitions=current,referenceDefinitions=references,forwardReplayExact=True,
                  outputs=[pin(path)for path in sorted(out.iterdir())],entry=str(out/'scalars.bend'),
                  publicLaws=['retained_id_preserves','retained_quantity_preserves'],supportLemmas=[],
                  transformation='Exact candidate declaration bodies with only leading unsafe annotations removed. Original nonrecursive ix/qt reference bodies are exact except their declaration names, authenticated reversibly to share the exact KTerm type.',
                  boundary='All typed finite KTerm values and full U32 projection results; no generated C lifetime theorem.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(dict(out=str(out),entry=manifest['entry'],targetsRun=False)))


if __name__=='__main__':main()
