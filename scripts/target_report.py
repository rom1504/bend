"""Public report panels for the upstream migration and direct x86 campaigns."""
from native_report import figure, link, table
from target_charts import timed_cases, ratio


def evidence(data, phase, title):
    return link(f"https://github.com/rom1504/bend/blob/{data['commit']}/implementation/phase{phase}/README.md", title)


def panel(title, body):
    return f'<section class="target-panel"><h4>{title}</h4>{body}</section>'


def runtime(data):
    latest = data['history'][-1]
    slow = sum(ratio(c) > 2 for c in timed_cases(data).values())
    history = figure('target-runtime', 'x86 execution time fell from over five times mature C time to about equal geometric time.',
                     '44 timed inputs. Each point uses its own timing campaign. Phase 185–186 generated assembly text. Later points use direct objects.', 500)
    programs = figure('target-programs', 'Original programs sorted by their x86 to mature C execution-time ratio.',
                      'Each row averages the timed inputs of one source. The geometric headline gives each timed input equal weight.', 1000)
    qbe = figure('qbe-runtime', 'QBE-generated program time fell from 7.088 to 1.663 times upstream C time on the earlier upstream pin.',
                 '44 timed inputs before the Bend 2.0.40 migration. In the separate Phase 186 comparison QBE took 1.347× our mature C time.', 400)
    scores = panel('Direct x86 machine code', f'''<div class="target-scores"><div><strong>{latest["geometric"]:.3f}×</strong>mature Bend C time · geometric mean</div><div><strong>{latest["fixed"]:.3f}×</strong>mature Bend C time · fixed batch</div><div><strong>{slow} / 44</strong>timed cases above twice C time</div></div>
<p>The geometric mean gives each timed input equal weight. The fixed batch keeps the original repetition counts. One additional case checks correctness with zero timed work. Measurements come from Phase 200.</p>''')
    case_rows = [[c['id'], f"{c['medianMs']['candidate']:.6g}", f"{c['medianMs']['c']:.6g}", f"{ratio(c):.4g}×"]
                 for c in sorted(timed_cases(data).values(), key=ratio, reverse=True)]
    case_table = table(['Input', 'x86 (ms)', 'Mature C (ms)', 'Time ratio'], case_rows, 'Median runtime per invocation · 44 positive-work inputs')
    charts = panel('How x86 and QBE runtimes evolved' , f'''
<div class="target-duo"><section><h5>Runtime history · mature Bend C = 1×</h5>{history}<h5>QBE history · upstream C = 1×</h5>{qbe}</section><section><h5>x86 by program · mature Bend C = 1×</h5>{programs}</section></div><details><summary>All timed inputs and paired medians</summary>{case_table}</details>
<p>{evidence(data,200,'x86 program measurements')} · {evidence(data,131,'QBE vs upstream')} · {evidence(data,186,'QBE and assembly vs mature Bend C')}</p>''')


    return scores, charts


def compilation(data, stage):
    role = 'n2' if stage == 'second-stage' else 'n1'
    rows = [[f'Phase {r["phase"]}', f'{r[role]:.3f}×', evidence(data, r['phase'], 'Request timings')] for r in data['requestHistory']]
    requests = table(['QBE producer', 'Time / upstream', 'Evidence'], rows, 'Lexer, closures and Map · three ordinary compiler requests before Bend 2.0.40')
    requests = figure('qbe-requests', 'Both native QBE compiler stages compared with upstream on three requests.', 'Each phase has a fresh upstream measurement for lexer, closures and Map. Compare within the same recorded block.', 410) + requests
    if stage == 'second-stage':
        build = data['coldBuilds'][-1]
        chart = figure('x86-self-build','Two matched pairs of complete x86 builds, ending at 292.71 seconds.',
                       'One run per producer per trial source. Both pairs use prepared Base and include linking. The two trial sources differ.',410)
        content = f'''<div class="target-scores"><div><strong>{build["selfSeconds"]:.2f} s</strong>source to linked x86 compiler</div></div>
<p>The Phase 203 research compiler reproduced its own {build["objectBytes"]:,}-byte object and the linked executable exactly. This times a full self-build.</p>{chart}
<p>{evidence(data,202,'First build pair')} · {evidence(data,203,'Latest build pair')}</p><h5>Ordinary requests · native QBE N2</h5>{requests}'''
        return panel('Cold x86 self-compilation', content)
    b = data['bootstrap'][-1]
    chart = figure('bootstrap-builds', 'Acquisition times by producer and output image.', 'P199–200 use native QBE to build N1 compilers capable of emitting x86. P201 uses a QBE-built producer to emit a direct x86 compiler. Each build uses its own source.', 410)
    return panel('Building a first x86 compiler', f'''<div class="target-scores"><div><strong>{b['seconds']:.2f} s</strong>{b['producer']} → {b['product']}</div></div>
<p>The Phase 201 timing covers acquisition of the complete executable. In the Phase 182 JavaScript bootstrap, acquiring checked API06 took 14.455 s. These are setup costs for different products.</p>
{chart}<p>{evidence(data,199,'QBE-built N1')} · {evidence(data,200,'Spill-rule N1')} · {evidence(data,201,'First x86 image')} · {evidence(data,182,'JavaScript bootstrap')}</p><h5>Ordinary requests · native QBE N1</h5>{requests}''')


def conformance(data):
    rows = [
        ['JavaScript · P182','23-case frontend gate (snapshot07)','Seven public JS controls','B3 reproduces B2 at the recorded Bun stack limit'],
        ['Native C · P182','16/16 public C and 10/10 controls','Fresh checkout emits, builds and runs C','C output checked in its own qualification'],
        ['QBE · P182','64/64 backend and 10/10 runtime','Six native session controls','QBE, assembly and object bytes match across generations'],
        ['Direct x86 · P189 release','64/64 backend and 10/10 runtime','14/14 installed command controls','Object-built N2 → N3 reproduces the complete compiler object'],
        ['Direct x86 · P202 research','24 distinct portfolio programs checked','Each replay executes its own oracle','Complete compiler object and linked ELF match'],
        ['Direct x86 · P203 research','12 additional cases checked in this campaign','Verifier and portfolio outputs checked','Complete compiler object and linked ELF match']]
    return panel('Which targets have been checked?', table(['Target and revision','Program checks','Command or execution checks','Reproduction'],rows)
                 + '<p>'+' · '.join(evidence(data,p,f'Phase {p}') for p in [182,189,202,203])+'</p>')


def architecture(data):
    return panel('From Bend source to a Linux AMD64 executable',
        '<ol class="target-route"><li>Bend source</li><li>Typed x86 instructions</li><li>ELF object</li><li>Linked executable</li></ol>'
        '<p>The compiler writes the object directly. Explicit assembly output uses the same typed instructions. Ordinary executable builds skip formatting and reparsing assembly text and still use the runtime and linker.</p>'
        +evidence(data,189,'Public object route'))
