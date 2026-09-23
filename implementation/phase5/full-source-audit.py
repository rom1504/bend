#!/usr/bin/env python3
"""Independent retained-file P523 audit; never executes a compiler or oracle.
Usage: full-source-audit.py COMPLETED_REPORT NEW_AUDIT_JSON
Run only after the comparison closes and its measurement owner releases the hold.
"""
import datetime as dt
import hashlib
import json
import math
from pathlib import Path
import statistics
import sys
import traceback

assert len(sys.argv) == 3, __doc__
source, destination = map(Path, sys.argv[1:])
assert not destination.exists(), 'Refuse to overwrite an audit'
ORDER = ['typescript', 'checked', 'derived', 'derived', 'checked', 'typescript']
FINAL_API = '5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667'
FINAL_SOURCE = 'e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d'
PIN = '6018e28ecc67cf1fffc0c20c64b11023474c2df8'
audit = {'kind': 'phase5-independent-full-source-audit', 'complete': False,
         'newCompilerExecutions': 0, 'newOracleExecutions': 0,
         'fixedPointProof': False, 'files': [], 'rows': []}
seen = {}
def stamp(s):
    return dt.datetime.fromisoformat(s.replace('Z', '+00:00'))
def record(file, expected=None):
    p = Path(file).absolute()
    data = p.read_bytes()
    item = {'file': str(p), 'canonicalPath': str(p.resolve()),
            'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
    if expected:
        assert item['sha256'] == expected['sha256'], 'Changed file: ' + str(p)
        assert item['canonicalPath'] == expected.get('canonicalPath', item['canonicalPath']), 'Changed canonical path: ' + str(p)
    if str(p) in seen:
        assert seen[str(p)] == item, 'File changed during audit: ' + str(p)
    else:
        seen[str(p)] = item
        audit['files'].append(item)
    return data
def read(file, expected=None):
    return json.loads(record(file, expected))
def check_identity(i):
    record(i['file'], i)
def execution(e):
    assert e['exitCode'] == 0 and e['signal'] is None and e['error'] is None, e
    assert e['timedOut'] is False and e['overflow'] is False, e
    assert math.isfinite(e['wallMs']) and e['wallMs'] > 0
    stdout, stderr = record(e['stdout']), record(e['stderr'])
    assert len(stdout) + len(stderr) == e['logBytes'] <= e['maxBytes']
    assert 0 < e['timeoutMs'] <= 900000
    return stdout
def close(a, b):
    assert math.isclose(a, b, rel_tol=1e-12, abs_tol=1e-8), (a, b)

try:
    report = read(source)
    record(__file__)
    plan_path = Path(__file__).resolve().parents[2] / 'experiments/phase5/P5-023-final-full-source-comparison.md'
    record(plan_path)
    association = read(source.parent.parent / 'full-source-plan-identity.json')
    assert Path(association['file']).resolve() == plan_path
    assert association['sha256'] == seen[str(plan_path)]['sha256']
    assert association['committedBytesEqualCurrent'] is True
    assert stamp(association['commitTime']) < stamp(report['started']) < stamp(association['recordedAt'])
    audit['planAssociation'] = association
    audit['planAssociationVerification'] = 'Current plan bytes and chronology checked; historical commit-byte equality is the separately retained root association, not a new git query or an original benchmark input.'
    assert report['kind'] == 'phase5-final-full-source-comparison'
    assert report['complete'] is True and report['inputsUnchanged'] is True
    assert not report.get('error') and not report.get('smoke') and not report.get('prepared')
    assert report['order'] == ORDER and len(report['rows']) == 6
    assert report['newBootstrap'] is False and report['decodedBaseEqual'] is True
    for i in report['inputs']:
        check_identity(i)
    config = read(report['inputs'][0]['file'], report['inputs'][0])
    assert config.get('smoke', False) is False and config.get('preflightOnly', False) is False
    assert config['cpu'] == report['cpu'] and config['deadline'] == report['deadline']
    assert report['node']['args'] == ['--stack-size=4096', '--max-old-space-size=12288']
    assert report['node']['version'] == 'v24.18.0'
    check_identity(report['node'])
    assert stamp(report['started']) < stamp(report['finished']) <= stamp(report['deadline'])
    assert report['original']['api']['sha256'] == FINAL_API
    assert report['source'] == report['compilerSource'] and report['source']['sha256'] == FINAL_SOURCE
    for i in [report['source'], report['base'], report['runtime'], *report['original'].values()]:
        check_identity(i)
    bootstrap = read(report['original']['bootstrap']['file'])
    assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['provenance']['verifiedAfterBuild'] is True
    assert bootstrap['apiSha256'] == FINAL_API and bootstrap['sourceSha256'] == FINAL_SOURCE
    assert bootstrap['apiPath'] == report['original']['api']['file'] and bootstrap['source'] == report['source']['file']
    assert bootstrap['revision'] == PIN == report['upstream']['pin']
    assert len(bootstrap['modules']) == 59
    for i in bootstrap['provenance']['inputs']:
        check_identity(i)
    derivation = read(report['derivation']['file'], report['derivation'])
    assert derivation['complete'] is True and derivation['newBootstrap'] is False
    assert derivation['original']['api'] == report['original']['api']
    assert derivation['original']['bootstrapReport'] == report['original']['bootstrap']
    assert derivation['original']['source'] == report['source']
    for i in [derivation['output'], derivation['toolSnapshot'], *derivation['original']['inputs']]:
        check_identity(i)
    assert report['variants']['checked']['api'] == report['original']['api']['file']
    assert report['variants']['derived']['api'] == derivation['output']['file']
    for h in report['hostCopies']:
        assert record(h['original']['file'], h['original']) == record(h['copy']['file'], h['copy'])
    upstream = report['upstream']['directory']
    assert Path(report['base']['file']).resolve() == (Path(upstream) / 'bend2/base.bend').resolve()
    for name, args in [('clean', ['diff', '--quiet', 'HEAD', '--', 'bend2', 'tests']),
                       ('finalClean', ['diff', '--quiet', 'HEAD', '--', 'bend2', 'tests']),
                       ('head', ['rev-parse', 'HEAD']), ('finalHead', ['rev-parse', 'HEAD'])]:
        e = report['upstream'][name]
        assert e['command'] == 'git' and e['args'] == ['-C', upstream, *args]
        text = execution(e).decode()
        if name.lower().endswith('head'):
            assert text.strip() == PIN
    roots = report['rootPolicy']['orderedRoots']
    assert len(roots) == len(set(roots)) == 1566
    final_inputs = {i['file']: i for i in report['inputs']}
    host = next(h['copy']['file'] for h in report['hostCopies'] if h['copy']['file'].endswith('/typed-driver.mjs'))
    node_prefix = ['-c', str(report['cpu']), report['node']['file'], *report['node']['args']]
    def cell(row, mode):
        assert row['passed'] is True
        request = read(row['request']['file'], row['request'])
        observed = read(row['result']['file'], row['result'])
        assert observed == row['observation'], 'Report differs from raw worker result'
        assert request['variant'] == row['variant'] == observed['variant']
        assert request['input'] == report['source']['file'] and request['mode'] == 'library'
        assert request['base'] == report['base']['file'] and request['runtime'] == report['runtime']['file']
        assert request['upstream'] == upstream and request['host'] == host
        assert request.get('api') == report['variants'][row['variant']].get('api')
        assert request['prime'] is (mode == 'prime') and request['preflight'] is (mode == 'preflight')
        assert request['inputs'] and all(i == final_inputs[i['file']] for i in request['inputs'])
        assert observed['inputsVerified'] is True
        assert observed['node'] == {'path': report['node']['file'], 'version': report['node']['version'], 'args': report['node']['args']}
        assert observed['affinity'].split(':')[1].strip() == str(report['cpu'])
        assert row['execution']['command'] == 'taskset'
        assert row['execution']['args'] == node_prefix + [str(source.parent.resolve() / 'worker.mjs'), row['request']['file'], row['result']['file']]
        execution(row['execution'])
        assert stamp(row['started']) < stamp(row['finished']) <= stamp(report['deadline'])
        for field in ('requestMs', 'maxRssKiB'):
            assert math.isfinite(observed[field]) and observed[field] > 0
        return request, observed
    caches = []
    assert [x['variant'] for x in report['prime']] == ['checked', 'derived']
    for row in report['prime']:
        request, observed = cell(row, 'prime')
        assert observed['result']['status'] == 'primed'
        cache = read(row['cache']['file'], row['cache'])
        assert cache['validatedBy'] == 'check_book' and cache['baseSha256'] == report['base']['sha256']
        assert cache['compilerSha256'] == final_inputs[request['api']]['sha256']
        assert cache['sourcePath'] == report['base']['file']
        caches.append(cache)
    assert caches[0]['book'] == caches[1]['book']
    assert [r['variant'] for r in report['preflight']] == ['checked', 'typescript']
    preflights = [cell(row, 'preflight')[1] for row in report['preflight']]
    assert all(o['result']['status'] == 'root-preflight' and o['result']['checked'] is False and o['roots'] == roots for o in preflights)
    metadata = preflights[1]['rootMetadata']
    eligible = [d['name'] for d in metadata if d['kind'] == 'Def' and d['templates'] == 0 and (d['valueTag'] != 'Absent') and (not d['base'] or d['valueTag'] == 'Foreign')]
    assert eligible == preflights[1]['eligibleRoots'] and set(eligible) == set(roots)
    outputs, exports = {}, None
    prior_finish = None
    for index, (row, variant) in enumerate(zip(report['rows'], ORDER)):
        assert row['index'] == index and row['variant'] == variant
        if prior_finish:
            assert prior_finish <= stamp(row['started']), 'Overlapping timed samples'
        prior_finish = stamp(row['finished'])
        request, observed = cell(row, 'sample')
        assert request['requestedRoots'] == roots == observed['roots']
        r = observed['result']
        assert (r['status'], r['phase'], r['checked'], r['exitCode'], r.get('diagnostic')) == ('ok', 'compile', True, 0, None)
        required = ['load', 'check', 'ownership', 'emit'] if variant == 'typescript' else ['check_from_exact_prefix', 'driver_owned', 'driver_todos', 'driver_emit_owned', 'annotate_selected', 'j_layout_error', 'j_library_selected']
        assert all(observed['calls'][name] == 1 for name in required)
        emitted = observed['emitted']
        assert emitted['file'] == request['output']
        data = record(emitted['file'], emitted)
        assert len(data) == emitted['bytes']
        family = 'typescript' if variant == 'typescript' else 'bend'
        if family in outputs:
            assert outputs[family] == data, 'Output bytes differ within emitter family'
        else:
            outputs[family] = data
        if variant == 'typescript':
            assert observed['rootMetadata'] == metadata and observed['eligibleRoots'] == eligible
            assert row['checkedRootClassifierEqual'] is True
        oracle_source = record(row['oracle']['file'], row['oracle']).decode()
        assert 'assert.equal(H.default.f_ascii_ident_code(65),true);assert.equal(H.default.f_ascii_ident_code(128512),false);' in oracle_source
        if variant != 'typescript':
            assert 'H.default.j_library_roots(H.list(defs))' in oracle_source
            assert 'assert.deepEqual(actual,' in oracle_source
        else:
            assert 'assert.deepEqual(Object.keys(H.default),roots);' in oracle_source
        assert row['outputExecution']['command'] == 'taskset' and row['outputExecution']['args'] == node_prefix + [row['oracle']['file']]
        oracle = json.loads(execution(row['outputExecution']))
        assert oracle == row['outputOracle']
        assert oracle['rootCount'] == 1566 and oracle['asciiOracle'] is True and oracle['actualOutputExports'] is True
        assert oracle['actualHClassifier'] is (variant != 'typescript')
        assert set(roots).issubset(oracle['actualExportKeys'])
        if variant == 'typescript':
            assert oracle['actualExportKeys'] == roots
        elif exports is None:
            exports = oracle['actualExportKeys']
        else:
            assert exports == oracle['actualExportKeys']
        audit['rows'].append({'index': index, 'variant': variant, 'requestMs': observed['requestMs'], 'processWallMs': row['execution']['wallMs'], 'maxRssKiB': observed['maxRssKiB'], 'emitted': emitted, 'rootCount': len(roots), 'actualHClassifier': oracle['actualHClassifier']})
    means = {v: {f: statistics.mean(x[f] for x in audit['rows'] if x['variant'] == v) for f in ('requestMs', 'processWallMs', 'maxRssKiB')} for v in ('typescript', 'checked', 'derived')}
    pairs = [{'checkedIndex': a, 'derivedIndex': b, 'requestReductionPercent': 100 * (1 - audit['rows'][b]['requestMs'] / audit['rows'][a]['requestMs']), 'processReductionPercent': 100 * (1 - audit['rows'][b]['processWallMs'] / audit['rows'][a]['processWallMs'])} for a, b in [(1, 2), (4, 3)]]
    ratios = {v: {'request': means[v]['requestMs'] / means['typescript']['requestMs'], 'process': means[v]['processWallMs'] / means['typescript']['processWallMs']} for v in ('checked', 'derived')}
    assert report['summary']['validComparison'] is True
    for v in means:
        for own, prior in [('requestMs', 'meanRequestMs'), ('processWallMs', 'meanProcessWallMs'), ('maxRssKiB', 'meanMaxRssKiB')]:
            close(means[v][own], report['summary']['variants'][v][prior])
    for own, prior in zip(pairs, report['summary']['pairs']):
        assert own.keys() == prior.keys()
        for k in own:
            close(own[k], prior[k])
    for v in ratios:
        for k in ratios[v]:
            close(ratios[v][k], report['summary']['descriptiveRatiosToTypescript'][v][k])
    audit.update({'complete': True, 'orderedRootCount': len(roots), 'means': means, 'pairs': pairs, 'ratiosToTypescript': ratios,
                  'meanReductionPercent': {k: 100 * (1 - means['derived'][k] / means['checked'][k]) for k in ('requestMs', 'processWallMs')},
                  'cachePolicy': report['cachePolicy'], 'timingBoundary': report['timingBoundary'],
                  'limitations': 'Two opposite-order pairs; TS checks Base fresh and Bend uses separately validated disk caches. Existing output oracle executions are audited, not rerun. No fixed-point claim.'})
except Exception:
    audit['error'] = traceback.format_exc()
destination.parent.mkdir(parents=True, exist_ok=True)
with destination.open('x') as f:
    json.dump(audit, f, indent=2)
    f.write('\n')
print(json.dumps({k: audit.get(k) for k in ('complete', 'means', 'pairs', 'ratiosToTypescript', 'error')}))
if not audit['complete']:
    sys.exit(1)
