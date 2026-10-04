#!/usr/bin/env python3
"""Close Phase44 selected-image qualification; no execution or installation."""
import hashlib
import json
import sys
from pathlib import Path

assert len(sys.argv) == 3, 'close-selected.py CONFIG_JSON NEW_OUT_JSON'
config_file, output = map(lambda p: Path(p).resolve(), sys.argv[1:])
assert not output.exists(), 'Output must be fresh'
inputs, assertions = {}, []

def require(value, message):
    assert value, message
    assertions.append(message)

def pin(file, expected=None):
    path = Path(file).resolve()
    if str(path) not in inputs:
        data = path.read_bytes()
        inputs[str(path)] = dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    actual = inputs[str(path)]
    if expected:
        require(all(actual[k] == expected[k] for k in ['sha256', 'bytes'] if k in expected), 'Unchanged: ' + str(path))
    return actual

def read(file):
    pin(file)
    return json.loads(Path(file).read_text())

def audit(value):
    if isinstance(value, dict):
        file = value.get('file', value.get('path'))
        if isinstance(file, str) and 'sha256' in value:
            pin(file, value)
        for child in value.values():
            audit(child)
    elif isinstance(value, list):
        for child in value:
            audit(child)

pin(__file__)
config = read(config_file)
resolve = lambda value: (config_file.parent / value).resolve()
attempt_file = resolve(config['attempt']) / 'attempt.json'
attempt = read(attempt_file)
require(attempt['checked'] is True and attempt['config']['strictExact'] is True, 'Passed strict checked attempt')
for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
    audit(attempt[key])
api = attempt['api']['sha256']
image = lambda binding: all(binding[k]['sha256'] == attempt[k]['sha256'] for k in ['api', 'runtime', 'base'])
focused = read(attempt_file.parent / 'validation-001/report.json'); audit(focused)
require(focused['complete'] and focused['pass'] and focused['api']['sha256'] == api, 'Selected checked-attempt validation passed')
snapshot = Path(attempt['snapshot']['root'])
source_root = Path(attempt['config']['project'])
manifest = read(snapshot / 'src/compiler.json')
source_paths = set(manifest['modules']) | {'src/compiler.json', 'src/runtime.mjs'}
bound_sources = []
for record in attempt['snapshot']['sources']:
    frozen, original = record['frozen'], record['original']
    pin(frozen['file'], frozen)
    relative = str(Path(original['file']).relative_to(source_root))
    if relative in source_paths or relative.startswith('src/runtime/js/'):
        require(original['sha256'] == frozen['sha256'], 'Snapshot source agrees: ' + relative)
        pin(original['file'], frozen)
        bound_sources.append(relative)
require(source_paths <= set(bound_sources), 'Every maintained module and runtime is source-bound')
names = ['frontend_main', 'frontend_broader', 'backend', 'maintained', 'composition', 'runtime', 'compiler_cost']
reports = {name: read(resolve(config[name])) for name in names}
for name, report in reports.items():
    require(report['complete'] is True and (name == 'backend' or report['pass'] is True), 'Complete gate: ' + name)
    audit(report)
for name, count, failures in [('frontend_main', 3026, 4), ('frontend_broader', 196, 0)]:
    report = reports[name]
    require(report['api']['sha256'] == api and report['expected'] == report['exact'] == count, 'Selected API and exact frontend count: ' + name)
    require(report['exactAgreement'] and report['healthPass'] and report['differences'] == report['extraFieldDifferences'] == 0, 'Exact healthy frontend: ' + name)
    require(len(report['raw']['candidateFailures']) == len(report['raw']['referenceFailures']) == failures, 'Shared frontend failures retained: ' + name)
    require(report['raw']['candidateSummary']['statuses'] == report['raw']['referenceSummary']['statuses'], 'Frontend raw statuses agree: ' + name)
shared_failures = {'io/cid_unknown.bend', 'io/effect_ctr_name.bend', 'io/main_foreign.bend', 'reg/array_open_element.bend'}
require(all({r['id'] for r in reports['frontend_main']['raw'][role + 'Failures']} == shared_failures for role in ['candidate', 'reference']), 'Exact four existing frontend failure identities')
backend = reports['backend']
require(backend['attempt']['sha256'] == pin(attempt_file)['sha256'], 'Backend selected attempt')
require(backend['agreementComplete'] and backend['rowsExpected'] == backend['exactRows'] == len(backend['rows']) == 81, 'All 81 backend observations agree')
require(backend['fixtureExecutionPasses'] == 69 and backend['sharedRawCheckFailures'] == 4 and not backend['incompleteBatchRows'] and not backend['unexecuted'], 'Backend 69 executions and four shared failures retained')
require(all(row['exactAgreement'] and row['acceptedCampaignObservation'] for row in backend['rows']), 'Every backend row accepted exactly')
require({status: sum(row['candidateVerdict'] == status for row in backend['rows']) for status in ['pass', 'not-applicable', 'fail']} == {'pass': 69, 'not-applicable': 8, 'fail': 4}, 'Backend raw status counts')
maintained = reports['maintained']
require(maintained['api']['sha256'] == api and maintained['attempt']['sha256'] == pin(attempt_file)['sha256'], 'Maintained suites selected image')
require({t['name'] for t in maintained['tests']} == {'ir', 'backend', 'global-initializers', 'choice', 'arm', 'primitive-guards', 'provenance', 'foreign'} and len(maintained['tests']) == 8, 'Exactly eight maintained suites')
require(all(t['pass'] and t['process']['complete'] and t['process']['returncode'] == 0 for t in maintained['tests']), 'Every maintained suite passed')
gates = {t['name']: t for t in maintained['tests']}
require(gates['ir']['checks'] == 37 and gates['primitive-guards']['guards'] == 1129 and gates['primitive-guards']['observations'] == 25 and gates['provenance']['constructors'] == 10, 'Maintained activation, primitive and constructor counts')
composition = reports['composition']
candidate = [r for r in composition['compilers'] if r['role'] == 'candidate']
require(len(candidate) == 1 and image(candidate[0]['compiler']), 'Composition selected API/runtime/Base')
require([len(composition[k]) for k in ['values', 'mixed', 'boundaries', 'higherOrder']] == [35, 4, 11, 26], 'Composition 35 plus four mixed, eleven boundary and 26 higher-order observations')
runtime = reports['runtime']
require(image(runtime['plan']['variants']['candidate']['compiler']), 'Runtime selected API/runtime/Base')
require(runtime['points'] == len(runtime['cases']) == 45 and runtime['samples'] == 669 and runtime['sourceCount'] == 23, 'Full 45-point 669-sample 23-source runtime comparison')
cost = reports['compiler_cost']
cost_config = read(cost['config']['file']); audit(cost_config)
require(image(cost_config['variants']['candidate']), 'Compiler cost selected API/runtime/Base')
cost_sources = {r['source'] for r in cost['rows']}
require(len(cost_sources) == 4 and len(cost['rows']) == 36 and {(r['source'], r['sample'], r['variant']) for r in cost['rows']} == {(s, n, v) for s in cost_sources for n in range(3) for v in ['typescript', 'baseline', 'candidate']}, 'Four-source three-round three-role compiler-cost requests')
require(all(r['execution']['complete'] and r['execution']['returncode'] == 0 and r['observation']['complete'] and r['observation']['pass'] for r in cost['rows']), 'All compiler-cost requests passed')
for entry in list(inputs.values()):
    require(hashlib.sha256(Path(entry['path']).read_bytes()).hexdigest() == entry['sha256'], 'Final identity: ' + entry['path'])
result = dict(kind='phase44-selected-qualification', complete=True, **{'pass': True}, attempt=pin(attempt_file), api=pin(attempt['api']['file']),
              sourceBindings=len(bound_sources), assertions=len(assertions), checks=assertions, inputs=list(inputs.values()), reports={n: pin(resolve(config[n])) for n in names},
              counts=dict(frontendMain=3026, frontendBroader=196, sharedFrontendFailures=4, backendAgreements=81, backendExecutionPasses=69, backendNotApplicable=8, backendSharedFailures=4, maintainedSuites=8, runtimePoints=45, runtimeSamples=669, compilerRequests=36),
              installed=False, scope='Selected Phase44 image and current named gates only. No inherited 34-owner renewal, installation, universal conformance, GPU, fixed-point or speed-parity claim.')
output.parent.mkdir(parents=True, exist_ok=True)
with output.open('x') as stream:
    json.dump(result, stream, indent=2); stream.write('\n')
print(json.dumps(dict(complete=True, **{'pass': True}, assertions=len(assertions), inputs=len(inputs), counts=result['counts'])))
