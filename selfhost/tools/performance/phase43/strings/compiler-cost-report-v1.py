#!/usr/bin/env python3
"""Render existing complete Phase35-format cost reports; never execute a target."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import statistics

CORE = ['local-pair', 'tree-bitonic', 'coverage-numeric-recurrence-1024', 'coverage-list-pipeline-512']
FAMILIES = ['lexer', 'coverage-map-churn-128', 'coverage-closures-256', 'coverage-bst-64']
ROLES = ['typescript', 'baseline', 'candidate']
METRICS = ['requestMs', 'importAndRequestMs', 'processWallMs', 'outputBytes']
BASE_API = '63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54'

def identity(path):
    path = Path(path).resolve()
    return {'file': str(path), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}

def close(a, b):
    assert math.isclose(a, b, rel_tol=1e-12, abs_tol=1e-9), (a, b)

def load(path, ids, candidate_api):
    report = json.loads(path.read_text())
    assert report['kind'] == 'phase35-normal-checked-library-cost'
    assert report['complete'] is True and report['pass'] is True and not report.get('error')
    config_path = Path(report['config']['file'])
    assert identity(config_path)['sha256'] == report['config']['sha256']
    config = json.loads(config_path.read_text())
    assert config['kind'] == 'phase35-normal-checked-library-cost-plan' and config['complete'] is True
    assert config['samples'] == 3 and config['order'] == ROLES and str(config['cpu']) == '3'
    assert config['heapMiB'] == 1024 and config['rssMiB'] == config['availableMiB'] == 2048
    assert config['timeoutMs'] == 180000
    assert [case['id'] for case in config['cases']] == ids
    assert config['variants']['baseline']['api']['sha256'] == BASE_API
    assert config['variants']['candidate']['api']['sha256'] == candidate_api
    assert config['variants']['typescript']['typescript'] is True
    assert all(config['variants'][r]['typescript'] is False for r in ['baseline', 'candidate'])
    assert len(report['rows']) == 36 and set(report['statistics']) == set(ids)
    seen = set()
    cases = {c['id']: c for c in config['cases']}
    for row in report['rows']:
        key = (row['source'], row['variant'], row['sample'])
        assert key not in seen and key[0] in ids and key[1] in ROLES and key[2] in range(3)
        seen.add(key)
        ex, obs = row['execution'], row['observation']
        assert ex['complete'] is True and ex['returncode'] == 0 and not ex.get('stopped')
        assert obs['complete'] is True and obs['pass'] is True and not obs.get('error')
        assert obs['variant'] == key[1] and obs['source'] == cases[key[0]]['source']
        assert obs['affinity'].split(':', 1)[1].strip() == '3'
        assert obs['node'] == 'v24.18.0'
        assert obs['output']['sha256'] == cases[key[0]]['expected'][key[1]]['sha256']
    result = {}
    for source in ids:
        result[source] = {}
        for role in ROLES:
            rows = sorted((r for r in report['rows'] if r['source'] == source and r['variant'] == role), key=lambda r: r['sample'])
            assert len(rows) == 3
            values = {m: [r['observation'][m] for r in rows] for m in METRICS[:2]}
            values['processWallMs'] = [r['execution']['wallSeconds'] * 1000 for r in rows]
            values['outputBytes'] = [r['observation']['output']['bytes'] for r in rows]
            result[source][role] = {}
            for metric, samples in values.items():
                assert all(isinstance(x, (int, float)) and math.isfinite(x) and x >= 0 for x in samples)
                stats = {'min': min(samples), 'median': statistics.median(samples), 'max': max(samples), 'samples': samples}
                saved = report['statistics'][source][role][metric]
                for field in ['min', 'median', 'max']:
                    close(stats[field], saved[field])
                assert len(saved['samples']) == 3
                for x, y in zip(samples, saved['samples']):
                    close(x, y)
                result[source][role][metric] = stats
    return report, config, result

def cell(stats, integer=False):
    fmt = (lambda x: f'{x:,.0f}') if integer else (lambda x: f'{x:.3f}')
    return ' / '.join(fmt(stats[f]) for f in ['min', 'median', 'max'])

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--core', type=Path, required=True)
    ap.add_argument('--families', type=Path, required=True)
    ap.add_argument('--candidate-api-sha256', required=True)
    ap.add_argument('--out', type=Path, required=True, help='Fresh Markdown path; adjacent JSON also written')
    a = ap.parse_args()
    assert len(a.candidate_api_sha256) == 64 and all(c in '0123456789abcdef' for c in a.candidate_api_sha256)
    core, cc, cs = load(a.core, CORE, a.candidate_api_sha256)
    families, fc, fs = load(a.families, FAMILIES, a.candidate_api_sha256)
    for role in ROLES:
        assert cc['variants'][role]['api'] == fc['variants'][role]['api']
        assert cc['variants'][role]['attempt'] == fc['variants'][role]['attempt']
    assert cc['node'] == fc['node'] and cc['worker']['sha256'] == fc['worker']['sha256']
    lines = ['# Phase43 compiler request costs', '',
             'These are normal checked-library compilation requests, compared with the previous release and the pinned TypeScript compiler. They are separate from generated-program execution speed. Each source/role has three serial fresh-process samples on Node 24.18.0 and CPU3, with a 1 GiB heap and 2 GiB process-tree RSS limit.', '',
             '`requestMs` includes checking and emission through the normal request, including Bend lazy API loading and normal Base cache handling. `importAndRequestMs` additionally includes host module import. `processWallMs` includes the complete worker process, including preflight and validation. `outputBytes` measures the emitted module; it is not heap use. Every table cell is **min / median / max**. Ratios use medians; a ratio above one means the candidate costs more.', '',
             'Compiler request timing does not isolate emitter time, and these eight sources do not establish whole-compiler throughput. The tables retain both improvements and regressions. Tiny differences and three-sample ranges do not establish statistical significance.', '',
             f"Baseline API: `{BASE_API}`. Candidate API: `{a.candidate_api_sha256}`.", '']
    for label, ids, stats, report_path in [('Core four', CORE, cs, a.core), ('Changed families four', FAMILIES, fs, a.families)]:
        lines += [f'## {label}', '', f'Raw report: [{report_path.name}]({Path(report_path).resolve()}).', '']
        for metric in METRICS:
            lines += [f'### {metric}', '', '| Source | Previous release | Candidate | TypeScript | Candidate / previous median |', '|---|---:|---:|---:|---:|']
            for source in ids:
                baseline = stats[source]['baseline'][metric]['median']
                candidate = stats[source]['candidate'][metric]['median']
                ratio = f'{candidate / baseline:.4f}' if baseline else 'undefined (zero baseline)'
                cells = [cell(stats[source][role][metric], metric == 'outputBytes') for role in ['baseline', 'candidate', 'typescript']]
                lines.append('| ' + ' | '.join([source, *cells, ratio]) + ' |')
            lines.append('')
    summary = {'kind': 'phase43-compiler-cost-summary', 'complete': True, 'pass': True,
               'renderer': identity(__file__), 'reports': [identity(a.core), identity(a.families)],
               'configs': [core['config'], families['config']], 'baselineApi': BASE_API,
               'candidateApi': a.candidate_api_sha256, 'rows': 72,
               'scope': 'Three fresh compiler-request samples per eight sources and three roles; not generated-program timing or emitter-only attribution.',
               'statistics': {'core': cs, 'changedFamilies': fs}}
    adjacent = a.out.with_suffix('.json')
    assert not a.out.exists() and not adjacent.exists(), 'Fresh output paths required'
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x', encoding='utf8') as stream:
        stream.write('\n'.join(lines))
    with adjacent.open('x', encoding='utf8') as stream:
        stream.write(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({'complete': True, 'rows': 72, 'markdown': str(a.out), 'json': str(adjacent)}))

if __name__ == '__main__':
    main()
