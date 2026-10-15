#!/usr/bin/env python3
"""Admit only the reviewed runtime-template digest update; no target execution."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase90'
PARENT = ROOT / 'selfhost/build/phase82/compiler04-admission.json'
PARENT_SHA = '1be793be6cf967d91b6ba3aabed3cdf8659aa1a59e8ffd16e1370ddc83c3ed06'
PLAN_SHA = '1d6824d4be2a0a3e763336fe7ee19f67482190b2d8f7701df788d4ffcacdf566'


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def checked(record):
    actual = pin(record['file'])
    assert actual['sha256'] == record['sha256'], actual['file']
    if 'bytes' in record:
        assert actual['bytes'] == record['bytes'], actual['file']
    return actual


def read(file):
    return json.loads(Path(file).read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt', type=Path, required=True)
    parser.add_argument('--ready', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.parent == RAW and not out.exists()
    inputs = []

    def bind(record):
        actual = checked(record)
        inputs.append(actual)
        return actual

    parent_pin = bind(dict(file=str(PARENT), sha256=PARENT_SHA))
    parent = read(PARENT)
    assert parent['kind'] == 'phase61-bootstrap-export-admission' and parent['version'] == 1
    old_driver = bind(parent['driver'])
    parent_attempt_file = Path(old_driver['file']).parents[2] / 'attempt.json'
    parent_attempt_pin = bind(pin(parent_attempt_file))
    parent_attempt = read(parent_attempt_file)
    parent_bootstrap_pin = bind(parent_attempt['bootstrapReport'])
    parent_bootstrap = read(parent_bootstrap_pin['file'])
    ready_pin = bind(pin(args.ready))
    ready = read(ready_pin['file'])
    assert ready['kind'] == 'phase90-runtime-large-table-accessor-prepared'
    assert ready['complete'] and ready['canonicalMutated'] is False
    plan_pin = bind(ready['plan'])
    assert plan_pin['sha256'] == PLAN_SHA
    plan = read(plan_pin['file'])
    assert plan['kind'] == 'phase90-runtime-large-table-accessor-plan'
    assert plan['complete'] and plan['targetExecuted'] is False
    runtime, template, candidate_driver = [bind(x) for x in ready['outputs']]
    assert runtime['sha256'] == plan['source']['sha256']
    receipt_pin = bind(ready['templateReceipt'])
    receipt = read(receipt_pin['file'])
    assert receipt['kind'] == 'bend-native-template' and receipt['exactRoundTrip'] and receipt['chunks'] == 5
    for key, expected in [('runtime', runtime), ('artifact', template), ('producer', plan['api']),
                          ('attempt', plan['attempt']), ('generator', plan['generator'])]:
        assert bind(receipt[key])['sha256'] == expected['sha256'], key
    artifact = read(template['file'])
    assert artifact['version'] == 1 and artifact['runtimeSha256'] == runtime['sha256']
    assert len(artifact['parts']) == 5 and all(isinstance(p, str) for p in artifact['parts'])
    assert ''.join(artifact['parts']).encode() == Path(runtime['file']).read_bytes()

    attempt_pin = bind(pin(args.attempt / 'attempt.json'))
    attempt = read(attempt_pin['file'])
    assert attempt['kind'] == 'bend-development-attempt' and attempt['checked']
    assert attempt['artifactKind'] == 'derived-b1'
    validation_pin = bind(pin(args.attempt / 'validation-001/report.json'))
    validation = read(validation_pin['file'])
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    assert validation['attempt']['sha256'] == attempt_pin['sha256']
    selected = validation['selected']
    assert selected['selectedComplete'] and selected['exactDifferences'] == 0 and selected['discrepancies'] == 0
    assert selected['reference']['probes'] == selected['candidate']['probes'] == 36
    bootstrap_pin = bind(attempt['bootstrapReport'])
    bootstrap = read(bootstrap_pin['file'])
    assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['provenance']['verifiedAfterBuild']
    assert bootstrap['revision'] == parent_bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    assert bootstrap['exports'] == parent_bootstrap['exports'], 'Export roots or their order changed'
    assert len(bootstrap['exports']) == len(set(bootstrap['exports']))
    snapshot = Path(attempt['snapshot']['root'])
    frozen_driver = bind(pin(snapshot / 'tools/typed-driver.mjs'))
    assert frozen_driver['sha256'] == candidate_driver['sha256']
    for relative, expected in [('src/runtime/native/runtime.c', runtime),
                               ('src/runtime/native/runtime-template.json', template),
                               ('tools/typed-driver.mjs', candidate_driver)]:
        assert bind(pin(snapshot / relative))['sha256'] == expected['sha256']
        assert bind(pin(ROOT / 'selfhost' / relative))['sha256'] == expected['sha256']
    manifest = bind(pin(snapshot / 'src/compiler.json'))
    previous_manifest = bind(pin(Path(parent_attempt['snapshot']['root']) / 'src/compiler.json'))
    assert manifest['sha256'] == previous_manifest['sha256'], 'Compiler module manifest changed'
    before = Path(old_driver['file']).read_text()
    after = Path(frozen_driver['file']).read_text()
    matches = re.findall(r"const nativeTemplateSha256='([0-9a-f]{64})';", before)
    assert len(matches) == 1 and matches[0] == plan['canonicalInputs'][1]['sha256']
    old = "const nativeTemplateSha256='" + matches[0] + "';"
    new = "const nativeTemplateSha256='" + template['sha256'] + "';"
    assert before.count(old) == 1 and before.replace(old, new, 1) == after, 'Driver changed beyond its template pin'
    assert after.count(new) == 1 and after.replace(new, old, 1) == before
    for record in inputs:
        checked(record)
    if args.check_only:
        print(json.dumps(dict(complete=True, checkOnly=True, targetsExecuted=False,
                              driver=frozen_driver, roots=len(bootstrap['exports']), inputs=len(inputs))))
        return
    out.mkdir()
    diff_file = out / 'driver-full.diff'
    diff_file.write_text(''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
                                                   fromfile=old_driver['file'], tofile=frozen_driver['file'])))
    admission = dict(kind='phase61-bootstrap-export-admission', version=1, driver=frozen_driver,
        addedRoots=list(parent['addedRoots']), parentAdmission=parent_pin,
        previousAttempt=parent_attempt_pin, previousBootstrap=parent_bootstrap_pin,
        attempt=attempt_pin, bootstrap=bootstrap_pin, validation=validation_pin, manifest=manifest,
        runtimePreparation=ready_pin, runtimeTemplateReceipt=receipt_pin, runtime=runtime, template=template,
        driverPrevious=old_driver, fullDriverDiff=pin(diff_file), producer=pin(__file__), inputs=inputs,
        exportRootsUnchanged=True, fullDriverExactExceptTemplateDigest=True, targetsExecuted=False,
        scope='Same checked export roots and order. Only the reviewed Bend-produced native template SHA changes in the driver. '
              'No compiler implementation, checking policy, foreign permission or public native-cache admission changes. '
              'Fresh B2 generation, driver comparison, self-check, fixed point and release gates remain required.')
    target = out / 'admission.json'
    target.write_text(json.dumps(admission, indent=2) + '\n')
    print(json.dumps(dict(admission=pin(target), targetsExecuted=False)))


if __name__ == '__main__':
    main()
