#!/usr/bin/env python3
"""Prepare real-I/O full-value string corpus with existing exact emitter method."""
import argparse
import hashlib
import json
from pathlib import Path
import re
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BUILD = ROOT/'selfhost/build/phase98'
def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path): return json.loads(Path(path).read_text())
def save(path,value): path.write_text(json.dumps(value,indent=2)+'\n')
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--qualification',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args(); out=args.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    original=HERE.parent/'comparison/held-controls01.bend'
    oracle=ROOT/'selfhost/tools/performance/phase88/strings/controls-v5.json'
    serializer=ROOT/'selfhost/build/phase97/challenge-base01/methods/serialize.bend'
    data=read(oracle); corpus=data['corpus']; source=original.read_text()
    assert len(corpus)==38
    assert [json.loads(x) for x in re.findall(r'p88_codes\((\[[\d, ]*\])\)',source)]==corpus
    edits=[('sumA: U32, sumB: U32}', 'sumA: U32, sumB: U32, left: String, right: String}'),
           ('p88_sum(a, 0), p88_sum(b, 0)}', 'p88_sum(a, 0), p88_sum(b, 0), a, b}'),
           ('def main() -> List<&2, P88StringCheck>:', 'def p98_corpus_rows() -> List<&2, P88StringCheck>:')]
    for before,after in edits:
        assert source.count(before)==1;source=source.replace(before,after)
    prefix=serializer.read_text().split('@unsafe\ndef p96.strings_body')[0]
    fields=['a','b','oldEq','sharedEq','ownedEq','oldOrder','sharedOrder','ownedOrder','lenA','lenB','sumA','sumB','left','right']
    parts=['U32.show('+name+')' for name in fields[:12]]+['p96.string(left)','p96.string(right)']
    source+='\n'+prefix+'\n@unsafe\ndef p98.row(value: P88StringCheck) -> String:\n  match value:\n    case P88StringCheck{'+', '.join(fields)+'}:\n      "[" ++ '+' ++ "," ++ '.join(parts)+' ++ "]"\n'
    source+='''
@unsafe
def p98.rows(values: List<&2, P88StringCheck>) -> String:
  match values:
    case Nil{}: ""
    case Con{head, Nil{}}: p98.row(head)
    case Con{head, Con{next, rest}}: p98.row(head) ++ "," ++ p98.rows(Con{next, rest})

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print_err("phase98-observer-corpus")
    IO.print("[" ++ p98.rows(p98_corpus_rows()) ++ "]")
'''
    expected=[]
    for i,a in enumerate(corpus):
        for j,b in enumerate(corpus):
            eq=int(a==b); order=0 if a<b else 1 if a==b else 2
            expected.append([i,j,eq,eq,eq,order,order,order,len(a),len(b),sum(a)%2**32,sum(b)%2**32,a,b])
    expected.reverse()
    qualification=args.qualification.resolve(); old=read(qualification/'plan.json')
    out.mkdir(parents=True); (out/'program.bend').write_text(source)
    stdout=json.dumps(expected,separators=(',',':'))+'\n';(out/'expected.stdout').write_text(stdout)
    (out/'expected.stderr').write_text('phase98-observer-corpus\n')
    dependencies=[pin(__file__),pin(original),pin(oracle),pin(serializer),pin(qualification/'plan.json'),pin(HERE/'qualify.mjs')]
    plan=dict(old);plan['cases']=[]
    plan['controls']=[dict(id='full-string-corpus',source=pin(out/'program.bend'),stdout=stdout,stderr='phase98-observer-corpus\n',observerOwner='p98_eq_walk',scalar=0)]
    plan['scope']='Followup after initial small qualification: unchanged38-input1444-pair corpus/12 observed fields plus complete surviving left/right character arrays; real IO.print_err requires old0/new1 observer permission. Reuses prior exact acquired APIs and unchanged emitter checker; no compiler acquisition.'
    plan['followupDependencies']=dependencies
    save(out/'plan.json',plan)
    save(out/'receipt.json',dict(complete=True,targetsRun=False,kind='phase98-observer-real-io-full-corpus-source',qualification=str(qualification),source=pin(out/'program.bend'),plan=pin(out/'plan.json'),expectedStdout=pin(out/'expected.stdout'),expectedStderr=pin(out/'expected.stderr'),inputs=dependencies,sourceEdits=edits,pairs=1444,fields=fields,scope=plan['scope']))
    print(json.dumps(dict(source=pin(out/'program.bend'),pairs=1444,stdoutBytes=len(stdout.encode()))))
if __name__=='__main__': main()
