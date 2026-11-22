"""Render the comparison tables from the recorded per-process samples."""
import json
from pathlib import Path
from statistics import geometric_mean
import sys

def render(path):
    data=json.loads(path.read_text())
    spec=json.loads((Path(__file__).parent/'suite.json').read_text())
    print('# Pilot measurements\n')
    print('Median microseconds per call, including the batch checksum. Smaller is faster. '
          'Each call uses the displayed size and one of 32 runtime seeds.\n')
    print('| Input | Original AGY | Tuned AGY | Original C | Tuned C | Tuned QBE | Tuned Bend-to-C | Tuned AGY / C |')
    print('|---|---:|---:|---:|---:|---:|---:|---:|')
    ratios={}
    totals={k:0 for k in ['original-agy','original-hand-c','tuned-agy','tuned-hand-c','tuned-qbe','tuned-bend-c']}
    for row in data['rows']:
        f=row['family']
        def us(k): return row['median_us'][f+'-'+k]
        cols=['original-agy','tuned-agy','original-hand-c','tuned-hand-c','tuned-qbe','tuned-bend-c']
        ratio=us('tuned-agy')/us('tuned-hand-c')
        print('| '+row['id']+' | '+' | '.join(f'{us(k):.4f}' for k in cols)+f' | {ratio:.2f}× |')
        if row['id'] not in spec['extension_points']:
            ratios.setdefault(f,[]).append(ratio)
            for k in totals:
                totals[k]+=us(k)*row['fixed_reps']/1e6
    print('\n## Family and fixed-work summaries\n')
    print('The family ratios use the geometric mean across the historical sizes in each family. '
          'The extension point is shown separately above.\n')
    families={k:geometric_mean(v) for k,v in ratios.items()}
    for family,ratio in families.items(): print(f'- {family}: {ratio:.2f}× tuned AGY / tuned handwritten C')
    print(f'\nEqual weight per measured family gives **{geometric_mean(families.values()):.2f}×**. '
          'The following normalized batch times multiply median time per call by the corresponding native45 '
          'repetition count. The seed schedule is specific to this suite.\n')
    print('| Program | Seconds for measured native45 anchors |\n|---|---:|')
    for k,v in totals.items(): print(f'| {k} | {v:.4f} |')
    print('\n## Fastest observed source per family\n')
    print('Here each side picks one source form for the whole family by its normalized fixed-work total on the historical sizes. '
          'This post hoc comparison includes the original and all attempted forms and is descriptive of these measured inputs.\n')
    print('| Family | AGY source | Handwritten C source | AGY / C (fixed work) |\n|---|---|---|---:|')
    for family in families:
        rows=[r for r in data['rows'] if r['family']==family and r['id'] not in spec['extension_points']]
        def best(role):
            by_form={form: sum(r['fixed_reps']*r['median_us'][f'{family}-{form}-{role}'] for r in rows)
                     for form in spec['families'][family]['forms']}
            chosen=min(by_form,key=by_form.get)
            return chosen,by_form[chosen]
        a,ta=best('agy')
        c,tc=best('hand-c')
        print(f'| {family} | {a} | {c} | {ta/tc:.2f}× |')
    print('\n## Effect of changing the Bend source on each backend\n')
    print('Speedup is original runtime divided by tuned runtime. Values below one mean the tuned source ran slower.\n')
    print('| Input | AGY x86 | QBE | Bend-to-C |\n|---|---:|---:|---:|')
    for row in data['rows']:
        times=row['median_us']
        family=row['family']
        speedups=[times[f'{family}-original-{role}']/times[f'{family}-tuned-{role}']
                  for role in ['agy','qbe','bend-c']]
        print('| '+row['id']+' | '+' | '.join(f'{gain:.2f}×' for gain in speedups)+' |')
    print('\n## List fusion control\n')
    print('| Input | Fused AGY (µs) | Fused handwritten C (µs) | AGY / C |\n|---|---:|---:|---:|')
    for row in data['rows']:
        if row['family']=='list':
            a=row['median_us']['list-fused-agy']
            c=row['median_us']['list-fused-hand-c']
            print(f"| {row['id']} | {a:.4f} | {c:.4f} | {a/c:.2f}× |")

if __name__=='__main__':
    render(Path(sys.argv[1]))
