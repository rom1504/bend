#!/usr/bin/env python3
"""Build both complete frozen outputs and check the original source's IO point.

Run inside one root-owned guard; this adapter starts no guard or compiler request.
"""
import argparse, json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import pin, verify, require, run, write_json, fresh_output

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--replay', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
replay = json.loads(a.replay.read_text())
require(replay['complete'] and replay.get('qbeOracleExact') is True, 'Complete exact-QBE replay required')
require(replay['executionArgs'] == ['--threads', '1', '--gpu', 'off'], 'Original source argument policy changed')
verify(replay['source'])
if replay['name'] == 'coverage-map-churn-128':
    require(replay['source']['sha256'] == '99892f1c473588fcc814f17594b9d173343ef195bda6378113dbf088bea01120', 'Wrong original Map source')
    expected = replay['expectedFile']; verify(expected)
    expected_bytes = Path(expected['file']).read_bytes()
    require(expected_bytes == b'3714872484\n', 'Wrong independent Map expectation')
    expectation = 'Maintained original Map stdout fixture.'
elif replay['name'] == 'compiler-verifier-slice':
    require(replay['source']['sha256'] == '42017745e7c9aa674c59823487fdcca8ff9ee4c957e2d753beb1fc3c9c6a2396', 'Wrong verifier source')
    # Independent source oracle: main computes Bool.to_u32(String.is_empty(
    # p111_verify_program(p111_empty()))). Empty program has no main; indexed
    # verifier returns the nonempty zero-argument-main diagnostic. Thus zero.
    # This expected value never comes from either generated product or replay.
    expected = None
    expected_bytes = b'0\n'
    expectation = 'Exact frozen source: p111_empty has no main; p111v_program_indexed returns nonempty diagnostic, String.is_empty=False, Bool.to_u32=0. No retained prior whole-program execution is asserted.'
else:
    raise ValueError('Only the two frozen original source points are admitted')
asset_path = ROOT/'selfhost/manifests/assets-native.json'
assets = json.loads(asset_path.read_text())
cc, toolchain = assets['assets']['clang'], assets['toolchains']['c']
require(toolchain['compiler'] == 'clang' and toolchain['flags'] == ['-std=c11', '-O3'], 'Unknown C machine policy')
require(toolchain['libraries'] == ['-lpthread', '-lm'], 'Unknown C libraries')
inputs = [pin(__file__), pin(a.replay), pin(asset_path), pin(ROOT/'selfhost/tools/build/native.py'),
          pin(ROOT/'selfhost/tools/build/common.py'), replay['source'], cc,
          *[replay['products'][role]['file'] for role in ['qbe','c']]]
if expected: inputs.append(expected)
for row in inputs: verify(row)
out = fresh_output(a.out, ROOT)
report = dict(kind='phase165-backend-machine-v2', complete=False, inputs=inputs, products={},
              expectedStdout=expected_bytes.decode(), expectedReason=expectation,
              scope='Complete frozen C/QBE programs; pinned incumbent machine policies; exact original source result and exit/stderr. No benchmark timing or compiler acquisition claim.')
def save(): write_json(out/'report.json', report)
save()
try:
    for role in ['qbe','c']:
        source = replay['products'][role]['file']
        if role == 'qbe':
            directory = out/'qbe'
            command = [sys.executable, '-B', 'selfhost/tools/build/native.py', '--assets', str(asset_path),
                       '--target', 'qbe', '--ir', source['file'], '--out', str(directory), '--seconds', '45']
        else:
            command = [cc['file'], *toolchain['flags'], *toolchain.get('includeFlags', []),
                       source['file'], '-o', str(out/'c-program'), *toolchain['libraries']]
        built = run(command, cwd=ROOT, stdout=out/(role+'-build.stdout'), stderr=out/(role+'-build.stderr'), seconds=50)
        report['products'][role] = dict(build=built); save()
        require(built['complete'], role+' machine construction failed')
        if role == 'qbe':
            receipt = json.loads((directory/'report.json').read_text())
            require(receipt['complete'], 'Incomplete QBE machine receipt')
            binary = receipt['binary']
            report['products'][role]['machineReceipt'] = pin(directory/'report.json')
        else: binary = pin(out/'c-program')
        verify(binary)
        observed = run([binary['file'], *replay['executionArgs']], cwd=ROOT,
                       stdout=out/(role+'.stdout'), stderr=out/(role+'.stderr'), seconds=10)
        exact = (observed['complete'] and observed['exitCode'] == 0 and
                 Path(observed['stdout']['file']).read_bytes() == expected_bytes and observed['stderr']['bytes'] == 0)
        report['products'][role].update(binary=binary, execution=observed, exact=exact); save()
        require(exact, role+' original semantic output failed')
    for row in inputs: verify(row)
    report['complete'] = True
except Exception as error:
    report['error'] = str(error)
    raise
finally:
    save()
    print(json.dumps(dict(complete=report['complete'], error=report.get('error'))))
