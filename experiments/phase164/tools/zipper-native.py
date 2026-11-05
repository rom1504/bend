#!/usr/bin/env python3
"""Build and time the bounded whole-map computation using the qualified compiler."""
import argparse
import json
import statistics
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, run, write_json, fresh_output
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--controls', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--source-generation', type=int, choices=[1,2], default=1)
a = p.parse_args()
controls = json.loads(a.controls.read_text())
require(controls['complete'], 'Complete independent controls required')
out = fresh_output(a.out, ROOT)
parent = ROOT / 'selfhost/build/phase152/native-n2/report.json'
image = json.loads(parent.read_text())['binary']; verify(image)
report = dict(complete=False, inputs=[pin(__file__),pin(a.controls),pin(parent),image], rows=[],
              scope='4096-key complete build/overwrite/all-field consumption, eight fresh maps. '
              'Four counterbalanced fresh-process pairs. Same qualified compiler and runtime; '
              'compiler-derived computation slice, not full compiler/upstream speed.')
def save(): write_json(out / 'report.json', report)
try:
    for expected in controls['runtimeExpected']:
        mode = expected['mode']; verify(expected['stdout'])
        report['inputs'].append(expected['stdout'])
        row = dict(mode=mode,products={},samples=[],complete=False)
        report['rows'].append(row);save()
        for role in ['baseline','candidate']:
            source = ROOT / f'selfhost/build/phase164/zipper-{role}{mode}-source{a.source_generation:02}/compiler.bend'
            report['inputs'].append(pin(source)); dest = out / f'{role}{mode}'
            command = [sys.executable,'-B','selfhost/tools/build/native.py','--assets',
              'selfhost/manifests/assets-native.json','--host','native','--stage','N2',
              '--target','qbe','--mode','cache','--image',image['file'],
              '--image-receipt',str(parent),'--source',str(source),'--out',str(dest),
              '--seconds','45','--expected-stdout',expected['stdout']['file']]
            job = run(command,cwd=ROOT,stdout=out/f'{role}{mode}.build.stdout',
                      stderr=out/f'{role}{mode}.build.stderr',seconds=50)
            require(job['complete'],'Build/output check failed '+role+str(mode))
            receipt = json.loads((dest/'report.json').read_text())
            require(receipt['complete'],'Incomplete native receipt')
            row['products'][role] = dict(build=pin(dest/'report.json'),binary=receipt['binary'],
                                        source=pin(source),buildSeconds=receipt['wallSeconds'])
            save()
        for pair in range(4):
            for role in (['baseline','candidate'] if (mode+pair)%2==0 else ['candidate','baseline']):
                binary=row['products'][role]['binary'];verify(binary)
                job=run([binary['file'],'--threads','1','--gpu','off'],cwd=ROOT,
                  stdout=out/f'{mode}-{pair}-{role}.stdout',stderr=out/f'{mode}-{pair}-{role}.stderr',seconds=15)
                require(job['complete'] and job['stderr']['bytes']==0,'Runtime failed')
                require(all(job['stdout'][k]==expected['stdout'][k] for k in ['bytes','sha256']),
                        'Complete output differs from hosted reference')
                row['samples'].append(dict(role=role,pair=pair,**job));save()
        row['medians']={role:statistics.median(x['seconds'] for x in row['samples']
            if x['role']==role) for role in ['baseline','candidate']}
        row['ratio']=row['medians']['candidate']/row['medians']['baseline']
        row['complete']=True;save()
    for item in report['inputs']:verify(item)
    report['complete']=True
except Exception as error:
    report['error']=str(error);raise
finally:
    save();print(json.dumps(dict(complete=report['complete'],error=report.get('error'))))
