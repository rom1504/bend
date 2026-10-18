#!/usr/bin/env python3
"""Append the bounded typed-entry prototype to a checked Phase110 source.

Preparation only. The native request adapter stays separate until the original
typed-book contract has passed real-source positive and negative probes.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]

def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',required=True,type=Path)
    parser.add_argument('--out',required=True,type=Path)
    args=parser.parse_args();source=args.source.resolve();out=args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    text=source.read_text();modules=[HERE/(name+'.bend') for name in ['model','layout','entry','library']]
    additions='\n\n'.join(module.read_text() for module in modules)
    names=lambda body:re.findall(r'^(?:def|type) ([A-Za-z0-9_]+)\b',body,re.M)
    if set(names(text))&set(names(additions)) or len(names(additions))!=len(set(names(additions))):
        raise ValueError('new declaration collision')
    out.mkdir(parents=True);target=out/'source.bend';target.write_text(text+'\n\n'+additions+'\n')
    record=dict(kind='phase110-bounded-typed-entry-prototype',complete=True,targetsRun=False,
        source=pin(target),inputs=[pin(Path(__file__)),pin(source),*map(pin,modules)],
        exports=['nxe_entry','nxe_layout_ok','nxe_source','nxe_role','nxe_signature','nxe_close','nxe_lower_library','nxe_lower_runtime_library'],
        limits=['Prototype entry representation facts only; no native frontend integration.',
                'Typed and erased facts must belong to the same authenticated checked request.',
                'Canonical Base String and List<&2,String> only; aliases, erased/dependent parameters and function results refuse.',
                'Ownership, body shape and closed callee verification remain separate.'])
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record))

if __name__=='__main__':main()
