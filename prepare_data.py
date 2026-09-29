#!/usr/bin/env python3
"""Curate charts and CSVs from the retained historical research, without Git writes."""
import csv
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
def read(name):
    return json.loads((HERE / 'research' / f'{name}.json').read_text())

s, c, z = (read(name) for name in ['speed','conformance','complexity'])
assert s['head'] == c['head'] == z['head']
def csv_write(name, rows, fields):
    with (HERE / name).open('w', newline='') as out:
        writer=csv.DictWriter(out,fieldnames=fields,extrasaction='ignore')
        writer.writeheader();writer.writerows(rows)

checking=[]
for r in s['speed_series']:
    checking.append(dict(phase=r['phase'],commit=r['commit'],date=r['commit_date'],
        upstream=r['pin'],compiler_s=r['bend_process_seconds'],ts_s=r['typescript_process_seconds'],
        ratio=r['bend_to_typescript_process_ratio'],baseline_s=r['same_window_predecessor_seconds'],
        baseline_ratio=r['same_window_predecessor_ratio'],samples=r['samples_per_image'],
        source=r['source_url'],finding=r['finding']))
main=[]
for r in c['main_frontend']:
    main.append(dict(phase=r['phase'],label=f"P{r['phase']}",commit=r['commit'],date=r['committed_at'],
        upstream=r['target'],total=r['observations'],exact=r['exact'],different=r['differences'],
        source=r['source']['url'],notes=r['notes']))
assert all(r['exact']+r['different']==r['total'] for r in main)
zrows=[{k:v for k,v in r.items() if k!='files'} for r in z['milestones']]
selected_labels={'Initial snapshot':'Initial','Phase5 / simplification baseline':'P5',
    'S1 obsolete paths':'P7 / S1','S4 frontend consolidation':'P7 / S4',
    'Phase8 upstream2.0.32':'P8','Phase15':'P15','Phase16 compact release':'P16',
    'Phase19 shared live checker':'P19','Phase22 contextual frontend':'P22',
    'Phase23 upstream2.0.34':'P23','Phase24':'P24'}
selected_z=[dict(r,chartLabel=selected_labels[r['label']]) for r in zrows if r['label'] in selected_labels]
labels={9:'P9 · repeated scans',11:'P11 · branch allocation',16:'P16 · compact literals',
    22:'P22 · contextual frontend',24:'P24 · local lookup'}
data=dict(schema=1,head=s['head'],status='Agent-generated report prepared for publication',
    checking=[r for r in checking if r['phase'] not in [20,21]],
    paired=[dict(r,label=labels[r['phase']]) for r in checking if r['phase'] in labels],
    conformance=[r for r in main if r['phase'] not in [7,11]],
    broader=c['broader_frontend'],complexity=selected_z,
    complexity_baseline=next(r for r in zrows if r['label']=='Phase5 / simplification baseline'),
    historical_scope=s['legacy_context_separate_panels'],
    developer_loop=s['developer_loop_observations'],emitted_code=s['emitted_program_evidence'],
    notes=['Each speed point has an internally identical workload across its lanes; source and harness boundaries change between points.',
           'Zero exact differences is not complete language, backend, kernel or platform conformance.',
           'Compiler core source membership is historical compiler.json, excluding host/runtime/tools/generated material.',
           'No controlled longitudinal emitted-program execution-speed series is available.'])
(HERE/'chart-data.json').write_text(json.dumps(data,indent=2)+'\n')
csv_write('checking-history.csv',checking,['phase','commit','date','upstream','compiler_s','ts_s','ratio','baseline_s','baseline_ratio','samples','finding','source'])
csv_write('conformance-history.csv',main,['phase','commit','date','upstream','total','exact','different','source','notes'])
csv_write('complexity-history.csv',zrows,['label','commit','date','upstream','physicalLines','nonblankLines','bytes','defs','laws','types','modules','sourceLink'])
print('Prepared chart-data.json and three source-linked CSV tables.')
