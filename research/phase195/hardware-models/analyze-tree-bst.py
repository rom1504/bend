#!/usr/bin/env python3
"""Offline ELF/physical-PC join for the one frozen tree/BST capture."""
from pathlib import Path
import collections
import gzip
import hashlib
import json
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
CAPTURE = ROOT/'selfhost/build/phase195/profile-tree-bst01'
PLAN = ROOT/'selfhost/build/phase195/profile-tree-bst-plan01'
OUT = HERE/'tree-bst-profile-results'


def pin(path):
    path = Path(path)
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


OUT.mkdir(exist_ok=False)
raw, normalized = read(CAPTURE/'report.json'), read(PLAN/'per-invocation.json')
plan = read(PLAN/'plan.json')
report = dict(targetsRun=False, method=pin(__file__), capture=pin(CAPTURE/'report.json'),
              normalization=pin(PLAN/'per-invocation.json'), rows=[],
              targetCpuSeconds=sum(row['cpuSeconds'] for row in raw['rows']),
              targetWallSeconds=sum(row['wallSeconds'] for row in raw['rows']))
coverage = []
for row in normalized['rows']:
    estimate = next(e for e in plan['estimates'] if e['case'] == row['case'] and e['role'] == row['role'])
    binary = estimate['binary']
    assert pin(binary['file']) == binary
    asm = subprocess.check_output(['objdump', '-d', '--no-show-raw-insn', '-M', 'intel', binary['file']], text=True)
    instructions = {}
    for line in asm.splitlines():
        match = re.match(r'\s*([a-f0-9]+):\s+(.+)', line)
        if match:
            instructions[int(match[1], 16)] = match[2]
    pcs = collections.defaultdict(lambda: dict(samples=0, weightedMicroseconds=0))
    analyses = []
    for path in sorted(CAPTURE.glob('*sample*'+row['case']+'-'+row['role']+'-'+row['role']+'/analysis.json')):
        analysis = read(path)
        analyses.append(pin(path))
        coverage.append(analysis['coverage']['sampled_thread_cpu_fraction'])
        shutil.copy2(path, OUT/(path.parent.name+'-analysis.json'))
        for pc in analysis['pcs']:
            key = (pc.get('decoded'), pc.get('elf_address'), pc['category'])
            pcs[key]['samples'] += pc['samples']
            pcs[key]['weightedMicroseconds'] += pc['samples']*analysis['header']['period_us']
    joined = []
    for (symbol, address, category), values in pcs.items():
        joined.append(dict(symbol=symbol, address=address, category=category, **values,
                           instruction=instructions.get(int(address, 16)) if category == 'executable' and address else None))
    selected = re.split(r'(?m)^([0-9a-f]+) <([^>]+)>:\n', asm)
    helpers = []
    for i in range(1, len(selected), 3):
        address, symbol, body = selected[i:i+3]
        if symbol in ('p125_rt_ctor2', 'p125_rt_ctor3', 'p125_rt_take2', 'p125_rt_take3') or symbol.startswith('NF_FID_112_51_55_46_98_115_116_46_105_110_115_101_114_116_'):
            destination = OUT/(row['case']+'-'+row['role']+'-'+symbol+'.asm.gz')
            destination.write_bytes(gzip.compress((address+' <'+symbol+'>:\n'+body).encode(), mtime=0))
            helpers.append(pin(destination))
    report['rows'].append(dict(case=row['case'], role=row['role'], binary=binary,
                              analyses=analyses, helpers=helpers,
                              pcs=sorted(joined, key=lambda pc: -pc['weightedMicroseconds'])))
report['minimumSampledThreadCpuCoverage'] = min(coverage)
for source, name in [(CAPTURE/'report.json', 'capture.json'), (PLAN/'per-invocation.json', 'per-invocation.json'),
                     (PLAN/'comparison.json', 'comparison.json'), (PLAN/'summary.md', 'summary.md'),
                     (CAPTURE.with_name(CAPTURE.name+'-guard')/'process.json', 'guard.json'),
                     (CAPTURE.with_name(CAPTURE.name+'-guard')/'retention.json', 'retention.json')]:
    shutil.copy2(source, OUT/name)
(OUT/'pc-join.json').write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps({key:report[key] for key in ('targetCpuSeconds', 'targetWallSeconds', 'minimumSampledThreadCpuCoverage')}))
