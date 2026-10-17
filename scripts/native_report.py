"""Render the native report alongside the preserved JavaScript evidence."""
from html import escape
from statistics import geometric_mean
import math


def e(value):
    return escape(str(value), quote=True)


def link(href, label='Source report'):
    if not href.startswith('https://'):
        raise ValueError('Source links must use HTTPS')
    return f'<a href="{e(href)}">{e(label)} ↗</a>'


def table(headers, rows, caption=''):
    return '<div class="table-scroll"><table><caption>' + e(caption) + '</caption><thead><tr>' + ''.join('<th scope="col">'+e(h)+'</th>' for h in headers) + '</tr></thead><tbody>' + ''.join('<tr>'+''.join('<td>'+str(c)+'</td>' for c in row)+'</tr>' for row in rows) + '</tbody></table></div>'


def figure(name, alt, caption, height=650):
    return f'<figure><div class="chart-frame"><img src="./charts/{name}.svg" alt="{e(alt)}" width="900" height="{height}" loading="lazy"></div><figcaption class="card-caption">{e(caption)}</figcaption></figure>'


def source_url(research, path):
    return 'https://github.com/rom1504/bend/blob/'+research['native']['sourceCommit']+'/'+path


def validate(research):
    native = research['native']
    latest = native['execution']['latest']
    points = latest['points']
    if len(points) != latest['pointCount'] or len({p['id'] for p in points}) != len(points):
        raise ValueError('Native runtime point counts must match')
    if not math.isclose(geometric_mean(p['ratio'] for p in points), latest['averageRatio'], rel_tol=2e-5):
        raise ValueError('Native runtime geometric average does not match its points')
    for key in ('compilation','secondStage'):
        current = native[key]['latest']
        for clock in ('request','process'):
            if not math.isclose(geometric_mean(p[clock+'Ratio'] for p in current['programs']), current[clock+'Ratio'], rel_tol=2e-5):
                raise ValueError(f'Native {key} {clock} mean does not match its programs')
    for point in points:
        if point['candidateMedianMs'] <= 0 or point['referenceMedianMs'] <= 0:
            raise ValueError('Only positive-work native points belong in the runtime average')
        if not math.isclose(point['candidateMedianMs']/point['referenceMedianMs'], point['ratio'], rel_tol=2e-5):
            raise ValueError('Native point ratio differs from its paired medians')


    indexed={p['id']:p['ratio'] for p in points}
    grouped=[]
    for group in latest['groups']:
        grouped.extend(group['pointIds'])
        if len(group['pointIds']) != group['pointCount'] or not math.isclose(geometric_mean(indexed[k] for k in group['pointIds']),group['ratio'],rel_tol=1e-9):
            raise ValueError('Native source grouping differs from its case ratios')
    if len(set(grouped)) != len(grouped) or set(grouped) != set(indexed):
        raise ValueError('Native source grouping omits or duplicates points')
    for key in ('compilation-average','second-stage'):
        c=research[key]['c_target']
        if not math.isclose(geometric_mean(p['ratio'] for p in c['programs']),c['requestRatio'],rel_tol=1e-9):
            raise ValueError('JS-hosted C-output average mismatch')
    for key in ('compilation','secondStage'):
        for p in native[key]['latest']['programs']:
            for clock in ('Request','Process'):
                ratio=p['candidate'+clock+'Ms']/p['baseline'+clock+'Ms']
                if not math.isclose(ratio,p[clock.lower()+'Ratio'],rel_tol=1e-9):
                    raise ValueError('Native compiler ratio differs from its paired medians')
    comparison = native['upstreamCompilation']
    if comparison['clock']['id'] != 'compiler-child-process-wall' or comparison['headlineWeighting'] != 'equal original source':
        raise ValueError('Native upstream headlines require process time and equal-original-source weighting')
    total_requests = 0
    for campaign_key, expected_points, expected_sources, expected_rounds in (('broad', 45, 23, 2), ('screen', 6, 6, 4)):
        campaign = comparison[campaign_key]
        if (campaign['pointCount'], campaign['sourceCount'], campaign['rounds']) != (expected_points, expected_sources, expected_rounds):
            raise ValueError('Native upstream campaign scope changed')
        expected_requests = expected_points * expected_rounds * 3 * 2
        if campaign['timedRequests'] != expected_requests:
            raise ValueError('Native upstream timed-request count mismatch')
        total_requests += campaign['timedRequests']
        cohort = None
        for mode in ('prepared', 'live'):
            for stage in ('b1', 'b2'):
                data = campaign['modes'][mode][stage]
                point_map = {p['id']: p for p in data['points']}
                if len(point_map) != len(data['points']) or len(point_map) != expected_points:
                    raise ValueError('Native upstream input points must be unique and complete')
                if cohort is not None and set(point_map) != cohort:
                    raise ValueError('Native upstream modes and stages must use the same input points')
                cohort = set(point_map)
                for p in data['points']:
                    if p['candidateMedianMs'] <= 0 or p['referenceMedianMs'] <= 0:
                        raise ValueError('Native upstream compiler timings must be positive')
                    if not math.isclose(p['candidateMedianMs'] / p['referenceMedianMs'], p['ratio'], rel_tol=1e-9):
                        raise ValueError('Native upstream ratio differs from its paired process medians')
                    if p['samples'] != expected_rounds or p['referenceSamples'] != expected_rounds:
                        raise ValueError('Native upstream point sample count mismatch')
                    for role in ('candidate', 'reference'):
                        low, high = p[role + 'RangeMs']
                        if not 0 < low <= p[role + 'MedianMs'] <= high:
                            raise ValueError('Native upstream median lies outside its observed range')
                groups = data['groups']
                if len(groups) != expected_sources or len({g['id'] for g in groups}) != expected_sources:
                    raise ValueError('Native upstream original-program count mismatch')
                grouped_ids = []
                for group in groups:
                    group_ids = group['pointIds']
                    grouped_ids.extend(group_ids)
                    if len(group_ids) != group['pointCount'] or any(point_map[k]['sourceId'] != group['id'] for k in group_ids):
                        raise ValueError('Native upstream source group contains incorrect inputs')
                    if not math.isclose(geometric_mean(point_map[k]['ratio'] for k in group_ids), group['ratio'], rel_tol=1e-9):
                        raise ValueError('Native upstream source-group average mismatch')
                if len(grouped_ids) != len(set(grouped_ids)) or set(grouped_ids) != cohort:
                    raise ValueError('Native upstream source groups omit or duplicate inputs')
                if not math.isclose(geometric_mean(g['ratio'] for g in groups), data['averageRatio'], rel_tol=1e-9):
                    raise ValueError('Native upstream equal-original-source headline mismatch')
                if not math.isclose(geometric_mean(p['ratio'] for p in data['points']), data['equalPointRatio'], rel_tol=1e-9):
                    raise ValueError('Native upstream equal-point average mismatch')
                if sum(p['ratio'] < 1 for p in data['points']) != data['fasterPointCount'] or sum(p['ratio'] > 1 for p in data['points']) != data['slowerPointCount']:
                    raise ValueError('Native upstream faster/slower point counts mismatch')
    for mode, expected_rounds in (('prepared', 2), ('live', 1)):
        data = comparison['fullSelf'][mode]
        if data['rounds'] != expected_rounds or data['timedRequests'] != expected_rounds * 3:
            raise ValueError('Native full-source campaign count mismatch')
        total_requests += data['timedRequests']
        reference = data['roles']['upstream']['medianMs']
        for role in ('b1', 'b2', 'upstream'):
            p = data['roles'][role]
            low, high = p['rangeMs']
            if p['samples'] != expected_rounds or not 0 < low <= p['medianMs'] <= high:
                raise ValueError('Native full-source observation range or sample count mismatch')
            if not math.isclose(p['medianMs'] / reference, p['ratio'], rel_tol=1e-9):
                raise ValueError('Native full-source upstream ratio mismatch')
    if total_requests != 693 or comparison['broad']['referenceAcquisitions'] != 45:
        raise ValueError('Native upstream evidence campaign totals mismatch')

    findings=research['recent-findings']['findings']
    if len({f['id'] for f in findings}) != len(findings) or any(not f['sources'] for f in findings):
        raise ValueError('Recent findings require unique IDs and evidence links')


def runtime_table(native):
    latest = native['execution']['latest']
    content = table(['Program / input','Bend C (ms)','Upstream C (ms)','Time ratio','Evidence'], [
        [e(p['label']),f"{p['candidateMedianMs']:.6f}",f"{p['referenceMedianMs']:.6f}",f"{p['ratio']:.4f}×",link(p['sourceUrl'])] for p in latest['points']
    ], 'Normalized per-call batch time, including result validation and loop overhead. 44 positive-work input points; the optimized-away control contributes no ratio.')
    content += table(['Checkpoint','Time / upstream C','Cohort','Evidence status','Source'], [
        [e(p['label']),f"{p['ratio']:.6f}×",e(p['cohortKey']),e(p.get('measurementStatus','')),link(p['sourceUrl'])] for p in native['execution']['history']
    ], 'Different cohorts and reused measurements remain explicitly identified; history is not a series of paired speedups.')
    return content


def compiler_table(data):
    rows=[]
    for p in data['latest']['programs']:
        rows.append([e(p['label']),f"{p['baselineRequestMs']:.2f}",f"{p['candidateRequestMs']:.2f}",f"{p['requestRatio']:.4f}×",f"{p['processRatio']:.4f}×",link(p['sourceUrl'])])
    return table(['Source','Phase 98 request (ms)','Current request (ms)','Request ratio','Process ratio','Evidence'],rows,'Same six sources, four balanced rounds. Ratios compare the current compiler with Phase 98, not with the upstream compiler.')


def self_table(native):
    return table(['Phase','Stage','Paired baseline (s)','Self-emission (s)','Scope','Evidence'],[
        ['P'+str(p['phase']),e(p['stage']),f"{p['baselineSeconds']:.3f}" if p.get('baselineSeconds') is not None else '—',f"{p['requestSeconds']:.3f}",e(p.get('note','')),link(p['sourceUrl'])] for p in native['fullSelfCompilation']
    ], 'Full compiler source emission is a separate workload. Qualification observations do not establish a repeated speed trend; Clang construction is excluded.')


def upstream_compiler_table(comparison, stage):
    broad = comparison['broad']
    content = '<h4>Current upstream comparison · one row per original program</h4>'
    groups = {mode: {p['id']: p for p in broad['modes'][mode][stage]['groups']} for mode in ('prepared', 'live')}
    content += table(['Original program', 'Input points', 'Prepared / upstream', 'Live Base / upstream', 'Evidence'], [
        [e(p['label']), str(p['pointCount']), f"{p['ratio']:.4f}×", f"{groups['live'][p['id']]['ratio']:.4f}×", link(p['sourceUrl'])]
        for p in broad['modes']['prepared'][stage]['groups']
    ], 'Geometric average within each original program, then equal weight across 23 original programs for each headline. All 45 input points count for compilation, including the zero-work execution control.')
    for mode, label in (('prepared', 'Prepared Base'), ('live', 'Live Base')):
        data = broad['modes'][mode][stage]
        content += '<h4>' + label + ' · all 45 input points</h4>'
        content += table(['Input point', 'Native process (ms)', 'Upstream process (ms)', 'Time / upstream', 'Evidence'], [
            [e(p['label']), f"{p['candidateMedianMs']:.3f}", f"{p['referenceMedianMs']:.3f}", f"{p['ratio']:.4f}×", link(p['sourceUrl'])]
            for p in data['points']
        ], f"Two fresh processes per role and point. Equal-point average: {data['equalPointRatio']:.6f}×. This differs from the equal-original-program headline.")
    content += '<h4>Complete compiler source · separate workload</h4>'
    rows = []
    for mode, label in (('prepared', 'Prepared Base'), ('live', 'Live Base')):
        data = comparison['fullSelf'][mode]
        for role in ('upstream', stage):
            p = data['roles'][role]
            rows.append([label, 'Upstream TS/Bun' if role == 'upstream' else 'Native ' + role.upper(), f"{p['medianMs']/1000:.3f}", f"{p['ratio']:.4f}×", str(data['rounds'])])
    content += table(['Mode', 'Compiler', 'Process time (s)', 'Time / upstream', 'Observations'], rows,
        'Every role compiles the same complete 1.79 MB compiler source to C. Prepared medians use two observations; live controls use one. Native stages emit the same 30,373,059-byte C output. Clang construction is excluded.')
    content += '<h4>Earlier native campaigns · original boundaries preserved</h4>'
    return content


def render_speed(card, research, javascript):
    metric = card['id']
    native = research['native']
    runtime = metric == 'execution'
    title = {'execution': 'Compiled program speed', 'second-stage': 'Second stage compiler compilation speed', 'compilation': 'First stage compiler compilation speed'}[metric]
    key = {'execution': 'execution', 'second-stage': 'secondStage', 'compilation': 'compilation'}[metric]
    chart = {'execution': 'native-runtime', 'second-stage': 'native-second-stage', 'compilation': 'native-compilation'}[metric]
    data = native[key]
    latest = data['latest']
    js_average, js_measurements, js_source = javascript
    js_data = research[card['average_dataset']]
    js_chart = card['chart']
    js_programs = card['breakdown_chart']
    self_callout = ''
    native_extra_history = ''
    js_extra_history = ''

    if runtime:
        native_ratio = latest['averageRatio']
        native_score_label = 'upstream C execution time'
        native_context = f"44 timed inputs · 23 original programs · {100*(native_ratio-1):.1f}% slower than upstream."
        native_secondary = ''
        native_clock = 'Warmed native execution; compilation and process startup excluded.'
        native_note = 'Latest broad timing: Phase 102 candidate04. The current compiler core is unchanged.'
        js_score_label = 'upstream JavaScript execution time'
        js_context = '45 timed inputs · 23 original programs · retained timing.'
        js_secondary = ''
        js_clock = 'Warmed JavaScript execution; compilation, imports and first call excluded.'
        js_note = 'Last fresh timing: Phase 66. Phase 91 preserves it through emitted-output identity checks.'
        native_history_name = chart + '-history'
        native_history_caption = 'Native C history keeps the earlier C12 cohort separate from the current 44 positive-work inputs. Reused results are labeled; checkpoints are not controlled before/after pairs.'
        native_breakdown_caption = 'Each bar geometrically averages one program’s timed inputs. The headline gives all 44 timed inputs equal weight; equal-source weighting is 1.065×. The zero-work control has no execution-time ratio.'
        native_method = 'For each input, divide the median Bend-generated C execution time by the paired upstream-generated C time. Take the geometric mean across 44 positive-work inputs. Three alternating rounds per comparator; all 45 catalog points pass semantic controls.'
        native_program_height = 1100
        native_measurements = runtime_table(native)
        native_source = source_url(research, 'implementation/phase102/default-promotion.md')
        takeaway = 'Both tracks compare programs compiled from the same Bend source. Native and JavaScript use separate output targets, cohorts and timing protocols; their histories remain separate.'
    else:
        stage = 'b2' if metric == 'second-stage' else 'b1'
        comparison = native['upstreamCompilation']
        prepared = comparison['broad']['modes']['prepared'][stage]
        live = comparison['broad']['modes']['live'][stage]
        native_ratio = prepared['averageRatio']
        native_score_label = 'upstream time · prepared standard library'
        native_context = '23 original programs · 45 input points · fresh compiler processes.'
        native_secondary = f'<div class="summary-secondary"><strong>{live["averageRatio"]:.3f}×</strong><span>upstream time · standard library checked from source</span></div>'
        native_clock = 'Complete compiler-process time to emit C; includes startup and preparation. Clang excluded.'
        native_note = 'Prepared standard library (Base): native reuses a checked artifact; upstream checks Base from source. In live mode, both check Base from source. Creating the reusable artifact is an excluded offline setup cost.'
        js_score_label = 'upstream time · compilation request'
        js_context = '23 programs · JavaScript host and output · Phase 91.'
        js_secondary = f'<div class="summary-secondary"><strong>{js_data["including_imports_average"]:.3f}×</strong><span>upstream time · with imports and API loading</span></div>'
        js_clock = 'First check-and-emit request after loading; process startup and cache preparation excluded.'
        js_note = 'Both JavaScript compilers use prepared standard-library caches. This request clock differs from the native complete-process clock.'
        native_history_name = chart + '-upstream'
        native_history_caption = 'Fresh Phase 105 upstream comparisons: prepared and live Base across 23 original programs, plus the separate complete-compiler workload. All use compiler-process time; these are three scopes, not consecutive releases.'
        native_extra_history = '<h5>Earlier measured improvements</h5>' + figure(chart + '-history', 'Earlier native compiler improvements within independently paired campaigns', 'Earlier optimization gains remain on the graph, with each campaign’s own baseline and timing boundary. They cannot be multiplied into the current upstream comparison.')
        native_breakdown_caption = 'Prepared and live Base stay separate for every original program. Each bar averages that program’s input points; every original program has equal headline weight. Below 1× is faster than upstream.'
        native_method = 'Use the geometric mean of input-level native / upstream process-time ratios within each original program, then the geometric mean across 23 programs. Two fresh observations per role, mode and point. Native and upstream have different internal request clocks, so only the shared child-process clock supplies these ratios.'
        native_program_height = 1372
        native_measurements = upstream_compiler_table(comparison, stage) + compiler_table(data) + self_table(native)
        native_source = comparison['sourceUrl']
        full = comparison['fullSelf']['prepared']
        measured = full['roles'][stage]
        reference = full['roles']['upstream']
        self_callout = f'''<section class="full-self-callout" aria-labelledby="self-source-{metric}"><div><h4 id="self-source-{metric}">Native {stage.upper()} compiling the complete compiler source</h4><p>The same 1.79 MB Bend source, kept separate from the ordinary-program average.</p></div><div class="full-self-value"><strong>{measured['ratio']:.3f}×</strong><span>upstream time · prepared Base</span></div><p class="full-self-times"><strong>{measured['medianMs']/1000:.3f} s</strong> native · <strong>{reference['medianMs']/1000:.3f} s</strong> upstream</p><p class="visual-note">Two process-time observations per compiler. Emits C; the subsequent Clang build is excluded.</p></section>'''
        takeaway = 'Prepared Base makes ordinary native compilation faster than upstream on this corpus. Live Base and the complete compiler source remain slower. These are distinct workloads, so there is no single combined speed score.'
        if card.get('supplemental_chart'):
            js_extra_history = '<h5>Compiling the compiler itself · historical JavaScript work</h5>' + figure(card['supplemental_chart'], card['supplemental_alt'], card['supplemental_caption'], int(card.get('supplemental_height', 490)))

    native_summary = f'''<section class="track-summary native-summary" aria-labelledby="native-summary-{metric}"><h4 class="track-label" id="native-summary-{metric}">Native{' · ' + stage.upper() if not runtime else ' output'}</h4><div class="summary-score"><strong>{native_ratio:.3f}×</strong><span>{e(native_score_label)}</span></div>{native_secondary}<p class="summary-context">{e(native_context)}</p><p class="summary-clock">{e(native_clock)}</p><p class="visual-note">{e(native_note)}</p></section>'''
    js_summary = f'''<section class="track-summary javascript-summary" aria-labelledby="js-summary-{metric}"><h4 class="track-label" id="js-summary-{metric}">JavaScript{' · ' + stage.upper() if not runtime else ' output'}</h4><div class="summary-score"><strong>{js_average:.3f}×</strong><span>{e(js_score_label)}</span></div>{js_secondary}<p class="summary-context">{e(js_context)}</p><p class="summary-clock">{e(js_clock)}</p><p class="visual-note">{e(js_note)}</p></section>'''
    native_history = figure(native_history_name, title + ' native upstream comparisons and history', native_history_caption, 650 if runtime else 640)
    js_history = figure(js_chart, card['alt'], card['caption'], int(card.get('history_height', 590)))
    native_breakdown = figure(chart + '-programs', title + ' native program breakdown against upstream', native_breakdown_caption, native_program_height)
    js_breakdown = figure(js_programs, card['breakdown_alt'], card['breakdown_caption'], int(card.get('breakdown_height', 1100)))
    return f'''<article class="chart-card speed-card native-card" id="{metric}" aria-labelledby="title-{metric}">
<div class="chart-card-top"><div class="card-category"><h3 id="title-{metric}"><span class="metric-dot {metric}-color"></span>{e(card['number'])} / {title}</h3><span>Upstream = 1× · Lower time is better</span></div><div class="track-summaries">{native_summary}{js_summary}</div></div>
{self_callout}
<div class="speed-charts history-charts"><section class="speed-chart" aria-labelledby="native-history-{metric}"><h4 id="native-history-{metric}">Native · comparison and history</h4><p>Upstream comparisons retain their own workloads and clocks.</p>{native_history}{native_extra_history}</section><section class="speed-chart" aria-labelledby="js-history-{metric}"><h4 id="js-history-{metric}">JavaScript · full history</h4><p>The complete earlier series stays visible, including its largest improvements.</p>{js_history}{js_extra_history}</section></div>
<div class="speed-charts breakdown-charts"><section class="speed-chart" aria-labelledby="native-programs-{metric}"><h4 id="native-programs-{metric}">Native · breakdown by program</h4><p>Each bar compares with the paired upstream compiler.</p>{native_breakdown}<div class="average-method"><strong>Native measurement</strong><p>{e(native_method)}</p></div></section><section class="speed-chart" aria-labelledby="js-programs-{metric}"><h4 id="js-programs-{metric}">JavaScript · breakdown by program</h4><p>The same upstream baseline, one program at a time.</p>{js_breakdown}<div class="average-method"><strong>JavaScript measurement</strong><p>{e(card['method'])}</p></div></section></div>
<p class="card-takeaway"><span aria-hidden="true">↳</span><span>{e(takeaway)}</span></p><div class="card-bottom">{link(native_source, 'Native measured report')} · {link(js_source, 'JavaScript measured report')}<span><a href="./charts/{native_history_name}.svg" download>Native graph SVG ↓</a> · <a href="./charts/{js_chart}.svg" download>JavaScript history SVG ↓</a></span></div><details class="data-details"><summary>Native measurements, protocols and sources</summary>{native_measurements}</details><details class="data-details"><summary>JavaScript measurements, commit dates and sources</summary>{js_measurements}</details></article>'''

def render_conformance(research):
    c=research['conformance']; native=c['currentNative']; cli=c['nativeCLI']
    report=source_url(research,'implementation/phase102/default-promotion.md')
    stats=[('69 / 69','Eligible native fixtures · both B1 and B2'),('45 / 45','Native semantic catalog points'),('41 / 41','Public CLI integration controls'),('3,173 / 3,174','JavaScript frontend exact agreement')]
    cells=''.join('<div><strong>'+e(value)+'</strong><span>'+e(label)+'</span></div>' for value,label in stats)
    rows=[['Native fixtures · P102','69 passes + 3 expected rejections per stage','31 exclusions; B1 and B2 qualified separately',link(report)],['Native semantic catalog · P102','45 / 45 catalog points','Includes the zero-work control; not 45 timing ratios',link(report)],['Native backend bridges · P102','70 obligations passed','Overlaps other native tests; not added to fixture counts',link(report)],['Public CLI · P103','41 / 41 controls; 6 / 6 C/verdict pairs','Integration and exact output checks, not a new broad timing campaign',link(source_url(research,'implementation/phase103/README.md'))],['JS frontend · P91','3,173 / 3,174 exact','Invalid proof is rejected; B2 falls back to shorter diagnostics after deep rendering overflows the JS stack',link(source_url(research,'implementation/phase91/README.md'))],['Historical JS execution · P66','1,045 distinct golden passes','123 exemptions; 1 shared Process.run failure; 1 graphics deferral',link(source_url(research,'implementation/phase66/README.md'))]]
    return f'''<article class="chart-card native-card" id="conformance" aria-labelledby="title-conformance"><div class="chart-card-top"><div class="card-category"><h3 id="title-conformance"><span class="metric-dot conformance-color"></span>04 / Conformance</h3><span>Expected behavior, by scope</span></div><p class="card-summary">Native execution, public interfaces and frontend agreement answer different questions. Each keeps its own denominator.</p><div class="qualification-grid">{cells}</div></div>{figure('conformance','Separate conformance histories and current native and CLI controls','Native exclusions and expected rejections remain visible. Historical JavaScript coverage is retained with its original execution and reuse boundaries.',1050)}<p class="card-takeaway"><span aria-hidden="true">↳</span><span>Correctness supports each optimization. One JavaScript diagnostic difference remains; passing executable controls does not prove the whole compiler.</span></p><details class="data-details"><summary>Current scope, exclusions and proof boundaries</summary>{table(['Scope','Result','Boundary','Evidence'],rows)}<h4>Independently checked optimization contracts</h4><p>Phase 96 independently checks 31 public laws and 7 supporting lemmas. Phase 98 connects 13 distinct accepted statements—8 public and 5 support—to selected production helper closures. The larger historical catalog includes unpromoted experiments. Finite tests and native memory behavior require their own evidence.</p>{link(source_url(research,'docs/self_hosted/COMPILER_LAWS.md'),'Law suite and exact scope')}</details></article>'''


def render_simplicity(research):
    h=research['history']['simplicity']
    rows=[]
    for p in h['series']:
        rows.append([e(p['chartLabel']),f"{p['physicalLines']:,}",str(p['modules']),link(p['sourceLink'])])
    return f'''<article class="chart-card native-card" id="simplicity" aria-labelledby="title-simplicity"><div class="chart-card-top"><div class="card-category"><h3 id="title-simplicity"><span class="metric-dot simplicity-color"></span>05 / Simplicity</h3><span>Count code. Explain dependencies.</span></div><div class="card-headline"><strong>34,231</strong><span>physical lines · 134 canonical Bend modules</span></div><p class="card-summary">The canonical source grew 20.15% from Phase 66 as native compiler functionality expanded. Ordinary native requests now run directly, with CLI policy and compiler algorithms written in Bend.</p></div>{figure('simplicity','Canonical source history and separate assembled native source sizes','Canonical modules and assembled compiler profiles have different counting boundaries; they are separate series.',850)}<div class="qualification-grid"><div><strong>152</strong><span>Bend lines for public CLI policy</span></div><div><strong>265</strong><span>C host lines: 246 OS provider + 19 startup</span></div></div><p class="card-takeaway"><span aria-hidden="true">↳</span><span>No Python, Node, Bun or TypeScript interpreter is needed for an ordinary public native request. Bootstrap, development and benchmark tools retain their own dependencies.</span></p><details class="data-details"><summary>Source history and counting boundaries</summary>{table(['Checkpoint','Physical lines','Modules','Evidence'],rows,'Canonical authored Bend modules; runtime, host glue, tests and generated files excluded.')}<p>Installed JavaScript compiler source remains 32,692 lines in 132 modules, a distinct release inventory. Assembled native compiler: 39,372 lines in promoted candidate04. Public CLI compiler: 39,545 lines, +173 (+0.44%). Assembly includes additional material, so these counts must not be connected to the canonical-module curve.</p>{link(source_url(research,'implementation/phase103/README.md'),'CLI implementation and source accounting')}</details></article>'''


def render_applications(data):
    cards=[]
    for item in data['cards']:
        preview=item['preview']
        if preview.get('src'):
            visual=f'<img src="{e(preview["src"])}" alt="{e(preview["alt"])}" loading="lazy">'
        else:
            visual='<pre>'+e(preview.get('text',''))+'</pre>'
        bars=[]
        for case in item['cases']:
            ratio=case['ratio_upstream']
            color='var(--simplicity)' if ratio > 1 else 'var(--green)'
            bars.append(f'<div class="application-bar"><div><span>{e(case["label"])}</span><strong>{ratio:.3f}×</strong></div><div class="application-bar-track"><span style="width:{min(100,ratio/1.3*100):.3f}%;background:{color}"></span><i style="left:{1/1.3*100:.3f}%" aria-hidden="true"></i></div></div>')
        sources=' '.join(link(s['url'],s['title']) for s in item['sources'])
        history=''
        if item['id']=='image-render':
            old=data['history'];scaling=old['parallel_scaling']
            history='<details class="application-history"><summary>Earlier parallel-scaling milestone · 2.05×</summary><p>Phase 100 measured Phase 98-generated code: one to four physical cores gave 2.05× speedup. This is a separate historical campaign, not a new scaling claim for candidate04.</p>'+table(['Workers','Native process (ms)','Upstream process (ms)'],[[str(w),str(b),str(u)] for w,b,u in zip(scaling['workers'],scaling['native_median_ms'],scaling['upstream_median_ms'])], 'Every worker setting produces the identical complete image. The one-tile serial control remains 310 ms across worker counts.')+link(old['source_url'],'Historical scaling experiment')+'</details>'
        cards.append(f'<article class="app-card"><div class="app-preview">{visual}</div><p class="preview-caption">{e(preview.get("caption", ""))}</p><div class="app-copy"><h3>{e(item["name"])}</h3><p>{e(item["description"])}</p><div class="application-bars"><span class="mini-label">PROCESS TIME / UPSTREAM C · TICK = 1×</span>{"".join(bars)}</div><p class="app-takeaway"><strong>{e(item.get("headline", ""))}</strong> {e(item["takeaway"])}</p><p class="visual-note">{e(item["note"])}</p><div class="finding-sources">{sources}</div>{history}</div></article>')
    return ''.join(cards)


def render_outlook(data, audit):
    screen = table(['Development case', 'B1 request (ms)', 'B2 request (ms)', 'B1 process (ms)', 'B2 process (ms)'], [
        [e(p['case'].replace('_original','').title()), f"{p['stages']['b1']['medianRequestMs']:.1f}", f"{p['stages']['b2']['medianRequestMs']:.1f}", f"{p['stages']['b1']['medianProcessMs']:.1f}", f"{p['stages']['b2']['medianProcessMs']:.1f}"] for p in audit['twoCaseScreen']
    ], 'Phase 104: four alternating rounds, two familiar development cases. These small differences do not establish a general B1/B2 ranking or recursive acceleration.')
    return screen + '<div class="outlook-copy">'+''.join('<p>'+e(p)+'</p>' for p in data['paragraphs'])+'</div><div class="native-stats">'+''.join('<div><strong>'+e(s['value'])+'</strong><span>'+e(s['label'])+'</span></div>' for s in data['stats'])+'</div><p class="visual-note">'+e(data['note'])+'</p><div class="finding-sources">'+''.join(link(s['url'],s['title']) for s in data['sources'])+'</div>'
