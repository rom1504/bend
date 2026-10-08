#!/usr/bin/env python3
"""Data-only frozen State09 source/image comparison; never executes a compiler."""
from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(sys.argv[1]).resolve() if len(sys.argv) == 2 else ROOT / 'implementation/phase64/evidence/state09-size.json'
INPUTS = {}


def identify(path, expected=None):
    path = Path(path)
    data = path.read_bytes()
    result = {'file': str(path), 'canonicalPath': str(path.resolve()),
              'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
    if expected:
        assert result['sha256'] == expected['sha256'], path
        if 'bytes' in expected:
            assert result['bytes'] == expected['bytes'], path
        if 'canonicalPath' in expected:
            assert result['canonicalPath'] == expected['canonicalPath'], path
    if result['canonicalPath'] in INPUTS:
        assert INPUTS[result['canonicalPath']] == result, path
    INPUTS[result['canonicalPath']] = result
    return result


def read(path, expected=None):
    identity = identify(path, expected)
    return json.loads(Path(path).read_text()), identity


def count(path, bend=True):
    data = Path(path).read_bytes()
    text = data.decode('utf-8')
    assert text.encode('utf-8') == data
    lines = text.splitlines()
    result = {'physicalLines': len(lines), 'utf8Bytes': len(data)}
    if bend:
        result.update(codeLines=sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in lines),
                      definitions=sum(bool(re.match(r'^def\s', x)) for x in lines),
                      laws=sum(bool(re.match(r'^law\s', x)) for x in lines),
                      types=sum(bool(re.match(r'^type\s', x)) for x in lines))
    return result


def state(phase, emission):
    attempt_path = ROOT / f'selfhost/build/phase{phase}/checked-state09/attempt.json'
    attempt, attempt_id = read(attempt_path)
    assert attempt['checked'] and attempt['config']['strictExact']
    snapshot = Path(attempt['snapshot']['root'])
    sources = {str(Path(x['frozen']['file']).relative_to(snapshot)): x['frozen']
               for x in attempt['snapshot']['sources']}
    manifest, manifest_id = read(snapshot / 'src/compiler.json', sources['src/compiler.json'])
    names = manifest['modules']
    assert len(names) == len(set(names)) and all(n.endswith('.bend') for n in names)
    modules = []
    for name in names:
        file = snapshot / name
        assert file.resolve().is_relative_to(snapshot.resolve())
        modules.append({'module': name, 'identity': identify(file, sources[name]), 'metrics': count(file)})
    keys = modules[0]['metrics'].keys()
    total = {k: sum(m['metrics'][k] for m in modules) for k in keys}
    total['modules'] = len(names)
    host = []
    for name in ['tools/typed-driver.mjs', 'tools/base-cache-graph.mjs',
                 'tools/development/workflow.mjs', 'tools/development/release.mjs']:
        file = snapshot / name
        host.append({'file': name, 'identity': identify(file, sources[name]), 'metrics': count(file, False)})
    runtime = {name: identify(snapshot / name, sources[name])
               for name in ['src/runtime.mjs', 'src/runtime/js/direct.mjs']}
    b2, b2_report = read(ROOT / emission)
    assert b2['complete'] and b2['pass']
    identify(b2['subject']['attempt']['file'], b2['subject']['attempt'])
    assert b2['subject']['attempt']['sha256'] == attempt_id['sha256']
    source = identify(b2['subject']['source']['file'], b2['subject']['source'])
    artifacts = {x['file']: x for x in attempt['artifacts']}
    identify(source['file'], artifacts[source['file']])
    backup = [identify(snapshot / n, sources[n]) for n in sorted(sources) if n.endswith('.bend.orig')]
    return {'phase': phase, 'attempt': attempt_id, 'manifest': manifest_id,
            'metrics': total, 'modules': modules, 'hostSupport': host, 'runtimes': runtime,
            'assembledSource': source, 'images': {
                'checkedB1Raw': identify(attempt['checkedApi']['file'], attempt['checkedApi']),
                'checkedB1EqualityDerived': identify(attempt['api']['file'], attempt['api']),
                'genuineB2': identify(b2['module']['file'], b2['module'])},
            'b2Receipt': b2_report, 'exports': b2['roots'],
            'excludedNonmanifestBackups': backup}


def differences(before, after):
    return {k: after[k] - before[k] for k in before}


baseline = state(63, 'selfhost/build/phase63/final-state09/bootstrap/full/report.json')
candidate = state(64, 'selfhost/build/phase64/bootstrap-state09/full/report.json')
assert baseline['manifest']['sha256'] == candidate['manifest']['sha256']
assert baseline['metrics'] == {'physicalLines': 28115, 'utf8Bytes': 1280814,
                              'codeLines': 23075, 'definitions': 3235,
                              'laws': 642, 'types': 117, 'modules': 114}
changed = []
for old, new in zip(baseline['modules'], candidate['modules']):
    assert old['module'] == new['module']
    if old['identity']['sha256'] != new['identity']['sha256']:
        changed.append({'module': old['module'], 'before': old['metrics'], 'after': new['metrics'],
                        'delta': differences(old['metrics'], new['metrics'])})
host_changes = []
for old, new in zip(baseline['hostSupport'], candidate['hostSupport']):
    assert old['file'] == new['file']
    host_changes.append({'file': old['file'], 'before': old['metrics'], 'after': new['metrics'],
                         'delta': differences(old['metrics'], new['metrics'])})
report = {
    'kind': 'phase64-frozen-state09-size-comparison', 'complete': True, 'pass': True,
    'dataOnly': True, 'targetExecuted': False, 'producer': identify(__file__),
    'method': {
        'scope': 'Exactly the Bend modules in each hash-verified frozen src/compiler.json manifest.',
        'physicalLines': 'Python UTF-8 text splitlines, per module; no generated assembly or headers.',
        'codeLines': 'Nonempty stripped lines excluding lines whose first nonspace character is #.',
        'declarations': 'Line-start def, law and type followed by whitespace; textual counts, not semantic complexity.',
        'hostSupport': 'Physical lines and UTF-8 bytes reported separately, not included in Bend totals.',
        'verification': 'Verify manifest/modules/host/runtime/images against frozen receipt SHA256; verify optional byte and canonicalPath fields; rehash all inputs after counting.',
        'imageScope': 'Checked-B1 raw, equality-derived API and genuine B2 are distinct. B2 export set grows by one private context API.',
    },
    'baseline': baseline, 'candidate': candidate,
    'delta': differences(baseline['metrics'], candidate['metrics']),
    'changedModules': changed, 'hostChanges': host_changes,
    'imageByteDeltas': {k: candidate['images'][k]['bytes'] - baseline['images'][k]['bytes'] for k in baseline['images']},
    'exportsAdded': [x for x in candidate['exports'] if x not in baseline['exports']],
    'exportsRemoved': [x for x in baseline['exports'] if x not in candidate['exports']],
    'runtimeUnchanged': all(baseline['runtimes'][k]['sha256'] == candidate['runtimes'][k]['sha256'] for k in baseline['runtimes']),
    'limitations': [
        'Line/declaration counts are reproducible size proxies, not a semantic concept or complexity score.',
        'The extra validate.bend.orig snapshot backup is not in the manifest and is explicitly excluded.',
        'The release helper snapshot delta incorporates the already-selected Phase63 packaging adapter; it is not a newly invented Phase64 compiler feature.',
        'No speed, conformance, release or fixed-point claim follows from these counts.'
    ]
}
for item in list(INPUTS.values()):
    identify(item['file'], item)
report['verifiedInputs'] = list(INPUTS.values())
OUT.parent.mkdir(parents=True, exist_ok=True)
with OUT.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps({'output': str(OUT), 'pass': True, 'baseline': baseline['metrics'],
                  'candidate': candidate['metrics'], 'delta': report['delta'],
                  'imageByteDeltas': report['imageByteDeltas'], 'verifiedInputs': len(INPUTS)}))
