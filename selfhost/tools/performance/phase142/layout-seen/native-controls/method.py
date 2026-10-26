#!/usr/bin/env python3
"""Metadata-only native layout-control planning/receipt comparison; never executes targets."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
TRANSPORT = ROOT / 'selfhost/tools/performance/phase125/native/native-emit.py'


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            size += len(block)
            digest.update(block)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def verify(row):
    assert pin(row['file']) == row, 'Changed pinned input: ' + row['file']
    return Path(row['file'])


def read(path):
    return json.loads(Path(path).read_text())


def write_fresh(path, value):
    path = Path(path).resolve()
    assert not path.exists(), 'Fresh metadata output required'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n')


def plan(args):
    fixtures = read(HERE / 'fixtures.json')
    selection_file = ROOT / 'implementation/phase141/candidate.json'
    selection = read(selection_file)
    assert selection['nativeQualified'] and selection['complete']
    baseline = verify(selection['preferredNative'])
    candidate = args.candidate.resolve()
    verify(pin(candidate))
    directory = args.directory.resolve()
    assert directory.is_relative_to(ROOT / 'selfhost/build/phase111') and not directory.exists()
    inputs = [pin(__file__), pin(HERE / 'fixtures.json'), pin(selection_file),
              pin(TRANSPORT), pin(ROOT / 'selfhost/tools/performance/phase111/native-assets01.json'),
              pin(baseline), pin(candidate), fixtures['priorReceipt'], fixtures['generator']]
    jobs = []
    for variant, image in [('baseline', baseline), ('candidate', candidate)]:
        for case in fixtures['cases']:
            source = verify(case['source'])
            inputs.append(case['source'])
            target = directory / variant / case['name']
            command = [sys.executable, '-B', str(TRANSPORT), '--image', str(image),
                       '--source', str(source), '--mode', 'cache', '--seconds', '45', '--out', str(target)]
            if variant == 'candidate' and case['expect'] == 'acceptance':
                command += ['--reference', str(directory / 'baseline' / case['name'])]
            jobs.append(dict(variant=variant, name=case['name'], expect=case['expect'],
                             expectedTransportExit=1 if case['expect'] == 'refusal' else 0,
                             source=case['source'], image=pin(image), output=str(target), command=command))
    for row in inputs:
        verify(row)
    write_fresh(args.out, dict(kind='phase142-native-layout-control-plan', complete=True,
                              targetsRun=False, inputs=inputs, jobs=jobs,
                              scope='Run serially under root CPU/RSS guard. Refusal transport exit1 is expected; observation method authenticates actual child rejection. No machine builds or generated-program execution.'))


def observe(args):
    data = read(args.plan)
    assert data['kind'] == 'phase142-native-layout-control-plan' and data['complete']
    for item in data['inputs']:
        verify(item)
    observations = {}
    receipts = []
    for job in data['jobs']:
        location = Path(job['output'])
        report_file = location / 'report.json'
        receipt = read(report_file)
        assert receipt['kind'] == 'phase125-aligned-native-source-qbe-emission'
        assert receipt['mode'] == 'cache' and receipt['image'] == job['image']
        assert job['source'] in receipt['inputs']
        for item in receipt['inputs']:
            verify(item)
        runs = [x for x in receipt['jobs'] if x['label'] == 'native-request']
        assert len(runs) == 1
        run = runs[0]
        assert not run.get('timedOut') and run['exitCode'] == job['expectedTransportExit']
        product = verify(receipt['product']).read_bytes()
        stderr = verify(receipt['stderr']).read_bytes()
        if job['expect'] == 'refusal':
            assert not receipt['complete'] and receipt['failedStage'] == 'emission'
            assert receipt['gates']['emission'] == 'failed' and product == b''
            # Payload comes from the prior checked-layout observation. The prefix
            # is the selected ordinary P86 adapter, independently re-observed below.
            fixtures = read(HERE / 'fixtures.json')
            case = next(x for x in fixtures['cases'] if x['name'] == job['name'])
            diagnostic = case['priorObservation']['emitted']['diagnostic']
            assert diagnostic.startswith('Error: ')
            expected = ('compile: ' + diagnostic[len('Error: '):] + '\n').encode()
            assert stderr == expected and not (location / 'build').exists()
        else:
            assert receipt['complete'] and receipt['gates']['emission'] == 'passed'
            assert product and stderr == b''
        observations[(job['variant'], job['name'])] = (product, stderr, run['exitCode'])
        receipts.append(pin(report_file))
    rows = []
    for name in ('constructor', 'dead', 'erased'):
        assert observations[('baseline', name)] == observations[('candidate', name)]
        rows.append(dict(name=name, exactExitStdoutStderr=True,
                         expectedRefusal=name == 'constructor', qbeCompared=name != 'constructor'))
    write_fresh(args.out, dict(kind='phase142-native-layout-control-observation', complete=True,
                              passed=True, inputs=[pin(__file__), pin(args.plan), *data['inputs'], *receipts],
                              rows=rows, scope='One actual native refusal and two actual native emission acceptances, exact against qualified parent. Positives are complete QBE comparisons, not generated-program execution or whole compiler qualification.'))


parser = argparse.ArgumentParser(description=__doc__)
sub = parser.add_subparsers(dest='mode', required=True)
p = sub.add_parser('plan')
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--directory', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p = sub.add_parser('observe')
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
plan(args) if args.mode == 'plan' else observe(args)
