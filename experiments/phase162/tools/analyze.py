#!/usr/bin/env python3
"""Admit observer boundaries and summarize immutable Phase162 observations."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'implementation/phase162';OUT.mkdir(exist_ok=True)
def load(name):return json.loads((ROOT/name).read_text())
def pin(path):
 p=ROOT/path;return dict(file=path,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def write(name,value):(OUT/name).write_text(json.dumps(value,indent=2)+'\n')
def observe(name):
 root='selfhost/build/phase162/'+name;r=load(root+'/report.json');assert r['complete'] and r['outputExact']
 d=load(root+'/counts.json');assert d['total']['gc_alloc_calls']>0
 if r['role']=='bendc':
  t={x['label']:x for x in d['timers']};assert t['parse']['calls']==t['parse']['done']==2 and t['check']['calls']==t['check']['done']==1 and t['report']['calls']==1
  assert t['parse']['counts']['parser_file_eof']==2 and t['parse']['counts']['parser_decl_completed']==t['check']['counts']['checker_jobs_attempted']==8761
  stages=[dict(stage=x['label'],cpuSeconds=x['cpuNs']/1e9,counts=x['counts']) for x in d['timers']]
 else:
  m=d['markers'];assert [x['label'] for x in m]==['parse_begin','check_begin','check_end_report_begin','report_end']
  assert [x['order'] for x in m]==[1,2,3,4] and all(x['calls']==1 for x in m)
  stages=[dict(stage=label,cpuSeconds=(b['cpuNs']-a['cpuNs'])/1e9,counts={k:b['counts'][k]-a['counts'][k] for k in a['counts']}) for label,a,b in zip(['parse_load','check_publication','proof_report'],m,m[1:])]
 return dict(report=pin(root+'/report.json'),counts=pin(root+'/counts.json'),diagnosticWallSeconds=r['process']['wallSeconds'],stages=stages,total=d['total'])
rows={name:observe(name) for name in ['bendc-diag-full02','ours-diag-map02','ours-diag-full02']}
if (ROOT/'selfhost/build/phase162/ours-diag-publication02/counts.json').exists():
 rows['ours-diag-publication02']=observe('ours-diag-publication02')
 old=rows['ours-diag-full02'];new=rows['ours-diag-publication02']
 for i in [0,2]:
  for key in ['gc_alloc_calls','gc_requested_words']:assert old['stages'][i]['counts'][key]==new['stages'][i]['counts'][key]
 for key in ['index_remove_rows','constructor_exists_rows']:assert old['stages'][1]['counts'][key]==new['stages'][1]['counts'][key]
clean={}
for name in ['parse-full01','check-full01','check-original01']:
 d=load('selfhost/build/phase162/'+name+'/report.json');clean[name]=dict(report=pin('selfhost/build/phase162/'+name+'/report.json'),process=d.get('process',d))
write('operation-metrics.json',dict(complete=True,observations=rows,clean=clean,scope='Counter clocks are diagnostic. Bendc parse/check includes Base; ours begins after Base preparation. Counts are logical executed sites, not machine instructions, system allocations, or RSS. Ours C02 uses BEND_UNBOX=0; bendc seed uses its parent representation. Do not sum nested/overlapping counters.'))
r=load('selfhost/build/phase162/unsafe-control01/report.json');p=r['process']
expected=b'SOME PROOFS FAIL\nError:\n- expected : U32\n- observed : Bool\nLocation: main\n3 | def main() -> U32:\n4>|   True{}\n  |   ^^^^^^\n5 | \n'
assert p['returncode']==1 and not p['timedOut'] and p['stdout']['bytes']==0 and Path(p['stderr']['file']).read_bytes()==expected
write('control-admission.json',dict(complete=True,originalObserverPassed=False,original=pin('selfhost/build/phase162/unsafe-control01/report.json'),stderr=p['stderr'],fixture=pin('selfhost/tests/phase162/unsafe-type-error.bend'),expected=expected.decode(),conclusion='Correctly rejects ill-typed body under @unsafe. Original runner incorrectly treated common proof-status prefix as a type-error rejection; original failed receipt is unchanged.',method=pin('experiments/phase162/tools/analyze.py')))
u=load('selfhost/build/phase162/bendc-diag-unsafe02/report.json');c=load('selfhost/build/phase162/bendc-diag-unsafe02/counts.json')
assert u['complete'] and u['outputExact'] and [(t['calls'],t['done']) for t in c['timers']]==[(2,2),(1,0),(0,0)]
write('observer-controls.json',dict(complete=True,negative=pin('selfhost/build/phase162/bendc-diag-unsafe02/report.json'),counts=pin('selfhost/build/phase162/bendc-diag-unsafe02/counts.json'),checks=['Full input: both parses Done; all8761jobs attempted; checker Done; exact unsafe verdict.','Ill-typed @unsafe: both parses Done, checker not Done, no proof-report call, exact128-byte error.','Our Map/full/publication: four once-only ordered stage markers, nonzero allocations, complete exact QBE.','Publication preserves parse/report logical allocation and word counts; index-remove/constructor-scan work unchanged.'],notRun=['Additional unsafe-valid and parse-error fixtures are supplied but were not executed.']))
print(json.dumps({name:[(s['stage'],s['cpuSeconds'],s['counts']['gc_alloc_calls']) for s in d['stages']] for name,d in rows.items()}))
