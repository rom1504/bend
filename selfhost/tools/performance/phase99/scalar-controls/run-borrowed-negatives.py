#!/usr/bin/env python3
"""Admit each bad helper first; then require unchanged production laws to fail."""
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
OUT = ROOT/'selfhost/build/phase99/borrowed-args-negatives01'
CHECK = HERE.parent/'check-laws.py'


def main():
    OUT.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, rows=[], scope='Safe helper admissions followed by unchanged law source rejection; positive independent kernel result is separate.')
    def save(): (OUT/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    try:
        for role in ['bad-head', 'bad-tail', 'bad-order']:
            for kind in ['candidate', 'laws']:
                out = OUT/(role+'-'+kind)
                source = HERE/'borrowed-args-laws01'/role/(kind+'.bend')
                result = subprocess.run([sys.executable, '-B', str(CHECK), '--source', str(source), '--source-only', '--out', str(out)], cwd=ROOT, capture_output=True, text=True)
                (OUT/(role+'-'+kind+'.log')).write_text(result.stdout+result.stderr)
                raw = json.loads((out/'report.json').read_text())
                if kind == 'candidate': assert result.returncode == 0 and raw['complete']
                else:
                    assert result.returncode != 0 and not raw['complete']
                    check = raw['rows']['check']; assert not check['process'].get('stoppedFor')
                    assert check['process']['returncode'] == 1
                    message = check['stdout']+check['stderr']
                    assert 'Error:' in message and ('expected' in message or 'Expected' in message), message
                report['rows'].append(dict(role=role, kind=kind, report=str(out/'report.json'), expectedOutcome=True)); save()
        report['complete'] = True
    except BaseException as e:
        report['error'] = repr(e); raise
    finally: save()


if __name__ == '__main__': main()
