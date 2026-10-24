#!/usr/bin/env python3
"""Preserve compact final-N2 profile findings without rerunning a target."""
import argparse
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[5]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
from run import pin,save,verify


def read(path):return json.loads(Path(path).read_text())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists()
    analysis_path=ROOT/'selfhost/build/phase131/final-profile-analysis01/report.json';analysis=read(analysis_path)
    old_path=ROOT/'selfhost/build/phase131/profile-analysis01/report.json';old=read(old_path)
    assert analysis['complete'] and old['complete']
    physical_manifest_path=ROOT/'selfhost/build/phase131/final-profile01/manifest.json'
    context_plan_path=ROOT/'selfhost/build/phase131/final-context01/runtime/plan.json'
    context_plan=read(context_plan_path)
    source=verify(analysis['source'])
    counters=['dispatches','heap_alloc_calls','heap_alloc_requested_words','heap_free_calls','term_drop_calls',
        'ctr_take_calls','frame_push_calls','register_words_copy_requested','register_words_clear_requested']
    rows=[]
    for w in analysis['workloads']:
        before=next(x for x in old['workloads'] if x['name']==w['name'])
        phy=w['physicalProfile']
        physical_top=[{k:x[k] for k in ['object','decoded','samples','periodWeightedFraction','estimatedCleanCpuSeconds']} for x in phy['functions'][:20]]
        oldleaves={(x['object'],x['decoded']):x for x in before['physicalProfile']['functions']}
        for x in physical_top:
            prior=oldleaves.get((x['object'],x['decoded']))
            x['priorEstimatedCleanCpuSeconds']=prior.get('estimatedCleanCpuSeconds') if prior else None
        rows.append(dict(name=w['name'],cleanCpuSeconds=w['clean']['cpuSeconds']['median'],
            priorCleanCpuSeconds=before['clean']['cpuSeconds']['median'],physicalSamples=phy['samples'],
            physicalAdequate=phy['adequate'],physicalWholeChildCpuCoverage=phy['wholeChildCpuCoverageAdequate'],
            physicalEstimateAvailable=phy['estimateAvailable'],loss=phy['captureLossTotals'],
            unknownPhysicalSamples=phy['unknownSamples'],physicalAccepted=len(phy['acceptedCaptures']),physicalRejected=phy['rejectedCaptures'],
            contextSamples=w['contextSamples'],contextAdequate=w['contextAdequate'],contextRejected=w['rejectedContexts'],
            contextOnlyWallOverClean=w['contextOnlyWallOverClean'],countersWallOverClean=w['countersWallOverClean'],
            topPhysicalLeaves=physical_top,topActiveOwners=w['topActiveOwners'][:15],familyContexts=w['familyContexts'],
            selectedDirectEntries=w['selectedDirectEntries'],selectedActiveFractions=w['selectedActiveFractions'],
            runtimeCounters={k:dict(prior=before['eventTotals'][k],current=w['eventTotals'][k],
                ratio=w['eventTotals'][k]/before['eventTotals'][k] if before['eventTotals'][k] else None,
                delta=w['eventTotals'][k]-before['eventTotals'][k]) for k in counters},
            topAllocationWordOwners=w['eventOwners']['heap_alloc_requested_words'][:10],
            topReclamationOwners=w['eventOwners']['term_drop_calls'][:10],
            topRegisterCopyOwners=w['eventOwners']['register_words_copy_requested'][:10],
            physicalCallerFractions=w['physicalCallerFractions'],eventReceipt=w['eventReceipt']))
    source_text=source.read_text().splitlines();definitions={}
    for name in ['p111v_get','p111v_put','p111v_name_chars','p111q_memory','p111q_body_text','nt_text_finish','p88_number','p88_field','p130m_word','p130m_number_read','nc_bangs_names']:
        match=[i+1 for i,line in enumerate(source_text) if line.startswith('def '+name+'(')]
        assert len(match)==1;definitions[name]=match[0]
    result=dict(kind='phase131-final-native-profile-findings',complete=True,targetsRun=False,
        source=analysis['source'],image=analysis['image'],measuredStage='Final Phase131 N2',
        diagnosticRuntime=context_plan['reusedRuntimeObject'],
        inputs=[pin(__file__),pin(analysis_path),pin(old_path),pin(physical_manifest_path),pin(context_plan_path)],
        requests=rows,sourceDefinitionLines=definitions,
        observedFindings=['All three physical and context sample pools exceed500; zero retained-capture drops/overruns and no rejected captures.',
            'The authenticated sampled libc copy PCs all recover physical caller p111_set_regs; no other libc cause is inferred.',
            'nc_bangs_names direct entries are138/48/219; all nc_bangs_* active owner shares are below0.5% in these requests.',
            'Verifier owners now occupy23.81%/5.40%/14.98% of lexer/closures/Map diagnostic active-owner samples.',
            'Carrier decoder owners occupy14.17%/48.68%/10.59%; p88_number requests4,536,966 allocation words in every case.',
            'String.append requests8,015,180/907,149/11,751,661 allocation words in lexer/closures/Map; Map QBE memory/body-text emission adds3,341,699/2,535,578 under their respective active owners.',
            'Allocation/free counts match within each final request; this is not a general proof against leaks or ownership errors.'],
        limitations=['Historical and final clean timings are different blocks; primary gain claims use the separate controlled timing reports.',
            'Counter totals are exact instrumented runtime-hook counts; private inlined operations may bypass hooks.',
            'Context-only adds6.1–8.3% wall overhead, counter-enabled adds66.8–86.5%; never treat diagnostic wall time as clean performance.',
            'Active-owner names reflect the current dispatch context, not allocation origin or inclusive ancestry. Physical and owner fractions overlap.',
            'Unknown physical/context samples remain in denominators; absence of an observed sample does not prove zero cost.',
            'Three short requests do not establish the dominant costs of a full compiler self-build or broad user-program speed.'])
    save(out,result);print(json.dumps(dict(complete=True,report=pin(out),requests=len(rows))))


if __name__=='__main__':main()
