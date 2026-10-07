#!/usr/bin/env python3
"""Data-only Phase60 stage and first-window profile classification; no target imports."""
import argparse
import ast
import collections
import hashlib
import json
import math
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase60'
B2 = 'a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081'
SOURCE = '85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091'
UPSTREAM = '018751270e800bc222a93dad7f257083ee53a5f7'
GROUPS = ['Import / API load', 'Cache / identity', 'Source loading',
          'Check + completion', 'Reach + code generation', 'Request residual']
CACHE = {'driver.base-identity', 'driver.base-cache', 'driver.prepare-base'}
LOAD = {'driver.source-graph', 'ts.book-load'}
CHECK = {'compiler.check-and-complete', 'ts.book-valid'}
EMIT = {'compiler.owned-layout', 'compiler.context', 'compiler.roots-and-stops',
        'compiler.source-reach', 'compiler.annotation', 'compiler.emitted-reach',
        'compiler.foreign-check', 'compiler.layout-proof', 'compiler.foreign-paths',
        'compiler.foreign-modules', 'compiler.library', 'driver.foreign-resolver',
        'driver.output-assembly', 'ts.js-lib'}
DIRECT_BOUNDARIES = {'check_program_diagnostic':'check-and-completion',
    'annotate_selected':'annotation', 'reach_book':'source-reach',
    'jd_reach_selected':'emitted-reach', 'jd_library_selected':'library-render',
    'jd_program_selected':'program-render'}


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def finite(x):
    return isinstance(x, (int, float)) and not isinstance(x, bool) and math.isfinite(x) and x >= 0


def approx(x, y):
    assert math.isclose(x, y, rel_tol=1e-10, abs_tol=.00001), (x, y)


def encode(name):
    return '$jd$' + ''.join(c if c.isascii() and c.isalnum() else '_'+str(ord(c))+'_' for c in name)


def named_family(frame, api_url):
    """Only classify actual frame names; never assign a shared worker to one member."""
    name = frame.get('functionName', '')
    if name == '(garbage collector)':
        return 'GC'
    if frame.get('url') != api_url:
        return 'Outside B2 image'
    if not name.startswith('$jd$'):
        return 'Runtime / anonymous / other image'
    body = name[4:]
    shared = body.endswith('$scc')
    if shared:
        body = body[:-4]
    decoded = re.sub(r'_([0-9]+)_', lambda m: chr(int(m[1])), body)
    if encode(decoded) != '$jd$'+body:
        return 'Runtime / anonymous / other image'
    if decoded.startswith('String.'):
        return 'String-named frames'
    if decoded.startswith(('jd_reach_', 'j_refs', 'jd_refs', 'jd_use', 'jd_used')):
        return 'Emitted reference / use names'
    if decoded.startswith(('index_', 'f_index')):
        return 'Index-named frames'
    if decoded.startswith(('subst', 'substitute')):
        return 'Substitution-named frames'
    if decoded.startswith('jd_primitive'):
        return 'Primitive table / lookup names'
    if decoded in {'qadd', 'qjoin', 'qdem', 'uses_get', 'uses_del', 'uses_merge'}:
        return 'Quantity-named frames'
    if decoded in {'kt', 'atom', 'missing'}:
        return 'Term / definition constructors'
    return 'Other named compiler frames'


def wall_partition(clock):
    assert clock['kind'] == 'phase59-exclusive-stage-clock' and clock['version'] == 1
    assert clock['incomplete'] == 0
    events = {e['id']: e for e in clock['events']}
    assert len(events) == len(clock['events'])
    roots = sorted((e for e in events.values() if e['parent'] is None), key=lambda e:e['startMs'])
    assert [e['name'] for e in roots] == ['host-import', 'api-load', 'first-request']
    groups = dict.fromkeys(GROUPS, 0.0)
    aggregate = collections.defaultdict(lambda: dict(calls=0, inclusiveMs=0.0, exclusiveMs=0.0))
    for e in events.values():
        assert not e['incomplete'] and e['exclusiveMs'] >= -.00001
        approx(e['endMs']-e['startMs'], e['inclusiveMs'])
        children = sorted((x for x in events.values() if x['parent'] == e['id']), key=lambda x:x['startMs'])
        previous = e['startMs']
        for child in children:
            assert previous <= child['startMs'] <= child['endMs'] <= e['endMs']
            previous = child['endMs']
        approx(sum(c['inclusiveMs'] for c in children), e['childMs'])
        approx(e['inclusiveMs']-e['childMs'], e['exclusiveMs'])
        chain, cursor = [], e
        while True:
            assert cursor['id'] not in [c['id'] for c in chain]
            chain.append(cursor)
            if cursor['parent'] is None:
                break
            cursor = events[cursor['parent']]
        names = {c['name'] for c in chain}
        if chain[-1]['name'] in {'host-import', 'api-load'}:
            group = GROUPS[0]
        elif names & CACHE:
            group = GROUPS[1]
        elif names & LOAD:
            group = GROUPS[2]
        elif names & CHECK:
            group = GROUPS[3]
        elif names & EMIT:
            group = GROUPS[4]
        else:
            group = GROUPS[5]
        groups[group] += e['exclusiveMs']
        a = aggregate[e['name']]
        a['calls'] += 1
        for key in ['inclusiveMs', 'exclusiveMs']:
            a[key] += e[key]
    for a in clock['aggregate']:
        actual = aggregate[a['name']]
        assert a['calls'] == actual['calls'] and a['incomplete'] == 0
        for key in ['inclusiveMs', 'exclusiveMs']:
            approx(a[key], actual[key])
    assert len(aggregate) == len(clock['aggregate'])
    for before, after in zip(roots, roots[1:]):
        assert before['endMs'] <= after['startMs']
    total = sum(e['inclusiveMs'] for e in roots)
    approx(total, sum(groups.values()))
    approx(total, clock['rootMs'])
    approx(total, clock['exclusiveMs'])
    return dict(totalMs=total, groupsMs=groups, stages=dict(aggregate))


def profile_partition(raw, mode, boundaries, api_url):
    if mode == 'cpu':
        nodes = {n['id']: n for n in raw['nodes']}
        assert len(nodes) == len(raw['nodes'])
        parents = {}
        for n in nodes.values():
            for child in n.get('children', []):
                assert child not in parents and child in nodes
                parents[child] = n['id']
        samples = [(n, 1) for n in raw['samples']]
        unit = 'CPU samples (one per event; no timestamp clipping)'
    else:
        nodes, parents, todo = {}, {}, [(raw['head'], None)]
        while todo:
            n, parent = todo.pop()
            assert n['id'] not in nodes
            nodes[n['id']] = n
            if parent is not None:
                parents[n['id']] = parent
            todo.extend((c, n['id']) for c in n.get('children', []))
        assert all(finite(s['size']) for s in raw['samples'])
        samples = [(s['nodeId'], s['size']) for s in raw['samples']]
        unit = 'Estimated sampled allocated bytes (cumulative, including collected objects)'
    cache = {}

    def ancestor(node):
        trail = []
        while node not in cache:
            assert node not in trail
            f = nodes[node]['callFrame']
            key = (f['url'], f['functionName'])
            if key in boundaries:
                cache[node] = boundaries[key]
                break
            trail.append(node)
            if node not in parents:
                cache[node] = 'unassigned'
                break
            node = parents[node]
        stage = cache[node]
        for n in trail:
            cache[n] = stage
        return stage

    stages, families, locations, leaves = (collections.Counter() for _ in range(4))
    boundary_urls = {u for u, _ in boundaries}
    for node, mass in samples:
        f = nodes[node]['callFrame']
        stages[ancestor(node)] += mass
        families[named_family(f, api_url)] += mass
        url, name = f.get('url', ''), f.get('functionName', '')
        if name == '(garbage collector)':
            location = 'GC'
        elif name in {'(root)', '(idle)', '(program)'}:
            location = name
        elif api_url and url == api_url:
            location = 'B2 image including runtime'
        elif not api_url and url in boundary_urls:
            location = 'TypeScript compiler (bend.ts + comp.ts)'
        elif api_url and url in boundary_urls:
            location = 'B2 host driver'
        elif url.startswith(('node:', 'internal/')):
            location = 'Node'
        elif '/tools/performance/' in url or '/build/phase60/' in url:
            location = 'Harness / other staged files'
        else:
            location = 'Other / unavailable location'
        locations[location] += mass
        leaves[(f['functionName'], f['url'], f['lineNumber'], f['columnNumber'])] += mass
    total = sum(v for _, v in samples)
    approx(sum(stages.values()), total)
    approx(sum(families.values()), total)
    approx(sum(locations.values()), total)
    def table(counter):
        return [dict(name=k, mass=v, percent=v/total*100 if total else 0) for k,v in counter.most_common()]
    return dict(unit=unit, total=total, sampleEvents=len(samples), ancestorStages=table(stages),
                selfNameFamilies=table(families), selfLocationGroups=table(locations),
                topSelf=[dict(functionName=k[0], url=k[1], lineNumber=k[2], columnNumber=k[3],
                              mass=v, percent=v/total*100 if total else 0) for k,v in leaves.most_common(20)],
                boundaryPolicy=[dict(url=u, functionName=n, stage=s) for (u,n),s in boundaries.items()])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, action='append', required=True)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert RAW in out.parents and not out.exists()
    inputs = {}

    def pin(value):
        p = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
        if str(p) not in inputs:
            inputs[str(p)] = dict(file=str(p), sha256=sha(p), bytes=p.stat().st_size)
        identity = inputs[str(p)]
        if isinstance(value, dict):
            assert identity['sha256'] == value['sha256'], str(p)
            if 'bytes' in value:
                assert identity['bytes'] == value['bytes']
        return identity

    def read(value):
        identity = pin(value)
        return identity, json.loads(Path(identity['file']).read_text())

    catid, catalog = read(args.catalog)
    assert catalog['complete'] and catalog['pass'] and catalog['upstreamCommit'] == UPSTREAM
    population = {c['id']:c for c in catalog['compileInputs']}
    assert len(population) == 23 and len(catalog['points']) == 45
    # Reuse the reviewed accounting policy without running its command-line body.
    method = pin(ROOT/'selfhost/tools/performance/phase57/analysis/profiles-v2.py')
    assert method['sha256'] == 'ab678fb32d51d497009d5e1ffbae3ffbba4fdae27973b47546d2b5859d7c0d19'
    tree = ast.parse(Path(method['file']).read_text())
    fn = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'cpu_views')
    context = dict(finite=finite, approx=approx, read=read)
    exec(compile(ast.Module(body=[fn], type_ignores=[]), method['file'], 'exec'), context)
    cpu_views = context['cpu_views']
    reports, rows, failures, seen = [], [], [], set()
    for path in args.report:
        rid, report = read(path)
        reports.append(rid)
        try:
            assert report['complete'] and report['kind'] == 'phase60-candidate-image-library-latency'
            cid, config = read(report['config'])
            mode = report['mode']
            assert mode in {'stages', 'cpu', 'allocation'} and config['mode'] == mode
            assert config['rounds'] == 1 and config['warmRequests'] == 0
            assert config['roles'] == ['direct', 'typescript'] and config['backend'] == 'direct'
            assert config['upstreamCommit'] == UPSTREAM
            assert config['kind'] == 'phase60-candidate-image-library-plan' and config['comparison'] == 'fixed-source'
            assert config['catalog']['sha256'] == catid['sha256']
            for key, value in dict(cpu=3, heapMiB=1024, rssMiB=2048, availableMiB=4096).items():
                assert config['resources'][key] == value
            assert set(c['id'] for c in config['cases']) == set(population)
            for identity in config['inputs'] + report['inputs']:
                pin(identity)
            method_id, campaign_method = read(report['methodDerivation'])
            assert campaign_method['kind'] in {'phase60-survey-method-derivation', 'phase60-survey-method-preflight-successor'}
            assert campaign_method['complete'] and campaign_method['dataOnly'] and not campaign_method['targetExecuted']
            if 'parentDerivation' in campaign_method:
                pin(campaign_method['parentDerivation'])
            outputs = {}
            for derivation in campaign_method['derivations']:
                pin(derivation['parent'])
                identity = pin(derivation['output'])
                name = Path(identity['file']).name
                assert name not in outputs
                outputs[name] = identity
            for name in ['run.py', 'profile.mjs', 'worker-stages.mjs' if mode == 'stages' else 'worker.mjs']:
                assert any(all(i[k] == outputs[name][k] for k in ['file', 'sha256']) for i in config['inputs'])
            expected = {(c, role, 0) for c in population for role in config['roles']}
            actual = [(r['case'], r['role'], r['sample']) for r in report['rows']]
            assert len(actual) == len(expected) and set(actual) == expected
            for row in report['rows']:
                try:
                    key = (mode, row['case'], row['role'], row['sample'])
                    assert key not in seen
                    seen.add(key)
                    wid, w = read(row['result'])
                    assert w == row['observation'] and w['complete'] and w['pass']
                    assert w['mode'] == mode and w['role'] == row['role'] and w['sample'] == 0
                    assert w['config']['sha256'] == cid['sha256'] and not w['cleanTiming'] and not w['warmRequests']
                    assert row['execution']['complete'] and row['execution']['returncode'] == 0
                    assert row['execution']['command'][:6] == ['taskset','-c','3',config['node']['file'],
                                                               '--stack-size=4096','--max-old-space-size=1024']
                    expected_worker = outputs['worker-stages.mjs' if mode == 'stages' else 'worker.mjs']
                    assert row['execution']['command'][-3] == expected_worker['file']
                    assert row['execution']['command'][-1] == wid['file']
                    assert w['node'] == 'v24.18.0' and w['kind'] == 'phase60-candidate-image-library-worker'
                    case = population[row['case']]
                    assert w['source'] == case['source']
                    for field in ['request', 'source', 'expected', 'output']:
                        pin(w[field])
                    assert all(w['expected'][k] == w['output'][k] for k in ['sha256', 'bytes'])
                    pid, preparation = read(w['preparation'])
                    assert preparation['complete'] and preparation['pass'] and preparation['role'] == row['role']
                    oracle = next(o for o in preparation['outputs'] if o['id'] == row['case'])
                    assert oracle['source'] == w['source'] and oracle['output'] == w['expected']
                    assert oracle['output'] == case['references'][row['role']]
                    proof = oracle['oracle']
                    assert proof['pass'] and proof['kind'] == 'inherited-qualified-raw-module' and proof['freshlyExecuted'] is False
                    assert proof['pointIds'] == case['pointIds'] and proof['points'] == case['oracles']
                    assert proof['catalog']['sha256'] == catid['sha256']
                    image = w.get('image')
                    if row['role'] == 'direct':
                        assert image == preparation['image'] and image['api']['sha256'] == B2 and image['source']['sha256'] == SOURCE
                        for value in image.values():
                            if isinstance(value, dict) and 'sha256' in value:
                                pin(value)
                        assert w['observation']['status'] == 'ok' and w['observation']['checked']
                    else:
                        assert preparation['upstreamCommit'] == UPSTREAM and w['observation']['checked']
                    item = dict(case=row['case'], role=row['role'], mode=mode, worker=wid, preparation=pid,
                                source=case['source'], pointIds=case['pointIds'], output=w['output'],
                                sourceBytes=case['source']['bytes'], emittedModuleBytes=w['output']['bytes'],
                                observedDefinitionCount=w['observation'].get('definitionCount'),
                                workerWallSeconds=row['execution']['wallSeconds'])
                    if mode == 'stages':
                        item.update(wall_partition(w['stages']))
                        pin(w['stageClock'])
                        if image:
                            did, d = read(w['diagnosticDriver'])
                            assert did['sha256'] == config['stageDriver']['sha256'] and d['complete'] and d['pass'] and d['exactInverse']
                            for field in ['source', 'output', 'producer', 'clock']:
                                pin(d[field])
                            assert w['originalDriver']['sha256'] == d['source']['sha256']
                            assert w['stageClock']['sha256'] == d['clock']['sha256']
                        rows.append(item)
                        continue
                    inline = w['profile']
                    qid, q = read(inline['receipt'])
                    assert q == {k:v for k,v in inline.items() if k != 'receipt'}
                    assert q['complete'] and q['pass'] and q['mode'] == mode and q['calls'] == 1 and q['schemaVersion'] == 2
                    assert q['maxRequests'] == 1 and len(q['requestMs']) == 1
                    assert w['profileWindow'] == 'Actual compiler import + API load + exactly one first compile; output validation after inspector stop'
                    assert q['sampling'] == ({'intervalMicroseconds':1000} if mode == 'cpu' else
                        dict(intervalBytes=131072, includeObjectsCollectedByMajorGC=True, includeObjectsCollectedByMinorGC=True))
                    for field in ['producer', 'predecessor', 'summaryMethod']:
                        pin(q[field])
                    assert all(q['producer'][k] == outputs['profile.mjs'][k] for k in ['file', 'sha256'])
                    rawid, raw = read(q['raw'])
                    sid, summary = read(q['summary'])
                    for field in ['totalWeight', 'sampleCount', 'unit']:
                        assert summary[field] == q['totals'][field]
                    if mode == 'cpu':
                        countid, count = cpu_views(raw, summary, q)
                        item.update(weightedStatus=q['weightedStatus'], weightedAccounting=q['weightedAccounting'],
                                    sampleCountSummary=countid)
                    else:
                        approx(sum(s['size'] for s in raw['samples']), summary['totalWeight'])
                    if image:
                        api_url = Path(image['api']['file']).as_uri()
                        assert q['moduleUrl'] == api_url
                        text = Path(image['api']['file']).read_text()
                        boundaries = {(api_url, encode(n)):s for n,s in DIRECT_BOUNDARIES.items()}
                        for n in DIRECT_BOUNDARIES:
                            assert 'function '+encode(n)+'(' in text
                        boundaries[(Path(image['driver']['file']).as_uri(), 'discoverSources')] = 'source-discovery'
                    else:
                        api_url = None
                        bend = (Path(config['upstream'])/'bend2/bend.ts').as_uri()
                        comp = (Path(config['upstream'])/'bend2/comp.ts').as_uri()
                        assert q['moduleUrl'] == comp
                        boundaries = {(bend,'book_load'):'typescript-load', (bend,'book_valid'):'check-and-completion',
                                      (comp,'file_book'):'typescript-file-analysis', (comp,'js_lib'):'library-render',
                                      (comp,'js_book'):'program-render'}
                    item.update(profile=qid, raw=rawid, summary=sid,
                                classification=profile_partition(raw, mode, boundaries, api_url))
                    rows.append(item)
                except Exception as exc:
                    failures.append(dict(report=rid, mode=mode, case=row.get('case'), role=row.get('role'), error=repr(exc), retainedRow=row))
            if not report['pass']:
                failures.append(dict(report=rid, mode=mode, error='Campaign reports pass:false; retained input failures remain disqualifying.', recorded=report.get('failures', [])))
        except Exception as exc:
            failures.append(dict(report=rid, error=repr(exc)))
    for identity in inputs.values():
        assert sha(identity['file']) == identity['sha256'], identity['file']
    result = dict(kind='phase60-diagnostic-population-analysis', complete=not failures,
                  dataOnly=True, targetExecuted=False, catalog=catid,
                  producer=dict(file=str(Path(__file__).resolve()), sha256=sha(__file__)),
                  cpuAccountingMethod=method, reports=reports, rows=rows, failures=failures,
                  inputs=list(inputs.values()), inputsUnchanged=True,
                  scope='Single observations per source/role/mode. Exclusive diagnostic wall partitions; CPU sample counts; sampled cumulative allocation. Nearest exact boundary ancestor wins; unknown ancestry retained. Name families label observed frames, including shared SCC leaders, not individual source operations or proven causes.')
    result['pass'] = not failures
    out.mkdir(parents=True)
    (out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(out), rows=len(rows), failures=failures, sha256=sha(out/'report.json'))))
    raise SystemExit(0 if result['pass'] else 1)


if __name__ == '__main__':
    main()
