#!/usr/bin/env python3
"""Frozen final held-out gate: three new sources, fixed native image, raw/fast QBE.

Run only under the root's serial external guard. Refusal is a gate failure;
there is no source exclusion, policy search, optimizer adaptation, or retry.
"""
import argparse
import hashlib
import json
import os
import shutil
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(file):
    file = Path(file).resolve(strict=True)
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--max-seconds', type=float, default=25)
    a = p.parse_args()
    assert 1 <= a.max_seconds <= 30
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    started = time.monotonic()
    manifest = json.loads((HERE/'manifest.json').read_text())
    report = dict(kind='phase107-heldout-controls', version=1, complete=False, passed=False,
                  manifest=pin(HERE/'manifest.json'), started=time.time(), jobs=[], builds=[],
                  observations=[], snapshots=[], affinity=sorted(os.sched_getaffinity(0)),
                  scope=manifest['scope'], planned=manifest['planned'],
                  clockScope='Recorded process wall is diagnostic; this is a correctness gate, not a speedup measurement.')

    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    def verify(item):
        assert pin(item['file']) == item, 'changed frozen input: '+item['file']

    save()
    try:
        assert manifest['kind'] == 'phase107-heldout-freeze' and manifest['targetsRun'] is False
        for item in manifest['inputs'].values():
            verify(item)
        assert pin(sys.executable) == manifest['inputs']['python']
        for name in ['controls.py', 'oracle.py', 'expected.json', 'manifest.json',
                     'gcd.bend', 'triangular.bend', 'saturating.bend']:
            shutil.copyfile(HERE/name, out/('snapshot-'+name))
            report['snapshots'].append(pin(out/('snapshot-'+name)))
        inputs = manifest['inputs']
        sys.path.insert(0, str(Path(inputs['driver']['file']).parent))
        from process import run as run_process
        from oracle import expected
        expected_data = json.loads(Path(inputs['expected']['file']).read_text())
        assert expected_data == expected(), 'frozen expectations differ from independent mathematical model'
        deadline = started+a.max_seconds

        def run(label, command, oracle=None):
            remaining = deadline-time.monotonic()
            assert remaining > 0, 'campaign deadline reached'
            row = dict(label=label, command=list(map(str, command)), status=None, started=time.time())
            report['jobs'].append(row)
            so, se = out/(label+'.stdout'), out/(label+'.stderr')
            begin = time.monotonic()
            try:
                with so.open('xb') as x, se.open('xb') as y:
                    result = run_process(row['command'], cwd=ROOT, stdout=x, stderr=y,
                                         timeout=min(8, remaining))
                row.update(status=result.returncode, pid=result.pid, waitMethod=result.wait_method,
                           waitFallback=result.wait_fallback)
            except Exception as error:
                row['error'] = repr(error)
                raise
            finally:
                row.update(seconds=time.monotonic()-begin, stdout=pin(so), stderr=pin(se))
                save()
            assert row['status'] == 0, 'refusal or execution failure: '+label
            if oracle is not None:
                assert so.read_bytes() == oracle['stdout'].encode() and se.read_bytes() == b'', label
            return row

        for source in expected_data['sources']:
            for policy in ['raw', 'fast']:
                label = source['id']+'-'+policy
                dest = out/label
                job = run(label, [inputs['python']['file'], '-B', inputs['driver']['file'],
                    inputs[source['id']]['file'], '--image', inputs['image']['file'], '--out', dest,
                    '--entry', 'bench', '--policy', policy, '--base', 'cache', '--qbe', inputs['qbe']['file'],
                    '--whole-object', '--timeout', '8'])
                child = json.loads((dest/'report.json').read_text())
                assert child['kind'] == 'phase107-native-qbe-compilation' and child['complete']
                assert child['source'] == inputs[source['id']]
                assert child['identity'] == manifest['identity']
                assert child['options'] == dict(entry='bench', policy=policy, base='cache', abiSalt='', objectMode='whole')
                assert child['methods'] == [inputs[key] for key in ['driver', 'cacheMethod', 'runMethod', 'processMethod']]
                assert child['tools'] == {key:inputs[key] for key in ['qbe', 'as', 'gcc', 'ld']}
                assert child['runner'] == inputs['runner']
                assert child['jobs'] and all(j['status'] == 0 for j in child['jobs'])
                for item in [child['binary'], child['transport']]:
                    verify(item)
                report['builds'].append(dict(id=label, report=pin(dest/'report.json'), binary=child['binary'],
                    qbe=child['transport'], wallSeconds=job['seconds'], frontendSeconds=child['frontendSeconds']))
                for index, case in enumerate(source['cases']):
                    run(label+'-'+str(index), [child['binary']['file'], '--expect', case['value'], *case['argv']], case)
                    report['observations'].append(dict(build=label, case=index, argv=case['argv'], value=case['value']))
                verify(child['binary'])
        assert len(report['builds']) == manifest['planned']['builds']
        assert len(report['observations']) == manifest['planned']['outputs']
        for item in manifest['inputs'].values():
            verify(item)
        verify(report['manifest'])
        report.update(complete=True, passed=True)
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        report.update(finished=time.time(), wallSeconds=time.monotonic()-started)
        save()
        print(json.dumps(dict(complete=report['complete'], passed=report['passed'], error=report.get('error'),
                             builds=len(report['builds']), outputs=len(report['observations']), report=str(out/'report.json'))))


if __name__ == '__main__':
    main()
