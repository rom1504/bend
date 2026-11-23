"""Summarize a completed paired screen with the historical fixed-work weights."""
import json
import math
from pathlib import Path
import statistics
import sys

def summarize(path):
    result = json.loads(path.read_text())
    assert len({row['id'] for row in result['cases']}) == len(result['cases']) == 45
    eligible = [r for r in result['cases'] if r['runsMs']['parent']]
    assert len(eligible) == 44 and all(len(values) == 6 for r in eligible for values in r['runsMs'].values())
    ratios = {}
    totals = {role: 0.0 for role in ('parent','port','c')}
    for row in eligible:
        medians = {role: statistics.median(times) / row['reps'][role] for role,times in row['runsMs'].items()}
        ratios[row['id']] = medians['port'] / medians['parent']
        for role in totals:
            totals[role] += medians[role] * row['fixedReps'] / 1000
    summary = dict(fixedSeconds=totals, fixedVsC={r: totals[r]/totals['c'] for r in ('parent','port')},
                   fixedPortVsParent=totals['port']/totals['parent'],
                   geometricPortVsParent=statistics.geometric_mean(ratios.values()),
                   byCase=dict(sorted(ratios.items(), key=lambda item:item[1])))
    print(json.dumps(summary,indent=2))

if __name__ == '__main__':
    summarize(Path(sys.argv[1]))
