#!/usr/bin/env python3
"""Prepare actual Base String.append semantic harness data without execution."""
import argparse
import hashlib
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[6]

def pin(path):return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())
def verify(row):
    path=ROOT/row['file']
    if any(pin(path)[key]!=row[key] for key in ['bytes','sha256']):raise ValueError('changed '+str(path))
    return path

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
    manifest=json.loads((HERE/'manifest.json').read_text())
    for row in manifest['inputs']:verify(row)
    out.mkdir(parents=True)
    for name in ['source.bend','harness.c','cases.json','expected.jsonl']:(out/name).write_bytes((HERE/name).read_bytes())
    (out/'abi.h').write_bytes(verify(manifest['abi']).read_bytes())
    cases=json.loads((HERE/'cases.json').read_text())['cases'];declarations=[];initializers=[]
    for i,c in enumerate(cases):
        for side in ['left','right']:
            declarations.append('static const uint32_t %s_%d[] = {%s};'%(side,i,','.join(map(str,c[side])) or '0'))
        initializers.append('  {%s,left_%d,right_%d,%d,%d,%d,%d,%d,%d,%d,%d}'%(json.dumps(c['name']),i,i,len(c['left']),len(c['right']),c['leftRepeats'],c['rightRepeats'],c['static'],c['aliases'],c['overlap'],c['suffix']))
    (out/'cases.inc.c').write_text('\n'.join(declarations)+'\nstatic const Case CASES[] = {\n'+',\n'.join(initializers)+'\n};\n')
    result=dict(kind='phase110-prepared-base-string-append',complete=True,targetsRun=False,entry=manifest['entry'],cases=len(cases),observations=len(cases)*2,
        inputs=[pin(HERE/'manifest.json'),*manifest['inputs']],outputs=[pin(f) for f in sorted(out.iterdir()) if f.is_file()])
    (out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,cases=len(cases),out=str(out))))

if __name__=='__main__':main()
