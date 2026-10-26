#!/usr/bin/env python3
"""Offline final03 profile analysis, preserving all three different engines."""
import importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('prior_summary',HERE/'integrated-summary-v2.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
from run import pin,verify

def main():
 out=ROOT/'research/phase144/final-profile.json';assert not out.exists()
 prior=previous.read('research/phase144/integrated-profile-v2.json')
 stage,events,current=previous.load('selfhost/build/phase144/final03-stages01/capture-stages.json',
     'selfhost/build/phase144/final03-stages01/capture/report.json','selfhost/build/phase144/final03-stages01/spec.json')
 cold_path=ROOT/'selfhost/build/phase130/p144-final03-fixed-cold01/report.json';cold=previous.read(cold_path)
 build_path=ROOT/'selfhost/build/phase134/p144-final03-n2/report.json';build=previous.read(build_path)
 runtime_plan_path=ROOT/'selfhost/build/phase144/final03-stages01/runtime/plan-reuse.json';runtime_plan=previous.read(runtime_plan_path)
 actual_build_path=ROOT/'selfhost/build/phase144/final03-stages01/build/report.json';actual_build=previous.read(actual_build_path)
 assert cold['complete'] and cold['exitCode']==0 and not cold['changedInputs'] and cold['image']==build['binary']
 assert all(cold['product'][k]==current['row']['stdout'][k] for k in ['sha256','bytes'])
 assert actual_build['complete'] and actual_build['plan']==pin(runtime_plan_path)
 assert actual_build['jobs'][0]['command']==runtime_plan['jobs'][0]['command'] and '-DP144_SINGLE_MUTATOR_RFC=1' in actual_build['jobs'][0]['command']
 assert actual_build['jobs'][1]['command'][2]==build['object']['file']
 for p in [cold['image'],cold['source'],cold['product'],build['runtime'],build['object']]:verify(p)
 n=len(events);active=previous.counts(events,'active');physical=previous.counts(events,'physical');caller=previous.counts(events,'caller')
 intervals=[]
 for old,now in zip(prior['intervals'],stage['intervals'][:23]):
  assert old['label']==now['label']
  chunk=events[now['sampleStartInclusive']:now['sampleEndExclusive']]
  intervals.append(dict(label=now['label'],phase143Seconds=old['before'],source01AtomicSeconds=old['after'],
    final03SerialSeconds=now['wallSeconds'],deltaVsSource01=now['wallSeconds']-old['after'],
    samples=now['samples'],quantitativeProfileAdmitted=now['quantitativeProfileAdmitted'],
    active=previous.rows(previous.counts(chunk,'active'),len(chunk)) if chunk else [],
    physical=previous.rows(previous.counts(chunk,'physical'),len(chunk)) if chunk else []))
 partitions=[(0,1),(1,10),(10,14),(14,16),(16,19),(19,20),(20,22),(22,23)]
 groups=[]
 for old,(start,end) in zip(prior['groups'],partitions):
  new=sum(x['final03SerialSeconds'] for x in intervals[start:end]);groups.append(dict(label=old['label'],phase143Seconds=old['before'],source01AtomicSeconds=old['after'],final03SerialSeconds=new,deltaVsSource01=new-old['after'],shareOfFinalStageTime=new/sum(x['final03SerialSeconds'] for x in intervals)))
 active_groups=[]
 for g in prior['activeGroups']:
  names=set(g['actualNames'])
  for prefix in ['p111v','p113k']:
   if g['label'].startswith(prefix):names.update(k for k in active if k and k.startswith(prefix+'_'))
  if g['label'].startswith('p131i'):names.update(k for k in active if k and k.startswith(('p131i_','index_')))
  count=sum(active[name] for name in names)
  active_groups.append(dict(label=g['label'],names=sorted(names),phase143Samples=g['beforeSamples'],source01Samples=g['afterSamples'],final03Samples=count,final03Fraction=count/n,final03SampledPeriodSeconds=count*.032))
 owner_changes=[]
 for r in prior['activeComparison']:owner_changes.append(dict(name=r['name'],phase143Samples=r['before'],source01Samples=r['after'],final03Samples=active[r['name']]))
 def select_counts(where):
  chunk=[e for e in events if where(e)];return dict(samples=len(chunk),physical=previous.rows(previous.counts(chunk,'physical'),len(chunk),30) if chunk else [])
 append=select_counts(lambda e:(e.get('dispatchContext')or{}).get('loweredOwner')=='String.append')
 physical_groups=[]
 for g in prior['physicalGroups']:
  names=set(g['actualNames']);count=sum(physical[name] for name in names)
  physical_groups.append(dict(label=g['label'],names=sorted(names),phase143Samples=g['beforeSamples'],source01Samples=g['afterSamples'],final03Samples=count,final03Fraction=count/n))
 summary=dict(kind='phase144-final03-serial-profile-summary-v1',complete=True,targetsRun=False,
  inputs=[pin(__file__),pin(HERE/'integrated-summary-v2.py'),pin(ROOT/'research/phase144/integrated-profile-v2.json'),pin(cold_path),pin(build_path),pin(runtime_plan_path),pin(actual_build_path)],
  phase143=prior['before'],source01Atomic=prior['after'],final03Serial=current,groups=groups,intervals=intervals,
  nestedFinal=stage['intervals'][-1],activeFamilies=active_groups,physicalFamilies=physical_groups,ownerChanges=owner_changes,
  stringAppendPhysical=append,registerBank=dict(direct=physical['p111_set_regs'],recoveredLibc=caller['p111_set_regs'],fraction=(physical['p111_set_regs']+caller['p111_set_regs'])/n),
  concatPhysical=select_counts(lambda e:'concat' in (e['leaf'].get('decoded')or e['leaf'].get('symbol')or'')),
  unknown=dict(activeOwner=active[None],physicalFunction=physical[None]),
  clean=dict(receipt=pin(cold_path),nativeSeconds=cold['nativeSeconds'],source=cold['source'],product=cold['product'],actualLinkedRuntime=build['runtime'],diagnosticOverClean=current['row']['wallSeconds']/cold['nativeSeconds']),
  limits=['Three engines differ in compiler source/runtime/code shape; intervals are descriptive, not isolated treatment effects.',
   'All profiles compile the same frozen Phase142 input; final03 emits changed QBE with its own same-image clean replay oracle.',
   'Final03 serial profile is not evidence about proposed final04, its range-pass omission, append removal or batch optimization.',
   'Physical leaves overlap active owners and stage clocks; sample-period equivalents are diagnostic, not predicted clean savings.',
   'The optional final verifier is nested; short intervals and individual low-count owners remain descriptive.',
   'A caller context is not a logical ancestry stack and cannot identify dynamic concat success/refusal frequencies.'])
 out.write_text(json.dumps(summary,indent=2)+'\n')
 print(json.dumps(dict(output=str(out),groups=groups,physical=physical_groups,active=active_groups,register=summary['registerBank'],concat=summary['concatPhysical'],clean=summary['clean']),indent=2))
if __name__=='__main__':main()
