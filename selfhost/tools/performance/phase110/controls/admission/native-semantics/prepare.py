#!/usr/bin/env python3
"""Authenticate and prepare four direct-entry semantic harnesses, source only."""
import argparse
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]

def pin(path):
    return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def verify(item):
    path = ROOT/item['file']
    if path.stat().st_size != item['bytes'] or pin(path)['sha256'] != item['sha256']:
        raise ValueError('frozen semantic input changed: '+item['file'])
    return path

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();out=args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
    manifest=json.loads((HERE/'manifest.json').read_text())
    for row in manifest['inputs']:verify(row)
    cases=json.loads((HERE/'cases.json').read_text())['cases']
    out.mkdir(parents=True)
    for name in ['harness.c','expected.jsonl','cases.json','unreachable.bend']:(out/name).write_bytes((HERE/name).read_bytes())
    abi=verify(manifest['abi']);(out/'abi.h').write_bytes(abi.read_bytes())
    (out/'source.bend').write_bytes(verify(manifest['source']).read_bytes())
    (out/'cases.inc.c').write_text('static const Case CASES[] = {\n'+',\n'.join('  {%s,%d,%d}'%(json.dumps(c['name']),c['root'],c['shape']) for c in cases)+'\n};\n')
    result=dict(kind='phase110-prepared-native-closure-semantics',complete=True,targetsRun=False,
        inputs=[pin(HERE/'manifest.json'),*manifest['inputs']],roots=manifest['roots'],cases=len(cases),observations=len(cases)*2,
        outputs=[pin(p) for p in sorted(out.iterdir()) if p.is_file()])
    (out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,out=str(out),cases=len(cases),observations=len(cases)*2)))

if __name__=='__main__':main()
