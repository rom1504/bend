#!/usr/bin/env python3
"""Data-only first-request CPU/allocation ancestry census. Never imports a compiler."""
import argparse
import ast
import collections
import hashlib
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase62'
UPSTREAM = '018751270e800bc222a93dad7f257083ee53a5f7'
B2 = '23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477'
SOURCE = '268b3cf2e1f1c2810c372925ccd1ad7eb91225853d432ca9517f05f2ecefd42e'
CPU_READER = ROOT / 'selfhost/tools/performance/phase57/analysis/profiles-v2.py'
CPU_READER_SHA = 'ab678fb32d51d497009d5e1ffbae3ffbba4fdae27973b47546d2b5859d7c0d19'

# The nearest real named boundary wins. Nested host conversion is therefore
# separate from final emission; definition/call-fact work is separately intersected.
GENERATED_BOUNDARIES = {
    'f_complete_source': 'source-completion',
    'f_complete_seed': 'source-completion',
    'f_prefix_complete_source': 'source-completion',
    'f_prefix_complete_seed': 'source-completion',
    'f_prefix_graph_trace': 'source-graph-freshening',
    'f_graph_trace_from_prefix': 'source-graph-freshening',
    'f_graph_trace': 'source-graph-freshening',
    'f_graph_error': 'source-error-scan',
    'fpe_defs': 'source-error-scan',
    'fpe_term': 'source-error-scan',
    'driver_emit_owned': 'owned-foreign-layout',
    'book_context': 'book-context',
    'jd_roots': 'roots-and-stops',
    'jd_stops': 'roots-and-stops',
    'reach_book': 'source-reach',
    'annotate_selected': 'annotation',
    'annotate_book': 'annotation',
    'jd_reach_selected': 'emitted-reach',
    'jd_library_selected': 'final-library',
    'jd_program_selected': 'final-program',
    'jd_foreign_error': 'foreign-validation',
    'j_layout_error': 'layout-proof',
    'jd_foreign_paths': 'foreign-paths',
    'jd_modules': 'foreign-modules',
}
DRIVER_BOUNDARIES = {
    'loadApi': 'api-load', 'loadApiForIdentity': 'api-load',
    'baseCacheInfo': 'base-identity', 'readBaseCache': 'base-cache',
    'prepareBase': 'base-preparation', 'discoverSources': 'source-loading',
    'foreignSources': 'foreign-sources',
}


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def finite(x):
    return isinstance(x, (int, float)) and not isinstance(x, bool) and math.isfinite(x) and x >= 0


def approx(x, y):
    assert math.isclose(x, y, rel_tol=1e-10, abs_tol=.001), (x, y)


def decoded(name):
    # A shared SCC function is named after one representative but can execute
    # other members. Require a real named wrapper somewhere in the stack.
    if name.endswith('$scc'):
        return None
    if name.startswith('$jd$'):
        body = name[4:]
        result = re.sub(r'_([0-9]+)_', lambda m: chr(int(m[1])), body)
        encoded = ''.join(c if c.isascii() and c.isalnum() else '_'+str(ord(c))+'_' for c in result)
        return result if encoded == body else None
    if name.startswith('$') and name.endswith('$'):
        return name[1:-1]
    return None


def flags(stack, api):
    names = [decoded(f['functionName']) for f in stack if f.get('url') == api]
    names = [n for n in names if n is not None]
    return {
        'substitution': any(n.startswith(('subst', 'env_subst')) for n in names),
        'normalization': any(n.startswith(('norm_', 'wnf')) for n in names),
        'index': any(n.startswith('index_') for n in names),
        'strings': any(n.startswith('String.') for n in names),
        'definition': 'jd_doc_definition' in names,
        'calls': 'jd_calls_context' in names,
        'reach': 'jd_reach_selected' in names,
        'library': 'jd_library_selected' in names,
        'host': any(n.startswith(('jd_host', 'jd_marshal')) for n in names),
        'arityQueries': any(n in {'jd_arity', 'jd_domains', 'jd_domains_head',
            'jd_live_arity', 'jd_live_arity_head', 'jd_params', 'jd_params_head'} for n in names),
        'jdArity': 'jd_arity' in names,
        'jdDomains': any(n in {'jd_domains', 'jd_domains_head'} for n in names),
        'jdLiveArity': any(n in {'jd_live_arity', 'jd_live_arity_head'} for n in names),
        'jdParams': any(n in {'jd_params', 'jd_params_head'} for n in names),
    }


def classify(stack, api, driver, upstream):
    """No source attribution from anonymous frames or shared SCC member guesses."""
    leaf = stack[0]
    name = leaf.get('functionName', '')
    if name == '(garbage collector)':
        return 'GC'
    if any(f.get('url', '').startswith('node:inspector') for f in stack):
        return 'inspector-overhead'
    if name in {'(idle)', '(program)', '(root)'}:
        return name.strip('()')
    if not api and any(f.get('url') == 'node:internal/modules/typescript' and
            f.get('functionName') in {'parseTypeScript', 'processTypeScriptCode', 'stripTypeScriptModuleTypes'}
            for f in stack):
        return 'typescript-module-stripping'
    for f in stack:
        name, url = f.get('functionName', ''), f.get('url', '')
        if api and url == api:
            n = decoded(name)
            if n:
                if n.startswith(('jd_host', 'jd_marshal')):
                    return 'host-wrapper'
                if n.startswith('check_program_diagnostic'):
                    return 'checker'
                if n in GENERATED_BOUNDARIES:
                    return GENERATED_BOUNDARIES[n]
        if driver and url == driver and name in DRIVER_BOUNDARIES:
            return DRIVER_BOUNDARIES[name]
        if not api:
            if url == (upstream / 'bend2/bend.ts').as_uri():
                if name == 'book_load': return 'source-loading'
                if name == 'book_valid': return 'checker'
            if url == (upstream / 'bend2/comp.ts').as_uri():
                if name == 'file_book': return 'ts-file-analysis'
                if name == 'js_lib': return 'ts-library'
                if name == 'js_book': return 'ts-program'
    if any(f.get('functionName') == 'compileSourceTextModule' for f in stack):
        return 'module-compilation'
    if api and leaf.get('url') == api:
        return 'other-generated-image'
    if driver and leaf.get('url') == driver:
        return 'other-host-driver'
    if not api and leaf.get('url') in {(upstream / 'bend2/bend.ts').as_uri(), (upstream / 'bend2/comp.ts').as_uri()}:
        return 'other-typescript'
    if leaf.get('url', '').startswith(('node:', 'internal/')):
        return 'other-node'
    return 'other-unassigned'


def partition(raw, mode, weights, api, driver, upstream):
    nodes, parents = {}, {}
    if mode == 'cpu':
        nodes = {n['id']: n for n in raw['nodes']}
        assert len(nodes) == len(raw['nodes'])
        for n in nodes.values():
            for child in n.get('children', []):
                assert child in nodes and child not in parents
                parents[child] = n['id']
        samples = list(zip(raw['samples'], weights))
    else:
        todo = [(raw['head'], None)]
        while todo:
            n, parent = todo.pop()
            assert n['id'] not in nodes
            nodes[n['id']] = n
            parents[n['id']] = parent
            todo.extend((c, n['id']) for c in n.get('children', []))
        samples = [(s['nodeId'], s['size']) for s in raw['samples']]
    stages, unions, cross, unknown, all_self = [collections.Counter() for _ in range(5)]
    absent, unknown_stacks = collections.Counter(), {}
    cache = {}
    for nid, weight in samples:
        assert finite(weight)
        if nid not in nodes:
            assert mode == 'allocation'
            absent[nid] += weight
            stages['absent-tree-node'] += weight
            continue
        if nid not in cache:
            stack, seen, cursor = [], set(), nid
            while cursor is not None:
                assert cursor not in seen
                seen.add(cursor)
                stack.append(nodes[cursor]['callFrame'])
                cursor = parents.get(cursor)
            stage = classify(stack, api, driver, upstream)
            leaf = stack[0]
            key = (leaf['functionName'], leaf.get('url', ''), leaf.get('lineNumber', -1), leaf.get('columnNumber', -1))
            f = flags(stack, api) if api else {}
            cache[nid] = stage, key, f, stack
        stage, key, f, stack = cache[nid]
        stages[stage] += weight
        all_self[key] += weight
        if stage.startswith('other-'):
            unknown[key] += weight
            unknown_stacks[key] = stack[:12]
        for k, value in f.items():
            if value: unions[k] += weight
        for k in ['definition', 'calls', 'substitution', 'normalization', 'arityQueries']:
            for boundary in ['reach', 'library', 'host']:
                if f.get(k) and f.get(boundary): cross[k+'Under'+boundary.title()] += weight
    total = sum(w for _, w in samples)
    approx(sum(stages.values()), total)
    def table(counter):
        return [dict(name=k, weight=v, percent=100*v/total if total else 0) for k, v in counter.most_common()]
    def frames(counter, limit, with_stack=False):
        result = []
        for k, v in counter.most_common(limit):
            row = dict(functionName=k[0], url=k[1], lineNumber=k[2], columnNumber=k[3], weight=v, percent=100*v/total if total else 0)
            if with_stack: row['exampleLeafFirstStack'] = unknown_stacks[k]
            result.append(row)
        return result
    return dict(total=total, sampleEvents=len(samples), exclusiveStages=table(stages),
                inclusiveAncestorUnions=table(unions), intersections=table(cross),
                absentTreeNodes=dict(weight=sum(absent.values()), ids=dict(absent)),
                topSelf=frames(all_self, 25), unresolvedSelf=frames(unknown, 30, True))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--report', type=Path, action='append', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    inputs = {}
    def pin(value):
        file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
        if str(file) not in inputs:
            inputs[str(file)] = dict(file=str(file), sha256=sha(file), bytes=file.stat().st_size)
        item = inputs[str(file)]
        if isinstance(value, dict):
            assert item['sha256'] == value['sha256'], str(file)
            if 'bytes' in value: assert item['bytes'] == value['bytes'], str(file)
        return item
    def read(value):
        ident = pin(value)
        return ident, json.loads(Path(ident['file']).read_text())
    predecessor = pin(Path(__file__).with_name('profiles.py'))
    assert predecessor['sha256'] == 'e488c6e4acc0dd6ad3a992684c170d0d8202a4a2b9863ff18dd1a7015c9b9822'
    cpu_method = pin(CPU_READER)
    assert cpu_method['sha256'] == CPU_READER_SHA
    tree = ast.parse(CPU_READER.read_text())
    fn = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'cpu_views')
    context = dict(finite=finite, approx=approx, read=read)
    exec(compile(ast.Module(body=[fn], type_ignores=[]), str(CPU_READER), 'exec'), context)
    rows, reports, failures, seen = [], [], [], set()
    for file in a.report:
        rid, report = read(file)
        reports.append(rid)
        cid, config = read(report['config'])
        assert config['upstreamCommit'] == UPSTREAM and config['rounds'] == 1 and config['warmRequests'] == 0
        assert config['mode'] in {'cpu', 'allocation'} and config['mode'] == report['mode']
        assert config['resources']['cpu'] == 3 and config['resources']['heapMiB'] == 1024
        expected = {(c['id'], r, 0) for c in config['cases'] for r in config['roles']}
        actual = [(r.get('case'), r.get('role'), r.get('sample')) for r in report['rows']]
        assert len(actual) == len(expected) and set(actual) == expected
        for item in config['inputs']: pin(item)
        if not (report['complete'] and report['pass']):
            failures.append(dict(report=rid, reason='Input campaign incomplete or failed; its status is preserved'))
        for row in report['rows']:
            try:
                key = config['mode'], row['case'], row['role'], row['sample']
                assert key not in seen
                seen.add(key)
                wid, w = read(row['result'])
                assert w == row['observation'] and row['success'] and row['execution']['returncode'] == 0
                assert w['complete'] and w['pass'] and not w['cleanTiming'] and not w['warmRequests']
                assert w['config']['sha256'] == cid['sha256'] and w['role'] == row['role']
                case = next(c for c in config['cases'] if c['id'] == row['case'])
                assert w['source'] == case['source'] and w['expected'] == case['references'][row['role']]
                for field in ['source', 'output', 'expected']: pin(w[field])
                assert Path(w['output']['file']).read_bytes() == Path(w['expected']['file']).read_bytes()
                _, prep = read(w['preparation'])
                assert prep['complete'] and prep['pass'] and prep['role'] == row['role']
                image = w.get('image')
                if image:
                    assert image == prep['image']
                    for value in image.values():
                        if isinstance(value, dict) and 'sha256' in value: pin(value)
                    if row['role'] == 'b2':
                        assert image['api']['sha256'] == B2 and image['source']['sha256'] == SOURCE
                inline = w['profile']
                qid, q = read(inline['receipt'])
                assert q == {k: v for k, v in inline.items() if k != 'receipt'}
                assert q['complete'] and q['pass'] and q['diagnosticOnly'] and q['calls'] == 1 and q['schemaVersion'] == 2
                mode = config['mode']
                assert q['mode'] == mode
                assert q['sampling'] == ({'intervalMicroseconds': 1000} if mode == 'cpu' else {'intervalBytes': 131072, 'includeObjectsCollectedByMajorGC': True, 'includeObjectsCollectedByMinorGC': True})
                for field in ['producer', 'predecessor', 'summaryMethod']: pin(q[field])
                rawid, raw = read(q['raw'])
                sid, summary = read(q['summary'])
                assert summary['totalWeight'] == q['totals']['totalWeight']
                api = Path(image['api']['file']).as_uri() if image else None
                driver = Path(image['driver']['file']).as_uri() if image else None
                upstream = Path(config['upstream'])
                assert q['moduleUrl'] == (api or (upstream/'bend2/comp.ts').as_uri())
                views = {}
                if mode == 'cpu':
                    context['cpu_views'](raw, summary, q)
                    views['counts'] = partition(raw, mode, [1]*len(raw['samples']), api, driver, upstream)
                    if q['weightedStatus'] == 'admitted':
                        views['microseconds'] = partition(raw, mode, [max(0, x) for x in raw['timeDeltas']], api, driver, upstream)
                else:
                    assert len(raw['samples']) == summary['sampleCount']
                    approx(sum(s['size'] for s in raw['samples']), summary['totalWeight'])
                    views['bytes'] = partition(raw, mode, None, api, driver, upstream)
                rows.append(dict(case=row['case'], role=row['role'], mode=mode, worker=wid, profile=qid,
                    raw=rawid, summary=sid, image=image, weightedStatus=q.get('weightedStatus'),
                    weightedAccounting=q.get('weightedAccounting'), views=views, sampling=q['sampling'], warnings=q['warnings']))
            except Exception as exc:
                failures.append(dict(report=rid, case=row.get('case'), role=row.get('role'), error=repr(exc)))
    for item in inputs.values(): assert sha(item['file']) == item['sha256'], item['file']
    result = dict(kind='phase62-current-profile-analysis', complete=not failures, dataOnly=True,
        targetExecuted=False, reports=reports, rows=rows, failures=failures, inputs=list(inputs.values()),
        producer=pin(__file__), cpuAccountingMethod=cpu_method,
        policy='Each raw sampled leaf is assigned exactly once in each view using nearest exact URL/named boundary; GC and inspector are separate. CPU counts exist for all admitted raw profiles; timestamp microseconds only when independently reviewed signed-delta policy admits them. Allocation estimates cumulative bytes, not live memory or time. Unions/intersections overlap; never add them to disjoint stages. Shared SCC names identify observed workers, never individual source operations. TS file_book analysis is not asserted equivalent to Bend reach. Profiler durations are not clean benchmark ratios.')
    result['pass'] = not failures
    out.mkdir(parents=True)
    (out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(out), rows=len(rows), failures=failures, weightedRefused=[dict(case=r['case'], role=r['role']) for r in rows if r['weightedStatus'] == 'refused'])))
    raise SystemExit(0 if result['pass'] else 1)


if __name__ == '__main__':
    main()
