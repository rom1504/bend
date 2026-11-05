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
require(replay['name'] == 'coverage-map-churn-128', 'Initial machine gate admits only original Map point')
require(replay['executionArgs'] == ['--threads', '1', '--gpu', 'off'], 'Original source argument policy changed')
expected = replay['expectedFile']; verify(expected)
expected_bytes = Path(expected['file']).read_bytes()
require(expected_bytes == b'3714872484\n', 'Wrong independent Map expectation')
asset_path = ROOT/'selfhost/manifests/assets-native.json'
assets = json.loads(asset_path.read_text())
cc, toolchain = assets['assets']['clang'], assets['toolchains']['c']
require(toolchain['compiler'] == 'clang' and toolchain['flags'] == ['-std=c11', '-O3'], 'Unknown C machine policy')
require(toolchain['libraries'] == ['-lpthread', '-lm'], 'Unknown C libraries')
inputs = [pin(__file__), pin(a.replay), pin(asset_path), pin(ROOT/'selfhost/tools/build/native.py'),
          pin(ROOT/'selfhost/tools/build/common.py'), replay['source'], expected, cc,
          *[replay['products'][role]['file'] for role in ['qbe','c']]]
for row in inputs: verify(row)
out = fresh_output(a.out, ROOT)
report = dict(kind='phase165-backend-machine', complete=False, inputs=inputs, products={},
              scope='Complete frozen C/QBE programs; pinned incumbent machine policies; exact original Map IO value and exit/stderr. No benchmark timing or compiler acquisition claim.')
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
