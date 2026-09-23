#!/usr/bin/env python3
"""Audit a completed final Phase5 proof and its P523 linkage; no execution.
Usage: final-selfhost-audit.py FINAL_SELFHOST_DIRECTORY P523_REPORT NEW_JSON
Do not run before the owner confirms proof closure. No report is rewritten.
"""
import hashlib
import json
import math
from pathlib import Path
import sys
import traceback

assert len(sys.argv) == 4, __doc__
directory, benchmark_file, output = map(Path, sys.argv[1:])
assert not output.exists()
repo = Path(__file__).resolve().parents[2]
project = repo / 'selfhost'
result = {'kind': 'phase5-independent-final-selfhost-audit', 'complete': False,
          'compilerExecutions': 0, 'oracleExecutions': 0, 'files': [], 'stages': [], 'modules': []}
seen = {}
def data(file, expected=None):
    p = Path(file).absolute()
    content = p.read_bytes()
    i = {'file': str(p), 'canonicalPath': str(p.resolve()), 'sha256': hashlib.sha256(content).hexdigest(), 'bytes': len(content)}
    if expected:
        assert i['sha256'] == expected['sha256'], 'Changed bytes: ' + str(p)
        assert i['canonicalPath'] == expected.get('canonicalPath', i['canonicalPath']), 'Changed path: ' + str(p)
    if i['file'] in seen:
        assert seen[i['file']] == i, 'Changed during audit: ' + str(p)
    else:
        seen[i['file']] = i
        result['files'].append(i)
    return content
def read(file, expected=None):
    return json.loads(data(file, expected))
def verify(i):
    return data(i['file'], i)
try:
    proof_file = directory / 'proof-01/report.json'
    proof = read(proof_file)
    assert proof['complete'] is True, 'Proof is not complete'
    assert not any(proof.get(k) for k in ('error', 'interrupted', 'currentStage', 'previousAttempts'))
    assert proof['requestedStages'] == [2, 3] and len(proof['stages']) == 2
    assert proof['validationPolicy']['required'] == [2, 3] and proof['validationPolicy']['optionalRepeat'] is False
    launch = read(directory / 'launch-report.json')
    assert launch['complete'] is True and launch['proofComplete'] is True and launch['inputsVerified'] is True
    assert not launch.get('error') and launch['proof']['file'] == str(proof_file.resolve())
    verify(launch['proof'])
    for i in launch['inputs']:
        verify(i)
    preparation = read(directory / 'preparation.json')
    attempt = read(Path(preparation['attempt']) / 'attempt.json')
    assert attempt['artifactKind'] == 'checked-b1' and attempt['checked'] is True
    assert attempt['api'] == proof['initialCompiler'] == preparation['api']
    bootstrap = read(attempt['bootstrapReport']['file'], attempt['bootstrapReport'])
    assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['provenance']['verifiedAfterBuild'] is True
    assert bootstrap['apiSha256'] == proof['initialCompiler']['sha256'] == '5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667'
    assert bootstrap['sourceSha256'] == proof['sourceSha256'] == preparation['sourceSha256'] == 'e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d'
    assert bootstrap['source'] == proof['source'] == preparation['source']
    verify(proof['sourceIdentity'])
    for i in bootstrap['provenance']['inputs'] + attempt['artifacts']:
        verify(i)
    assert proof['base'] == attempt['base'] == preparation['base']
    verify(proof['base'])
    assert Path(proof['base']['file']).resolve() == (Path(attempt['config']['upstream']) / 'bend2/base.bend').resolve()
    assert proof['runtimeSha256'] == attempt['runtime']['sha256'] == preparation['runtime']['sha256']
    runtime = verify(attempt['runtime'])
    assert data(directory / 'proof-01/runtime.mjs') == runtime == data(project / 'src/runtime.mjs')
    assert verify(proof['driver']) == data(project / 'tools/typed-driver.mjs')
    assert proof['driver']['sha256'] == preparation['driver']['sha256']
    for i in proof['hostHelpers']:
        assert verify(i) == data(project / 'tools' / Path(i['file']).name)
    assert verify(preparation['tool']) == data(project / 'tools/conformance/selfhost.mjs')
    frozen = Path(attempt['snapshot']['root'])
    current_config = read(project / 'src/compiler.json')
    frozen_config = read(frozen / 'src/compiler.json')
    names = [m['file'] for m in bootstrap['modules']]
    assert len(names) == len(set(names)) == 59
    assert names == current_config['modules'] == frozen_config['modules']
    for m in bootstrap['modules']:
        original, copied, assembled = project / m['file'], frozen / m['file'], Path(proof['source']).parent / m['file']
        a = data(original, m)
        assert a == data(copied, m) == data(assembled, m)
        result['modules'].append({'file': m['file'], 'sha256': m['sha256'], 'currentFrozenAssembledEqual': True})
    env = launch['environment']
    assert env == preparation['environment']
    assert not any(k in env for k in ('BEND_SELFHOST_RESUME', 'BEND_SELFHOST_REPEAT'))
    assert env['BEND_TYPED_API'] == proof['initialCompiler']['file']
    assert env['BEND_BASE'] == proof['base']['file'] and env['BEND_TYPED_RUNTIME'] == attempt['runtime']['file']
    assert env['BEND_SELFHOST_DRIVER'] == proof['driver']['file']
    resources = proof['resourceConfiguration']
    assert resources['node'] == 'v24.18.0' and resources['nodeArgs'] == preparation['nodeArgs'] == ['--stack-size=4096', '--max-old-space-size=12288']
    assert resources['osStackKB'] == 'unlimited' or int(resources['osStackKB']) >= 8192
    assert resources['timeoutMs'] == int(env['BEND_SELFHOST_TIMEOUT']) == 2400000
    e = launch['execution']
    assert e['command'] == 'taskset' and e['args'] == ['-c', str(preparation['cpu']), preparation['node'], *preparation['nodeArgs'], preparation['tool']['file'], proof['source'], preparation['output']]
    assert e['exitCode'] == 0 and e['signal'] is None and e['error'] is None and not e['timedOut'] and not e['overflow']
    assert len(data(e['stdout'])) + len(data(e['stderr'])) == e['logBytes'] <= e['maxBytes']
    assert e['timeoutMs'] == 3300000 and e['wallMs'] > 0
    first_output = None
    previous = proof['initialCompiler']
    for number, stage in zip((2, 3), proof['stages']):
        assert stage['compiler'] == previous['file'] and stage['compilerSha256'] == previous['sha256']
        verify(previous)
        assert Path(stage['output']).resolve() == (directory / f'proof-01/stage{number}.mjs').resolve()
        assert stage['code'] == 0 and stage['signal'] is None and stage['inputsVerified'] is True
        assert stage['nodeArgs'] == resources['nodeArgs'] and 0 < stage['ms'] <= resources['timeoutMs']
        current = {'file': stage['output'], 'sha256': stage['outputSha256']}
        body = verify(current)
        data(stage['output'] + '.log')
        if first_output is None:
            first_output = body
        else:
            assert body == first_output, 'Actual stage2/stage3 bytes differ'
        for k in ('compiler', 'compilerSha256', 'output', 'outputSha256', 'code', 'signal', 'inputsVerified', 'ms'):
            assert launch['stages'][number - 2][k] == stage[k]
        result['stages'].append({'stage': number, **stage, 'bytes': len(body), 'durationScope': 'Descriptive checked proof child duration; no controlled H/TS performance ratio.'})
        previous = current
    benchmark = read(benchmark_file)
    assert benchmark['complete'] is True and benchmark['inputsUnchanged'] is True
    assert benchmark['original']['api'] == proof['initialCompiler']
    assert benchmark['source'] == proof['sourceIdentity'] and benchmark['base'] == proof['base'] and benchmark['runtime'] == attempt['runtime']
    links = []
    bend_rows = [x for x in benchmark['rows'] if x['variant'] in ('checked', 'derived')]
    assert len(bend_rows) == 4
    for row in bend_rows:
        assert row['passed'] is True and row['execution']['exitCode'] == 0
        raw = read(row['result']['file'], row['result'])
        assert raw == row['observation'] and raw['result']['checked'] is True and raw['result']['status'] == 'ok'
        assert verify(raw['emitted']) == first_output
        links.append({'index': row['index'], 'variant': row['variant'], 'output': raw['emitted'], 'bothProofStagesByteIdentical': True})
    companion = []
    for name in ('workflow', 'process'):
        file = str(project / 'tools/development' / (name + '.mjs'))
        entries = [i for i in benchmark['inputs'] if i['file'] == file]
        assert len(entries) == 1
        verify(entries[0])
        companion.append(entries[0])
    data(__file__)
    result.update({'complete': True, 'actualStageBytesEqual': True, 'actualCurrentFrozenModulesEqual': True,
                   'benchmarkOutputLinks': links, 'wrapperHelperCompanion': companion,
                   'wrapperHelperScope': 'Maintained workflow/process helper bytes match their earlier P523 identities; companion association only, not retroactively added to launch-report.inputs.',
                   'scope': 'Fresh unchanged maintained checked B1→H→H fixed point on the exact final source. Not native compiler execution, full-language conformance or a repeated H performance benchmark.'})
except Exception:
    result['error'] = traceback.format_exc()
output.parent.mkdir(parents=True, exist_ok=True)
with output.open('x') as f:
    json.dump(result, f, indent=2)
    f.write('\n')
print(json.dumps({k: result.get(k) for k in ('complete', 'actualStageBytesEqual', 'actualCurrentFrozenModulesEqual', 'error')}))
if not result['complete']:
    sys.exit(1)
