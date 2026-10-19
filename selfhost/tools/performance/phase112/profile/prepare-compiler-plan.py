#!/usr/bin/env python3
"""Freeze a future compiler diagnostic plan from exact completed native receipts.

Source/artifact verification only: never invokes a compiler, linker or target.
The existing compiler-run.py consumes the resulting additive plan unchanged.
"""
import argparse
import datetime
import json
from pathlib import Path
from prepare import ROOT
from parse import pin
from run import read, verify


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--compiler-emission', type=Path, required=True,
                   help='Complete receipt that produced the full compiler QBE')
    p.add_argument('--compiler-build', type=Path, required=True,
                   help='Complete direct QBE machine-build receipt for that exact image')
    p.add_argument('--request-report', type=Path, required=True,
                   help='Completed uninstrumented lexer-scan request by that exact compiler image')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise SystemExit('fresh plan path required; frozen plans are never replaced')
    emission, built, request = read(a.compiler_emission), read(a.compiler_build), read(a.request_report)
    if (not emission.get('complete') or not emission.get('product') or
            not (emission.get('sourceChecked') or emission.get('image'))):
        raise SystemExit('completed checked-source or native producer receipt required')
    if (built.get('kind') != 'phase111-direct-qbe-build' or not built.get('complete') or
            built.get('perProgramC') or built.get('cproc') or not built.get('cachedRuntime')):
        raise SystemExit('completed cached-runtime direct-QBE machine build required')
    jobs = {job['label']: job for job in built['jobs']}
    if any(jobs.get(name, {}).get('exitCode') != 0 for name in ['qbe', 'assemble', 'link']):
        raise SystemExit('incomplete compiler QBE/assembly/link chain')
    qc, ac, lc = [jobs[name]['command'] for name in ['qbe', 'assemble', 'link']]
    if (len(qc) != 6 or qc[1:4] != ['-t', 'amd64_sysv', '-o'] or
            Path(qc[-1]).resolve() != Path(emission['product']['file']).resolve() or
            len(ac) != 4 or ac[1] != '-o' or ac[3] != qc[4] or
            Path(ac[2]).resolve() != Path(built['object']['file']).resolve() or
            len(lc) != 8 or lc[1] != '-no-pie' or lc[2] != ac[2] or
            lc[4:7] != ['-pthread', '-lm', '-o'] or
            Path(lc[-1]).resolve() != Path(built['binary']['file']).resolve()):
        raise SystemExit('unexpected full compiler build chain')
    build_inputs = {str(Path(row['file']).resolve()): row for row in built['inputs']}
    qbe = build_inputs.get(str(Path(qc[-1]).resolve()))
    linker = build_inputs.get(str(Path(lc[0]).resolve()))
    if qbe != emission['product'] or linker is None:
        raise SystemExit('compiler QBE or linker lacks exact input provenance')
    native_jobs = [job for job in request.get('jobs', []) if job['label'] == 'native-request']
    if (request.get('kind') != 'phase111-native-source-qbe-emission' or
            not request.get('complete') or request.get('mode') != 'cache' or
            request.get('image') != built['binary'] or
            request.get('imageReceipt') != pin(a.compiler_build) or
            len(native_jobs) != 1 or native_jobs[0]['exitCode'] != 0):
        raise SystemExit('successful uninstrumented request from this exact compiler required')
    command = native_jobs[0]['command']
    if (len(command) != 12 or command[1:7] != ['--threads', '1', '--gpu', 'off', '--', 'phase111'] or
            Path(command[0]).resolve() != Path(built['binary']['file']).resolve() or
            Path(command[7]).name != 'lexer-scan.bend' or command[9] != 'cache' or
            not command[11].startswith('p88-private-base-text-1:')):
        raise SystemExit('exact existing cache-protocol lexer-scan request required')
    request_inputs = {str(Path(row['file']).resolve()): row for row in request['inputs']}
    for at in [7, 8, 10]:
        if str(Path(command[at]).resolve()) not in request_inputs:
            raise SystemExit('request source/Base/carrier not bound by receipt')
    if (native_jobs[0]['stdout'] != request['product'] or
            native_jobs[0]['stderr']['bytes'] != 0 or request['stderr']['bytes'] != 0):
        raise SystemExit('raw SSA stdout and empty stderr must be bound by request')
    inputs = [pin(Path(__file__)), pin(a.compiler_emission), pin(a.compiler_build), pin(a.request_report),
              *emission['inputs'], *built['inputs'], *request['inputs'],
              built['object'], built['binary'], request['product'], request['stderr']]
    by_path = {}
    for row in inputs:
        path = str(verify(row))
        actual = pin(Path(path))
        if path in by_path and by_path[path] != actual:
            raise SystemExit('inconsistent duplicate provenance for ' + path)
        by_path[path] = actual
    plan = dict(kind='phase112-frozen-compiler-diagnostic', version=1, name='lexer-scan',
                createdUTC=datetime.datetime.now(datetime.timezone.utc).isoformat(), targetsRun=False,
                compilerEmission=pin(a.compiler_emission), compilerBuild=pin(a.compiler_build),
                compilerObject=built['object'], compilerQBE=qbe, linker=linker,
                requestReceipt=pin(a.request_report), requestCommand=command,
                expectedSSA=request['product'], inputs=list(by_path.values()),
                scope='New immutable plan for a named candidate, without replacing compiler-plan01. '
                      'Exact native request argv/assets and raw expected SSA are from that same candidate image. '
                      'Only diagnostic relinking may change the executable path. Source-only provenance checks '
                      'do not imply new semantic, self-hosting, or performance qualification.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(a.out), inputs=len(by_path))))


if __name__ == '__main__':
    main()
