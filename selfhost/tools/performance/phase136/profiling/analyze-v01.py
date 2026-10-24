#!/usr/bin/env python3
"""Offline exact-image physical/context attribution for the planned full sample."""
import argparse,collections,json,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.dont_write_bytecode=True;sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from attribute import attribute
from compare import capture_reasons
import timeline

def read(p):return json.loads(pathlib.Path(p).read_text())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--profile',type=pathlib.Path,required=True);ap.add_argument('--out',type=pathlib.Path,required=True);a=ap.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase136')
 manifest=read(a.profile/'manifest.json');rp=a.profile/'capture/report.json';r=read(rp);assert r['complete']and r['passed']and len(r['rows'])==1 and not r['changedInputs'];row=r['rows'][0]
 assert row['mode']=='sample'and row['periodUs']==32000 and row['correct']and row['diagnosticRuntime']and'events'not in row
 analysis_path=verify(row['analysis']);analysis=read(analysis_path);owners=verify(manifest['ownerMap']);contexts=verify(row['contexts']);callers=verify(row['callers']);table=verify(manifest['unwindTable'])
 joined,events=attribute(analysis_path,callers,table,contexts,owners);assert joined['pairing']['verified']and joined['pairing']['correct']and joined['contextHeader']['context_available'];assert joined['identities']['binary']==manifest['diagnosticImage']
 owners_count=collections.Counter();leaves=collections.Counter();by_owner=collections.defaultdict(collections.Counter)
 for e in events:
  owner=e.get('dispatchContext',{}).get('loweredOwner')or'[unknown]';leaf=e['leaf'].get('decoded')or e['leaf'].get('symbol')or'[unknown]';owners_count[owner]+=1;leaves[leaf]+=1;by_owner[owner][leaf]+=1
 total=len(events);selected=[]
 for owner in ['f_find','lookup','nc_ctor_owned','has_name','index_remove','p111v_get']:
  counts=by_owner[owner];n=sum(counts.values());rc=sum(v for k,v in counts.items()if k in('term_drop','span_fade'));eq=sum(v for k,v in counts.items()if'$p118borrow.read.p88_string_eq_go'in k)
  selected.append(dict(owner=owner,samples=n,fractionOfAll=n/total,dropAndFade=dict(samples=rc,fractionOfAll=rc/total,fractionOfOwner=rc/n if n else None),borrowedEquality=dict(samples=eq,fractionOfAll=eq/total,fractionOfOwner=eq/n if n else None),topLeaves=[dict(leaf=k,samples=v)for k,v in counts.most_common(10)]))
 sequence=timeline.windows(events,analysis['header'],joined,window_cpu_seconds=30,top=8);sequence.update(identities=joined['identities'],pairing=joined['pairing'],quality=joined['quality'])
 out.mkdir(parents=True);save(out/'attribution.json',joined);save(out/'timeline.json',sequence);(out/'timeline.md').write_text(timeline.markdown(sequence))
 inputs=[pin(__file__),pin(rp),pin(a.profile/'manifest.json'),row['analysis'],row['contexts'],row['callers'],manifest['ownerMap'],manifest['unwindTable'],pin(PROF/'attribute.py'),pin(PROF/'timeline.py')]
 for p in inputs:verify(p)
 result=dict(kind='phase136-qualified-n2-full-profile-analysis',complete=True,targetsRun=False,inputs=inputs,lineage=manifest['lineage'],diagnosticImage=manifest['diagnosticImage'],observation={k:row[k]for k in ['wallSeconds','cpuSeconds','peakRssKiB','stdout','stderr']},countersEnabled=False,cleanObservations=0,newSpeedRatio=None,samples=total,qualityReasons=capture_reasons(analysis),quality=joined['quality'],callerCoverage=joined['coverage'],topActiveOwners=[dict(owner=k,samples=v,fractionOfAll=v/total)for k,v in owners_count.most_common(40)],topPhysicalLeaves=[dict(leaf=k,samples=v,fractionOfAll=v/total)for k,v in leaves.most_common(40)],selectedOwnerLeafIntersections=selected,attribution=pin(out/'attribution.json'),timeline=pin(out/'timeline.json'),scope='One sample-only exact-output ordinary request. Active contexts include synchronous private calls; intersections are subsets, never additive phase costs. CPU windows are approximate sample order, not wall stage boundaries. No allocation counts, original allocation sites, cache recurrence, clean speedup or profiler overhead claim.')
 save(out/'report.json',result);print(json.dumps(dict(complete=True,targetsRun=False,samples=total,qualityReasons=result['qualityReasons'],report=pin(out/'report.json'),top=result['topActiveOwners'][:8])))
if __name__=='__main__':main()
