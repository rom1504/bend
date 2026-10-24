"""Summarize retained clean selector measurements and internal milliseconds; no runs."""
from pathlib import Path
import argparse,hashlib,json,statistics
H=Path(__file__).resolve().parent;R=H.parents[5]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists()
report=R/'selfhost/build/phase131/selector-ceiling-timed02/report.json';manifest=R/'selfhost/build/phase131/selector-ceiling-timing02/manifest.json';d=json.loads(report.read_text());m=json.loads(manifest.read_text());assert d['complete']and d['passed']and len(d['rows'])==12
rows=[];groups=[]
for r in d['rows']:
 assert r['correct']and r['returncode']==0 and r['mode']=='clean'and not r['diagnosticRuntime']
 stdout=Path(r['stdout']['file']);assert pin(stdout)==r['stdout'];lines=stdout.read_text().splitlines();assert len(lines)==3 and lines[0]=='1';count=int(r['command'][-1]);assert int(lines[1])==count
 rows.append(dict(workload=r['workload'],variant=r['variant'],round=r['round'],repetitions=count,wallMilliseconds=r['wallSeconds']*1000,cpuMilliseconds=r['cpuSeconds']*1000,internalMilliseconds=int(lines[2]),peakRssKiB=r['peakRssKiB'],correct=r['correct'],stdout=r['stdout']))
for w in ['selector-bucket1','selector-bucket64']:
 old={r['round']:r for r in rows if r['workload']==w and r['variant']=='original'};new={r['round']:r for r in rows if r['workload']==w and r['variant']=='fused'};assert len(old)==len(new)==3
 def stats(rs,field):
  vs=[r[field]for r in rs.values()];return dict(median=statistics.median(vs),minimum=min(vs),maximum=max(vs),samples=vs)
 metrics={role:{field:stats(rs,field)for field in ['wallMilliseconds','cpuMilliseconds','internalMilliseconds','peakRssKiB']}for role,rs in [('original',old),('fused',new)]}
 paired=[dict(round=i,wallRatio=new[i]['wallMilliseconds']/old[i]['wallMilliseconds'],internalRatio=new[i]['internalMilliseconds']/old[i]['internalMilliseconds'])for i in old]
 groups.append(dict(workload=w,repetitions=old[1]['repetitions'],metrics=metrics,wallMedianRatio=metrics['fused']['wallMilliseconds']['median']/metrics['original']['wallMilliseconds']['median'],cpuMedianRatio=metrics['fused']['cpuMilliseconds']['median']/metrics['original']['cpuMilliseconds']['median'],paired=paired,anyInternalUnder100ms=any(r['internalMilliseconds']<100 for r in [*old.values(),*new.values()]),pilotTarget500msAchieved=metrics['fused']['internalMilliseconds']['minimum']>=500))
result=dict(schema='phase131-selector-ceiling-summary-v1',complete=True,targetsRun=False,inputs=[pin(__file__),pin(report),pin(manifest),pin(H/'oracle.json'),pin(H/'short-oracle.json'),pin(H/'qualification.json'),pin(H/'static.json'),pin(R/'selfhost/tools/performance/phase131/laws/bucket-evidence.json')],cpuAffinity=d['cpuAffinity'],rounds=3,groups=groups,rows=rows,interpretation={'singleEntry':'Small consistent improvement in this source kernel; all internal loops 104 ms or longer, near minimum useful timing window. Not full compiler or population estimate.','collision64':'Approximately 0.52% median wall improvement; too small for a meaningful broad performance claim. Traversal/ownership still dominate.','nativeWork':'Wrapper 111→7instructions while scalar bucket 272→376 and selector 595→594: projection mostly moves. No borrowed descendant or broad allocation elimination established.','calibration':'Pilot included process/setup cost, so linear scaling undershot 500 ms target, especially single-entry. Report actual times; no repeat requested solely to increase apparent precision.','correctness':'All 4 binaries pass 34-line independent ordinary outputs. Exact bucket fusion law proved over all List<KDef>/String; complete tree selector proof not claimed.','selection':'Experimental source ceiling only; production compiler and qualification unchanged.'})
out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,summary=str(out),groups=[dict(workload=g['workload'],wallReduction=1-g['wallMedianRatio'],minimumInternal=g['metrics']['fused']['internalMilliseconds']['minimum'])for g in groups])))
