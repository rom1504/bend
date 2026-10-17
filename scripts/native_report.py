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


def render_speed(card, research, legacy):
    metric=card['id']; native=research['native']; runtime=metric=='execution'
    title={'execution':'Compiled program speed','second-stage':'Second stage compiler compilation speed','compilation':'First stage compiler compilation speed'}[metric]
    key={'execution':'execution','second-stage':'secondStage','compilation':'compilation'}[metric]
    data=native[key]; latest=data['latest']
    chart={'execution':'native-runtime','second-stage':'native-second-stage','compilation':'native-compilation'}[metric]
    if runtime:
        value=f"{latest['averageRatio']:.3f}×"; unit='upstream-generated C execution time'
        summary=f"Native programs are {100*(latest['averageRatio']-1):.2f}% above upstream on average. The promoted compiler uses {latest['timeReductionPercent']:.2f}% less program runtime than its freshly measured Phase 98 control."
        badges=['Native C output','44 timed points · 23 sources','Baseline: upstream C','Last broad run: P102 candidate04']
        secondary=f"{latest['equalSourceRatio']:.3f}× with equal weight per source"
        history_intro='One cohort per series. Earlier C12 results are kept separate.'
        history_caption='Historical checkpoints retain their source dates, timing windows and reuse status. The current broad campaign compares paired native executables with the same upstream C target.'
        breakdown_intro='Each source gets one bar; the headline gives each timed input equal weight.'
        breakdown_caption='Different inputs of a source are geometrically averaged for its bar. Equal-source weighting gives a slightly different average. The zero-work control has no timing ratio.'
        method='Divide each native program’s median time by its paired upstream-generated C time, then take the geometric mean of the 44 positive-work points. Three alternating rounds per comparator; 45 catalog points pass semantic controls. Compilation, process startup and warmup are outside this clock.'
        takeaway='The same Bend programs are compiled by two compilers and run as native C executables. “Upstream” describes the reference compiler; these are not TypeScript programs.'
        measurements=runtime_table(native)
        source=source_url(research,'implementation/phase102/default-promotion.md')
        extra=''
    else:
        stage='B2' if metric=='second-stage' else 'B1'
        ratio=latest['requestRatio']; delta=100*(ratio-1)
        value=f"{abs(delta):.2f}%";unit=('less' if delta<0 else 'more')+' request time vs Phase 98'
        summary=('The Bend-built native compiler improves substantially on ordinary compilation. The gain is measured against the previous native release across six sources.' if stage=='B2' else 'The upstream-built native compiler is slightly slower on this six-source campaign. Its earlier Phase 98 improvement remains visible in the history.')
        badges=['Native '+stage+' host · C output','6 sources · 4 balanced rounds','Baseline: Phase 98','P102 candidate04']
        secondary=f"{ratio:.3f}× request time · {latest['processRatio']:.3f}× complete process time"
        history_intro='Each release is compared with its own measured predecessor.'
        history_caption='These are independent paired campaigns. A lower bar means less time than the stated predecessor; different baselines are not joined or multiplied into an upstream estimate.'
        breakdown_intro='Current compiler / Phase 98, using identical source inputs.'
        breakdown_caption='The request clock excludes prepared Base decoding. The process clock includes startup, Base preparation, output writing and teardown. Neither includes a subsequent C toolchain build.'
        method='The geometric mean weights six source-level ratios equally. Request and process time stay separate. This campaign has no current native-versus-upstream compiler comparison; the earlier JavaScript comparison is available below.'
        takeaway='Latest broad measurement: Phase 102 candidate04. Phase 103 packages the same compiler core as a public native CLI; Phase 104 adds a two-case timing screen and lineage audit.'
        measurements=compiler_table(data)
        source=source_url(research,'implementation/phase102/default-promotion.md')
        extra=''
        if stage=='B2':
            extra='<details class="data-details"><summary>Full compiler source: self-emission and build cost</summary>'+self_table(native)+'<p>Phase 104 rechecks the existing artifacts: B1 and B2 emitted identical 30,373,059-byte C files. B3 C exists; its executable has not been built. The historical B2 C emission took 150.846 s and Clang construction took 374.033 s. These are distinct clocks and single observations.</p>'+link(source_url(research,'implementation/phase104/README.md'),'Audited lineage and cost model')+'</details>'
    js=legacy.replace('id="'+metric+'"','id="js-'+metric+'"').replace('title-'+metric,'title-js-'+metric)
    js_summary='JavaScript output · retained average and complete history' if runtime else 'JavaScript-hosted '+('B2' if metric=='second-stage' else 'B1')+' · latest upstream comparison and full history'
    badges_html=''.join('<span>'+e(b)+'</span>' for b in badges)
    return f'''<article class="chart-card speed-card native-card" id="{metric}" aria-labelledby="title-{metric}">
<div class="chart-card-top"><div class="card-category"><h3 id="title-{metric}"><span class="metric-dot {metric}-color"></span>{e(card['number'])} / {title}</h3><span>Lower time is better</span></div><div class="scope-badges">{badges_html}</div><div class="speed-head"><div><div class="card-headline"><strong>{value}</strong><span>{unit}</span></div><p class="native-secondary">{e(secondary)}</p></div><p class="card-summary">{summary}</p></div></div>
<div class="speed-charts"><div class="speed-chart"><h4>Progress through the releases</h4><p>{history_intro}</p>{figure(chart+'-history', title+' history with separate measurement boundaries',history_caption)}<div class="average-method"><strong>What this measures</strong><p>{method}</p></div></div><div class="speed-chart"><h4>Breakdown by program</h4><p>{breakdown_intro}</p>{figure(chart+'-programs',title+' by program and comparison baseline',breakdown_caption,1100 if runtime else 650)}</div></div>
<p class="card-takeaway"><span aria-hidden="true">↳</span><span>{takeaway}</span></p><div class="card-bottom">{link(source,'Measured native report')}<span><a href="./charts/{chart}-history.svg" download>History SVG ↓</a> · <a href="./charts/{chart}-programs.png" download>Program chart PNG ↓</a></span></div><details class="data-details"><summary>Native measurements and sources</summary>{measurements}</details>{extra}
<details class="track-history"><summary>{js_summary}</summary>{js}</details></article>'''


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
            bars.append(f'<div class="application-bar"><div><span>{e(case["label"])}</span><strong>{ratio:.3f}×</strong></div><div class="application-bar-track"><span style="width:{min(100,ratio/1.3*100):.3f}%;background:{color}"></span><i style="left:{1/1.3*100:.3f}%" aria-hidden="true"></i></div><small>{100*(1-case["ratio_previous"]):.1f}% less time than Phase 98</small></div>')
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
