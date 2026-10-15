#!/usr/bin/env python3
"""Verify already completed deep-diagnostic controls; execute no compiler."""
import argparse, hashlib, importlib.util, json, sys
from pathlib import Path
sys.dont_write_bytecode = True
from census import ROOT, PROJECT, INPUTS, pin, read, reference

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location('strict_collector', Path(__file__).with_name('collect-conformance.py'))
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    method = pin(module.__file__)
    assert method['sha256'] == 'f23cd6e401e8373d28ca9da7350910de0e009e5738ca296e3264ed73ec2e7349'
    directory = PROJECT / 'build/phase91/deep-diagnostic01'
    plan, plan_pin = read(directory / 'plan.json')
    assert [job['role'] for job in plan['jobs']] == ['b1', 'b2', 'old-b2', 'typescript']
    output = dict(kind='phase91-deep-diagnostic-audit', complete=False, dataOnly=True,
                  targetExecuted=False, method=pin(__file__), validationMethod=method, plan=plan_pin, roles=[])
    with args.output.open('x') as stream:
        json.dump(output, stream, indent=2); stream.write('\n')
    def save(): args.output.write_text(json.dumps(output, indent=2) + '\n')
    try:
        diagnostics = {}
        for job in plan['jobs']:
            role = job['role']; report, report_pin = read(directory / role / 'report.json')
            module.stable(report)
            guard, guard_pin = read(directory / role / 'guard/process.json')
            expected = 1 if role in ['b2', 'old-b2'] else 0
            assert guard['returncode'] == expected and not guard.get('stoppedFor') and not guard.get('interrupted')
            assert guard['finished'] and guard['complete'] is (expected == 0)
            argv = job['command'][job['command'].index('--') + 1:]
            assert guard['command'][-len(argv):] == argv
            assert len(report['results']) == 1 and report['options']['worker-mode'] == 'isolated'
            assert report['options']['stack-kb'] == 4096 and report['options']['heap-mb'] == 1024
            row = report['results'][0]; result = row['result']; diagnostic = result['diagnostic']
            assert (row['id'], row['lane']) == ('page/deep_list_walk.bend', 'check')
            assert result['status'] == 'error' and result['phase'] == 'check' and result['checked'] is True
            assert result['typeAccepted'] is False and result['exitCode'] == 1
            assert row['status'] == ('fail' if expected else 'pass')
            stderr = Path(row['artifacts']) / 'worker.stderr'; stderr_pin = pin(stderr); trace = stderr.read_text()
            marker = 'diagnostic rendering unavailable: Maximum call stack size exceeded'
            if expected:
                assert marker in trace
                assert diagnostic == 'SOME PROOFS FAIL\nError: thm: reflexivity endpoints differ'
            else:
                assert marker not in trace and len(diagnostic) == 12119
            if job.get('api'):
                reference(job['api'])
                assert report['identity']['artifacts']['compiler']['sha256'] == job['api']['sha256']
            diagnostics[role] = diagnostic
            output['roles'].append(dict(role=role, report=report_pin, guard=guard_pin,
                sourceApi=job.get('api'), observedStatus=row['status'], proofAccepted=False,
                diagnosticCharacters=len(diagnostic), diagnosticSha256=hashlib.sha256(diagnostic.encode()).hexdigest(),
                stackOverflowObserved=bool(expected), trace=stderr_pin, seconds=guard['wallSeconds']))
        assert diagnostics['b1'] == diagnostics['typescript']
        assert diagnostics['b2'] == diagnostics['old-b2']
        old = PROJECT / 'build/phase66/conformance-new-bend-full01/bend-candidate-new-base/project'
        unchanged = []
        for name in ['src/core/pretty.bend','src/core/normalize.bend','src/diagnostic/render.bend',
                     'src/diagnostic/frontend.bend','src/diagnostic/trace.bend','src/check/kernel.bend']:
            current, prior = pin(PROJECT/name), pin(old/name)
            assert current['sha256'] == prior['sha256']
            unchanged.append(dict(module=name, current=current, historical=prior))
        output['unchangedSource'] = unchanged
        for record in list(INPUTS.values()): pin(record['file'])
        output.update(complete=True, inputBindingsUnchanged=True, verifiedInputs=len(INPUTS),
            interpretation='A pre-existing JS B2 diagnostic stack-depth gap: both B2 images reject the false proof but fall back after a caught rendering stack overflow. Current B1 and TypeScript retain the exact full error page.',
            limitation='The caught exception identifies diagnostic rendering, not the exact overflowing Bend helper. Source inspection nominates recursive constructor pretty-printing; no stack-trace attribution, fix, larger-stack workaround or new compiler run is performed here.')
        save(); print(json.dumps(dict(complete=True, targetExecuted=False, report=str(args.output.resolve()))))
    except Exception as error:
        output.update(error=str(error), retainedFailure=True); save(); raise

if __name__ == '__main__': main()
