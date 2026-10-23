"""Plot the original44 matched runtime points; no compiler or target execution."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path

os.environ.setdefault('MPLCONFIGDIR', '/tmp/bend-phase126-matplotlib')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--summary', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists()
raw = a.summary.read_bytes()
d = json.loads(raw)
assert d['complete'] and len(d['screens']) == 1
rows = d['screens'][0]['cases']
assert len(rows) == 45 and len({r['name'] for r in rows}) == 45
rows = [r for r in rows if r['ratioEligible']]
assert len(rows) == 44
rows.sort(key=lambda r: r['baselineOverUpstream'], reverse=True)
old = [r['baselineOverUpstream'] for r in rows]
new = [r['candidateOverUpstream'] for r in rows]
assert all(v > 0 and math.isfinite(v) for v in old + new)
gm = lambda xs: math.exp(sum(map(math.log, xs)) / len(xs))
loss = lambda xs: sum(max(0, math.log(x)) for x in xs) / len(xs)
matplotlib.rcParams['svg.hashsalt'] = 'bend-phase126-frozen44'
fig, ax = plt.subplots(figsize=(12, 13))
y = list(range(len(rows)))
for i, (before, after) in enumerate(zip(old, new)):
    ax.plot([before, after], [i, i], color='#cbd5e1', linewidth=1.4, zorder=1)
ax.scatter(old, y, s=24, color='#64748b', label='Phase125, same run', zorder=2)
ax.scatter(new, y, s=27, color='#087e8b', label='Selected Phase126', zorder=3)
ax.axvline(1, color='#b91c1c', linewidth=1, linestyle='--', label='Upstream parity')
ax.set_xscale('log')
ax.set_yticks(y, [r['name'] for r in rows], fontsize=8)
ax.invert_yaxis()
ax.set_xlabel('Generated-program execution time / pinned upstream C/Clang (lower is better)')
ax.grid(axis='x', alpha=.2)
ax.legend(loc='lower right', fontsize=9)
ax.set_title(f'Original44 timed programs: {gm(old):.3f}× → {gm(new):.3f}× geometric mean\n'
             f'Mean positive log-slowdown: {loss(old):.3f} → {loss(new):.3f}', loc='left')
fig.text(.02, .008, 'Three rotated rounds, fixed original repetitions; all45 complete-output checks retained.\n'
         'Source: ' + str(a.summary) + ' · SHA256 ' + hashlib.sha256(raw).hexdigest()[:16], fontsize=7)
fig.tight_layout(rect=(0, .035, 1, 1))
a.out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(a.out, metadata={'Date': None})
plt.close(fig)
print(json.dumps(dict(complete=True, targetsRun=False, figure=str(a.out), timedCases=44,
    baselineGeomean=gm(old), candidateGeomean=gm(new))))
