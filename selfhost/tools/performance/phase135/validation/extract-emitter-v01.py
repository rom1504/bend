#!/usr/bin/env python3
"""Freeze an unqualified source-only emitter slice, copied from the real compiler.

Lexical overapproximation is only a packaging aid, never a semantic cache key.
The checked Bend compiler must admit this source before any target experiment.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase131/prepare.py'
spec=importlib.util.spec_from_file_location('compose',METHOD);P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--full-plan',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    plan=json.loads(a.full_plan.read_text());assert plan['complete'];out=a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase135')
    source=plan['revisions'][0]['source'];assert P.pin(source['file'])==source
    original=Path(source['file']).read_text();blocks=P.blocks(original);constructors={}
    for name,body in blocks.items():
        if re.match(r'(?:@unsafe\n)?type ',body):
            for ctor in re.findall(r'^  ([A-Za-z_][\w.]*)\s*\{',body,re.M):constructors[ctor]=name
    quoted=re.compile(r'"(?:\\.|[^"\\])*"|\#.*$',re.M)
    selected=set();todo=['p111q_text']
    while todo:
        name=todo.pop()
        if name in selected:continue
        selected.add(name)
        for token in re.findall(r'\b[A-Za-z_][A-Za-z0-9_.]*',quoted.sub(' ',blocks[name])):
            dependency=token if token in blocks else constructors.get(token)
            if dependency and dependency not in selected:todo.append(dependency)
    assert 'p111q_main' in selected and 'main' not in selected
    body='import Base\n\n'+''.join(blocks[n]for n in blocks if n in selected)
    suffix='''
@unsafe
def p135vc_program() -> P111Program:
  P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]}],[],[],[],[],True{}}

@unsafe
def main() -> String:
  p111q_text(p135vc_program())
'''
    before=body+suffix;declaration=blocks['p111q_main'];assert declaration.count('%result')==2
    after=before.replace(declaration,declaration.replace('%result','%answer'));assert before!=after and len(before)==len(after)
    out.mkdir(parents=True);(out/'a.bend').write_text(before);(out/'b.bend').write_text(after)
    report=dict(complete=True,checked=False,targetsRun=False,inputs=[P.pin(__file__),P.pin(METHOD),P.pin(a.full_plan),source],
        roots=['p111q_text'],declarations=[n for n in blocks if n in selected],declarationCount=len(selected),
        physicalLines=len(before.splitlines()),sourceBytes=len(before.encode()),a=P.pin(out/'a.bend'),b=P.pin(out/'b.bend'),
        actualCompilerDeclarationBytesPreserved=True,changedDeclaration='p111q_main',
        scope='Unchecked source packaging only: real renderer/type/index/list/string dependencies plus a tiny data-only IR wrapper. It tests compiled compiler-subset reuse, not full-image cost or execution of generated synthetic machine IR. Lexical closure is not a semantic invalidation proof.')
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:report[k]for k in ['complete','checked','targetsRun','declarationCount','physicalLines','sourceBytes']}))


if __name__=='__main__':main()
