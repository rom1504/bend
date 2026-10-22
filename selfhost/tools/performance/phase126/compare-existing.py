"""Rotate already-built candidate products against the frozen source/output oracle."""
import argparse
import importlib.util
import os
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('oracle', ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py')
O = importlib.util.module_from_spec(spec)
spec.loader.exec_module(O)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--variant', action='append', required=True, help='LABEL=SCREENREPORT; selects candidate role')
    p.add_argument('--case', nargs='+', required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=3)
    p.add_argument('--scale', type=int, default=4)
    a = p.parse_args()
    assert sorted(os.sched_getaffinity(0)) == [3], 'Root serial CPU3 guard required'
    assert 1 <= a.rounds <= 20 and 1 <= a.scale <= 32 and len(set(a.case)) == len(a.case)
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    manifest = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
    counts_file = ROOT/'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json'
    builder = ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
    cases = {c['name']: c for c in O.read(manifest)['cases']}
    counts = O.read(counts_file)['cases']
    assert set(a.case) <= set(cases)
    inputs = [O.pin(__file__),O.pin(O.__file__),O.pin(manifest),O.pin(counts_file),O.pin(builder),
              O.pin(ROOT/'selfhost/tools/performance/phase125/repeat-products.py')]
    variants, verified = {}, set()
    def verify(pin):
        key = (pin['file'],pin['sha256'])
        if key not in verified:
            O.verify(pin)
            verified.add(key)
    for value in a.variant:
        label, file = value.split('=',1)
        assert re.fullmatch('[A-Za-z0-9_-]+',label) and label not in variants
        screen = O.read(file)
        assert screen['complete'] and all(r.get('correct') and r['status']==0 for r in screen['rows'])
        inputs.extend([O.pin(file),*screen['inputs']])
        for row in screen['inputs']:
            verify(row)
        emissions = []
        for row in screen['inputs']:
            if Path(row['file']).suffix == '.json':
                data = O.read(row['file'])
                if isinstance(data,dict) and data.get('complete') and isinstance(data.get('cases'),list) and isinstance(data.get('runtime'),dict):
                    emissions.append((row,data))
        products = {}
        for name in a.case:
            rows = [r for r in screen['rows'] if r['name']==name and r['role']=='candidate']
            assert rows and all(r['binary']==rows[0]['binary'] for r in rows)
            binary = rows[0]['binary']
            build_rows = [b for b in screen['builds'] if b['name']==name]
            assert len(build_rows)==1 and build_rows[0]['status']==0
            build_pin = build_rows[0]['report']; verify(build_pin)
            build = O.read(build_pin['file'])
            assert build['complete'] and build['binary']==binary
            for row in build['inputs']:
                verify(row)
            expected_builder = O.pin(builder)
            assert any(x['sha256']==expected_builder['sha256'] and x['bytes']==expected_builder['bytes'] for x in build['inputs'])
            matches = [(receipt,e,c) for receipt,e in emissions for c in e['cases']
                       if c['name']==name and c.get('verified') and c['source']==cases[name]['source']
                       and c['qbe'] in build['inputs'] and e['runtime'] in build['inputs']]
            assert matches, 'Missing exact source→verified QBE→runtime→binary lineage: '+name
            receipt,e,c = matches[0]
            assert all(other['runtime']==e['runtime'] for _,other,_ in matches)
            for row in (cases[name]['source'],cases[name]['expectedStdoutEvidence'],binary,e['runtime'],c['qbe']):
                verify(row)
            products[name] = dict(binary=binary,runtime=e['runtime'],source=c['source'],qbe=c['qbe'],
                                  build=build_pin,emission=receipt)
            inputs.append(build_pin)
        variants[label] = dict(screen=O.pin(file),cases=products)
    assert len(variants)>=2
    for row in inputs:
        verify(row)
    out.mkdir(parents=True)
    report = dict(complete=False,inputs=inputs,variants=variants,cases=[cases[n] for n in a.case],
        rounds=a.rounds,scale=a.scale,rows=[],builds=[],
        scope='No builds. Each label selects the candidate role of its exact completed screen. Aligned builder/source/runtime/product lineage checked. Complete unchanged source/output/count oracle; roles rotate once each round. Subset evidence, no broad-parity claim.')
    save = lambda: O.save(out/'report.json',report)
    save(); started=time.monotonic()
    try:
        for name in a.case:
            case = dict(cases[name],repetitions=counts[name]['repetitions']*a.scale,warmups=counts[name]['warmups'])
            for rnd in range(a.rounds):
                labels=list(variants);labels=labels[rnd%len(labels):]+labels[:rnd%len(labels)]
                for label in labels:
                    binary=variants[label]['cases'][name]['binary']
                    cmd=[binary['file'],'--threads','1','--gpu','off','--',str(case['repetitions']),str(case['warmups']),*map(str,case['runtimeArgs'])]
                    start=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=30);wall=time.monotonic()-start
                    stdout=out/f'{name}-{label}-{rnd}.stdout';stderr=out/f'{name}-{label}-{rnd}.stderr'
                    stdout.write_bytes(child.stdout);stderr.write_bytes(child.stderr)
                    row=dict(name=name,role=label,round=rnd,command=cmd,binary=binary,status=child.returncode,
                             wallSeconds=wall,stdout=O.pin(stdout),stderr=O.pin(stderr))
                    report['rows'].append(row);save()
                    row['elapsedMs']=O.observation(child.stdout,child.stderr,child.returncode,case,wall)
                    row['correct']=True;save()
        for row in inputs:
            O.verify(row)
        for variant in variants.values():
            for product in variant['cases'].values():
                O.verify(product['binary']);O.verify(product['runtime'])
        report['complete']=True
    finally:
        report['seconds']=time.monotonic()-started;save()


if __name__=='__main__':
    main()
