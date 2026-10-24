"""Seal the checked nq_uses shortcut ceiling for root-owned CPU3 timing."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('probe',Path(__file__).with_name('reader-identity-probe.py'))
probe=importlib.util.module_from_spec(spec);spec.loader.exec_module(probe)
pin=probe.pin

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    checks=ROOT/'selfhost/build/phase131/reader-identity-uses-check01/report.json'
    proof=ROOT/'selfhost/build/phase131/laws-string-reflexivity01/report.json'
    r=json.loads(checks.read_text());assert r['complete'] and all(x['independentOutputExact'] for x in r['observations'])
    inputs=[pin(Path(__file__)),pin(checks),pin(proof),*r['inputs']]
    variants=[]
    for role,path in [('baseline','p131-regions-uses01-candidate-build'),('candidate','p131-reader-identity-uses-ceiling01')]:
        report=ROOT/'selfhost/build/phase111'/path/'report.json';build=json.loads(report.read_text())
        assert build['complete'];inputs += [pin(report),*build['inputs'],build['binary']]
        variants.append(dict(name=role,binary=build['binary'],
            command=[build['binary']['file'],'--threads','1','--gpu','off','--','2047'],
            expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',prefix='2\n4094\n'),
                          stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
    for row in inputs:assert pin(Path(row['file']))==row
    out.mkdir();manifest=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=inputs,
        workloads=[dict(name='compiler-uses-private-identity',timeoutSeconds=20,variants=variants)],repetitions=2047,
        scope='Exact selected private borrowed String reader identity ceiling, QBE-only and unqualified. '
              'Same source/runtime; all independent nq_uses ordinary and repeated outputs passed. '
              'Five clean alternating pairs; whole-child time includes startup. Do not call this compiler speed.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    command=['python3',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(out/'guard'),
        '--seconds','60','--rss-mib','512','--available-mib','16384','--file-mib','64','--cpu','3','--',
        'python3',str(ROOT/'selfhost/tools/profiler/run.py'),'--manifest',str(out/'manifest.json'),
        '--out',str(out/'timing'),'--modes','clean','--rounds','5']
    (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,command=command),indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,jobs=str(out/'jobs.json'))))

if __name__=='__main__':main()
