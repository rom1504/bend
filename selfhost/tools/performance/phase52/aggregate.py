#!/usr/bin/env python3
"""Read-only aggregation of three completed, exact-image direct-backend batches."""
import argparse
from html import escape
import json
import math
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))
from support import identity, save
from run import load_bundle, summarize, relative_path


def gm(values):
    values = list(values)
    assert values and all(math.isfinite(x) and x > 0 for x in values)
    return math.exp(sum(math.log(x) for x in values) / len(values))


def chart(rows):
    """A standalone paired log-axis plot; all completed points remain visible."""
    values = [r['ratios'][k] for r in rows for k in ['baseline/typescript', 'candidate/typescript']]
    lo, hi = min(-1, math.floor(math.log2(min(values)))), max(1, math.ceil(math.log2(max(values))))
    left, right, top, step = 405, 955, 100, 23
    height = top + step * len(rows) + 90
    pos = lambda value: left + (math.log2(value) - lo) / (hi - lo) * (right - left)
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1100 {height}" role="img" aria-labelledby="title desc">',
        '<title id="title">Phase52 direct backend: all45 execution ratios</title>',
        '<desc id="desc">Paired dots compare Phase51 and the direct candidate with same-run pinned TypeScript for each point. Horizontal position uses a logarithmic base2 axis. Lower is faster.</desc>',
        f'<rect width="1100" height="{height}" fill="white"/>',
        '<g font-family="sans-serif" font-size="12" fill="#17212b">',
        '<text x="24" y="28" font-size="20" font-weight="bold">All45 points · same-run ratios to TypeScript · lower is faster</text>',
        '<circle cx="34" cy="52" r="4" fill="#b05a00"/><text x="45" y="56">Phase51</text>',
        '<circle cx="145" cy="52" r="4" fill="#0868ac"/><text x="156" y="56">Direct candidate</text>',
        '<text x="340" y="56">Log₂ axis; 1× is TypeScript. No points excluded.</text>']
    for power in range(lo, hi + 1):
        x = pos(2**power)
        parts += [f'<line x1="{x:.2f}" y1="80" x2="{x:.2f}" y2="{top+step*len(rows):.2f}" stroke="{"#394d59" if power == 0 else "#e0e5e9"}" stroke-width="{2 if power == 0 else 1}"/>',
                  f'<text x="{x:.2f}" y="75" text-anchor="middle">{2**power:g}×</text>']
    for i, row in enumerate(rows):
        y = top + i * step
        a, b = pos(row['ratios']['baseline/typescript']), pos(row['ratios']['candidate/typescript'])
        flag = any(f['halfDriftOver20Percent'] or f['roundSpreadOver20Percent'] for f in row['timingFlags'].values())
        if i % 2 == 0:
            parts.append(f'<rect x="18" y="{y-9}" width="1060" height="22" fill="#f7f9fb" fill-opacity="0.6"/>')
        parts += [f'<text x="24" y="{y+4}">{escape(row["id"])}{" *" if flag else ""}</text>',
                  f'<line x1="{a:.2f}" y1="{y}" x2="{b:.2f}" y2="{y}" stroke="#9eaab2"/>',
                  f'<circle cx="{a:.2f}" cy="{y}" r="4" fill="#b05a00"/>',
                  f'<circle cx="{b:.2f}" cy="{y}" r="4" fill="#0868ac"/>',
                  f'<text x="975" y="{y+4}">{row["ratios"]["candidate/typescript"]:.3f}×</text>']
    parts += [f'<text x="24" y="{height-42}">* At least one role has &gt;20% half drift or &gt;1.2× round spread; see the unfiltered report.</text>',
              f'<text x="24" y="{height-22}">Direct mode uses the upstream callable contract. This chart is execution evidence, not full-language or release qualification.</text>', '</g></svg>']
    return '\n'.join(parts) + '\n'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--attempt', type=Path, required=True)
    p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--reports', type=Path, nargs=3, required=True)
    p.add_argument('--smoke', type=Path, required=True)
    p.add_argument('--catalog', type=Path, default=HERE.parent / 'phase37/catalog.json')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists(), 'Output must be fresh'
    pins = {}

    def keep(file, expected=None):
        row = identity(file)
        if expected:
            assert row['sha256'] == expected['sha256'], str(file)
            assert 'bytes' not in expected or row['bytes'] == expected['bytes'], str(file)
        assert row['path'] not in pins or pins[row['path']] == row
        pins[row['path']] = row
        return row

    def pointer(row):
        return keep(row.get('file', row.get('path', row.get('canonicalPath'))), row)

    def read(file):
        return json.loads(Path(keep(file)['path']).read_text())

    for f in [__file__, PROGRAMS / 'run.py', PROGRAMS / 'execute.mjs', PROGRAMS / 'support.py']:
        keep(f)
    catalog, profile = read(a.catalog), read(HERE / 'profiles.json')
    cases = {c['id']: c for c in catalog['cases']}
    assert len(cases) == 45 and len({c['source']['sha256'] for c in cases.values()}) == 23
    for c in cases.values():
        keep(relative_path(a.catalog.parent, c['source']['path']), c['source'])
    bundles = {}
    for label, file, roles in [('baseline', a.baseline, ['baseline', 'typescript']), ('candidate', a.candidate, ['candidate'])]:
        inputs = []
        bundles[label] = load_bundle(file, catalog, keep(a.catalog)['sha256'], list(cases.values()), roles, inputs)
        for row in inputs:
            keep(row['path'], row)
    baseline = bundles['baseline']['roles']['baseline']['compiler']
    assert baseline['api']['sha256'] == 'c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061'
    assert baseline['runtime']['sha256'] == '3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46'
    compiler = bundles['candidate']['roles']['candidate']['compiler']
    assert compiler['backend'] == 'direct' and compiler['callingContract'] == 'upstream-compatible-direct-v1'
    attempt_file = a.attempt / 'attempt.json'
    attempt = read(attempt_file)
    assert attempt['checked'] is True and attempt['artifactKind'] == 'derived-b1'
    for key in ['api', 'runtime', 'base']:
        assert pointer(compiler[key]) == pointer(attempt[key])
    frozen = {Path(row['frozen']['file']).relative_to(attempt['snapshot']['root']).as_posix(): row['frozen'] for row in attempt['snapshot']['sources']}
    for key, path in [('driver', 'tools/typed-driver.mjs'), ('directRuntime', 'src/runtime/js/direct.mjs')]:
        assert pointer(compiler[key]) == pointer(frozen[path])
    bootstrap = read(pointer(attempt['bootstrapReport'])['path'])
    assert compiler['sourceSha256'] == bootstrap['sourceSha256']
    assert compiler['upstreamCommit'] == bootstrap['revision'] == catalog['upstreamCommit']
    manifest = read(a.candidate)
    preparation_file = relative_path(a.candidate.parent, manifest['preparation']['path'])
    keep(preparation_file, manifest['preparation'])
    preparation = read(preparation_file)
    assert preparation['complete'] and len(preparation['sources']) == 23
    source_hashes = set()
    for row in preparation['sources']:
        assert row['process']['complete'] and row['process']['returncode'] == 0
        file = relative_path(a.candidate.parent, row['emission']['path'])
        keep(file, row['emission']); emitted = read(file)
        assert emitted['complete'] and emitted['observation']['checked'] and emitted['observation']['status'] == 'ok' and emitted['compiler'] == compiler
        assert pointer(emitted['attempt']) == keep(attempt_file)
        assert pointer(emitted['catalog']) == keep(a.catalog)
        source_hashes.add(pointer(emitted['input'])['sha256'])
        pointer(emitted['output'])
        for item in emitted['emissionInputs']:
            pointer(item)
    assert source_hashes == {c['source']['sha256'] for c in cases.values()}
    smoke = read(a.smoke)
    assert smoke['complete'] and smoke['passed'] and len(smoke['cases']) == 45
    assert {c['id'] for c in smoke['cases']} == set(cases)
    smoke_inputs = [pointer(row) for row in smoke['inputs']]
    assert keep(a.candidate) in smoke_inputs
    for row in smoke['cases']:
        assert row['passed'] and row['process']['complete'] and row['result']['complete'] and row['result']['pass']
        assert row['result']['module']['sha256'] == bundles['candidate']['points'][row['id']]['candidate']['sha256']
        assert all(row['result']['config'][key] == value for key, value in cases[row['id']]['point'].items())
    expected_roles = {**bundles['baseline']['roles'], **bundles['candidate']['roles']}
    rows, reports, sample_count = [], [], 0
    for index, file in enumerate(a.reports):
        report = read(file)
        assert report['complete'] and report['pass'] and report['status'] == 'measured'
        assert report['selectedCases'] == report['measuredCases'] == 15
        assert report['plan']['selectedIds'] == profile['full45Batches'][index]
        assert report['plan']['variants'] == expected_roles
        assert report['plan']['budgetSeconds'] == 600 and report['plan']['roles'] == ['typescript', 'baseline', 'candidate']
        assert report['plan']['protocol'] == dict(defaultSet='full', rounds=5, warmupCalls=3, warmupMs=1000, calibrationMs=50, targetMs=300)
        assert (report['plan']['cpu'], report['plan']['heapMiB'], report['plan']['rssMiB'], report['plan']['availableMiB']) == (3, 1024, 2048, 4096)
        for item in report['inputs']:
            pointer(item)
        contract = read(file.parent / 'phase52-comparison.json')
        assert contract['complete'] and contract['passed'] and contract['callingContract'] == compiler['callingContract']
        assert pointer(contract['methodReport']) == keep(file)
        contract_inputs = [pointer(i) for i in contract['inputs']]
        assert keep(a.candidate) in contract_inputs and keep(a.baseline) in contract_inputs
        for c in report['cases']:
            assert c['point'] == cases[c['id']]['point']
            rounds = 3 if c['id'] == 'raytrace' else 5
            assert c['rounds'] == rounds and len(c['samples']) == rounds * 3
            calculated = summarize(c['samples'], report['plan']['roles'], rounds)
            assert calculated == c['summary'] and calculated['complete']
            for sample in c['samples']:
                assert sample['process']['complete'] and sample['process']['returncode'] == 0
                result = sample['result']; assert result['complete'] and result['pass']
                assert all(result['config'][key] == value for key, value in cases[c['id']]['point'].items())
                bundle = bundles['candidate' if sample['role'] == 'candidate' else 'baseline']
                assert result['module']['sha256'] == bundle['points'][c['id']][sample['role']]['sha256']
                assert result['toolSha256'] == keep(PROGRAMS / 'execute.mjs')['sha256']
                assert result['node'] == attempt['node']['version']
                pointer(result['module'])
            flags = {}
            for role, stats in calculated['stats'].items():
                drift = [x for x in stats['halfDriftPercent'] if x is not None]
                flags[role] = dict(maxAbsoluteHalfDriftPercent=max(map(abs, drift), default=0),
                    maxOverMinRoundMedian=stats['maximumMs'] / stats['minimumMs'],
                    halfDriftOver20Percent=any(abs(x) > 20 for x in drift),
                    roundSpreadOver20Percent=stats['maximumMs'] / stats['minimumMs'] > 1.2)
            ratios = calculated['ratios']
            rows.append(dict(id=c['id'], sourceSha256=cases[c['id']]['source']['sha256'], source=cases[c['id']]['source']['path'],
                mediansMs={role: stats['medianMs'] for role, stats in calculated['stats'].items()}, ratios=ratios,
                candidateOverBaseline=1 / ratios['baseline/candidate'], timingFlags=flags, report=keep(file)))
            sample_count += len(c['samples'])
        reports.append(keep(file))
    assert len(rows) == len({r['id'] for r in rows}) == 45 and sample_count == 669
    by_source = {}
    for row in rows:
        by_source.setdefault(row['sourceSha256'], []).append(row)
    keys = ['baseline/typescript', 'candidate/typescript', 'baseline/candidate']
    sources = [dict(sha256=sha, ids=[r['id'] for r in group], ratios={k: gm(r['ratios'][k] for r in group) for k in keys}) for sha, group in sorted(by_source.items())]
    ranges = {k: dict(minimum=min(rows, key=lambda r:r['ratios'][k])['id'], minimumRatio=min(r['ratios'][k] for r in rows),
        maximum=max(rows, key=lambda r:r['ratios'][k])['id'], maximumRatio=max(r['ratios'][k] for r in rows)) for k in keys}
    sizes = {}
    for role in ['baseline', 'candidate', 'typescript']:
        bundle = bundles['candidate' if role == 'candidate' else 'baseline']
        entries = [bundle['points'][name][role] for name in cases]
        distinct = {row['sha256']: row['bytes'] for row in entries}
        sizes[role] = dict(distinctUsedModules=len(distinct), distinctModuleBytes=sum(distinct.values()),
                           pointMappedBytes=sum(row['bytes'] for row in entries),
                           scope='Whole emitted module bytes including runtime and observer; distinct hashes counted once. Repeated source/input points do not add distinct code.')
    for item in list(pins.values()):
        assert identity(item['path']) == item, 'Input changed: ' + item['path']
    output = dict(kind='phase52-completed-direct-full45-aggregate', complete=True, passed=True, compiler=compiler,
        scope='Exact selected image; all45 points/23 sources/669 fresh samples. Same-run medians only; new upstream-compatible direct ABI. No release, full-language conformance or isolated causal attribution claim.',
        attempts=keep(attempt_file), reports=reports, points=45, sources=23, samples=sample_count,
        equalPointGeometricMeans={k:gm(r['ratios'][k] for r in rows) for k in keys},
        equalSourceGeometricMeans={k:gm(r['ratios'][k] for r in sources) for k in keys}, ranges=ranges,
        slowerThanBaseline=[r['id'] for r in rows if r['candidateOverBaseline'] > 1],
        slowerThanBaselineByOver10Percent=[r['id'] for r in rows if r['candidateOverBaseline'] > 1.1],
        slowerThanTypeScript=[r['id'] for r in rows if r['ratios']['candidate/typescript'] > 1],
        timingFlagPolicy='Descriptive only: absolute half drift >20% or maximum/minimum fresh-round time >1.2. No rows excluded. Lack of flags is not proof of JIT convergence or statistical significance.',
        rows=rows, sourceRows=sources, generatedModuleSizes=sizes, inputs=list(pins.values()), inputsUnchanged=True)
    a.out.mkdir(parents=True, exist_ok=False)
    save(a.out / 'report.json', output)
    lines = ['# Direct backend full45 comparison', '', 'All45 points,23 distinct sources and669 fresh samples passed. Direct/TS and direct/Phase51 below1 favor direct; Phase51/direct above1 favors direct.', '',
             '| Weighting | Phase51 / TS | Direct / TS | Phase51 / direct |', '|---|---:|---:|---:|']
    for label, key in [('Equal point','equalPointGeometricMeans'),('Equal source','equalSourceGeometricMeans')]:
        lines.append('| '+label+' | '+' | '.join(f'{output[key][k]:.6f}×' for k in keys)+' |')
    lines += ['', '| Point | TS µs | Phase51 µs | Direct µs | Direct / TS | Direct / Phase51 | Flags |', '|---|---:|---:|---:|---:|---:|---|']
    for row in rows:
        flags = ', '.join(role for role, f in row['timingFlags'].items() if f['halfDriftOver20Percent'] or f['roundSpreadOver20Percent']) or 'none'
        lines.append('| '+row['id']+' | '+' | '.join(f"{row['mediansMs'][r]*1000:.6f}" for r in ['typescript','baseline','candidate'])+f" | {row['ratios']['candidate/typescript']:.6f}× | {row['candidateOverBaseline']:.6f}× | {flags} |")
    lines += ['', output['timingFlagPolicy'], '', 'Regressions remain included. This report does not qualify an installed release or the extra legacy descriptor ABI.', '']
    (a.out / 'report.md').write_text('\n'.join(lines))
    (a.out / 'ratios.svg').write_text(chart(rows))
    print(json.dumps(dict(complete=True, points=45, samples=669, equalPoint=output['equalPointGeometricMeans'], equalSource=output['equalSourceGeometricMeans'])))


if __name__ == '__main__':
    main()
