#!/usr/bin/env python3
"""Reuse checked APIs for a balanced, complete-output native append experiment."""
import argparse
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
GUARD = ROOT/'selfhost/tools/performance/phase86/guard.py'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
CC = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qualification', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    qualification = a.qualification.resolve()
    r = json.loads((qualification/'report.json').read_text())
    assert r['complete'] and r['inputsUnchanged']
    for row in r['inputs']: assert pin(row['file']) == row
    report = dict(complete=False, rows=[], samples=[], method=pin(__file__),
                  qualification=pin(qualification/'report.json'),
                  scope='Synthetic append/reconstruction, one CPU, complete outputs. '
                        'Whole-process time, not a compiler-speed result.')

    def save(): (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    def run(name, argv, seconds=60, rss=2048):
        folder = out/(name+'-guard')
        cmd = [sys.executable, '-B', str(GUARD), '--out', str(folder), '--seconds', str(seconds),
               '--rss-mib', str(rss), '--available-mib', '16384', '--cpu', '3', '--', *map(str, argv)]
        result = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        (out/(name+'.launcher.log')).write_text(result.stdout+result.stderr)
        process = json.loads((folder/'process.json').read_text())
        report['rows'].append(dict(name=name, process=process, receipt=pin(folder/'process.json'))); save()
        assert result.returncode == 0 and process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor'), name
        return folder, process

    try:
        plan = json.loads((qualification/'plan.json').read_text())
        plan['cases'] = []
        plan['controls'] = [dict(id='append', source=pin(HERE/'append-micro.bend'),
                                 stdout='missing input\n', stderr='', scalar=0)]
        (out/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
        run('emission', [NODE, '--stack-size=16384', '--max-old-space-size=3072',
                         HERE/'emit.mjs', out/'plan.json', out/'emission'], 120, 4096)
        emission = json.loads((out/'emission/report.json').read_text()); assert emission['complete']
        binaries = {}
        for role in ['baseline', 'candidate']:
            row = next(x for x in emission['programs'] if x['id'] == 'append-'+role)
            c = row['c']; assert pin(c['file']) == c
            binary = out/(role+'-program')
            run(role+'-clang', [CC, '-isystem', CC.parent.parent/'include/clang', '-O2', c['file'], '-o', binary, '-lm', '-pthread'])
            binaries[role] = pin(binary)
        inputs = ['abcdefgh'*8, 'λ🙂xyz']
        expected = str((sum(map(ord, ''.join(inputs)))*100000) % 2**32)+'\n'+'\n'.join(inputs)+'\n'
        for rnd in range(4):
            for role in (['baseline', 'candidate'] if rnd % 2 == 0 else ['candidate', 'baseline']):
                folder, process = run(f'round{rnd}-{role}', [binaries[role]['file'], '--threads', '1', '--gpu', 'off', '--', *inputs], 30)
                assert (folder/'stdout.log').read_text() == expected
                assert (folder/'stderr.log').read_text() == 'phase99-append\n'
                report['samples'].append(dict(round=rnd, role=role, wallSeconds=process['wallSeconds'], fullOutputExact=True)); save()
        medians = {role: statistics.median(x['wallSeconds'] for x in report['samples'] if x['role'] == role) for role in binaries}
        report.update(complete=True, medians=medians, candidateOverBaseline=medians['candidate']/medians['baseline'], binaries=binaries,
                      source=pin(HERE/'append-micro.bend'), emission=pin(out/'emission/report.json'))
    except BaseException as e:
        report['error'] = repr(e); raise
    finally: save()


if __name__ == '__main__': main()
