"""Data-only joins of closed relink and fixed-batch observations."""
import importlib.util
from pathlib import Path
import statistics

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('relink',HERE/'relink-v01.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
spec=importlib.util.spec_from_file_location('batch',HERE/'batch-relink-v01.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
root=M.ROOT;raw=M.RAW
paths={n:raw/p/'report.json' for n,p in [('safety','relink-safety01'),('full','relink-full01'),('batches','batch-relink01')]}
reports={n:M.read(p)for n,p in paths.items()}
safety,full,batches=[reports[n]for n in ['safety','full','batches']]
M.require(all(r['complete']for r in reports.values())and safety['passed']and full['passed'],'Campaign incomplete')
plan=M.read(M.verify(full['plan']));bp=M.read(M.verify(batches['plan']))
M.require(M.same(full['plan'],safety['plan'])and M.same(full['safetyReceipt'],M.pin(paths['safety']))and M.same(batches['semanticQualification'],M.pin(paths['full'])),'Receipt linkage differs')
M.require(M.same(bp['semanticPlan'],full['plan'])and M.same(plan['method'],M.pin(M.__file__))and M.same(bp['method'],M.pin(B.__file__)),'Methods or plans differ')
for item in plan['inputs']+bp['inputs']:M.verify(item)
jobs=safety['jobs']+full['jobs'];by_label={j['label']:j for j in jobs}
M.require(len(jobs)==len(by_label)==247 and len(full['cases'])==61 and len(safety['cases'])==6,'Wrong semantic counts')
M.require({c['id']for c in full['cases']}=={c['id']for c in plan['cases']},'Semantic case set differs')
for c in full['cases']:
    case=next(x for x in plan['cases']if x['id']==c['id'])
    expected=M.verify(case['expectedStdout']).read_bytes()
    M.require(c['passed']and M.same(c['object'],case['object'])and M.same(c['expected'],case['expectedStdout']),'Semantic object/oracle differs')
    for role in ['atomic','serial']:
        binary=M.verify(c['images'][role]);link=by_label[c['id']+'-'+role+'-link'];execute=by_label[c['id']+'-'+role+'-execute']
        M.require(link['command']==[plan['cc']['canonicalPath'],'-no-pie',case['object']['file'],plan['runtimes'][role]['file'],'-pthread','-lm','-o',str(binary)],'Link command differs')
        M.require(execute['command']==[str(binary)]+plan['executionArgs'],'Execution policy differs')
        for job,wanted in [(link,b''),(execute,expected)]:
            M.require(job['passed']and not job['timedOut']and job['exitCode']==0 and M.verify(job['stdout']).read_bytes()==wanted and M.verify(job['stderr']).read_bytes()==b'','Semantic output differs')
M.require(safety['refusals']==full['refusals']and len(safety['refusals'])==3,'CLI refusal count differs')
for job in safety['refusals']:
    M.require(job['passed']and job['exitCode']==1 and not job['timedOut']and M.verify(job['stdout']).read_bytes()==b''and M.verify(job['stderr']).read_bytes()==b'bend: Phase111 ABI v1 requires --threads 1 --gpu off\n','CLI refusal differs')
M.require(len(batches['rows'])==48 and len(batches['jobs'])==56,'Batch coverage differs')
summary=[]
for c in bp['cases']:
    rows=[r for r in batches['rows']if r['name']==c['name']]
    values={role:[]for role in ['atomic','serial']}
    for role in values:
        binary=batches['images'][c['name']][role];M.verify(binary)
        link=next(j for j in batches['jobs']if j['label']=='link-'+c['name']+'-'+role)
        M.require(link['command']==[bp['cc']['canonicalPath'],'-no-pie',c['object']['file'],bp['runtimes'][role]['file'],'-pthread','-lm','-o',binary['file']],'Batch link differs')
        M.require(link['status']==0 and not link['timedOut']and M.verify(link['stdout']).read_bytes()==M.verify(link['stderr']).read_bytes()==b'','Batch link failed')
        for rnd in range(6):
            matches=[r for r in rows if r['role']==role and r['round']==rnd];M.require(len(matches)==1,'Missing unique pair member');row=matches[0];job=batches['jobs'][row['job']]
            M.require(row['correct']and M.same(row['binary'],binary)and job['command']==[binary['file']]+c['args']and not job['timedOut'],'Batch row binding differs')
            elapsed=B.O.observation(M.verify(job['stdout']).read_bytes(),M.verify(job['stderr']).read_bytes(),job['status'],c,job['wallSeconds'])
            M.require(elapsed==row['elapsedMs']and job['wallSeconds']==row['wallSeconds'],'Elapsed observation differs');values[role].append(elapsed)
    medians={role:statistics.median(v)for role,v in values.items()}
    summary.append(dict(name=c['name'],samplesMs=values,mediansMs=medians,serialOverAtomic=medians['serial']/medians['atomic'],serialFasterPairs=sum(a<b for a,b in zip(values['serial'],values['atomic'])),pairs=6,allSamplesAtLeast20ms=min(v for a in values.values()for v in a)>=20))
result=dict(kind='phase144-relink-runtime-observations-v01',complete=True,targetsRun=False,method=M.pin(__file__),
    reports={n:M.pin(p)for n,p in paths.items()},semanticPlan=full['plan'],batchPlan=batches['plan'],
    semanticCases=61,ordinaryExecutions=122,runtimeCliRefusals=3,historicalCompilerRefusalsNotRerun=3,
    batchCases=4,batchObservations=48,batchSummary=summary,
    semanticsSeconds=dict(safety=safety['seconds'],remaining=full['seconds']),batchCampaignSeconds=batches['seconds'],
    scope='Fresh runtime-only relinks. Phase14361 program objects pass complete original oracles. Four Phase131 fixed-work objects isolate runtime performance. Helper/lifetime/source proof/real-file IO and compiler throughput are separate evidence; no installed/default promotion.',
    interpretation='Map and record results are approximately flat; BST and Unicode show modest lower medians. Later rounds slow in both roles. No general generated-program or compiler-throughput speedup is established by these four selected workloads.')
out=root/'implementation/phase144/serial-rfc-relink-results.json';M.require(not out.exists(),'Fresh summary required');M.save(out,result);print(M.pin(out))
