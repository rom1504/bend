#!/usr/bin/env python3
"""Final04 frozen-wrapper gate: exact-product inheritance, changed-only timing.

Root runs targets. Existing native transport, builder and output oracle are reused.
The inherited timing block is explicitly historical evidence, never a fresh score.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
def module(name,path):
    s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
M=module('p144_programs',HERE/'runtime-v04.py')
ROOT,RAW,O=M.ROOT,M.RAW,M.O
E=module('p144_elf',ROOT/'selfhost/tools/performance/phase127/compare-machine.py')
pin,verify,read,save,require=M.pin,M.verify,M.read,M.save,M.require
SELF=Path(__file__).resolve()
PRIOR_PLAN=RAW/'programs-plan04/plan.json'
ACQUIRE=RAW/'programs-plan04-acquire/report.json'
TIMED=RAW/'programs-last-resume01/report.json'
FINAL_PLAN=RAW/'final04-plan/plan.json'
ORDER=['candidate','fast','codegen','baseline']


def prepare(out):
    M.fresh(out);old,acq,timed,final=map(read,[PRIOR_PLAN,ACQUIRE,TIMED,FINAL_PLAN])
    require(old['complete'] and acq['complete'] and timed['complete'] and len(timed['rows'])==720,'Completed earlier corpus required')
    require(acq['plan']==pin(PRIOR_PLAN) and timed['acquisition']==pin(ACQUIRE) and timed['originalPlan']==pin(PRIOR_PLAN),'Prior campaign lineage differs')
    require(final['complete'] and final['sourceAdmission']['controls']==198 and final['runtime']==old['runtimes']['selected'],'Final source/runtime admission differs')
    require(pin(HERE/'runtime-v04.py') in old['inputs'],'Original method changed')
    inputs=[pin(p) for p in [SELF,HERE/'runtime-v04.py',E.__file__,PRIOR_PLAN,ACQUIRE,TIMED,FINAL_PLAN,M.ORACLE,M.COUNTS,M.REQUEST,M.BUILDER,M.GUARD]]
    inputs.extend(final[k] for k in ['runtime','carrierReceipt','base','carrier'])
    inputs.extend(final['sourceAdmission'][k] for k in ['source','sourceManifest','checkedApi','finiteControls'])
    for entry,built in zip(old['cases'],acq['rows']):
        require(entry['case']['name']==built['name'] and entry['case']['source']==built['source'],'Prior sources/order differ')
        inputs.extend([entry['case']['source'],entry['case']['expectedStdoutEvidence']])
        for role in ORDER:
            p=built['products'][role];inputs.extend(p[k] for k in ['qbe','object','binary','runtime','build','emission'])
            rows=[r for r in timed['rows'] if r['name']==built['name'] and r['role']==role]
            require(len(rows)==4 and all(r['correct'] and r['binary']==p['binary'] for r in rows),'Earlier timed product differs')
    unique={p['file']:p for p in inputs}
    for p in unique.values():verify(p)
    out.mkdir();plan=dict(kind='phase144-final04-wrapper-plan',complete=True,targetsRun=False,inputs=list(unique.values()),oldPlan=pin(PRIOR_PLAN),acquisition=pin(ACQUIRE),timed=pin(TIMED),finalPlan=pin(FINAL_PLAN),futureN2Build=str(Path(final['paths']['n2'])/'report.json'),futureQ3=str(Path(final['paths']['q3'])/'report.json'),futureFocused=str(Path(final['paths']['n2-focused19'])/'report.json'),source=final['sourceAdmission']['source'],runtime=final['runtime'],carrierReceipt=final['carrierReceipt'],base=final['base'],carrier=final['carrier'],stamp=final['stamp'],cases=old['cases'],countScale=4,scope='Fresh final04 N2 emissions and one correctness execution of every frozen45 wrapper. Whole-QBE identity permits old-object reuse; changed QBE must be built. Timing inherited only for identical loaded machine products under identical runtime; no new full-corpus performance score.')
    save(out/'plan.json',plan);dest=RAW/'programs-final04-acquire01'
    command=[sys.executable,'-B',str(M.GUARD),'--out',str(dest)+'-guard','--seconds','360','--rss-mib','3072','--available-mib','16384','--file-mib','128','--cpu','3','--',sys.executable,'-B',str(SELF),'acquire','--plan',str(out/'plan.json'),'--out',str(dest)]
    save(out/'jobs.json',dict(complete=True,targetsRun=False,command=command,prerequisite='Final04 N2 build, exact Q3 and N2 focused19 must complete; roots are admitted at execution, not assumed now.'))
    print(json.dumps(dict(prepared=True,jobs=str(out/'jobs.json'))))


def run(action,plan_path,out):
    M.fresh(out);require(os.sched_getaffinity(0)=={3},'Root CPU3 guard required')
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']),'Diagnostic environment refused')
    plan=read(plan_path);require(plan['complete'] and pin(SELF) in plan['inputs'],'Frozen method differs')
    for p in plan['inputs']:verify(p)
    prior,timed=map(read,[ACQUIRE,TIMED]);out.mkdir();start=time.monotonic()
    result=dict(kind='phase144-final04-wrapper-'+action,complete=False,inputs=plan['inputs']+[pin(plan_path)],plan=pin(plan_path),rows=[],jobs=[],scope=plan['scope'])
    def persist():result['seconds']=time.monotonic()-start;save(out/'report.json',result)
    def child(label,command,seconds=45):
        t=time.monotonic();r=subprocess.run(list(map(str,command)),cwd=ROOT,capture_output=True,timeout=seconds);wall=time.monotonic()-t
        so=out/(label+'.stdout');se=out/(label+'.stderr');so.write_bytes(r.stdout);se.write_bytes(r.stderr)
        j=dict(label=label,command=list(map(str,command)),seconds=wall,exitCode=r.returncode,stdout=pin(so),stderr=pin(se));result['jobs'].append(j)
        require(r.returncode==0,'Child failed: '+label);return r,j
    persist()
    try:
        if action=='acquire':
            n2,q3,focused=map(read,[plan['futureN2Build'],plan['futureQ3'],plan['futureFocused']])
            require(n2['complete'] and n2['source']==plan['source'] and n2['runtime']==plan['runtime'],'Future final04 N2 differs')
            require(q3['complete'] and q3['byteExact'] and q3['image']==n2['binary'] and q3['source']==plan['source'],'Q3 exact gate incomplete')
            require(focused['complete'] and focused['passed'] and n2['binary'] in focused['inputs'] and plan['runtime'] in focused['inputs'],'Final N2 focused gate incomplete')
            result['image']=n2['binary'];result['inputs'].extend([n2['binary'],pin(plan['futureN2Build']),pin(plan['futureQ3']),pin(plan['futureFocused'])])
            for entry,built in zip(plan['cases'],prior['rows']):
                c=entry['case'];name=c['name'];dest=ROOT/'selfhost/build/phase130'/('p144-final04-wrapper-'+name)
                child(name+'-emit',[sys.executable,'-B',M.REQUEST,'--image',n2['binary']['file'],'--source',c['source']['file'],'--carrier-receipt',plan['carrierReceipt']['file'],'--out',dest,'--seconds','30'])
                er=read(dest/'report.json');require(er['complete'] and er['image']==n2['binary'] and er['source']==c['source'] and er['base']==plan['base'] and er['carrier']==plan['carrier'] and er['stamp']==plan['stamp'] and not er['changedInputs'] and er['stderr']['bytes']==0,'Native emission differs')
                qp=er['product'];verify(qp);match=next((r for r in ORDER if M.same(qp,built['products'][r]['qbe'])),None)
                if match is not None:
                    old=built['products'][match];require(Path(qp['file']).read_bytes()==Path(old['qbe']['file']).read_bytes(),'Whole-QBE reuse bridge differs')
                    product=dict(qbe=qp,object=old['object'],build=old['build'],emission=pin(dest/'report.json'),runtime=plan['runtime'],reusedObjectFrom=match)
                    serial=next((r for r in ['candidate','fast'] if M.same(product['object'],built['products'][r]['object']) and built['products'][r]['runtime']==plan['runtime']),None)
                    if serial is not None:product['binary']=built['products'][serial]['binary'];product['binaryReuseFrom']=serial
                    else:
                        binary=out/(name+'-serial');_,j=child(name+'-link',[read(PRIOR_PLAN)['gcc']['file'],'-no-pie',product['object']['file'],plan['runtime']['file'],'-pthread','-lm','-o',binary]);require(j['stderr']['bytes']==0,'Link diagnostics');product.update(binary=pin(binary),link=j)
                else:
                    bd=ROOT/'selfhost/build/phase111'/('p144-final04-wrapper-'+name)
                    child(name+'-build',[sys.executable,'-B',M.BUILDER,'--source',qp['file'],'--runtime',plan['runtime']['file'],'--out',bd,'--seconds','30'])
                    br=read(bd/'report.json');require(br['complete'] and qp in br['inputs'] and plan['runtime'] in br['inputs'],'New build differs')
                    product=dict(qbe=qp,object=br['object'],binary=br['binary'],build=pin(bd/'report.json'),emission=pin(dest/'report.json'),runtime=plan['runtime'],reusedObjectFrom=None)
                for key in ['binary','object','qbe']:verify(product[key])
                sections,_,address=E.inspect(Path(product['binary']['file']));matches=[]
                for role in ['candidate','fast']:
                    old=built['products'][role];oldsections,_,oldaddress=E.inspect(Path(old['binary']['file']))
                    changed=[k for k in sections.keys()|oldsections.keys() if sections.get(k)!=oldsections.get(k)]
                    if old['runtime']==plan['runtime'] and not(set(changed)-{'.note.gnu.build-id'}) and address==oldaddress:matches.append(role)
                inherited=[]
                if matches:
                    chosen=matches[0]  # Fixed role order, independent of measured times.
                    inherited=[r for r in timed['rows'] if r['name']==name and r['role']==chosen]
                    counts=read(M.COUNTS)['cases'][name];frozen=dict(c,repetitions=counts['repetitions']*4,warmups=counts['warmups'])
                    require(len(inherited)==4,'Exactly four inherited observations required')
                    for r in inherited:
                        j=r['job'];require(O.observation(verify(j['stdout']).read_bytes(),verify(j['stderr']).read_bytes(),j['exitCode'],frozen,j['seconds'])==r['elapsedMs'],'Inherited output/count oracle differs')
                r,j=child(name+'-smoke',[product['binary']['file'],'--threads','1','--gpu','off','--','1','0',*map(str,c['runtimeArgs'])]);elapsed=O.observation(r.stdout,r.stderr,r.returncode,dict(c,repetitions=1,warmups=0),j['seconds'])
                result['rows'].append(dict(name=name,source=c['source'],product=product,wholeQbeMatchRole=match,loadedMachineMatchingRoles=matches,inheritedTiming=inherited,timingLabel='inherited-exact-machine' if matches else 'new-measurement-required',smoke=dict(correct=True,elapsedMs=elapsed,job=j)));persist();print(name,'checked',flush=True)
            changed=[r['name'] for r in result['rows'] if not r['loadedMachineMatchingRoles']]
            selected=[e['case']['name'] for e in plan['cases'] if e['case']['ratioEligible'] and (e['case']['name'] in changed or e['case']['name']=='complete-generic-row32')]
            result.update(changedMachineCases=changed,selectedForTiming=selected,inheritedCases=sum(bool(r['loadedMachineMatchingRoles']) for r in result['rows']),freshCorrectnessExecutions=45,newFullCorpusTimingScore=False)
            target=RAW/'programs-final04-timing01'
            command=[sys.executable,'-B',str(M.GUARD),'--out',str(target)+'-guard','--seconds','160','--rss-mib','2048','--available-mib','16384','--file-mib','128','--cpu','3','--',sys.executable,'-B',str(SELF),'measure','--plan',str(plan_path),'--out',str(target)]
            save(out/'timing-jobs.json',dict(complete=True,targetsRun=False,selected=selected,command=command,maximumCases=8,note='Only changed timed products plus mandatory row32; stop and ask coordinator if more than8.'))
        else:
            ap=RAW/'programs-final04-acquire01/report.json';acq=read(ap);require(acq['complete'] and acq['plan']==pin(plan_path),'Final wrapper acquisition incomplete')
            selected=acq['selectedForTiming'];require(len(selected)<=8,'More than8 changed cases: coordinator review required');result['inputs'].append(pin(ap));result['scope']='Changed-only eight alternating pairs; original baseline for row32, prior selected serial candidate for other changed cases. No new full-corpus score.'
            counts=read(M.COUNTS)
            for name in selected:
                c=next(e['case'] for e in plan['cases'] if e['case']['name']==name);c=dict(c,repetitions=counts['cases'][name]['repetitions']*4,warmups=counts['cases'][name]['warmups'])
                old=next(r for r in prior['rows'] if r['name']==name);new=next(r for r in acq['rows'] if r['name']==name);role='baseline' if name=='complete-generic-row32' else 'candidate'
                products={'reference':old['products'][role],'final04':new['product']}
                for p in products.values():verify(p['binary']);verify(p['qbe']);verify(p['runtime'])
                for pair in range(8):
                    for label in (['reference','final04'] if pair%2==0 else ['final04','reference']):
                        binary=products[label]['binary'];r,j=child(f'{name}-{label}-{pair}',[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])],10)
                        elapsed=O.observation(r.stdout,r.stderr,r.returncode,c,j['seconds']);result['rows'].append(dict(name=name,role=label,pair=pair,binary=binary,elapsedMs=elapsed,correct=True,job=j))
                    persist()
            summary=[]
            for name in selected:
                med={role:statistics.median(r['elapsedMs'] for r in result['rows'] if r['name']==name and r['role']==role) for role in ['reference','final04']};ratios=[]
                for pair in range(8):
                    v={r['role']:r['elapsedMs'] for r in result['rows'] if r['name']==name and r['pair']==pair};ratios.append(v['final04']/v['reference'])
                summary.append(dict(name=name,referenceRole='baseline-143-atomic' if name=='complete-generic-row32' else 'candidate-final03-serial',mediansMs=med,ratioOfMedians=med['final04']/med['reference'],pairedRatios=ratios))
            result['summary']=summary
        for p in result['inputs']:verify(p)
        result['complete']=True
    except BaseException as e:result['error']=repr(e);raise
    finally:persist()
    print(json.dumps(dict(complete=True,seconds=result['seconds'],changed=result.get('changedMachineCases'),inherited=result.get('inheritedCases'),summary=result.get('summary'))))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('action',choices=['prepare','acquire','measure']);p.add_argument('--out',type=Path,required=True);p.add_argument('--plan',type=Path);a=p.parse_args()
    if a.action=='prepare':prepare(a.out.resolve())
    else:require(a.plan is not None,'Plan required');run(a.action,a.plan.resolve(),a.out.resolve())
