#!/usr/bin/env python3
"""Prepare reachable negative source entries without changing positive fixtures.

The exact original declarations are retained. Only main is replaced so mature
checked request reachability captures dynamic and partial call definitions.
No compiler or target runs in this preparation tool.
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]

def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',required=True,type=Path)
    args=parser.parse_args();out=args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    manifest=HERE.parent/'controls/call-shapes/manifest.json'
    contract=json.loads(manifest.read_text());source=ROOT/contract['source']['file']
    old=pin(source)
    if old['sha256']!=contract['source']['sha256'] or old['bytes']!=contract['source']['bytes']:
        raise ValueError('frozen source differs')
    text=source.read_text();marker='def main() -> IO(Unit):\n'
    if text.count(marker)!=1:raise ValueError('unique original main required')
    prefix,original_main=text.split(marker,1)
    replacement='''def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p110_append_join(p110_call_dynamic(p110_call_identity, ["a"])))
    IO.print(p110_append_join(p110_call_partial(["a"])(["b"])))

#|a
#|a|b
'''
    out.mkdir(parents=True);target=out/'source.bend';target.write_text(prefix+replacement)
    report=dict(kind='phase110-reachable-call-refusal-source',complete=True,targetsRun=False,
        inputs=[pin(Path(__file__)),pin(manifest),pin(source)],source=pin(target),
        preservedDeclarationPrefixSha256=hashlib.sha256(prefix.encode()).hexdigest(),
        replacedMainSha256=hashlib.sha256((marker+original_main).encode()).hexdigest(),
        exactPreservedDeclarations=True,expectedStdout='a\na|b\n',
        entries=['p110_call_dynamic','p110_call_partial'],
        purpose='Reachability wrapper for separate checked-fact refusal probes; positive source and oracles unchanged.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))

if __name__=='__main__':main()
