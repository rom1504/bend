#!/usr/bin/env python3
"""Audit closed genuine selfhosting and full emitted-program equality; no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item['file'] if item else value).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'canonicalPath' in item:
            assert str(file) == item['canonicalPath'], file
        if 'bytes' in item:
            assert len(data) == item['bytes'], file
    assert row['file'] not in inputs or inputs[row['file']] == row
    inputs[row['file']] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def passed(value):
    result = read(value)
    assert result['complete'] and result['pass'], value
    for item in result.get('inputs', []):
        pin(item)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['image-pins', 'plan', 'execution', 'program-equality', 'b1-oracles', 'b2-oracles', 'out']:
        p.add_argument('--'+name, type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    image = read(a.image_pins)
    assert image['kind'] == 'phase56-direct-image-pins'
    for key in ['producer', 'plan', 'attempt', 'emission', 'comparison', 'source', 'b1', 'b2', 'runtime', 'rootsReference', 'admission']:
        pin(image[key])
    attempt = read(image['attempt'])
    assert attempt['checked'] and attempt['config']['strictExact'] and attempt['artifactKind'] == 'derived-b1'
    assert pin(attempt['api']) == pin(image['b1'])
    emission, comparison = passed(image['emission']), passed(image['comparison'])
    assert pin(emission['module'])['sha256'] == image['b2']['sha256']
    assert pin(emission['subject']['attempt']) == pin(image['attempt'])
    assert pin(emission['subject']['source']) == pin(image['source'])
    assert pin(emission['generator']['api']) == pin(image['b1'])
    assert comparison['observations'] == 8
    tiny = passed(emission['qualification'])
    assert tiny['splitEqualsUnsplit'] and tiny['planEqualsCompatibility']
    assert len(image['roots']) == len(set(image['roots'])) == 99
    assert emission['roots'] == image['roots']
    for role in ['source', 'direct']:
        driver = passed(comparison[role])
        assert pin(driver['emission']) == pin(image['emission'])
        assert driver['subject'] == emission['subject'] and driver['generator'] == emission['generator']

    plan, execution = read(a.plan), passed(a.execution)
    assert plan['complete'] and not plan['executed']
    assert pin(plan['imagePins']) == pin(a.image_pins)
    assert execution['planSha256'] == pin(a.plan)['sha256']
    assert Path(execution['plan']).resolve() == a.plan.resolve()
    assert execution['returncode'] == 0
    assert len(plan['commands']) == len(execution['steps']) == 2
    assert [row['name'] for row in plan['commands']] == ['self-check', 'fixed-point']
    for command, step in zip(plan['commands'], execution['steps']):
        assert command['name'] == step['name'] and command['command'] == step['command']
        assert command.get('environment', {}) == step['environment']
        assert step['returncode'] == 0 and step['finished'] >= step['started']
    for item in plan['inputs']:
        pin(item)
    directory = Path(plan['out']).resolve(strict=True)
    assert directory.is_relative_to(RAW)
    own_file, fixed_file = directory/'self-check/report.json', directory/'fixed-point/report.json'
    own, fixed = passed(own_file), passed(fixed_file)
    assert pin(own['image'])['sha256'] == image['b2']['sha256']
    assert pin(own['imagePins']) == pin(a.image_pins)
    assert pin(own['source']) == pin(image['source'])
    assert own['freshSelfCheck'] and own['freshTypeCheck'] and own['expectedProofTrustFailure']
    assert own['mathematicalProof'] is False and own['observation']['typeAccepted']
    assert own['observation']['proofTrust'] == 'failed' and own['observation']['kernelChecked'] is False
    assert own['observation']['status'] == 'error' and own['observation']['phase'] == 'verdict'
    assert own['sourceTrustOracle']['definitions'] == own['sourceTrustOracle']['explicitlyUnsafe']
    assert len(own['observation']['unsafeDefinitions']) == own['sourceTrustOracle']['definitions']
    assert own['additionalUnsafeDeclarations'] == [] and own['cacheBefore'] == []
    assert fixed['byteEquality']
    assert pin(fixed['b2'])['sha256'] == pin(fixed['b3'])['sha256'] == image['b2']['sha256']
    assert pin(fixed['image']['pins']) == pin(a.image_pins)
    assert pin(fixed['image']['checkedSubject']) == pin(image['attempt'])

    equality = passed(a.program_equality)
    assert equality['programsExecuted'] is False
    assert equality['image']['api']['sha256'] == image['b2']['sha256']
    assert pin(equality['generator']['attempt']) == pin(image['attempt'])
    assert pin(equality['generator']['api']) == pin(image['b1'])
    assert equality['counts'] == dict(freshCheckedSources=23, rawByteEqualModules=23,
        pointByteEqual=45, uniquePointModules=24, observerModules=1)
    assert len(equality['emissions']) == 23 and len(equality['points']) == 45
    for row in equality['emissions'] + equality['points']:
        assert row['byteEqual'] and pin(row['output'])['sha256'] == pin(row['reference'])['sha256']
    b1, b2 = passed(a.b1_oracles), passed(a.b2_oracles)
    assert pin(b1['attempt']) == pin(b2['attempt']) == pin(image['attempt'])
    assert b1['counts'] == b2['counts'] == dict(sources=23, points=45)
    assert b1['image']['api']['sha256'] == image['b1']['sha256']
    assert b2['image']['api']['sha256'] == image['b2']['sha256']
    assert pin(b2['checkedB1Oracles']) == pin(a.b1_oracles)
    assert pin(b2['b2Equality']) == pin(a.program_equality)
    for key in ['runtime', 'base', 'driver', 'directRuntime', 'source']:
        assert pin(b1['image'][key]) == pin(b2['image'][key])
    assert pin(b1['image']['source']) == pin(image['source'])
    for item in list(inputs.values()):
        pin(item)
    result = dict(kind='phase66-selected-selfhosting-program-audit', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, producer=pin(__file__), attempt=pin(image['attempt']),
        selectedB1=pin(image['b1']), selectedB2=pin(image['b2']), source=pin(image['source']),
        imagePins=pin(a.image_pins), plan=pin(a.plan), execution=pin(a.execution),
        selfCheck=pin(own_file), fixedPoint=pin(fixed_file), programEquality=pin(a.program_equality),
        b1Oracles=pin(a.b1_oracles), b2Oracles=pin(a.b2_oracles), exports=99, driverObservations=8,
        unsafeDefinitions=own['sourceTrustOracle']['definitions'], mathematicalProof=False,
        rawModules=23, programPoints=45, observerModules=1,
        inputs=list(inputs.values()),
        scope='Actual selected B2 emission, tiny/driver checks, fresh own-source type acceptance with expected unsafe proof-trust refusal, exact B2/B3 bytes, and full emitted-module equality transferring the actual B1 program oracles. No new program runtime or clean compiler timing claim.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(a.out), complete=True, passed=True, verifiedInputs=len(inputs))))


if __name__ == '__main__':
    main()
