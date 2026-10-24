#!/usr/bin/env python3
"""Reanalyze retained historical owner/physical-leaf intersections; no targets."""
import argparse,collections,json,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[5];sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
from run import pin,verify,save
from owners import decoded_symbol

def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'implementation/phase136')
 summary_path=ROOT/'implementation/phase131/full-context-results.json';summary=json.loads(summary_path.read_text());full_path=verify(summary['fullAnalysis']);r=json.loads(full_path.read_text());tpath=verify(r['timeline']);timeline=json.loads(tpath.read_text());matrix=r['ownerLeafMatrix'];n=r['samples'];assert r['complete']and n==sum(x['samples']for x in matrix)
 def leaf(row):return decoded_symbol(row['leafSymbol']or'')or row['leafSymbol']or'[unknown]'
 selectors={'dropAndFade':lambda s:s in('term_drop','span_fade'),'borrowedStringEquality':lambda s:'$p118borrow.read.p88_string_eq_go'in s,'runtimeTake':lambda s:s.startswith('p125_rt_take')or s=='p111_rt_take','runtimeKeepSink':lambda s:s in('p111_rt_keep','p111_rt_sink')}
 rows=[]
 for name in ['nc_ctor_owned','lookup','f_find','has_name','p111v_get','index_remove']:
  current=[x for x in matrix if x['dispatchLoweredOwner']==name];count=sum(x['samples']for x in current);counts={k:sum(x['samples']for x in current if pred(leaf(x)))for k,pred in selectors.items()};top=collections.Counter()
  for x in current:top[leaf(x)]+=x['samples']
  rows.append(dict(owner=name,samples=count,fractionOfAll=count/n,physicalIntersections={k:dict(samples=v,fractionOfAll=v/n,fractionOfOwner=v/count)for k,v in counts.items()},topLeaves=[dict(leaf=k,samples=v)for k,v in top.most_common(8)]))
 windows=[dict(index=w['index'],approximateCpuStartSeconds=w.get('approximateCpuStartSeconds'),approximateCpuEndSeconds=w.get('approximateCpuEndSeconds'),samples=w['samples'],topActiveOwners=w['topActiveOwners'],topPhysicalLeaves=w['topPhysicalLeaves'])for w in timeline['windows']]
 evidence=[pin(__file__),pin(summary_path),pin(full_path),pin(tpath),r['originalN2'],r['diagnosticImage'],r['source']]
 for v in evidence:verify(v)
 result=dict(complete=True,targetsRun=False,kind='phase136-historical-profile-reanalysis',inputs=evidence,historicalPhase=131,totalSamples=n,quality=r['quality'],rows=rows,windows=windows,scope='Historical source/image only. Physical intersections are subsets of active contexts, never added as separate time. Timeline is approximate sampled-thread CPU order; no exact Phase135/136 frontend wall-stage attribution, allocation counts, causal speedup or recurrence frequency.')
 out.mkdir(parents=True);save(out/'historical.json',result)
 lines=['# Historical native lookup evidence','',result['scope'],'','| Active owner | All samples | Drop/fade within owner | Drop/fade of all samples | Borrowed equality of all samples |','|---|---:|---:|---:|---:|']
 for row in rows:
  d=row['physicalIntersections']['dropAndFade'];e=row['physicalIntersections']['borrowedStringEquality'];lines.append(f"| `{row['owner']}` | {100*row['fractionOfAll']:.2f}% | {100*d['fractionOfOwner']:.2f}% | {100*d['fractionOfAll']:.2f}% | {100*e['fractionOfAll']:.2f}% |")
 lines+=['','These intersections explain the shape of each active computation. They do not identify the original allocation site, distinguish reference decrements from actual frees, or prove that a cache can eliminate the entire context.','', '| Approximate sampled CPU window | Leading active owners |','|---|---|']
 for w in windows:
  top=', '.join(f"`{x['owner']or'[unknown]'}` {100*x['fractionOfWindow']:.1f}%"for x in w['topActiveOwners'][:3]);lines.append(f"| {w['approximateCpuStartSeconds']:.0f}–{w['approximateCpuEndSeconds']:.0f}s | {top} |")
 lines+=['','Early `f_find` and `lookup` concentration supports profiling parsing/name resolution first. The later repeated `nc_ctor_owned` appearances show that ownership queries cross boundaries; a table attached only before private lowering can miss earlier work. Neither observation assigns samples to measured frontend sub-stages.','']
 (out/'historical.md').write_text('\n'.join(lines));print(json.dumps(dict(complete=True,targetsRun=False,report=pin(out/'historical.json'))))
if __name__=='__main__':main()
