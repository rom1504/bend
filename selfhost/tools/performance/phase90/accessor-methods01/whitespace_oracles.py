"""Admit only completed CPU preprocessing proofs and their exact new C oracles."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
METHOD_SHA = 'b916bef1c3daf337b4bc7d133407b5f02104209789abf8ea1393c56299c59f50'
NAMES = ['small', 'map_closed', 'unicode', 'file-io']


def read(path):
    return json.loads(Path(path).read_text())


def load_oracles(path, auth, bind_file, bound, bind_tree):
    proof_pin = bind_file(path)
    proof = read(proof_pin['file'])
    assert proof['kind'] == 'phase90-checked-b1-cpu-preprocessed-c-equality'
    assert proof['complete'] and proof['pass'] and proof['inputBindingsUnchanged']
    assert proof['executionPerformed'] and not proof['checkOnly']
    assert len(proof['rows']) == 4 and [row['name'] for row in proof['rows']] == NAMES
    bind_tree(proof['inputs'])
    for key in ['method', 'node', 'attempt', 'selectedApi', 'rawApi', 'bootstrap',
                'derivation', 'base', 'driver', 'runtime', 'clang', 'nineEffectManifest',
                'nativeRuntime', 'nativeRuntimeTemplate']:
        bound(proof[key])
    assert proof['method']['sha256'] == METHOD_SHA
    assert bound(proof['previousMethod'])['sha256'] == 'c86b2fd437f4596f4125e3c6af977008ce679ec9046f695db13a1cd6456b92b4'
    previous = read(bound(proof['previousFailure'])['file'])
    assert not previous['complete'] and not previous['pass']
    failed = previous['rows'][0]['preprocess']['baseline']
    assert failed['stdout']['bytes'] == failed['stderr']['bytes'] == 0 and 'ETIMEDOUT' in failed['error']
    assert proof['clang']['sha256'] == '9fcd5fc4baeea9c449bcc9ca4b9db7714465107669498b0056a853f22f5f4def'
    assert proof['nineEffectManifest']['sha256'] == '1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b'
    assets = read(proof['nineEffectManifest']['file'])
    assert len(proof['nineEffects']) == len(assets['admittedEffects']) == 9
    assert [bound(item) for item in proof['nineEffects']] == [bound(item) for item in assets['admittedEffects']]
    assert bound(proof['base']) == auth['base']
    assert proof['nativeRuntime']['sha256'] == auth['runtime']['sha256']
    assert bound(proof['nativeRuntimeTemplate']) == auth['template']
    if auth.get('originalProvenance', auth['provenance']) == 'JS-B1-cross-host-emitted-C':
        assert bound(proof['attempt']) == bound(auth['producer']['attempt'])
        assert bound(proof['selectedApi']) == bound(auth['producer']['api'])

    execution = proof['executionGuard']
    assert Path(execution['cwd']).resolve() == ROOT
    directory = Path(execution['directory']).resolve()
    assert Path(execution['processFile']).resolve() == directory / 'process.json'
    guard = read(bind_file(directory / 'process.json')['file'])
    guard_inputs = [bound(item) for item in read(bind_file(directory / 'inputs.json')['file'])]
    assert guard['complete'] and guard['returncode'] == 0 and not guard.get('stoppedFor')
    expected = execution['expectedCommand']
    actual = guard['command'][-len(expected):]
    assert len(actual) == len(expected)
    assert all(a == b or (Path(b).is_absolute() and (ROOT / a).resolve() == Path(b).resolve())
               for a, b in zip(actual, expected)), 'Preprocessing outer guard command differs'
    assert bound(proof['method']) in guard_inputs and bound(proof['node']) in guard_inputs
    macros = proof['macros']
    include = str(Path(proof['clang']['file']).parent.parent / 'include/clang')
    expected_args = ['-isystem', include, '-x', 'c', '-E', '-P', '-fminimize-whitespace', '-H', '-']
    assert macros['scope'] == 'default host CPU' and macros['definitions'] == []
    assert macros['sameStdinFilename'] == '<stdin>' and macros['args'] == expected_args
    assert Path(macros['cwd']).resolve() == ROOT and macros['includeDirectories'] == [include]
    expected_command = [proof['clang']['file'], *expected_args]

    gate_pin = bound(proof['oracleGates'])
    assert Path(gate_pin['file']) == ROOT / 'selfhost/build/phase90/native-gates01/gates.json'
    gates = read(gate_pin['file'])
    assert gates['kind'] == 'phase90-combined-native-b1-gates' and gates['complete'] and gates['passed']
    assert gates['executionPerformed'] and not gates['checkOnly'] and len(gates['rows']) == 8
    assert all(row['passed'] and row['exactC'] for row in gates['rows'])
    references = {case['name']: case for case in gates['oracleCases']}
    cases = []
    for row in proof['rows']:
        assert row['passed'] and row['exactPreprocessed']
        assert row['observation']['status'] == 'ok' and row['observation']['checked']
        reference = references[row['name']]
        source = bound(row['source'])
        assert source == bound(reference['source'])
        assert bound(row['oracleReceipt']) == bound(reference['oracleReceipt'])
        baseline, current = bound(row['baseline']), bound(row['current'])
        assert all(baseline[key] == reference['oracle'][key] for key in ['sha256', 'bytes'])
        assert 0 < current['bytes'] <= 64 * 1024 * 1024
        bind_tree(row['requestInputs'])
        for name, code in [('baseline', baseline), ('current', current)]:
            preprocessing = row['preprocess'][name]
            assert preprocessing['passed'] and preprocessing['returncode'] == 0
            assert preprocessing['signal'] is None and preprocessing['error'] is None
            assert preprocessing['stdinTransport'] == 'read-only-file-descriptor' and preprocessing['stdinStartOffset'] == 0
            assert preprocessing['command'] == expected_command and Path(preprocessing['cwd']).resolve() == ROOT
            assert bound(preprocessing['stdin']) == code
            bound(preprocessing['stdout']); bound(preprocessing['stderr']); bind_tree(preprocessing['headers'])
        before, after = row['preprocess']['baseline'], row['preprocess']['current']
        assert before['headers'] == after['headers']
        assert all(before['stdout'][key] == after['stdout'][key] for key in ['sha256', 'bytes'])
        assert before['stdout']['bytes'] > 0
        assert Path(before['stdout']['file']).read_bytes() == Path(after['stdout']['file']).read_bytes()
        cases.append(dict(name=row['name'], source=source, oracle=current, oracleReceipt=proof_pin,
                          priorOracle=reference['oracle'], cpuTokenProof=True))
    return cases, proof_pin
