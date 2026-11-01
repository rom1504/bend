#!/usr/bin/env python3
"""Offline stage ranking for a completed Phase147 capture; no target execution."""
import argparse, hashlib, json
from pathlib import Path

def pin(p):
    p=Path(p).resolve();h=hashlib.sha256()
    with p.open('rb')as f:
        for b in iter(lambda:f.read(1<<20),b''):h.update(b)
    return {'file':str(p),'bytes':p.stat().st_size,'sha256':h.hexdigest()}
def read(p):return json.loads(Path(p).read_text())
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--capture',required=True,type=Path);ap.add_argument('--out',required=True,type=Path);a=ap.parse_args();root=a.capture.resolve();out=a.out.resolve()
    if out.exists():raise ValueError('Fresh output directory required')
    stage=read(root/'stages.json');run=read(root/'capture/report.json');summary=read(root/'summary.json')
    if not(stage['complete'] and stage['stageAttributionValid'] and run['complete'] and run['passed'] and not run['changedInputs']):raise ValueError('Complete immutable stage and exact-output capture required')
    if len(run['rows'])!=1:raise ValueError('One current diagnostic capture expected')
    row=run['rows'][0];analysis=read(row['analysis']['file']);header=analysis['header']
    intervals=summary['exclusiveIntervals'];total=sum(r['threadCpuSeconds']for r in intervals if r['available']);assigned=sum(r['samples']for r in intervals if r['available'])
    ranked=[]
    for r in intervals:
        if not r['available']:raise ValueError('Exclusive stage unavailable: '+r['label'])
        ranked.append({**r,'fractionOfStagedThreadCpu':r['threadCpuSeconds']/total,'fractionOfAllSamples':r['samples']/stage['samples'] if stage['samples'] else None})
    ranked.sort(key=lambda r:r['threadCpuSeconds'],reverse=True)
    result={'kind':'phase147-current-native-stage-summary','complete':True,'targetsRun':False,'inputs':[pin(__file__),pin(root/'stages.json'),pin(root/'capture/report.json'),pin(root/'summary.json'),pin(row['analysis']['file'])],'source':summary['source'],'diagnosticWallSeconds':row['wallSeconds'],'diagnosticProcessCpuSeconds':row['cpuSeconds'],'stagedThreadCpuSeconds':total,'stageCpuShareOfSampledThread':total/(header['main_thread_cpu_ns']/1e9),'totalSamples':stage['samples'],'exclusiveSamples':assigned,'boundaryAndOutsideStageSamples':stage['samples']-assigned,'quality':stage['quality'],'rankedExclusiveStages':ranked,'optionalIntervals':[r for r in stage['intervals']if '(nested)'in r['label']],'interpretation':['Times are diagnostic; pipeline clean build times are not comparable standalone timings.','Physical leaves and active lowered owners are alternative views, never additive.','Within-stage distributions are quantitative only when the original stage quality gate admits them.','No call counts, source-level logical stack or causal speedup follows from samples.','Nested intervals excluded from ranked totals; edge/prelude/exit samples remain unassigned.']}
    clean=root/'clean.json'
    if clean.exists():
        c=read(clean);result['separateSelectedClean']=pin(clean);result['singlePairDiagnosticOverCleanWall']=row['wallSeconds']/c['wallSeconds']
    out.mkdir(parents=True);(out/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Native compiler diagnostic stage profile','',f"Diagnostic request: {row['wallSeconds']:.3f}s wall; {stage['samples']:,} samples; {assigned:,} assigned after boundary exclusions.",'', '| Stage | Thread CPU seconds | Share of staged CPU | Samples | Quantitative samples? |','|---|---:|---:|---:|---|']
    for r in ranked:lines.append(f"| {r['label']} | {r['threadCpuSeconds']:.3f} | {100*r['fractionOfStagedThreadCpu']:.1f}% | {r['samples']} | {'yes'if r['quantitativeProfileAdmitted']else'no'} |")
    for r in ranked[:6]:
        lines+=['',f"## {r['label']}",'',f"{r['threadCpuSeconds']:.3f}s thread CPU; sample evidence is {'admitted'if r['quantitativeProfileAdmitted']else'descriptive only'}.",'']
        for field,label in [('topActiveOwners','Active lowered owners'),('topPhysicalLeaves','Physical leaves')]:
            names=', '.join(f"`{x['name']}` {x['samples']} ({100*x['fractionOfAllSamples']:.1f}%)"for x in r[field][:6]);lines.append(label+': '+names+'.');lines.append('')
    lines+=['Interpretation: '+ ' '.join(result['interpretation']),''];(out/'report.md').write_text('\n'.join(lines))
    print(json.dumps({'complete':True,'out':str(out),'topStages':[(r['label'],r['threadCpuSeconds'])for r in ranked[:6]]}))
if __name__=='__main__':main()
