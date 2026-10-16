#!/usr/bin/env python3
"""Authenticate closed candidate04 emissions and exact saved-product observations."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT / 'selfhost/build/phase102'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(item):
    actual = pin(item['file'])
    assert actual == item, item['file']
    return actual


def read(path):
    return json.loads(Path(path).read_text())


def hints(text):
    return {name: hint for hint, name in re.findall(r'(?m)^(NF_INLINE|INLINE) Term (NF_FID_\w+)\(', text)}


def normalized(text):
    return text.replace('NF_INLINE Term NF_FID_', 'INLINE Term NF_FID_')


def job(record):
    directory = Path(record['guard'])
    raw = read(directory / 'process.json')
    assert raw == record['process'] and raw['complete'] and raw['returncode'] == 0
    assert record['guardExit'] == 0 and not raw.get('stoppedFor') and not raw.get('interrupted')
    argv = record['command'][record['command'].index('--') + 1:]
    assert raw['command'] == ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase86', 'taskset', '-c', '3'] + argv
    return pin(directory / 'process.json')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    emission_path = BUILD / 'projection-cost-emission01/report.json'
    emission = read(emission_path)
    assert emission['complete'] and len(emission['programs']) == 7
    emission_pin = pin(emission_path)
    verify(emission['compilerSource']); verify(emission['api']); verify(emission['acquisition'])
    acquired = read(emission['acquisition']['file'])
    assert acquired['complete'] and acquired['source'] == emission['compilerSource']
    ablation_path = BUILD / 'hint-ablation-run01/report.json'
    ablation = read(ablation_path)
    assert ablation['complete']
    for item in ablation['methodInputs'] + ablation['products'] + [ablation['method'], ablation['plans']]:
        verify(item)
    cases = {case['id']: case for case in read(ablation['products'][1]['file'])['cases']}
    ablations = {row['id']: row for row in ablation['rows']}
    rows = []
    observations = []
    for emitted in emission['programs']:
        assert emitted['complete']
        for key in ('source', 'receipt', 'c'):
            verify(emitted[key])
        receipt = read(emitted['receipt']['file'])
        assert receipt['complete']
        name = emitted['id']; new = Path(emitted['c']['file']).read_text()
        row = dict(id=name, source=emitted['source'], receipt=emitted['receipt'], candidateC=emitted['c'])
        if name not in ablations:
            oldpath = BUILD / 'final-emission03' / name / 'emitted/program.c'
            priorpath = BUILD / 'depth-emission01' / name / 'emitted/program.c'
            old = oldpath.read_text()
            row.update(parentC=pin(oldpath), priorCostC=pin(priorpath),
                hintsOnly=normalized(old) == normalized(new),
                priorHintsRestored=hints(new) == hints(priorpath.read_text()))
            assert row['hintsOnly'] and row['priorHintsRestored']
        else:
            previous = ablations[name]
            verify(previous['diagnostic'])
            diagnostic = read(previous['diagnostic']['file'])
            product = previous['products']['prior-hints']
            assert emitted['c']['sha256'] == verify(product['c'])['sha256']
            assert Path(product['c']['file']).read_bytes() == Path(emitted['c']['file']).read_bytes()
            row.update(exactPriorProductC=product['c'], inheritedBinary=verify(product['binary']),
                diagnostic=previous['diagnostic'], identicalPriorProduct=True)
            assert normalized(Path(diagnostic['after']['file']).read_text()) == normalized(new)
            assert hints(new) == hints(Path(diagnostic['before']['file']).read_text())
            for role, existing in previous['products'].items():
                verify(existing['c']); verify(existing['binary']); job(existing['build'])
                command = existing['build']['command']
                tail = command[command.index('--') + 1:]
                assert tail[-7:] == ['-std=c11', '-O3', existing['c']['file'], '-o', existing['binary']['file'], '-lpthread', '-lm']
            for sample in previous['samples']:
                existing = previous['products'][sample['role']]
                verify(sample['child']); process = job(sample['job'])
                child = read(sample['child']['file'])
                values = list(cases[name]['point']['args']) + [0, 0]
                argv = [existing['binary']['file'], '--threads', '1', '--gpu', 'off', '--',
                        str(sample['repetitions']), str(sample['warmups']), str(values[0]), str(values[1])]
                assert child['command'] == argv and child['returncode'] == 0 and child['stderr'] == ''
                assert child['stdout'] == str(cases[name]['expected']) + '\n' + str(sample['warmups']) + '\n' + str(sample['repetitions']) + '\n' + str(sample['elapsedMs']) + '\n'
                assert sample['correct'] and sample['qualified'] and sample['elapsedMs'] >= 100
                observations.append(dict(id=name, role=sample['role'], round=sample['round'],
                    inheritedCandidate04Product=sample['role'] == 'prior-hints',
                    child=sample['child'], process=process, binary=existing['binary']))
        rows.append(row)
    assert len(observations) == 128
    assert sum(row['inheritedCandidate04Product'] for row in observations) == 32
    assert pin(emission_path) == emission_pin
    report = dict(complete=True, targetsRun=False, method=pin(__file__),
        candidateRecipe=pin(BUILD / 'projection-cost-source01/changes.json'),
        acquisition=emission['acquisition'], closedEmission=emission_pin,
        ablationComparison=pin(ablation_path), programs=rows, observations=observations,
        totalRetainedComparisonObservations=128, inheritedCandidate04ProductObservations=32,
        freshCandidate04Executions=0, nativeCandidate04Qualified=False,
        scope='Seven actual checked-API products. Three apps differ only in inline hints from qualified03. '
              'Four runtime products exactly equal prior hint-ablation C and inherit only the 32 matching '
              'product observations; the other 96 observations remain comparison context. '
              'Full captured outputs, product binaries/builds and raw guard receipts authenticated. '
              'No new runtime measurement or native04 image qualification.')
    out = args.out.resolve(); assert out.is_relative_to(BUILD)
    out.mkdir(parents=True, exist_ok=False)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, programs=7, inherited=32, comparison=128)))


if __name__ == '__main__':
    main()
