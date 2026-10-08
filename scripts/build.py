#!/usr/bin/env python3
"""Build a static progress report from saved evidence; never read the compiler checkout."""
import argparse
from datetime import date
from html import escape
import json
import math
from pathlib import Path
import re
from statistics import geometric_mean
from string import Template
import subprocess
import sys
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'site'
RESEARCH = ('history', 'conformance', 'runtime', 'runtime-average', 'second-stage', 'compilation-average')
METRICS = {'execution': 'Program speed', 'second-stage': 'Second-stage compilation', 'compilation': 'First-stage compilation', 'conformance': 'Conformance', 'simplicity': 'Simplicity'}


def e(value):
    return escape(str(value), quote=True)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def url(value):
    parsed = urlparse(value)
    require(parsed.scheme == 'https' and bool(parsed.netloc), 'Expected an HTTPS source URL: ' + value)
    return e(value)


def link(value, title):
    return f'<a href="{url(value)}">{e(title)} ↗</a>'


def number(value, digits=3):
    if value is None:
        return '—'
    return f'{value:,.{digits}f}'.rstrip('0').rstrip('.') if digits else f'{value:,.0f}'


def validate(config, research):
    require(config['schema_version'] == 2, 'Unsupported schema_version')
    date.fromisoformat(config['metadata']['collected_at'])
    require(re.fullmatch('[0-9a-f]{40}', config['metadata']['checkpoint']), 'Invalid source checkpoint')
    require([c['id'] for c in config['cards']] == list(METRICS), 'Expected all five metric cards in report order')
    ids = set()
    for finding in config['findings']:
        require(re.fullmatch('[a-z][a-z0-9-]*', finding['id']), 'Invalid finding id')
        require(finding['id'] not in ids, 'Duplicate finding id')
        ids.add(finding['id'])
        require(bool(finding['metrics']) and set(finding['metrics']) <= set(METRICS), 'Unknown finding metric')
        require(bool(finding['sources']), 'Every finding needs sources')
    for card in config['cards']:
        require(card['finding'] in ids, 'Card links to an unknown finding')
        require(re.fullmatch('[a-z-]+', card['chart']), 'Invalid chart filename')
        require((SITE / 'charts' / (card['chart'] + '.svg')).is_file(), 'Missing chart: ' + card['chart'])
        for key in ('breakdown_chart', 'supplemental_chart'):
            if card.get(key):
                require((SITE / 'charts' / (card[key] + '.svg')).is_file(), 'Missing chart: ' + card[key])
    for point in research['conformance']['mainSeries'] + research['conformance']['broaderSeries']:
        require(point['exact'] + point['different'] == point['total'], 'Conformance denominator mismatch')
        require(math.isclose(point['exact'] / point['total'] * 100, point['exactPercent'], abs_tol=0.0001), 'Conformance percentage mismatch')
    for point in research['runtime']['pairedGains']:
        require(point['beforeMs'] > 0 and point['afterMs'] > 0, 'Runtime samples must be positive')
        require(math.isclose(point['beforeMs'] / point['afterMs'], point['speedup'], rel_tol=0.0001), 'Runtime speedup mismatch')
    for point in research['runtime']['latest']['points']:
        require(math.isclose(point['candidate']['medianMs'] / point['reference']['medianMs'], point['ratioToTypeScript'], rel_tol=0.001), 'Runtime reference ratio mismatch')
    runtime = research['runtime-average']
    points = runtime['latest']['points']
    point_ids = {p['id'] for p in points}
    require(len(point_ids) == len(points) == runtime['headline']['pointCount'], 'Runtime case count mismatch')
    ratios = []
    for point in points:
        ratio = point['candidate']['medianMs'] / point['reference']['medianMs']
        require(ratio > 0 and math.isclose(ratio, point['ratioToTypeScript'], rel_tol=1e-9), 'Invalid runtime ratio')
        ratios.append(ratio)
    require(math.isclose(geometric_mean(ratios), runtime['headline']['averageRatio'], rel_tol=1e-9), 'Runtime headline average mismatch')
    grouped_ids = []
    by_id = {p['id']: p['ratioToTypeScript'] for p in points}
    for group in runtime['latest']['sourceGroups']:
        grouped_ids.extend(group['pointIds'])
        require(len(group['pointIds']) == group['pointCount'], 'Program case count mismatch')
        require(math.isclose(geometric_mean(by_id[k] for k in group['pointIds']), group['ratioToTypeScript'], rel_tol=1e-9), 'Program average mismatch')
    require(len(grouped_ids) == len(set(grouped_ids)) and set(grouped_ids) == point_ids, 'Program breakdown omits or duplicates cases')
    require(len({p['suiteId'] for p in runtime['history']}) == 1, 'Runtime history mixes benchmark suites')
    require(all(p['pointCount'] == len(points) for p in runtime['history']), 'Runtime history changes case count')
    require(math.isclose(runtime['history'][-1]['averageRatio'], runtime['headline']['averageRatio'], rel_tol=1e-9), 'Latest runtime history differs from headline')
    for dataset in ('compilation-average', 'second-stage'):
        compilation = research[dataset]
        cohort = {p['id'] for p in compilation['cohort']}
        cohort_members = {}
        for checkpoint in compilation['history']:
            ids = {p['id'] for p in checkpoint['programs']}
            key = checkpoint.get('cohortKey', 'fixed-four-programs')
            require(len(ids) == len(checkpoint['programs']), 'Compilation history duplicates a program')
            require(ids == set(checkpoint.get('cohortIds', ids)), 'Compilation history cohort metadata mismatch')
            require(len(ids) == checkpoint.get('cohortSize', len(ids)), 'Compilation history cohort size mismatch')
            require(key not in cohort_members or cohort_members[key] == ids, 'Compilation history changes programs within a cohort')
            cohort_members[key] = ids
            require(all(p['bend_ms'] > 0 and p['typescript_ms'] > 0 for p in checkpoint['programs']), 'Compilation medians must be positive')
            ratios = [p['bend_ms'] / p['typescript_ms'] for p in checkpoint['programs']]
            require(math.isclose(geometric_mean(ratios), checkpoint['ratio'], rel_tol=1e-9), 'Compilation history average mismatch')
        require({p['id'] for p in compilation['programs']} == cohort, 'Latest compilation cohort mismatch')
        require(math.isclose(geometric_mean(p['bend_ms'] / p['typescript_ms'] for p in compilation['programs']), compilation['latest_average'], rel_tol=1e-9), 'Compilation headline average mismatch')
        require(math.isclose(compilation['history'][-1]['ratio'], compilation['latest_average'], rel_tol=1e-9), 'Latest compilation history differs from headline')
        including_load = [p['including_imports'] for p in compilation['programs']]
        require(all(math.isclose(p['bend_ms'] / p['typescript_ms'], p['ratio'], rel_tol=1e-9) for p in compilation['programs']), 'Compilation program ratio mismatch')
        require(all(p['bend_ms'] > 0 and p['typescript_ms'] > 0 for p in including_load), 'Loading-inclusive samples must be positive')
        require(all(math.isclose(p['bend_ms'] / p['typescript_ms'], p['ratio'], rel_tol=1e-9) for p in including_load), 'Loading-inclusive program ratio mismatch')
        require(math.isclose(geometric_mean(p['bend_ms'] / p['typescript_ms'] for p in including_load), compilation['including_imports_average'], rel_tol=1e-9), 'Loading-inclusive average mismatch')
        paired_change = 100 * (compilation['latest_average'] / compilation['same_run_baseline_average'] - 1)
        require(math.isclose(paired_change, compilation['same_run_change_percent'], abs_tol=1e-8), 'Compilation paired change mismatch')
    emission = research['second-stage']['selfEmissionHistory']
    require(len(emission) == 2 and all(p['complete'] and p['byte_equal'] and p['seconds'] > 0 for p in emission), 'Invalid clean self-emission comparison')
    require(len({p['method'] for p in emission}) == 1, 'Self-emission methods differ')
    for point in research['conformance'].get('independentSemanticSeries', []):
        require(point['pass'] + point['failed'] == point['total'], 'Independent semantic total mismatch')
    census = research['conformance']['javascriptCensus']
    require(census['goldenPasses'] + census['exempt'] + census['sharedFailure'] + census['deferred'] == census['eligibleFixtures'], 'JavaScript census denominator mismatch')
    require(census['primaryNode']['candidatePass'] + census['supplementalBunPasses'] == census['goldenPasses'], 'Mixed-runtime census double counts observations')
    checking = research['history']['compilerChecking']
    for point in checking['series']:
        require(point['bend_process_seconds'] > 0 and point['typescript_process_seconds'] > 0, 'Checking times must be positive')
        require(math.isclose(point['bend_process_seconds'] / point['typescript_process_seconds'], point['bend_to_typescript_process_ratio'], rel_tol=1e-9), 'Historical checking ratio mismatch')
        require(point['kind'] == 'ordinary_check_and_trust_no_emission', 'Historical checking boundary changed')
    for point in checking['selectedPairs']:
        reduction = 100 * (1 - point['bend_process_seconds'] / point['same_window_predecessor_seconds'])
        require(math.isclose(reduction, point['process_time_reduction_percent'], abs_tol=.02), 'Paired checking reduction mismatch')


def table(headers, rows, caption=None):
    head = ''.join(f'<th scope="col">{e(h)}</th>' for h in headers)
    body = ''.join('<tr>' + ''.join(f'<td>{value}</td>' for value in row) + '</tr>' for row in rows)
    caption = f'<caption>{e(caption)}</caption>' if caption else ''
    return f'<div class="table-scroll"><table>{caption}<thead><tr>{head}</tr></thead><tbody>{body}</tbody></table></div>'


def tables(research):
    h, c, r = (research[k] for k in ('history', 'conformance', 'runtime'))
    result = {}
    result['simplicity'] = table(['Checkpoint', 'Physical lines', 'Nonblank', 'Code lines', 'Modules', 'Source'], [
        [e(p['chartLabel']), number(p['physicalLines'], 0), number(p['nonblankLines'], 0), number(p.get('codeLines'), 0), e(p['modules']), link(p['sourceLink'], p['shortCommit'])]
        for p in h['simplicity']['series']
    ], 'Canonical Bend modules; equally spaced saved checkpoints, not elapsed time.')
    result['compilation'] = table(['Phase', 'Before (s)', 'After (s)', 'Less time', 'Source'], [
        [e(p['label']), number(p['same_window_predecessor_seconds']), number(p['bend_process_seconds']), number(p['process_time_reduction_percent'], 2) + '%', link(p['source_url'], p['commit'][:7])]
        for p in h['compilerChecking']['selectedPairs']
    ], 'Each row is an independent paired checking comparison on the same frozen input.')
    latest = h['latestCompilation']
    result['compilation'] += '<p>Separate Phase 36 ordinary compilation controls: request medians, three samples per role. Before/after ranges overlap in all four cases. ' + link(latest['sourceURL'], 'Full cost report') + '</p>'
    result['compilation'] += table(['Program', 'P35 (ms)', 'P36 (ms)', 'Change', 'TypeScript (ms)'], [
        [e(p['workload']), number(p['baseline_ms']), number(p['candidate_ms']), f'{p["candidate_change_percent"]:+.2f}%', number(p['typescript_ms'])]
        for p in latest['points']
    ], 'Checked-library request time. This is different from the historical full-source checking workload above.')
    census = c['javascriptCensus']
    result['conformance'] = '<h4>Current JavaScript census · selected B1 · Phase ' + e(census['phase']) + '</h4>' + table(['Outcome', 'Distinct fixtures'], [
        ['Golden passes · Node plus scoped Bun results', number(census['goldenPasses'], 0)],
        ['Unprintable-main exemptions', number(census['exempt'], 0)],
        ['Shared Process.run golden failure', number(census['sharedFailure'], 0)],
        ['Graphics environment deferral', number(census['deferred'], 0)],
        ['Total JavaScript-eligible fixtures', number(census['eligibleFixtures'], 0)],
    ], 'Each fixture is counted once. Exemptions, the shared failure and the deferred graphics case are not passes.')
    result['conformance'] += table(['Runtime evidence', 'Bend golden passes', 'TypeScript golden passes'], [
        ['Node alone', number(census['primaryNode']['candidatePass'], 0), number(census['primaryNode']['referencePass'], 0)],
        ['Additional paired Bun passes', number(census['supplementalBunPasses'], 0), number(census['supplementalBunPasses'], 0)],
        ['Distinct combined passes', number(census['goldenPasses'], 0), number(census['referenceGoldenPasses'], 0)],
    ], 'Bun evidence transfers through exact emitted-module and runtime identity; it is not a new final07 execution campaign. Bend passes the retained NaN fixture that TypeScript fails.')
    result['conformance'] += '<p>Observed TypeScript-pass / Bend-fail cases: <strong>' + number(census['referencePassingCandidateFailures'], 0) + '</strong>. ' + link(census['source'], 'Complete census and platform scope') + '</p>'
    result['conformance'] += '<h4>Independent semantic observations</h4>' + table(['Phase', 'Source-oracle passes', 'TypeScript passes', 'Source'], [
        [e(p['label']), f'{p["pass"]} / {p["total"]}', f'{p["referencePass"]} / {p["referenceTotal"]}', link(p['source'], 'Report')]
        for p in c.get('independentSemanticSeries', [])
    ], 'The source oracle defines the expected answer. TypeScript retains a known NaN-fixture mismatch; matching that result is not required.')
    result['conformance'] += '<h4>Historical frontend agreement</h4>' + table(['Phase', 'Target', 'Exact / total', 'Differences', 'Source'], [
        [e(p['label']), e(p['upstream'][:7]), f'{p["exact"]:,} / {p["total"]:,}', number(p['different'], 0), link(p['source'], p['commit'][:7])]
        for p in c['mainSeries']
    ], 'Main exact parse/check comparisons. Target changes introduce a different denominator.')
    result['conformance'] += table(['Phase', 'Broader exact / total', 'Source'], [
        [e(p['label']), f'{p["exact"]} / {p["total"]}', link(p['source'], p['commit'][:7])]
        for p in c['broaderSeries']
    ], 'Separate broader selection; partly overlaps the main suite.')
    current = c['current']
    result['conformance'] += '<p>The latest recorded frontend evidence is Phase ' + e(current.get('frontendLastFreshPhase', current['phase'])) + '. The separate broader selection retains its own last observation at Phase ' + e(c['broaderSeries'][-1]['phase']) + '. Their counts overlap and are not added together.</p>'
    result['conformance'] += '<h4>Installed B1 controls · Phase ' + e(current['phase']) + '</h4>' + table(['Scope', 'Result'], [
        ['Independent semantic observations', f'{current.get("semanticPass", 0)} / {current.get("semanticTotal", 0)}'],
        ['Numeric controls', f'{current.get("numericPass", 0)} / {current.get("numericTotal", 0)}'],
        ['Composition controls', f'{current.get("compositionPass", 0)} / {current.get("compositionTotal", 0)}'],
        ['Overapplication controls', f'{current.get("overapplicationPass", 0)} / {current.get("overapplicationTotal", 0)}'],
        ['Ordinary / relocated interfaces', f'{current["cliPass"]} / {current["cliTotal"]}'],
        ['Historical direct JavaScript census · P' + str(current.get('directBackendLastFreshPhase', current['phase'])), f'{current["directBackendExact"]} / {current["directBackendTotal"]} outcomes: 18 runtime passes, 4 expected rejections, 4 not applicable'],
        ['Maintained compatibility suites', e(current['maintainedSuites'])]
    ], 'Scopes overlap and are not summed into a total pass count.')
    reproduction = c['selfReproduction']
    result['conformance'] += '<h4>Separately qualified B2 · not installed</h4>' + table(['Scope', 'Result'], [
        ['Independent source semantics', f'{reproduction["semanticPass"]} / {reproduction["semanticTotal"]}'],
        ['Numeric / composition / overapplication', '34 / 34 · 18 / 18 · 2 / 2'],
        ['Fresh complete-source type check', 'Passed' + (' · ' + number(reproduction['freshCheck']['internalSeconds'], 3) + ' seconds internally' if reproduction['freshCheck'].get('internalSeconds') is not None else ' · no comparable timing published')],
        ['B2 → B3 reproduction', 'Byte-identical' + (' · ' + number(reproduction['imageBytes'], 0) + ' bytes' if reproduction.get('imageBytes') is not None else '')],
        ['Generated-program equality with B1', '23 source modules · 45 observed point modules'],
    ], 'B2 controls are measured separately. B1 interface and census results are not asserted for B2.')
    result['conformance'] += '<p>' + e(reproduction['freshCheck']['scope']) + ' ' + e(reproduction['proofScope']) + '</p>'
    backend = c['backendPilot']
    outcomes = backend['rawOutcomes']
    result['conformance'] += f'<p>Separate historical backend pilot (Phase {e(backend["phase"])}): {outcomes["pass"]} passes, {outcomes["notApplicable"]} not applicable, {outcomes["sharedFailures"]} shared failures. All {backend["exact"]} outcomes match the reference; they are not all execution passes.</p>'
    result['runtime'] = table(['Phase / program', 'Before (ms)', 'After (ms)', 'Speedup', 'Source'], [
        [e({30:'P29 → P30',31:'P30 → P31',32:'P31 → P32',35:'P32 → P35',36:'P35 → P36'}[p['phase']] + ' · ' + p['id']), number(p['beforeMs'], 6), number(p['afterMs'], 6), number(p['speedup'], 2) + '×', link(p['sourceUrl'], 'Report')]
        for p in r['pairedGains'] if p['phase'] in (30, 31, 32, 35, 36)
    ], 'Complete exported calls. Each row has its own timing window; compiler execution is excluded.')
    return result


def speed_tables(card, research):
    data = research[card['average_dataset']]
    is_runtime = card['id'] == 'execution'
    rows = []
    for p in data['history']:
        date_value = p['date'] if is_runtime else p['commit_date']
        source = p['sourceUrl'] if is_runtime else p['source_url']
        scope = p.get('notes', '') if is_runtime else p.get('note', '')
        count = p['pointCount'] if is_runtime else len(p['programs'])
        reference = p.get('typescript_commit', p.get('referenceCommit', '018751270e800bc222a93dad7f257083ee53a5f7'))
        boundary = 'Warmed program execution' if is_runtime else p.get('measurement_boundary_label', p.get('boundary', 'Checked-library request'))
        rows.append([link('https://github.com/rom1504/bend/commit/' + p['commit'], p.get('label', 'P' + str(p['phase'])) + ' · ' + p['commit'][:7]), e(date_value.replace('T', ' ').replace('Z', ' UTC')), number(p['ratio'], 3) + '×', str(count), e(reference[:7]), e(boundary), link(source, 'Report'), e(scope)])
    html = ''
    if card['id'] == 'compilation':
        checking = research['history']['compilerChecking']
        html += '<h4>Earlier compiler-source checking · release snapshots</h4>' + table(['Release / commit', 'Commit date', 'Bend (s)', 'TypeScript (s)', 'Bend / TS', 'Reference pin', 'Report'], [
            [link(p['commit_url'], p['label'] + ' · ' + p['commit'][:7]), e(p['commit_date'][:10]), number(p['bend_process_seconds']), number(p['typescript_process_seconds']), number(p['bend_to_typescript_process_ratio'], 3) + '×', e(p['pin'][:7]), link(p['source_url'], 'Report')]
            for p in checking['series']
        ], 'Process time for compiler-source checking, without emission. Inputs evolve between releases; the TypeScript target changes at P23. These are individual observations, not a multi-program average.')
        html += '<h4>Measured improvements on identical inputs</h4>' + table(['Release', 'Predecessor (s)', 'Candidate (s)', 'Less time', 'Report'], [
            [e(p['label']), number(p['same_window_predecessor_seconds']), number(p['bend_process_seconds']), number(p['process_time_reduction_percent'], 2) + '%', link(p['source_url'], 'Report')]
            for p in checking['selectedPairs']
        ], 'Each before/after pair uses the same frozen source in its own measurement window. Reductions are not compounded across windows.')
    html += '<h4>Average by recorded observation</h4>' + table(['Compiler release / commit' if is_runtime else 'Observation / report commit', 'Release date' if is_runtime else 'Publication date', 'Average / TS', 'Cases' if is_runtime else 'Programs', 'TS reference', 'Timing window', 'Source', 'Measurement note'], rows)
    if is_runtime:
        html += '<h4>Latest program breakdown</h4>' + table(['Program / source', 'Cases', 'Average / TS'], [
            [e(p['label']), str(p['pointCount']), number(p['ratioToTypeScript'], 3) + '×']
            for p in sorted(data['latest']['sourceGroups'], key=lambda p: p['ratioToTypeScript'])
        ], 'Programs are grouped by source file. The headline weights cases equally, not programs equally.')
        html += f'<h4>All {len(data["latest"]["points"])} individual benchmark cases</h4>' + table(['Case', 'Bend (ms)', 'TypeScript (ms)', 'Bend / TS', 'Source'], [
            [e(p['id']), number(p['candidate']['medianMs'], 6), number(p['reference']['medianMs'], 6), number(p['ratioToTypeScript'], 3) + '×', link(p['sourceUrl'], 'Report')]
            for p in data['latest']['points']
        ], 'Warmed generated-JavaScript execution medians per complete call. Compilation, import and first call are separate.')
        average = data['headline']['averageRatio']
        source = data['headline']['sourceUrl']
    else:
        html += '<h4>Latest compilation breakdown</h4>' + table(['Program', 'Bend compile (ms)', 'TypeScript compile (ms)', 'Compile / TS', 'With loading / TS', 'Source'], [
            [e(p['name']), number(p['bend_ms']), number(p['typescript_ms']), number(p['ratio'], 3) + '×', number(p['including_imports']['ratio'], 3) + '×', link(p['source_url'], 'Program')]
            for p in data['programs']
        ], 'Compilation checks and emits a library in a prepared fresh process; loading is outside that clock. The separate final column adds module import and API loading. Each role/program uses the median of three fresh-process observations.')
        html += '<h4>Including module import and API loading</h4>' + table(['Program', 'Bend total (ms)', 'TypeScript total (ms)', 'Bend / TS'], [
            [e(p['name']), number(p['including_imports']['bend_ms']), number(p['including_imports']['typescript_ms']), number(p['including_imports']['ratio'], 3) + '×']
            for p in data['programs']
        ], 'A separate measured clock. Inputs and disk artifacts are prepared before the process; process launch and preparation are excluded.')
        if data.get('same_run_change_percent') is not None:
            change = data['same_run_change_percent']
            html += '<p class="source-note">Latest same-window comparison: ' + number(data['same_run_baseline_average'], 3) + '× → ' + number(data['latest_average'], 3) + '× TypeScript time (' + number(abs(change), 2) + ('% more time' if change >= 0 else '% less time') + '). Historical checkpoints use separately paired TypeScript runs and may use different program sets; compare only the stated scopes.</p>'
        if data.get('current_default_comparison', {}).get('status') == 'not_measured':
            html += '<p class="source-note">Phase ' + e(data['installed_phase']) + ' uses direct JavaScript by default. Its compilation throughput has not been measured in a comparable published benchmark. The latest measured sample above is from the legacy JavaScript backend at Phase ' + e(data['latest_phase']) + '.</p>'
        average = data['latest_average']
        source = data['history'][-1]['source_url']
        if data.get('selfEmissionHistory'):
            html += '<h4>B2 compiling its own source · clean emission</h4>' + table(['Compiler', 'Seconds', 'Method', 'Source', 'Scope'], [
                [e(p['label']), number(p['seconds'], 6), e(p['method']), link(p['source_url'], 'Report'), e(p['note'])]
                for p in data['selfEmissionHistory']
            ], 'Each compiler emits its own changed source without a fresh source type check. Single observations under the same method; the earlier baseline is retained, not rerun consecutively.')
            html += '<h4>Separate self-hosting qualification history</h4>' + table(['Phase', 'Reproduction (s)', 'Fresh type check (s)', 'Source', 'Scope'], [
                ['P' + str(p['phase']), number(p.get('seconds'), 3) if p['complete'] else 'Stopped at ' + number(p['deadline_seconds'], 0) + ' s', number(p.get('check_seconds'), 3), link(p['source_url'], 'Report'), e(p['note'])]
                for p in data['qualificationHistory']
            ], 'Qualification and clean performance use different clocks. A timeout does not supply an exact speedup.')
    return average, html, source


def render_speed_card(card, research):
    average, measurements, source = speed_tables(card, research)
    metric, chart, breakdown = e(card['id']), e(card['chart']), e(card['breakdown_chart'])
    historical_context = ''
    supplemental = ''
    secondary = ''
    data = research[card['average_dataset']]
    if data.get('including_imports_average') is not None:
        secondary = f'<p class="secondary-average"><strong>{data["including_imports_average"]:.2f}×</strong><span>TypeScript time with imports and API loading included</span></p>'
    if card.get('supplemental_chart'):
        extra = e(card['supplemental_chart'])
        stats = ''.join(f'<div><strong>{e(s["value"])}</strong><span>{e(s["label"])}</span></div>' for s in card['supplemental_stats'])
        supplemental = f'''<section class="self-emission" aria-labelledby="self-emission-title"><div class="self-emission-copy"><h4 id="self-emission-title">{e(card['supplemental_title'])}</h4><p>{e(card['supplemental_caption'])}</p><div class="stage-stats">{stats}</div><p class="self-emission-downloads"><a href="./charts/{extra}.svg" download>SVG ↓</a> · <a href="./charts/{extra}.png" download>PNG ↓</a></p></div><figure><div class="chart-frame"><img src="./charts/{extra}.svg" alt="{e(card['supplemental_alt'])}" width="900" height="490" loading="lazy"></div></figure></section>'''
    if card['id'] == 'compilation':
        checking = research['history']['compilerChecking']
        gains = []
        for phase, title in ((9, 'Reuse the binder bound'), (16, 'Keep literals compact')):
            point = next(p for p in checking['selectedPairs'] if p['phase'] == phase)
            gains.append(f'<div class="history-gain"><strong>−{point["process_time_reduction_percent"]:.1f}%</strong><div><b>P{phase} · {e(title)}</b><p>{point["same_window_predecessor_seconds"]:.2f} → {point["bend_process_seconds"]:.2f} seconds</p>{link(point["source_url"], "Paired release measurement")}</div></div>')
        historical_context = '<aside class="history-findings"><h4>What drove the early reductions</h4><p>Two releases measured large gains on identical before/after inputs.</p>' + ''.join(gains) + '<p>Compiler-source checking process time; no code emission. Each pair uses its own source and timing window.</p></aside>'
    return f'''<article class="chart-card speed-card" id="{metric}" aria-labelledby="title-{metric}">
<div class="chart-card-top"><div class="card-category"><h3 id="title-{metric}"><span class="metric-dot {metric}-color"></span>{e(card['number'])} / {e(card['title'])}</h3><span>{e(card['direction'])}</span></div>
<div class="speed-head"><div><div class="card-headline"><strong>{average:.2f}×</strong><span>{e(card['unit'])}</span></div>{secondary}<p class="speed-cohort">{e(card['cohort'])}</p></div><p class="card-summary">{e(card['summary'])}</p></div></div>
<div class="speed-charts"><div class="speed-chart"><h4>{e(card['history_label'])}</h4><p>{e(card.get('history_intro', 'TypeScript = 1×. The benchmark set stays fixed.'))}</p><figure><div class="chart-frame"><img src="./charts/{chart}.svg" alt="{e(card['alt'])}" width="900" height="{int(card.get('history_height', 590))}" loading="lazy"></div><figcaption class="card-caption">{e(card['caption'])}</figcaption></figure><div class="average-method"><strong>{e(card.get('method_label', 'How this average is calculated'))}</strong><p>{e(card['method'])}</p></div></div>
<div class="speed-chart"><h4>{e(card['breakdown_label'])}</h4><p>The same TypeScript baseline, one program at a time.</p><figure><div class="chart-frame"><img src="./charts/{breakdown}.svg" alt="{e(card['breakdown_alt'])}" width="900" height="{int(card.get('breakdown_height', 600))}" loading="lazy"></div><figcaption class="card-caption">{e(card['breakdown_caption'])}</figcaption></figure>{historical_context}</div></div>
{supplemental}<p class="card-takeaway"><span aria-hidden="true">↳</span><span>{e(card['takeaway'])}</span></p><div class="card-bottom">{link(source, 'Read the measured report')}<div class="speed-downloads"><span>History: <a href="./charts/{chart}.svg" download>SVG ↓</a> · <a href="./charts/{chart}.png" download>PNG ↓</a></span><span>Programs: <a href="./charts/{breakdown}.svg" download>SVG ↓</a> · <a href="./charts/{breakdown}.png" download>PNG ↓</a></span></div></div>
<details class="data-details"><summary>All measurements, commit dates &amp; sources</summary>{measurements}</details></article>'''


def render_cards(config, research):
    content = []
    measurements = tables(research)
    for card in config['cards']:
        if card.get('average_dataset'):
            content.append(render_speed_card(card, research))
            continue
        chart, metric = e(card['chart']), e(card['id'])
        content.append(f'''<article class="chart-card" id="{metric}" aria-labelledby="title-{metric}">
<div class="chart-card-top"><div class="card-category"><h3 id="title-{metric}"><span class="metric-dot {metric}-color"></span>{e(card['number'])} / {e(card['title'])}</h3><span>{e(card['direction'])}</span></div>
<div class="card-headline"><strong>{e(card['value'])}</strong><span>{e(card['unit'])}</span></div><p class="card-summary">{e(card['summary'])}</p></div>
<figure style="margin:0"><div class="chart-frame"><img src="./charts/{chart}.svg" alt="{e(card['alt'])}" width="900" height="{int(card.get('chart_height', 560))}" loading="lazy"></div><figcaption class="card-caption">{e(card['caption'])}</figcaption></figure>
<p class="card-takeaway"><span aria-hidden="true">↳</span><span>{e(card['takeaway'])}</span></p>
<div class="card-bottom"><a href="#finding-{e(card['finding'])}" data-show-metric="{metric}">Explore the finding ↗</a><span><a href="./charts/{chart}.svg" download>SVG ↓</a> · <a href="./charts/{chart}.png" download>PNG ↓</a></span></div>
<details class="data-details"><summary>Measurements &amp; sources</summary>{measurements[card['table']]}</details></article>''')
    return '\n'.join(content)


def render_findings(config):
    sections = []
    for i, item in enumerate(config['findings'], 1):
        tags = ''.join(f'<span class="finding-tag">{e(METRICS[m])}</span>' for m in item['metrics'])
        paragraphs = ''.join(f'<p>{e(p)}</p>' for p in item['paragraphs'])
        flow = '<span class="flow-arrow" aria-hidden="true">→</span>'.join(f'<span class="flow-step">{e(step)}</span>' for step in item['flow'])
        stats = ''.join(f'<div class="impact-stat"><strong>{e(s["value"])}</strong><span>{e(s["label"])}</span></div>' for s in item['stats'])
        sources = ''.join(link(source['url'], source['title']) for source in item['sources'])
        sections.append(f'''<article class="finding" id="finding-{e(item['id'])}" data-metrics="{e(' '.join(item['metrics']))}" aria-labelledby="finding-title-{e(item['id'])}">
<div class="finding-copy"><div class="finding-kicker"><span>{i:02d} / {e(item['phase'])}</span><div class="finding-tags">{tags}</div></div><h3 id="finding-title-{e(item['id'])}">{e(item['title'])}</h3>{paragraphs}<div class="finding-sources">{sources}</div></div>
<div class="finding-visual"><span class="mini-label">THE MECHANISM → THE IMPACT</span><div class="flow">{flow}</div><div class="impact-grid">{stats}</div><p class="visual-note">{e(item['note'])}</p></div></article>''')
    return '\n'.join(sections)


def render(config, research):
    meta = config['metadata']
    values = {key: e(value) for key, value in meta.items()}
    for key in ('repository_url', 'pr_url', 'issue_url', 'checkpoint_url', 'upstream_url', 'runtime_source'):
        values[key] = url(meta[key])
    values['collected_iso'] = e(meta['collected_at'])
    values['collected_date'] = date.fromisoformat(meta['collected_at']).strftime('%d %b %Y')
    values['chart_cards'] = render_cards(config, research)
    values['findings'] = render_findings(config)
    values['sources'] = ''.join(link(s['url'], s['title']) for s in config['sources'])
    return Template((ROOT / 'templates/index.html').read_text(encoding='utf-8')).substitute(values)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Validate data, chart hashes and generated pages without writing')
    args = parser.parse_args()
    try:
        subprocess.run([sys.executable, str(ROOT / 'scripts/charts.py'), '--check'], check=True)
        config = json.loads((ROOT / 'progress.json').read_text(encoding='utf-8'))
        research = {name: json.loads((ROOT / (name + '-research.json')).read_text(encoding='utf-8')) for name in RESEARCH}
        validate(config, research)
        outputs = {
            SITE / 'index.html': render(config, research),
            SITE / 'progress.json': json.dumps({'site': config, 'research': research}, ensure_ascii=False, indent=2) + '\n',
        }
        stale = []
        for path, content in outputs.items():
            encoded = content.encode('utf-8')
            if args.check:
                if not path.is_file() or path.read_bytes() != encoded:
                    stale.append(str(path.relative_to(ROOT)))
            else:
                path.write_bytes(encoded)
        require(not stale, 'Generated files are stale: ' + ', '.join(stale) + '. Run python3 scripts/build.py')
    except (OSError, ValueError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        print(f'Build failed: {error}', file=sys.stderr)
        return 1
    print('Evidence, charts and generated pages verified.' if args.check else 'Built site/index.html and the complete site/progress.json dataset.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
