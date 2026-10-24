#!/usr/bin/env python3
"""Plot already recorded equal-source request observations; execute no targets."""
import argparse
import hashlib
import json
import os
from pathlib import Path

os.environ.setdefault('MPLCONFIGDIR', '/tmp/bend-phase134-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pin(path):
    p = Path(path).resolve()
    data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def load(report_path):
    report = json.loads(Path(report_path).read_text())
    assert report['complete'] and report['requestComplete']
    sample_pin = report['samplesFile']
    assert pin(sample_pin['file']) == sample_pin
    request_pin = report['requestReport']
    assert pin(request_pin['file']) == request_pin
    request = json.loads(Path(request_pin['file']).read_text())
    assert request['complete']
    rows = [json.loads(line) for line in Path(sample_pin['file']).read_text().splitlines()]
    return report, request, rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--parent', type=Path, required=True)
    p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    parent, candidate = load(a.parent), load(a.candidate)
    assert parent[1]['source'] == candidate[1]['source']
    assert candidate[1]['byteExact']
    a.out.mkdir(parents=True)
    fig, axes = plt.subplots(2, 1, figsize=(9, 6), sharex=True, constrained_layout=True)
    for label, color, data in [('Phase131 producer', '#b65c2b', parent), ('Streaming candidate', '#246a9b', candidate)]:
        rows = data[2]
        xs = [r['elapsedSeconds'] for r in rows]
        axes[0].plot(xs, [r['processTreeRssBytes'] / 1e9 for r in rows], label=label, color=color)
        axes[1].plot(xs, [(r['productBytes'] or 0) / 1e6 for r in rows], label=label, color=color)
    axes[0].set_ylabel('Observed descendant RSS (GB)')
    axes[1].set_ylabel('Visible QBE output (MB)')
    axes[1].set_xlabel('Elapsed request observation (seconds)')
    axes[0].legend(loc='upper left')
    for ax in axes:
        ax.grid(alpha=.2)
        ax.set_ylim(bottom=0)
    fig.suptitle('Identical compiler source and output; one observation per executable\n'
                 'Memory/visibility evidence, not isolated stage costs or a calibrated speed comparison', fontsize=11)
    output = a.out / 'memory.svg'
    fig.savefig(output, metadata={'Date': None})
    plt.close(fig)
    output.write_text('\n'.join(line.rstrip() for line in output.read_text().splitlines()) + '\n')
    receipt = dict(complete=True, targetsRun=False,
        inputs=[pin(__file__), pin(a.parent), pin(a.candidate),
                parent[0]['samplesFile'], candidate[0]['samplesFile'],
                parent[0]['requestReport'], candidate[0]['requestReport']],
        source=parent[1]['source'], output=pin(output),
        scope='One-second process-tree RSS and output visibility. Shared pages may be counted more than once; no PSS, live-object or exclusive compiler-stage claim.')
    (a.out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')


if __name__ == '__main__':
    main()
