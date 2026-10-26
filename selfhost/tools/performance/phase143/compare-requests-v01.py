"""Paired ordinary fresh-process requests; invokes per-job guards, never nest one."""
import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]


def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=3)
    a = p.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase143')
    assert 1 <= a.rounds <= 5 and all(c.isalnum() or c == '-' for c in out.name)
    reference = ROOT/'selfhost/build/phase134/reference03.json'
    refs = json.loads(reference.read_text())
    assert refs['complete']
    names = ['lexer', 'coverage-map-churn-128', 'coverage-closures-256']
    cases = [next(c for c in refs['cases'] if c['name'] == n) for n in names]
    images = dict(baseline=a.baseline.resolve(), candidate=a.candidate.resolve())
    inputs = [pin(__file__), pin(reference), *map(pin, images.values())]
    for c in cases:
        for k in ['source', 'expectedQbe']:
            assert pin(c[k]['file']) == c[k]
            inputs.append(c[k])
    out.mkdir(parents=True)
    report = dict(kind='phase143-paired-native-small-requests', complete=False,
                  inputs=inputs, rounds=a.rounds, rows=[], summary={},
                  scope='Fresh native processes, same inputs/Base/CPU3 and exact frozen QBE; '
                        'alternating order. Compiler request latency, not generated-program runtime. '
                        'Three pairs are an exploratory comparison, not a confidence interval.')
    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    try:
        for round_no in range(a.rounds):
            for i, c in enumerate(cases):
                order = ['baseline', 'candidate']
                if (round_no+i) % 2:
                    order.reverse()
                row = dict(name=c['name'], round=round_no, order=order, runs={})
                report['rows'].append(row)
                save()
                for mode in order:
                    stem = f'p143-{out.name}-{round_no}-{i}-{mode}'
                    dest = ROOT/'selfhost/build/phase130'/stem
                    guard = out/(stem+'-guard')
                    cmd = [sys.executable, '-B', str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
                           '--out', str(guard), '--seconds', '70', '--rss-mib', '3072',
                           '--available-mib', '16384', '--file-mib', '64', '--cpu', '3', '--',
                           sys.executable, '-B', str(ROOT/'selfhost/tools/performance/phase130/native-request.py'),
                           '--image', str(images[mode]), '--source', c['source']['file'],
                           '--carrier-receipt', str(ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'),
                           '--expected-qbe', c['expectedQbe']['file'], '--out', str(dest), '--seconds', '60']
                    subprocess.run(cmd, check=True, cwd=ROOT, stdout=subprocess.DEVNULL)
                    result = json.loads((dest/'report.json').read_text())
                    assert result['complete'] and result['byteExact']
                    row['runs'][mode] = dict(seconds=result['nativeSeconds'],
                                             receipt=pin(dest/'report.json'), guard=pin(guard/'process.json'))
                    save()
                row['ratio'] = row['runs']['candidate']['seconds']/row['runs']['baseline']['seconds']
                save()
        for name in names:
            rows = [r for r in report['rows'] if r['name'] == name]
            medians = {mode: statistics.median(r['runs'][mode]['seconds'] for r in rows) for mode in images}
            report['summary'][name] = dict(medians=medians,
                medianPairedRatio=statistics.median(r['ratio'] for r in rows),
                ratioOfMedians=medians['candidate']/medians['baseline'],
                pairs=[r['ratio'] for r in rows])
        for item in inputs:
            assert pin(item['file']) == item
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        save()
        print(json.dumps(dict(complete=report['complete'], summary=report['summary'])))


if __name__ == '__main__':
    main()
