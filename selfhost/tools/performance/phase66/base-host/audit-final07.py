#!/usr/bin/env python3
"""Join four closed final07 annotation controls; execute no compiler or Node target."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'implementation/phase66/evidence/base-host07.json'
inputs = {}
transitive = {}


def pin(value, direct=True):
    expected = value if isinstance(value, dict) else None
    file = Path(expected['file'] if expected else value).resolve(strict=True)
    data = file.read_bytes()
    result = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert result['sha256'] == expected['sha256'], file
        assert 'bytes' not in expected or result['bytes'] == expected['bytes'], file
        assert 'canonicalPath' not in expected or str(file) == expected['canonicalPath'], file
    for inventory in [transitive] + ([inputs] if direct else []):
        assert str(file) not in inventory or inventory[str(file)] == result, file
        inventory[str(file)] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def same(a, b):
    assert pin(a) == pin(b)


def audit_pins(value):
    if isinstance(value, dict):
        if isinstance(value.get('file'), str) and isinstance(value.get('sha256'), str):
            pin(value, direct=False)
        for child in value.values():
            audit_pins(child)
    elif isinstance(value, list):
        for child in value:
            audit_pins(child)


def main():
    assert not OUT.exists()
    producer = pin(__file__)
    plan_pin = pin(dict(file=str(HERE/'final07-controls-plan.json'), sha256='d71b04c13656cff295074160eadaa6fef87529c89a9a8f29b62052ed0a2c93b0'))
    plan = read(plan_pin)
    assert plan['kind'] == 'phase66-final07-annotation-controls-recipes'
    assert [j['name'] for j in plan['jobs']] == ['owned-checked07', 'custom-checked07', 'owned-b2-07', 'custom-b2-07']
    attempt_pin = pin(RAW/'checked-b1-07/attempt.json')
    attempt = read(attempt_pin)
    assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1' and attempt['config']['strictExact']
    b1 = pin(attempt['api'])
    image_pins = pin(RAW/'bootstrap-b2-07/image-pins.json')
    image = read(image_pins)
    same(image['attempt'], attempt_pin)
    same(image['b1'], b1)
    b2, source = pin(image['b2']), pin(image['source'])
    assert len(image['roots']) == len(set(image['roots'])) == 99
    audit_pins(image)
    rows = []
    reports = {}
    for job in plan['jobs']:
        method, config_pin, report_pin = pin(job['method']), pin(job['input']), pin(job['report'])
        config, report = read(config_pin), read(report_pin)
        assert report['complete'] and report['pass'] and report['inputsUnchanged']
        assert report['diagnosticOnly']
        same(report['config'], config_pin)
        audit_pins(report)
        audit_pins(config)
        assert method in [pin(p, direct=False) for p in report['inputs']]
        supervisor_pin = pin(Path(job['report']).parent.with_name(Path(job['report']).parent.name+'-exec')/'run.json')
        supervisor = read(supervisor_pin)
        assert supervisor['complete'] and supervisor['returncode'] == 0 and not supervisor.get('stopReason')
        assert supervisor['command'] == job['command'][job['command'].index('--')+1:]
        assert supervisor['cwd'] == plan['cwd'] == str(ROOT)
        assert supervisor['secondsLimit'] == 90 and supervisor['rssLimitBytes'] == 2048*1024**2
        assert supervisor['availableFloorBytes'] == 4096*1024**2
        audit_pins(supervisor)
        assert supervisor['stderr']['bytes'] == 0
        generation = report['generation']
        same(generation['attempt'], attempt_pin)
        same(generation['source'], source)
        same(config['image']['api'], b2 if 'b2' in job['name'] else b1)
        same(config['image']['base'], attempt['base'])
        snapshot_driver = Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs'
        same(config['image']['driver'], snapshot_driver)
        assert config['image']['driver']['sha256'] == 'e093483d5103a8e833b6ca710246b1ec3c579b7fac5060c8e42f626c5e25ec85'
        if 'b2' in job['name']:
            assert generation['kind'] == 'genuine-B2'
            same(generation['imagePins'], image_pins)
            same(generation['b1'], b1)
            same(generation['b2'], b2)
            assert generation['roots'] == image['roots']
        else:
            assert generation['kind'] == 'equality-derived-B1-profile7'
            same(generation['api'], b1)
            same(generation['checkedApi'], attempt['checkedApi'])
            same(generation['derivation'], attempt['derivationReport'])
            same(generation['bootstrap'], attempt['bootstrapReport'])
            assert generation['hostTransforms'] == config['hostTransforms'] == []
            assert generation['requestedExports'] == image['roots']
        row = dict(name=job['name'], report=report_pin, method=method, config=config_pin,
            supervisor=supervisor_pin, wallSeconds=supervisor['wallSeconds'],
            reportInputPinsReverified=len(report['inputs']), complete=True, passed=True)
        if job['name'].startswith('owned'):
            assert report['kind'] in ['phase66-base-annotation-owned-controls', 'phase66-base-annotation-genuine-b2-owned-controls']
            prep = report['preparation']
            assert prep['producerReady'] and prep['allProductsExact'] and prep['preparationPairs'] == 99261
            assert prep['checkedDefinitions'] == 475 and len(prep['keys']) == len(set(prep['keys'])) == 12
            assert pin(prep['sidecar'])['bytes'] == 438959
            assert [c['id'] for c in report['cases']] == ['lexer', 'test-map-set-ops', 'numeric-recurrence']
            for case in report['cases']:
                assert case['pass'] and case['ordinaryObservation'] == dict(status='ok', phase='compile', checked=True)
                assert all(case['publicInjected'][key] == 0 for key in ['world', 'context', 'wanted', 'allowed', 'consumer', 'productReads'])
                assert case['ordinary']['consumer'] == case['ordinary']['productReads'] == 0
                cached = case['cached']
                assert cached['world'] == cached['context'] == cached['wanted'] == 1
                if case['id'] == 'test-map-set-ops':
                    assert cached['allowed'] == cached['consumer'] == cached['productReads'] == 1
                    assert cached['annotationExact'] and cached['actualAllowed'] and cached['actualWanted']
                    assert cached['annotationReused'] == 7 and cached['annotationComparedPairs'] == 101907
                    assert len(case['privateGuards']) == 7 and all(v is True for v in case['privateGuards'].values())
                else:
                    assert cached['actualWanted'] is False
                    assert cached['allowed'] == cached['consumer'] == cached['productReads'] == cached['annotationReused'] == 0
            row.update(preparation=prep, cases=report['cases'], actualExportCount=generation.get('actualExportCount', generation.get('actualExports')))
        else:
            assert report['kind'] == 'phase66-base-annotation-custom-base-owned-controls'
            custom = report['customBase']
            assert custom['otherwiseReadyWorld'] and custom['preparedTwice'] and report['optionalArtifactAbsent']
            original, derived = Path(pin(custom['original'])['file']).read_bytes(), Path(pin(custom['derived'])['file']).read_bytes()
            assert derived == original+b'\n# Phase66 custom Base content permission control.\n'
            expected = dict(base_annotation_prepare=0, base_annotation_wanted=0, base_annotation_allowed=0,
                annotate_selected_base=0, check_program_diagnostic_world=1, book_context_world=1)
            assert report['counts'] == report['customCounts'] == expected
            assert report['observation'] == report['standardObservation'] == dict(status='ok', phase='compile', checked=True)
            assert report['output']['sameImageOrdinaryModuleExact']
            module = pin(report['standardModule'])
            assert {k:module[k] for k in ['sha256', 'bytes']} == {k:report['output'][k] for k in ['sha256', 'bytes']}
            row.update(customBase=custom, optionalCounts=expected, optionalArtifactAbsent=True, output=report['output'])
        rows.append(row)
        reports[job['name']] = report
    for suffix in ['checked07', 'b2-07']:
        owned, custom = reports['owned-'+suffix], reports['custom-'+suffix]
        output = next(c['output'] for c in owned['cases'] if c['id'] == 'test-map-set-ops')
        assert output == {k:custom['output'][k] for k in ['sha256', 'bytes']}
    assert reports['owned-checked07']['preparation']['keys'] == reports['owned-b2-07']['preparation']['keys']
    assert [c['output'] for c in reports['owned-checked07']['cases']] == [c['output'] for c in reports['owned-b2-07']['cases']]
    for item in list(transitive.values()):
        pin(item, direct=False)
    receipt = dict(kind='phase66-final07-base-host-admission-audit', version=1, complete=True, pass_=True,
        dataOnly=True, targetExecuted=False, producer=producer, plan=plan_pin, attempt=attempt_pin,
        selectedB1=b1, selectedB2=b2, source=source, imagePins=image_pins,
        base=pin(attempt['base']), driver=pin(snapshot_driver), reports=rows,
        semanticEquality=dict(allProducts=True, ownedOrdinaryPublicResults=True, b1B2SelectedModules=True,
            stoppedObjectPreserved=True, readinessErrorCollisionRefusal=True, customBaseOrdinaryModule=True),
        demand=dict(noHitProductBodyReads=0, customOptionalCalls=0, customArtifactAbsent=True),
        allInputsUnchanged=True, transitiveInputPinsReverified=len(transitive),
        scope='Four actual final07 B1/B2 owned and comment-only custom Base controls. Pins and reviewed target assertions reaudited; no target rerun, benchmark, native qualification or universal annotation proof. Complete transitive input inventories remain in the four pinned raw reports.',
        inputs=list(inputs.values()))
    receipt['pass'] = receipt.pop('pass_')
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open('x') as stream:
        stream.write(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps(dict(output=pin(OUT), reports=4, transitivePins=receipt['transitiveInputPinsReverified'])))


if __name__ == '__main__':
    main()
