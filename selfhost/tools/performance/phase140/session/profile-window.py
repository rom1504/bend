#!/usr/bin/env python3
"""Bounded offline warm-window diagnostic from a completed two-revision capture.

No target runs. Time coordinates are sample ordinals, not measured timestamps.
"""
import argparse, collections, hashlib, json, math
from pathlib import Path

def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['receipt','analysis','out']:ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();r=read(a.receipt);x=read(a.analysis);h=x['header'];q=x['quality']
 assert r['complete'] and r['diagnostic'] and r['independentProductsExact'] and len(r['jobs'])==2
 assert r['jobs'][0]['mode']=='cold' and r['jobs'][1]['mode']=='warm'
 assert q['zero_loss'] and q['handler_intact'] and q['delivery_plausible'] and q['near_complete_process_cpu_coverage']
 assert pin(r['samples']['file'])==r['samples']==x['identities']['capture']
 assert x['identities']['binary'] in r['inputs'] and pin(x['identities']['binary']['file'])==x['identities']['binary']
 # All recorded wall intervals are inside the constructor-to-destructor capture.
 # CPU cannot advance faster than wall time. Unknown process gaps are left in
 # conservative bounds, not assigned to a preferred compiler stage.
 wall=h['wall_ns']/1e9;cpu=h['main_thread_cpu_ns']/1e9;deficit=wall-cpu
 known=(r['prepareMs']+sum(j['ioMs']+j['stages']['totalMs']for j in r['jobs']))/1000
 assert wall>=known and deficit>=0
 start_latest=wall-r['jobs'][1]['stages']['totalMs']/1000
 end_earliest=known-deficit
 # One-second margins cover ms clock rounding and ordinary sampling jitter.
 # This remains approximate attribution, not a timestamped phase trace.
 lo=math.ceil(start_latest+1);hi=math.floor(end_earliest-1);assert hi>lo
 lines=Path(r['samples']['file']).read_text().splitlines();pcs=lines[lines.index('PCS')+1:-1]
 assert len(pcs)==h['samples']
 period=h['period_us']/1e6;begin=math.ceil(lo/period);end=math.floor(hi/period)
 rows={int(v['pc'],16):v for v in x['pcs']};counts=collections.Counter();groups=collections.Counter()
 for pc in pcs[begin:end]:
  v=rows[int(pc,16)];counts[v.get('decoded')or v.get('symbol')or '['+v['category']+']']+=1;groups[v['group']]+=1
 n=sum(counts.values());assert n==end-begin
 rank=lambda c:[dict(name=k,samples=v,percent=v/n*100)for k,v in c.most_common()]
 out=dict(kind='phase140-approximate-warm-cpu-window',complete=True,inputs=[pin(__file__),pin(a.receipt),pin(a.analysis),r['samples'],x['identities']['binary']],
  bounds=dict(captureWallSeconds=wall,captureMainCpuSeconds=cpu,wallMinusCpuSeconds=deficit,knownWallSeconds=known,warmStartLatestWallSeconds=start_latest,warmEndEarliestCpuSeconds=end_earliest,selectedCpuOrdinalSeconds=[lo,hi],sampleStart=begin,sampleEndExclusive=end),samples=n,groups=rank(groups),functions=rank(counts),
  scope='Approximate warm-window physical leaf counts. Bounds conservatively include all unknown process gaps; one-second margins cover ordinary jitter, not a formal guarantee. Constructor clocks precede native stage clocks. No loss/overrun and near-complete main-thread coverage required. No exact phase timestamps, active caller attribution, additive optimization ceiling or clean speed claim.')
 assert not a.out.exists();a.out.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(dict(bounds=out['bounds'],samples=n,groups=out['groups'],top=out['functions'][:12])))
if __name__=='__main__':main()
