#!/usr/bin/env python3
"""Root-only plan-bound diagnostic executor; one serial guarded CPU3 lane."""
import argparse
import hashlib
import importlib.util
import json
import os
import time
from pathlib import Path


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def check(inputs):
    for expected in inputs:
        assert pin(expected['file']) == expected, expected['file']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('plan', type=Path)
    args = parser.parse_args()
    plan_pin = pin(args.plan)
    plan = json.loads(args.plan.read_text())
    check(plan['inputs'])
    assert {key: os.environ.get(key) for key in plan['compilerEnvironment']} == plan['compilerEnvironment']
    assert pin(__file__) == plan['controller']
    spec = importlib.util.spec_from_file_location('support', plan['support'])
    support = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(support)
    out = Path(plan['execution'])
    assert out.is_relative_to(Path(__file__).resolve().parents[5]/'selfhost/build/phase70')
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase70-observer-native-diagnostics-v2', complete=False, pass_=False,
        plan=plan_pin, inputs=plan['inputs'], rows=[], scope=plan['scope'])

    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    save()
    try:
        with support.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for job in plan['jobs']:
                check(plan['inputs'])
                row = dict(name=job['name'], expected=job['expected'], correct=False)
                report['rows'].append(row)
                dest = out/job['name']
                dest.mkdir()
                executable = dest/'program'
                command = ['taskset','-c','3',plan['clang'],*plan['clangArgs'],
                    job['source']['file'],*plan['linkArgs'],'-o',str(executable)]
                row['build'] = guard.run(command, dest/'compile', time.monotonic()+90)
                save()
                assert row['build']['complete'], ('Clang', job['name'])
                row['executable'] = pin(executable)
                command = ['taskset','-c','3','python3','-B',plan['execute'],
                    str(dest/'run/child.json'),str(executable),'--threads','1','--gpu','off']
                row['process'] = guard.run(command, dest/'run', time.monotonic()+20)
                child_file = dest/'run/child.json'
                assert child_file.is_file(), ('Missing child receipt', job['name'])
                child = json.loads(child_file.read_text())
                row['child'] = child
                # execute.py intentionally propagates expected native rc1.
                # Guard.complete is then false, while an unstopped normal rc1
                # with an exact child receipt is the successful error oracle.
                process = row['process']
                expected = job['expected']
                normal = 'stoppedFor' not in process and 'error' not in process
                stderr = child['stderr']
                marker = expected.get('stderrMarker')
                if marker:
                    assert stderr.splitlines(keepends=True).count(marker) == 1, ('Entry marker', job['name'], stderr)
                    stderr = ''.join(line for line in stderr.splitlines(keepends=True) if line != marker)
                row['correct'] = (normal and child['returncode'] == expected['returncode']
                    and process.get('returncode') == expected['returncode']
                    and child['stdout'] == expected['stdout'] and stderr == expected['stderr'])
                row['normalizedStderr'] = stderr
                assert pin(executable) == row['executable']
                save()
                print(json.dumps(dict(name=job['name'], correct=row['correct'])), flush=True)
                assert row['correct'], job['name']
        check(plan['inputs'])
        assert pin(args.plan) == plan_pin
        report['inputsUnchanged'] = True
        report['complete'] = True
        report['pass_'] = len(report['rows']) == len(plan['jobs']) and all(row['correct'] for row in report['rows'])
        assert report['pass_']
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise
    save()


if __name__ == '__main__':
    main()
