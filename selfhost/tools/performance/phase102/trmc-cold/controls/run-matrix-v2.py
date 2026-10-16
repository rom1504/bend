#!/usr/bin/env python3
"""Root-only guarded compilation and full-output checks for frozen policy variants."""
import argparse, importlib.util, json, re, sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R
spec = importlib.util.spec_from_file_location('matrix_prepare', Path(__file__).with_name('prepare-matrix-v1.py'))
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True); p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
plan = R.read(a.plan); assert plan['complete'] and not plan['targetsRun']
for item in [plan['method'], *plan['inputs']]: R.verify(item)
_, context = R.authenticate(); cc = context['clang']['file']
report = dict(complete=False, method=R.pin(__file__), plan=R.pin(a.plan), context=context, variants=[],
              scope='Diagnostic same-C macro variants on a unique constructor chain; not natural compiler outputs or a whole ownership proof.')
R.save(out / 'report.json', report)
for variant in plan['variants']:
    for item in [variant['c'], variant['expectedStdout']]: R.verify(item)
    folder = out / variant['id']; folder.mkdir()
    common = [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-std=c11']
    row = dict(id=variant['id'], c=variant['c'], executions=[]); report['variants'].append(row)
    row['preprocessor'], child = R.guarded(folder / 'preprocess', [*common, '-E', '-P', variant['c']['file']])
    assert child['returncode'] == 0
    preprocessed = (folder / 'preprocess/stdout.log').read_text()
    body = M.function(preprocessed.replace('Env e, _Bool seq, Term* nf_out', 'Env e, bool seq, Term* nf_out'), plan['shape']['worker'] + '_trmc')
    assigned = list(map(int, re.findall(r'nf_out\[4\]\s*=\s*([01]);', body)))
    expected = [variant['hot'][ctor] for ctor in plan['shape']['nodeSlots']]
    assert assigned == expected, (variant['id'], assigned, expected)
    row['preprocessedPolicies'] = assigned
    binary = folder / 'program'
    row['build'], child = R.guarded(folder / 'build', [*common, '-O3', variant['c']['file'], '-o', binary, '-lpthread', '-lm'])
    assert child['returncode'] == 0; row['binary'] = R.pin(binary)
    for workers in variant['threads']:
        directory = folder / ('threads-' + str(workers))
        job, child = R.guarded(directory, [binary, '--threads', str(workers), '--gpu', 'off'], cpu={1:'3',2:'2,3',4:'0,1,2,3'}[workers])
        assert child['returncode'] == variant['expectedExit'] and child['stderr'] == variant['expectedStderr']
        assert (directory / 'stdout.log').read_bytes() == Path(variant['expectedStdout']['file']).read_bytes()
        row['executions'].append(dict(workers=workers, passed=True, job=job))
    R.save(out / 'report.json', report)
    print(json.dumps(dict(id=variant['id'], passed=True, policies=assigned)), flush=True)
for item in [report['method'], report['plan'], *context['inputs']]: R.verify(item)
report['complete'] = True; R.save(out / 'report.json', report)
