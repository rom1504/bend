"""Seal two independently checked wide-record kernels for root CPU3 timing."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
def pin(p):
    p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
p.add_argument('--repeats',type=int,default=262143);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
assert 1<=a.repeats<=10000000
checks=ROOT/'selfhost/build/phase131/wide-builds01/report.json';r=json.loads(checks.read_text());assert r['complete']
finite=ROOT/'selfhost/build/phase131/wide-finite02/report.json';f=json.loads(finite.read_text());assert f['complete']
inputs=[pin(__file__),pin(checks),pin(finite),pin(HERE/'oracle.json'),*r['inputs'],*f['inputs']]
workloads=[]
for case in ['compiler-kdef','record-transfer']:
    variants=[]
    for role in ['baseline','candidate']:
        row=next(x for x in r['rows'] if x['case']==case and x['role']==role)
        build=json.loads(Path(row['build']['file']).read_text());assert build['complete'] and build['outputExact']
        inputs += [row['build'],*build['inputs'],build['binary']]
        variants.append(dict(name=role,binary=build['binary'],
            command=[build['binary']['file'],'--threads','1','--gpu','off','--',str(a.repeats)],
            expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',prefix=f'1\n{a.repeats}\n'),
                          stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
    workloads.append(dict(name=case,timeoutSeconds=20,variants=variants))
for row in inputs:assert pin(row['file'])==row,row['file']
out.mkdir();manifest=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=inputs,
    workloads=workloads,repetitions=a.repeats,
    scope='Checked four-bound widening8to16 on frozen final source. Same source programs/runtime, unchanged '
          'late inline template, exact independent11line output gates on four binaries. ActualKDef9 and '
          'unrelated9field scalar name queries;16field ordinary control. No whole-compiler qualification or gain claim.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
cmd=['python3',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(out/'guard'),
    '--seconds','120','--rss-mib','512','--available-mib','16384','--file-mib','64','--cpu','3','--',
    'python3',str(ROOT/'selfhost/tools/profiler/run.py'),'--manifest',str(out/'manifest.json'),
    '--out',str(out/'timing'),'--modes','clean','--rounds','5']
(out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,command=cmd),indent=2)+'\n')
print(json.dumps(dict(complete=True,targetsRun=False,jobs=str(out/'jobs.json'))))
