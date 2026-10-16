#!/usr/bin/env python3
"""Extract exact safe scalar-transport helpers; prepare laws/negatives, run no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
BASE_SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def declaration(source, name, kind):
    match = re.search(r'(?m)^'+kind+' '+name+r'\b', source); assert match, name
    start = match.start(); end = source.find('\n\n', start)
    assert end != -1
    body = source[start:end].rstrip()+'\n'
    return body, dict(name=name, kind=kind, lineStart=source.count('\n',0,start)+1,
                      bytes=len(body.encode()), sha256=hashlib.sha256(body.encode()).hexdigest(), text=body)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out=args.out.resolve()
    assert out.is_relative_to(HERE) and not out.exists()
    assert pin(BASE)['sha256'] == BASE_SHA
    source=args.source.read_text(); baseline=BASE.read_text(); records=[]; chunks=['import Base\n']
    for kind,name in [('type','N_WordKind'),('type','NC_Binding'),('def','nk_typed_bindings'),('def','nl_c_type'),('def','nf_param_type')]:
        body,record=declaration(source,name,kind)
        assert body==declaration(baseline,name,kind)[0], ('Changed helper: review the source bridge before reusing these laws',name)
        chunks.append(body);records.append(record)
    extracted='\n'.join(chunks)
    law_template=(HERE/'kind-laws.template.bend').read_text()
    out.mkdir(parents=True)
    rows=[]
    mutants={
        'positive':extracted,
        'bad-slots':extracted.replace('NC_Binding{id, word, kind}, nk_typed_bindings', 'NC_Binding{0, "lost", kind}, nk_typed_bindings'),
        'bad-kind':extracted.replace('NC_Binding{id, word, kind}, nk_typed_bindings', 'NC_Binding{id, word, old}, nk_typed_bindings'),
        'bad-opaque':extracted.replace('case _: "Term"', 'case _: "NF_SCALAR"')}
    assert len(set(mutants.values()))==4
    for role,body in mutants.items():
        folder=out/role;folder.mkdir();helper=folder/'candidate.bend';laws=folder/'laws.bend'
        helper.write_text(body);laws.write_text(law_template)
        rows.append(dict(role=role,helper=pin(helper),laws=pin(laws),
                         expectedStandaloneAdmission='accept',expectedLawCheck='accept' if role=='positive' else 'reject',status='prepared; not checked'))
    report=dict(kind='phase99-production-kind-law-preparation',complete=True,targetsRun=False,
        method=pin(__file__),template=pin(HERE/'kind-laws.template.bend'),source=pin(args.source),baseline=pin(BASE),declarations=records,rows=rows,
        bridge='Exact declaration bodies and actual production datatypes. Leading @unsafe annotations are excluded; independent safe admission remains required. No fabricated scalar-kind model replaces the helpers.',
        scope='Binding identifiers/word names survive kind transport; the head receives the supplied kind; opaque private parameters remain Term. These laws do not prove that the supplied kind matches a runtime value, host authentication, C narrowing, evaluation order or reference counting.',
        requirements=['Admit each bad helper without its laws first, then check the unchanged law template.',
                      'Positive checking and safe elaboration/independent kernel acceptance are separate statuses.',
                      'Re-extract against the actual selected candidate before reporting candidate coverage.'])
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,manifest=pin(out/'manifest.json'))))


if __name__=='__main__': main()
