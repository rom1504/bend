"""Runtime, cold build and transfer measurements from the target campaigns."""
from math import isclose
from statistics import geometric_mean

GREEN = '#245f43'
ORANGE = '#99551e'
BLUE = '#365f92'
TITLES = ('target-runtime', 'target-programs', 'qbe-runtime', 'x86-self-build',
          'x86-scan', 'source-transforms', 'compiler-work', 'qbe-requests', 'bootstrap-builds')


def timed_cases(data):
    return {r['id']: r for r in data['cases'] if r['ratioEligible']}


def ratio(case):
    return case['medianMs']['candidate'] / case['medianMs']['c']


def validate(data):
    cases = timed_cases(data)
    members = [i for g in data['groups'] for i in g['pointIds']]
    if len(data['cases']) != 45 or len(cases) != 44 or sorted(members) != sorted(cases):
        raise ValueError('Runtime groups must cover all 44 timed cases exactly once')
    last = data['history'][-1]
    fixed = lambda role: sum(r['fixedEquivalentMs'][role] for r in cases.values())
    if not isclose(geometric_mean(map(ratio, cases.values())), last['geometric']) or not isclose(fixed('candidate') / fixed('c'), last['fixed']):
        raise ValueError('Headline and timed suite disagree')
    if sum(ratio(r) > 2 for r in cases.values()) != 18:
        raise ValueError('Count of cases above twice mature C differs')


def canvas(plt, height=3.9):
    fig, ax = plt.subplots(figsize=(7, height), layout='constrained')
    ax.spines[['top', 'right', 'left']].set_visible(False)
    ax.tick_params(length=0, pad=7)
    return fig, ax


def bars(plt, save, name, labels, values, reference, description, seconds=False):
    fig, ax = canvas(plt, 1.15 + .60 * len(values))
    ax.grid(axis='x', alpha=.35)
    if not seconds:
        ax.axvline(1, lw=1, color='#68766b', ls='--')
    colors = [GREEN if n % 2 else BLUE for n in range(len(values))] if seconds else GREEN
    rects = ax.barh(labels, values, height=.48, color=colors, zorder=3)
    ax.bar_label(rects, labels=[f'{v:.2f} s' if seconds else f'{v:.3f}×' for v in values], padding=5)
    ax.invert_yaxis()
    ax.set_xlim(0, max(max(values), 1) * 1.22)
    ax.set_xlabel(reference)
    save(plt, fig, name, description)


def render(plt, data, save):
    validate(data)
    history = data['history']
    fig, ax = canvas(plt)
    for key, color, marker, label in [('geometric', GREEN, 'o', 'Equal-case geometric mean'),
                                      ('fixed', ORANGE, 's', 'Original fixed batch')]:
        ax.plot([r['phase'] for r in history], [r[key] for r in history], marker=marker,
                ms=4, lw=2.2, color=color, label=label)
    ax.axhline(1, ls='--', color='#415349', lw=1)
    ax.set_xticks([185, 188, 190, 192, 194, 196, 198, 200])
    ax.set_xlabel('Compiler phase · assembly at 185–186, direct objects from 190')
    ax.set_ylabel('Time ÷ mature Bend C time')
    ax.legend(frameon=False)
    ax.grid(axis='y', alpha=.35)
    save(plt, fig, 'target-runtime', 'x86 program time by phase. Dashed line is mature Bend C parity.')
    fig, ax = canvas(plt, 8)
    cases = timed_cases(data)
    groups = sorted((geometric_mean(ratio(cases[i]) for i in g['pointIds']), g['label'])
                    for g in data['groups'])
    for y, (v, label) in enumerate(groups):
        ax.hlines(y, min(v, 1), max(v, 1), color='#acb9aa', lw=1.5)
        ax.plot(v, y, 'o', color=GREEN if v < 1 else ORANGE, ms=5)
        ax.annotate(f'{v:.3g}×', (v, y), xytext=(6, 0), textcoords='offset points', va='center', fontsize=9)
    ax.set_yticks(range(len(groups)), [g[1] for g in groups], fontsize=10)
    ax.invert_yaxis()
    ax.set_xscale('log')
    ax.set_xlim(groups[0][0]*.65,groups[-1][0]*2.5)
    ax.axvline(1, color='#415349', ls='--')
    ax.set_xlabel('Execution time ÷ mature Bend C time · log scale')
    save(plt, fig, 'target-programs', 'Sorted geometric mean of timed inputs for each original source.')
    fig, ax = canvas(plt,3.2)
    phases, values = zip(*data['qbeUpstream'])
    ax.plot(phases, values, 'o-', color=BLUE)
    ax.axhline(1, color='#415349', ls='--')
    ax.set_xticks([113,118,121,125,131]); ax.grid(axis='y', alpha=.35)
    ax.set_ylabel('Time ÷ upstream C time'); ax.set_xlabel('Compiler phase · earlier upstream reference')
    save(plt, fig, 'qbe-runtime', 'Selected broad QBE runtime checkpoints relative to upstream C.')
    builds = data['coldBuilds']
    labels, values = [], []
    for b in builds:
        for phase, key in [(b['phase']-1, 'baselineSeconds'), (b['phase'], 'selfSeconds')]:
            labels.append(f"P{phase} on P{b['phase']} source")
            values.append(b[key])
    bars(plt, save, 'x86-self-build', labels, values, 'Cold source to linked x86 executable · seconds',
         'Two independently matched full-build pairs. One observation per role per input.', seconds=True)
    fig, ax = canvas(plt,3.6)
    phases = [r['phase'] for r in data['requestHistory']]
    for key, color in [('n1', BLUE), ('n2', ORANGE)]:
        ax.plot(phases, [r[key] for r in data['requestHistory']], marker='o', color=color, label=key.upper())
    ax.set_xticks(phases); ax.axhline(1, color='#415349', ls='--')
    ax.set_ylabel('Request time ÷ upstream time'); ax.set_xlabel('QBE compiler phase')
    ax.legend(frameon=False); ax.grid(axis='y', alpha=.35)
    save(plt, fig, 'qbe-requests', 'Historical three-program request comparison against the earlier upstream pin.')
    bars(plt, save, 'bootstrap-builds', ['P199 · QBE-built N1', 'P200 · QBE-built N1', 'P201 · x86-built image'],
         [b['seconds'] for b in data['bootstrap']], 'Time to acquire each compiler executable · seconds',
         'Different source images. The first two use the native QBE compiler. The third uses a QBE-built direct-x86 producer.', seconds=True)
    for plot in data['experiments']:
        bars(plt, save, plot['name'], plot['labels'], plot['values'], plot['axis'], plot['description'])
