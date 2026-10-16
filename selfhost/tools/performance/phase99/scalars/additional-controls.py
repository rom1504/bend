#!/usr/bin/env python3
"""Use already checked APIs for additional full-width native controls."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
OUT = ROOT/'selfhost/build/phase99/full-width01'
QUAL = ROOT/'selfhost/build/phase99/scalars-small03'
NODE = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
CC = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
GUARD = ROOT/'selfhost/tools/performance/phase86/guard.py'


def pin(p):
    p = Path(p).resolve(); data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    assert not (OUT/'report.json').exists()
    previous = json.loads((QUAL/'report.json').read_text()); assert previous['complete']
    for row in previous['inputs']: assert pin(row['file']) == row
    fixture = json.loads((HERE.parent/'scalar-controls/scon-full-width01.json').read_text())
    plan = json.loads((QUAL/'plan.json').read_text())
    plan['cases'] = []
    plan['controls'] = [dict(id='full-width', source=fixture['source'], stdout=fixture['expectedStdout'], stderr=fixture['expectedStderr'], scalar=0)]
    (OUT/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
    report = dict(complete=False, method=pin(__file__), qualification=pin(QUAL/'report.json'), rows=[])
    def save(): (OUT/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    def run(name, argv, rss=2048):
        folder = OUT/(name+'-guard')
        cmd = [sys.executable, '-B', str(GUARD), '--out', str(folder), '--seconds', '90', '--rss-mib', str(rss), '--available-mib', '16384', '--cpu', '3', '--', *map(str,argv)]
        process = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        (OUT/(name+'.launcher.log')).write_text(process.stdout+process.stderr)
        raw = json.loads((folder/'process.json').read_text()); report['rows'].append(dict(name=name, process=raw, receipt=pin(folder/'process.json'))); save()
        assert process.returncode == 0 and raw['complete'] and raw['returncode'] == 0 and not raw.get('stoppedFor'), name
        return folder
    try:
        run('emission', [NODE, '--stack-size=16384', '--max-old-space-size=3072', HERE/'emit.mjs', OUT/'plan.json', OUT/'emission'], 4096)
        emitted = json.loads((OUT/'emission/report.json').read_text()); assert emitted['complete']
        for row in emitted['programs']:
            c = Path(row['c']['file']); assert pin(c) == row['c']
            binary = OUT/row['id']
            run(row['id']+'-build', [CC, '-isystem', CC.parent.parent/'include/clang', '-O2', c, '-o', binary, '-lm', '-pthread'])
            result = run(row['id']+'-run', [binary, '--threads', '1', '--gpu', 'off'])
            assert (result/'stdout.log').read_text() == row['stdout']
            assert (result/'stderr.log').read_text() == row['stderr']
        candidate = (OUT/'emission/full-width-candidate.c').read_text()
        raw = (OUT/'emission/full-width-raw.c').read_text()
        denied = (OUT/'emission/full-width-explicit-false.c').read_text()
        assert '#define NATIVE_FIELD32_CID_SCON_0 1' in candidate
        assert '#define NATIVE_FIELD32_CID_SCON_0 1' not in raw+denied
        assert '#define NATIVE_FIELD32_CID_SCON_1 1' not in candidate
        report.update(complete=True, programs=len(emitted['programs']), emission=pin(OUT/'emission/report.json'),
                      fullWidthAndAliasesExact=True, field0Only=True, rawAndDeniedUnchanged=True)
    except BaseException as e:
        report['error'] = repr(e); raise
    finally: save()


if __name__ == '__main__': main()
