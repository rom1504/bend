#!/usr/bin/env python3
"""Authenticate exact safe helper/algorithm bodies in an acquired candidate.

This is a source identity gate, not a semantic proof of compilation, summary
merge or caller behavior. The independently checked laws prove only the named
safe declarations and their stated input domains.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent

def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def declaration(text,name):
    pattern=r'^(?:def|type) '+re.escape(name)+r'(?=\b)[\s\S]*?(?=\n\n|\Z)'
    found=re.findall(pattern,text,re.M)
    assert len(found)==1,(name,len(found))
    return found[0].rstrip()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--candidate',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); source=a.candidate.resolve(); out=a.out.resolve()
    assert source.is_relative_to(ROOT) and out.is_relative_to(ROOT/'selfhost/build/phase131') and not out.exists()
    out.mkdir(parents=True)
    text=source.read_text(); expected={}
    for file,names in [('production.bend',['p131a_add','p131a_low','p131a_high']),
                       ('absent-production.bend',['P131UEntry','p131u_absent'])]:
        body=(HERE/file).read_text()
        for name in names:
            expected[name]=declaration(body,name)
            assert declaration(text,name)==expected[name],name
    stamp=json.loads((HERE/'absent-source.json').read_text())
    original=ROOT/stamp['source']
    assert pin(original)['sha256']==stamp['sourceSha256']
    assert pin(HERE/'absent-production.bend')['sha256']==stamp['outputSha256']
    assert stamp['originalDeclaration'].removeprefix('@unsafe\n')==stamp['extractedDeclaration']
    assert stamp['extractedDeclaration'].strip()==expected['p131u_absent']
    report=dict(complete=True,method=pin(__file__),candidate=pin(source),
                inputs=[pin(HERE/x) for x in ['production.bend','absent-production.bend','absent-source.json']]+[pin(original)],
                exactDeclarations=list(expected),
                scope='Byte-identical declaration bodies and types; only the production unsafe annotation on absent is removed in its proof extraction. No runtime/backend correctness claim.')
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,exactDeclarations=list(expected))))

if __name__=='__main__': main()
