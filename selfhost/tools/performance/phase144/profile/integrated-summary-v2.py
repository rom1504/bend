#!/usr/bin/env python3
"""Offline comparison of the two frozen Phase144 full-stage captures."""
import collections, json, sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
import attribute
from run import pin, verify

def read(rel):
    return json.loads((ROOT / rel).read_text())

def counts(events, view):
    if view == 'active':
        return collections.Counter((e.get('dispatchContext') or {}).get('loweredOwner') for e in events)
    if view == 'physical':
        return collections.Counter(e['leaf'].get('decoded') or e['leaf'].get('symbol') for e in events)
    return collections.Counter((e.get('caller') or {}).get('decoded') or (e.get('caller') or {}).get('symbol') for e in events)

def rows(counter, n, limit=30):
    return [dict(name=k, samples=v, fractionOfAllSamples=v/n, sampledPeriodSeconds=v*.032)
            for k, v in counter.most_common(limit)]

def load(stage_rel, run_rel, spec_rel):
    stage, run, spec = read(stage_rel), read(run_rel), read(spec_rel)
    assert stage['complete'] and stage['requestExact'] and stage['stageAttributionValid']
    assert run['complete'] and run['passed'] and not run['changedInputs'] and len(run['rows']) == 1
    row = run['rows'][0]
    assert row['correct'] and row['diagnosticRuntime'] and row['periodUs'] == 32000
    for key in ['analysis', 'profile', 'callers', 'contexts', 'stdout', 'stderr']:
        verify(row[key])
    table = ROOT/'selfhost/build/phase127/libc-unwind01/table.json'
    doc, events = attribute.attribute(row['analysis']['file'], row['callers']['file'], table,
                                      row['contexts']['file'], verify(spec['ownerMap']))
    assert doc['pairing']['verified'] and len(events) == stage['samples']
    analysis = json.loads(Path(row['analysis']['file']).read_text())
    summary = dict(stageReport=pin(ROOT/stage_rel), run=pin(ROOT/run_rel), spec=pin(ROOT/spec_rel),
                   row=row, header=analysis['header'], coverage=doc['coverage'], quality=doc['quality'],
                   ownerBinding=doc['ownerBinding'], pairing=doc['pairing'], objectErrors=doc['objectErrors'],
                   active=rows(counts(events,'active'),len(events),50),
                   physical=rows(counts(events,'physical'),len(events),40),
                   recoveredPhysicalCallers=rows(counts(events,'caller'),len(events),20))
    return stage, events, summary

def main():
    out = ROOT/'research/phase144/integrated-profile-v2.json'
    assert not out.exists(), 'Fresh result required'
    old, oe, os = load('selfhost/build/phase144/stages02/stage-profile.json',
                       'selfhost/build/phase144/stages02/capture/report.json',
                       'selfhost/build/phase144/stages02/stage-plan.json')
    new, ne, ns = load('selfhost/build/phase144/integrated-stages01/capture-stages.json',
                       'selfhost/build/phase144/integrated-stages01/capture/report.json',
                       'selfhost/build/phase144/integrated-stages01/spec.json')
    for key in ['stdout','stderr']:
        assert all(os['row'][key][k] == ns['row'][key][k] for k in ['bytes','sha256'])
    intervals=[]
    for a in old['intervals']:
        b=next(x for x in new['intervals'] if x['label']==a['label'])
        sample=ne[b['sampleStartInclusive']:b['sampleEndExclusive']]
        intervals.append(dict(label=a['label'], before=a['wallSeconds'], after=b['wallSeconds'],
                              delta=b['wallSeconds']-a['wallSeconds'], ratio=b['wallSeconds']/a['wallSeconds'],
                              beforeSamples=a['samples'], afterSamples=b['samples'],
                              quantitativeProfileAdmitted=b['quantitativeProfileAdmitted'],
                              active=rows(counts(sample,'active'),len(sample)) if sample else [],
                              physical=rows(counts(sample,'physical'),len(sample)) if sample else []))
    partitions=[('Base preparation',0,1),('Frontend including erasure',1,10),
                ('Admission, static preparation and raw lowering',10,14),
                ('Initial optimizer and first independent verifier',14,16),
                ('Observer work and selected final admission',16,19),('Output opening',19,20),
                ('Registry',20,22),('Rendering, output and exit tail',22,23)]
    groups=[]
    for label,start,end in partitions:
        a=sum(x['before'] for x in intervals[start:end]);b=sum(x['after'] for x in intervals[start:end])
        groups.append(dict(label=label,before=a,after=b,delta=b-a,ratio=b/a,
                           shareOfNewStageTime=b/sum(x['after'] for x in intervals)))
    ac,bc=counts(oe,'active'),counts(ne,'active');ap,bp=counts(oe,'physical'),counts(ne,'physical')
    names=['f_find','f_eq','f_grow_base','nc_ctor_owned','String.append','String.eq','p88_string_eq',
           'lookup','constructor_exists','p131i_insert','index_remove','book_final_seen','dr_own_names',
           'nc_uses_term','nc_uses_list','p111q_body_text','p144e_body_tail','p111q_memory','p112w_ready']
    active_comparison=[dict(name=k,before=ac[k],after=bc[k],sampleDelta=bc[k]-ac[k]) for k in names]
    active_groups=[]
    predicates=[('p111v verifier helpers',lambda k:k.startswith('p111v_')),
                ('p113k optimizer fact helpers',lambda k:k.startswith('p113k_')),
                ('p131i plus index map helpers',lambda k:k.startswith(('p131i_','index_'))),
                ('String append/eq plus p88 string equality',lambda k:k in ['String.append','String.eq','p88_string_eq','p88_string_eq_go']),
                ('nc uses traversal',lambda k:k in ['nc_uses_term','nc_uses_list']),
                ('constructor_exists plus lookup',lambda k:k in ['constructor_exists','lookup'])]
    for label,pred in predicates:
        aa=sum(v for k,v in ac.items() if k and pred(k));bb=sum(v for k,v in bc.items() if k and pred(k))
        active_groups.append(dict(label=label,beforeSamples=aa,afterSamples=bb,
                                  beforeFraction=aa/len(oe),afterFraction=bb/len(ne),
                                  beforeSampledPeriodSeconds=aa*.032,afterSampledPeriodSeconds=bb*.032,
                                  actualNames=sorted(k for k in bc if k and pred(k))))
    physical_groups=[]
    for label,needle in [('drop','drop'),('fade','fade'),('take helpers','take'),('constructor helpers','ctor'),('direct register bank helper','p111_set_regs')]:
        aa=sum(v for k,v in ap.items() if k and needle in k and not k.startswith('p111_FID_'))
        bb=sum(v for k,v in bp.items() if k and needle in k and not k.startswith('p111_FID_'))
        physical_groups.append(dict(label=label,beforeSamples=aa,afterSamples=bb,
                                    beforeFraction=aa/len(oe),afterFraction=bb/len(ne),
                                    actualNames=sorted(k for k in bp if k and needle in k and not k.startswith('p111_FID_'))))
    clean_paths=['selfhost/build/phase130/p144-parent-fixed-cold01/report.json',
                 'selfhost/build/phase130/p144-integrated-fixed-cold01/report.json',
                 'selfhost/build/phase130/p144-integrated-serial-fixed-cold01/report.json']
    clean=[]
    for path in clean_paths:
        r=read(path);assert r['complete'] and r['byteExact'] and r['exitCode']==0 and not r['changedInputs']
        clean.append(dict(receipt=pin(ROOT/path),nativeSeconds=r['nativeSeconds'],source=r['source'],image=r['image'],
                          runtime=r['runtime'],product=r['product'],peakRssKiB=r['peakRssKiB'],command=r['command']))
    assert clean[0]['source']==clean[1]['source']==clean[2]['source']
    for r in clean:assert all(r['product'][k]==ns['row']['stdout'][k] for k in ['bytes','sha256'])
    report=dict(kind='phase144-integrated-profile-comparison-v2',complete=True,targetsRun=False,
                inputs=[pin(__file__)]+[pin(ROOT/p) for p in ['research/phase144/stage-profile.json',
                    'selfhost/build/phase144/integrated-source01/manifest.json']],
                before=os,after=ns,intervals=intervals,groups=groups,
                nestedFinal=dict(before=old['conditionalFinalVerificationInterval'],
                                 after=new['intervals'][-1],additive=False),
                activeComparison=active_comparison,activeGroups=active_groups,physicalGroups=physical_groups,
                registerBank=dict(beforeDirectLeaf=ap['p111_set_regs'],afterDirectLeaf=bp['p111_set_regs'],
                    beforeRecoveredLibcCaller=counts(oe,'caller')['p111_set_regs'],afterRecoveredLibcCaller=counts(ne,'caller')['p111_set_regs'],
                    note='Direct helper PCs and recovered libc caller PCs are disjoint samples; active owner attribution overlaps both.'),
                unknownActiveOwner=dict(before=ac[None],after=bc[None]),
                supersedes=pin(ROOT/'research/phase144/integrated-profile.json'),
                clean=clean,cleanCandidateParentRatio=clean[1]['nativeSeconds']/clean[0]['nativeSeconds'],
                diagnosticCandidateParentRatio=ns['row']['wallSeconds']/os['row']['wallSeconds'],
                diagnosticVsClean=dict(before=os['row']['wallSeconds']/clean[0]['nativeSeconds'],
                                       after=ns['row']['wallSeconds']/clean[1]['nativeSeconds']),
                limits=['One diagnostic capture per engine and one clean observation per block; descriptive, no confidence interval.',
                        'The old and new stage runtimes differ. Diagnostic interval deltas do not uniquely attribute clean gains.',
                        'Sample counts times32ms are approximate diagnostic CPU equivalents, not clean function times.',
                        'Physical leaves, recovered callers and active owners overlap. Private synchronous calls may retain outer owner.',
                        'Unknown owners/callers remain in all denominators. FID binding does not prove semantic emitter provenance.',
                        'Conditional final interval is nested in observer work. Do not add it to the disjoint partitions.',
                        'Serial-runtime249s result is a separate unprofiled executable/runtime, not this diagnostic image.'])
    out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(output=str(out),samples=len(ne),coverage=ns['coverage'],groups=groups,
                          active=report['activeComparison'],physical=physical_groups),indent=2))

if __name__=='__main__':main()
