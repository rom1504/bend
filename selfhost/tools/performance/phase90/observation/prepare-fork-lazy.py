#!/usr/bin/env python3
"""Offline lazy fork derivative; reuse frozen fork03 fixtures and whole products."""
import argparse
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p90_shared',HERE/'prepare.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
PARENT_SHA='d8a94ce9f16e7576d2f4269c858d008e3da2f40f734cdf0983a3a9835f330791'
FUNCTIONS=['p90_fork_reaches','p90_fork_scan']

def verify(record):
    actual=s.pin(Path(record['file']))
    assert actual==record,actual
    return actual

def write_json(path,value):
    with path.open('x') as stream:json.dump(value,stream,ensure_ascii=False,indent=2);stream.write('\n')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--compiler',type=Path,help='Optional exact indexed compiler d8a94ce9… for incremental two-function derivative')
    args=parser.parse_args();args.out.mkdir(parents=True,exist_ok=False)
    parent_file=HERE/'fork03/manifest.json';parent=json.loads(parent_file.read_text())
    assert parent['kind']=='phase90-indexed-fork-controls' and parent['complete'] and parent['cases']==46
    baseline=verify(next(x for x in parent['outputs'] if x['file'].endswith('/legacy.bend')))
    indexed=verify(next(x for x in parent['outputs'] if x['file'].endswith('/indexed.bend')))
    lazy_file=HERE/'fork-lazy.bend';indexed_file=HERE/'fork-indexed.bend'
    lazy=lazy_file.read_text();old=indexed_file.read_text()
    changes=[]
    for name in FUNCTIONS:
        before=s.declaration(old,name);after=s.declaration(lazy,name)
        assert before!=after and 'String.eq' not in before+after
        changes.append(dict(name=name,before=before,after=after))
    # Verify that all other algorithm declarations are unchanged.
    actual_old=old
    for change in changes:
        assert actual_old.count(change['before'])==1
        actual_old=actual_old.replace(change['before'],change['after'],1)
    assert actual_old[actual_old.index('@unsafe'):]==lazy[lazy.index('@unsafe'):]
    def derive(source):
        result=source
        for change in changes:
            assert result.count(change['before'])==1,change['name']
            result=result.replace(change['before'],change['after'],1)
        inverse=result
        for change in reversed(changes):
            assert inverse.count(change['after'])==1
            inverse=inverse.replace(change['after'],change['before'],1)
        assert inverse==source
        return result
    candidate=args.out/'lazy.bend'
    with candidate.open('x') as stream:stream.write(derive(Path(indexed['file']).read_text()))
    inputs=[s.pin(Path(__file__)),s.pin(HERE/'prepare.py'),s.pin(parent_file),baseline,indexed,s.pin(lazy_file),s.pin(indexed_file)]
    outputs=[baseline,s.pin(candidate)]
    meta=dict(kind=parent['kind'],variant='lazy-indexed',complete=True,targetExecuted=False,
        cases=parent['cases'],labels=parent['labels'],expected=parent['expected'],
        collision=parent['collision'],inputs=inputs,outputs=outputs,
        oracle='Unchanged fork03 independent complete-product oracle: ordered roots/duplicates/fuel, flags and prefixes, one-pass behavior, retained seeds and segments. No timing or operation-count claim.',
        fixtureTransport=dict(parent=s.pin(parent_file),baselineReused=True,unchangedFixtureBytesOutsideFunctions=True,
            maxSegmentCallsPerLiteral=16,maxCaseCallsPerLiteral=4),
        priorDiagnostics='Frozen fork03 Python short-circuit name counts do not model eager Bend Bool.and/or demand; deliberately not inherited.',
        semantics='Equivalent on finite well-formed pure Data; unchecked partial/cyclic host input demand and resource/error timing are not preserved or admitted.',
        replacements=changes,fixtureInverseByteExact=True)
    if args.compiler:
        compiler_pin=s.pin(args.compiler);assert compiler_pin['sha256']==PARENT_SHA
        full=args.out/'compiler-fork-lazy.bend'
        with full.open('x') as stream:stream.write(derive(args.compiler.read_text()))
        receipt=dict(kind='phase90-indexed-to-lazy-fork-derivative',complete=True,targetExecuted=False,
            parent=compiler_pin,output=s.pin(full),replacements=changes,inverseByteExact=True,
            exactOutsideFunctions=True,functions=FUNCTIONS,inputs=inputs+[compiler_pin])
        receipt_file=args.out/'compiler-fork-lazy.derivation.json';write_json(receipt_file,receipt)
        inputs.append(compiler_pin);outputs.append(s.pin(full))
        meta['compilerDerivation']=s.pin(receipt_file)
    # Preserve each parent expected product exactly, not only its list length.
    assert meta['labels']==parent['labels'] and meta['expected']==parent['expected']
    write_json(args.out/'manifest.json',meta)
    print(json.dumps(dict(complete=True,targetExecuted=False,cases=meta['cases'],outputs=outputs)))

if __name__=='__main__':main()
