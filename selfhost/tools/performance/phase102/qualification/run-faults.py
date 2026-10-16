#!/usr/bin/env python3
"""Root-only bounded fault challenges. A failed C build or timeout is inconclusive."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p102_fault_guard', HERE.parent / 'guarded.py')
G = importlib.util.module_from_spec(spec); spec.loader.exec_module(G)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    inputs = {}
    def bind(value):
        actual = G.pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict): assert actual == value
        assert inputs.setdefault(actual['file'], actual) == actual
        return actual
    def tree(value):
        if isinstance(value, list):
            for x in value: tree(x)
        elif isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys(): bind(value)
            else:
                for x in value.values(): tree(x)
    plan_pin = bind(a.plan); plan = G.read(a.plan); tree(plan)
    assert plan['kind'] == 'phase102-generated-C-fault-plan' and plan['complete'] and not plan['targetsRun']
    control = G.read(plan['controls']['file']); tree(control); assert control['complete']
    clang = bind(control['context']['clang'])
    report = dict(kind='phase102-generated-C-fault-results', complete=False, targetsRun=False,
        imageQualified=False, started=time.time(), plan=plan_pin, method=bind(__file__),
        guardMethod=bind(G.__file__), rows=[], inputs=[],
        scope='Three generated-C faults only. Each successful build is compared with the unchanged complete exit/stdout/stderr oracle. Build failures and bounded execution timeouts remain inconclusive. No compiler performance, universal proof or positive release qualification.')
    def save(): report['inputs'] = list(inputs.values()); G.save(out / 'report.json', report)
    def run(folder, command, seconds):
        try: return G.guarded(folder, command, seconds=seconds)
        except AssertionError:
            job = G.read(folder.parent / (folder.name + '-job.json'))
            child = G.read(folder / 'child.json') if (folder / 'child.json').exists() else None
            return job, child
    save()
    try:
        for challenge in plan['rows']:
            folder = out / challenge['id']; folder.mkdir()
            row = dict(id=challenge['id'], status='not-run', caught=False, mutant=challenge['mutantC'])
            report['rows'].append(row); report['targetsRun'] = True; save()
            original = Path(challenge['originalC']['file']).read_text()
            mutant = Path(challenge['mutantC']['file']).read_text(); at = challenge['offset']
            assert original[at:at+len(challenge['old'])] == challenge['old']
            assert mutant == original[:at] + challenge['new'] + original[at+len(challenge['old']):]
            binary = folder / 'program'
            command = [clang['file'], '-isystem', str(Path(clang['file']).parents[1] / 'include/clang'),
                '-std=c11', '-O3', challenge['mutantC']['file'], '-o', str(binary), '-lpthread', '-lm']
            row['build'], built = run(folder / 'build', command, 60); tree(row['build']); save()
            if not built or built['returncode'] != 0 or row['build']['process'].get('stoppedFor'):
                row['status'] = 'inconclusive-build'; save(); continue
            row['binary'] = bind(binary)
            argv = [str(binary), '--threads', str(challenge['workers']), '--gpu', 'off', '--', *challenge['argv']]
            row['run'], observed = run(folder / 'run', argv, 5); tree(row['run'])
            process = row['run']['process']
            if (observed is None or process.get('stoppedFor') or process.get('interrupted')
                    or process.get('error') or not process.get('finished')
                    or not isinstance(observed.get('returncode'), int) or observed['returncode'] < 0):
                row['status'] = 'inconclusive-execution'; save(); continue
            assert observed['command'] == argv and observed['returncode'] == process['returncode']
            row['captures'] = {s:bind(folder / 'run' / (s + '.log')) for s in ['stdout', 'stderr']}
            row['matchesOriginalOracle'] = dict(
                exit=observed['returncode'] == challenge['expectedExit'],
                stdout=Path(row['captures']['stdout']['file']).read_bytes() == Path(challenge['expectedStdout']['file']).read_bytes(),
                stderr=Path(row['captures']['stderr']['file']).read_bytes() == Path(challenge['expectedStderr']['file']).read_bytes())
            row['observedExit'] = observed['returncode']
            row['caught'] = not all(row['matchesOriginalOracle'].values())
            row['status'] = 'caught' if row['caught'] else 'survived'; save()
        for value in inputs.values(): assert G.pin(value['file']) == value
        report.update(complete=True, inputsUnchanged=True,
            counts={status:sum(x['status'] == status for x in report['rows']) for status in ['caught', 'survived', 'inconclusive-build', 'inconclusive-execution']})
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: report['finished'] = time.time(); save()
    print(json.dumps(dict(complete=True, counts=report['counts'])))


if __name__ == '__main__': main()
