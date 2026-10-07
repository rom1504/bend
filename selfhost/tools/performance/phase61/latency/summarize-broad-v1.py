#!/usr/bin/env python3
"""Read-only audit of a complete 23-source, three-round first-request campaign.
Usage: summarize-broad-v1.py REPORT NEW_SUMMARY_JSON NEW_CSV
No compiler imports, target execution, or historical writes.
"""
import csv, hashlib, json, math, pathlib, statistics, sys

ROLES = ['baseline', 'candidate', 'typescript']
CLOCKS = ['hostImportMs', 'apiLoadMs', 'firstRequestMs', 'importApiAndFirstMs']
METRICS = ['importApiAndFirstMs', 'firstRequestMs']
PAIRS = [('baseline', 'typescript'), ('candidate', 'typescript'), ('candidate', 'baseline')]
CATALOG_SHA = 'd5903c18804afa14b9ca4fc51196d1d419148989a9496e768822f6637004c9ba'
API_SHAS = {'baseline': 'a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081',
            'candidate': '23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477'}
pins = {}

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''): h.update(block)
    return h.hexdigest()

def identity(value):
    expected = value if isinstance(value, dict) else None
    path = pathlib.Path(value['file'] if expected else value).resolve()
    if str(path) not in pins:
        pins[str(path)] = {'file': str(path), 'sha256': digest(path), 'bytes': path.stat().st_size}
    actual = pins[str(path)]
    if expected:
        assert actual['sha256'] == expected['sha256'], str(path)
        if 'bytes' in expected: assert actual['bytes'] == expected['bytes'], str(path)
    return actual

def read(value): return json.loads(pathlib.Path(identity(value)['file']).read_text())
def gm(xs): return math.exp(statistics.mean(math.log(x) for x in xs))
def ratio_name(a, b): return a + 'Over' + b.title()
def stats(values):
    assert values and all(math.isfinite(x) and x >= 0 for x in values)
    median = statistics.median(values)
    return {'median': median, 'min': min(values), 'max': max(values), 'samples': values,
            'relativeRange': (max(values) - min(values)) / median if median else 0.0}

def main():
    assert len(sys.argv) == 4, __doc__
    report_path, summary_path, csv_path = [pathlib.Path(x).resolve() for x in sys.argv[1:]]
    for output in [summary_path, csv_path]:
        assert not output.exists(), str(output)
        assert 'phase61' in output.parts, 'New outputs must stay in Phase61'
    assert summary_path != csv_path
    producer = identity(__file__)
    report = read(report_path); config = read(report['config']); catalog = read(config['catalog'])
    assert config['catalog']['sha256'] == CATALOG_SHA
    assert report['complete'] and report['pass'] and not report['failures']
    assert report['mode'] == config['mode'] == 'clean'
    assert config['roles'] == ROLES and config['rounds'] == 3 and config['warmRequests'] == 0
    assert config['backend'] == 'direct' and not config['prepareOnly']
    assert report['expectedWorkers'] == report['successfulWorkers'] == len(report['rows']) == 207
    assert report['stableVerificationFinal']['complete'] and report['stableVerificationFinal']['pass_']
    identity(report['methodDerivation']); identity(config['imageBindings'])
    for item in config['inputs']: identity(item)
    for item in config['stableVerification']: identity(item['identity'])
    canonical = {c['id']: c for c in catalog['compileInputs']}
    assert len(canonical) == len(config['cases']) == 23
    assert [c['id'] for c in config['cases']] == [c['id'] for c in catalog['compileInputs']]
    point_ids = [p for c in config['cases'] for p in c['pointIds']]
    assert len(point_ids) == len(set(point_ids)) == 45
    assert set(point_ids) == set(report['coverage']['pointIds'])
    assert report['coverage']['freshRuntimeExecutions'] == 0
    assert report['coverage']['compileInputIds'] == list(canonical)
    expected_order = [(c['id'], n, role) for c in config['cases'] for n in range(3)
                      for role in ROLES[n:] + ROLES[:n]]
    assert [(r['case'], r['sample'], r['role']) for r in report['rows']] == expected_order
    preparation_report = read(report['preparationsReusedFrom'])
    assert preparation_report['complete'] and preparation_report['pass']
    assert report['preparations'] == preparation_report['preparations']
    preparations = {}; images = {}; receipt_rows = []; cases = []; previous_finish = 0
    for row in report['preparations']:
        o = read(row['result']); assert o == row['observation']
        assert row['success'] and row['execution']['complete'] and row['execution']['returncode'] == 0
        assert o['complete'] and o['pass'] and o['stage'] == 'prepare'
        preparations[o['role']] = (row['result'], o)
    assert set(preparations) == set(ROLES)
    for case in config['cases']:
        original = canonical[case['id']]
        for key in ['source', 'files', 'emissionInputs', 'options', 'pointIds', 'oracles']:
            assert case[key] == original[key], (case['id'], key)
        roles = {}
        for role in ROLES:
            ref_role = 'typescript' if role == 'typescript' else 'direct'
            assert config['outputPolicies'][role] == {'kind': 'catalog', 'referenceRole': ref_role}
            assert case['references'][role] == original['references'][ref_role]
            prep_id, prep = preparations[role]
            matches = [x for x in prep['outputs'] if x['id'] == case['id']]
            assert len(matches) == 1
            prepared = matches[0]; oracle = prepared['oracle']
            assert prepared['source'] == case['source'] and prepared['output'] == case['references'][role]
            assert oracle['kind'] == 'inherited-qualified-raw-module' and oracle['pass']
            assert oracle['freshlyExecuted'] is False and oracle['catalog'] == config['catalog']
            assert oracle['pointIds'] == case['pointIds'] and oracle['points'] == case['oracles']
            rows = [r for r in report['rows'] if r['case'] == case['id'] and r['role'] == role]
            assert [r['sample'] for r in rows] == [0, 1, 2]
            observations = []
            for row in rows:
                execution = row['execution']; o = read(row['result']); request = read(o['request'])
                assert row['success'] and execution['complete'] and execution['returncode'] == 0
                assert row['observation'] == o and o['complete'] and o['pass'] and o['cleanTiming']
                assert o['mode'] == 'clean' and o['stage'] == 'sample' and not o.get('profile')
                assert not o['warmRequests'] and o['role'] == role and o['sample'] == row['sample']
                assert o['preparation'] == request['preparation'] == prep_id
                assert o['config'] == request['config'] == report['config']
                assert request['case'] == case['id'] and request['role'] == role
                assert request['sample'] == row['sample'] and request['stage'] == 'sample'
                assert pathlib.Path(request['output']).resolve() == pathlib.Path(o['output']['file']).resolve()
                assert execution['command'][-2:] == [o['request']['file'], row['result']['file']]
                assert o['source'] == case['source'] and o['expected'] == case['references'][role]
                for value in [o['source'], o['expected'], o['output']]: identity(value)
                assert pathlib.Path(o['output']['file']).read_bytes() == pathlib.Path(o['expected']['file']).read_bytes()
                assert abs(o['importApiAndFirstMs'] - sum(o[k] for k in CLOCKS[:3])) < 1e-6
                assert o['image'] == prep['image']
                if o['image']:
                    assert o['image']['kind'] == 'direct' and not o['image']['diagnosticDerivation']
                    assert o['image']['api']['sha256'] == API_SHAS[role]
                    for key in ['api', 'source', 'base', 'runtime', 'directRuntime', 'driver', 'emission', 'checkedGenerator']:
                        identity(o['image'][key])
                    if role in images: assert images[role] == o['image']
                    images[role] = o['image']
                else: assert role == 'typescript'
                observations.append(o)
                receipt_rows.append({'case': case['id'], 'role': role, 'sample': row['sample'],
                                     'result': row['result'], 'output': o['output'], 'execution': execution})
            measured = {m: stats([o[m] for o in observations]) for m in CLOCKS + ['maxRssKiB', 'preflightMs', 'workerElapsedMs']}
            for m in CLOCKS:
                published = {k: v for k, v in measured[m].items() if k != 'relativeRange'}
                assert published == report['statistics'][case['id']][role][m]
            measured['peakTreeRssBytes'] = stats([r['execution']['peakTreeRssBytes'] for r in rows])
            roles[role] = measured
        ratios = {m: {ratio_name(a,b): roles[a][m]['median'] / roles[b][m]['median'] for a,b in PAIRS} for m in METRICS}
        cases.append({'id': case['id'], 'source': case['source'], 'pointIds': case['pointIds'], 'roles': roles, 'ratios': ratios})
    for row in report['rows']:
        ex = row['execution']; assert ex['started'] >= previous_finish and ex['finished'] >= ex['started']
        previous_finish = ex['finished']
    metrics = {}
    for metric in METRICS:
        aggregates = {'geomeans': {}, 'ratioOfSummedMedians': {}, 'counts': {}, 'variability': {}}
        for a,b in PAIRS:
            name = ratio_name(a,b)
            values = [c['ratios'][metric][name] for c in cases]
            aggregates['geomeans'][name] = gm(values)
            aggregates['ratioOfSummedMedians'][name] = sum(c['roles'][a][metric]['median'] for c in cases) / sum(c['roles'][b][metric]['median'] for c in cases)
            aggregates['counts'][name] = {'lower': sum(x < 1 for x in values), 'equal': sum(x == 1 for x in values), 'higher': sum(x > 1 for x in values)}
        for role in ROLES:
            spreads = [c['roles'][role][metric]['relativeRange'] for c in cases]
            aggregates['variability'][role] = {'medianRelativeRange': statistics.median(spreads), 'maxRelativeRange': max(spreads),
                 'maxRangeCase': max(cases, key=lambda c: c['roles'][role][metric]['relativeRange'])['id']}
        metrics[metric] = aggregates
    memory = {role: {m: {'medianAcrossCaseMedians': statistics.median(c['roles'][role][m]['median'] for c in cases),
                        'maximumObserved': max(c['roles'][role][m]['max'] for c in cases)}
                    for m in ['maxRssKiB','peakTreeRssBytes']} for role in ROLES}
    out = {'kind': 'phase61-balanced-broad-analysis', 'complete': True, 'pass': True, 'producer': producer,
           'report': identity(report_path), 'config': report['config'], 'catalog': config['catalog'], 'methodDerivation': report['methodDerivation'],
           'preparation': report['preparationsReusedFrom'], 'images': images,
           'protocol': {'sources': 23, 'inheritedRuntimePoints': 45, 'workers': 207, 'rounds': 3, 'warmRequests': 0,
                        'roles': ROLES, 'roleOrderPerSource': [ROLES[n:] + ROLES[:n] for n in range(3)],
                        'balance': 'Each role appears once in each execution position within every source; source order remains fixed.'},
           'wallSeconds': report['wallSeconds'], 'measurementStageSeconds': report['measurementStageSeconds'],
           'workerWallSeconds': sum(r['execution']['wallSeconds'] for r in report['rows']),
           'started': report['rows'][0]['execution']['started'], 'finished': report['rows'][-1]['execution']['finished'],
           'metrics': metrics, 'memory': memory, 'cases': cases, 'receipts': receipt_rows,
           'scope': ['Three fresh-process first requests per role/source with privately primed Base disk caches.',
                     'Combined includes host import, ordinary API load, and first ordinary compile; compile-only excludes both import clocks.',
                     'Every raw emitted module was compared byte-for-byte after the clocks. All 45 runtime values are inherited qualification, not newly executed.',
                     'Equal-source geometric means and ratios of summed medians are different weightings and are reported separately.',
                     'Observed minima/maxima and relative ranges describe three samples; they are not confidence intervals or significance tests.',
                     'RSS includes the entire worker/preflight/import/validation lifetime; polled tree RSS is a separate observation, not compiler-only allocation.',
                     'Different compiler source and driver/cache implementations are compared together; no isolated-pass attribution or steady-state claim.']}
    fields = ['source','metric','role','sample0','sample1','sample2','median','min','max','relative_range','baseline_over_ts','candidate_over_ts','candidate_over_baseline','max_rss_kib_median','max_rss_kib_max','tree_rss_bytes_max']
    for output in [summary_path, csv_path]: output.parent.mkdir(parents=True, exist_ok=True)
    for pin in list(pins.values()): assert digest(pathlib.Path(pin['file'])) == pin['sha256'], pin['file']
    with csv_path.open('x', newline='') as f:
        writer = csv.writer(f); writer.writerow(fields)
        for case in cases:
            for metric in METRICS:
                for role in ROLES:
                    values=case['roles'][role][metric]; memory_row=case['roles'][role]
                    writer.writerow([case['id'],metric,role,*values['samples'],values['median'],values['min'],values['max'],values['relativeRange'],
                       *[case['ratios'][metric][ratio_name(a,b)] for a,b in PAIRS],memory_row['maxRssKiB']['median'],memory_row['maxRssKiB']['max'],memory_row['peakTreeRssBytes']['max']])
    out['csv'] = identity(csv_path); out['inputs'] = list(pins.values())
    with summary_path.open('x') as f: json.dump(out, f, indent=2); f.write('\n')
    print(json.dumps({'summary': str(summary_path), 'metrics': metrics, 'memory': memory}, indent=2))

if __name__ == '__main__': main()
