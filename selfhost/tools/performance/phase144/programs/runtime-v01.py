#!/usr/bin/env python3
"""Frozen45 native regression screen; only root executes acquire/measure.

Compiler logic and the complete-output/count oracle are existing checked tools.
This observer binds products, reuses exact objects, and separates codegen from
the selected runtime change. No benchmark source or count is rewritten.
"""
import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import shutil
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
SELF = Path(__file__).resolve()
RAW = ROOT/'selfhost/build/phase144'
CORPUS = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
COUNTS = CORPUS.with_name('upstream-50ms-profile01.json')
ORACLE = CORPUS.with_name('run.py')
REQUEST = ROOT/'selfhost/tools/performance/phase130/native-request.py'
BUILDER = ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
GUARD = ROOT/'selfhost/tools/performance/phase111/guard.py'
PARENT = ROOT/'implementation/phase143/qualification.json'
PARENT_CANDIDATE = ROOT/'implementation/phase143/candidate.json'
FINAL = RAW/'final03-plan/plan.json'
OLD_SCREEN = ROOT/'selfhost/build/phase131/combined-programs01/runtime/report.json'
OLD_EMIT = ROOT/'selfhost/build/phase118/p131-combined-literals01-wrappers/report.json'
ROLES = ['baseline', 'codegen', 'candidate']
spec = importlib.util.spec_from_file_location('p144_frozen_oracle', ORACLE)
O = importlib.util.module_from_spec(spec); spec.loader.exec_module(O)
pin, verify, read, save = O.pin, O.verify, O.read, O.save


def require(test, reason):
    if not test: raise ValueError(reason)


def same(a, b):
    return a['bytes'] == b['bytes'] and a['sha256'] == b['sha256']


def fresh(out):
    require(out.is_relative_to(RAW) and not out.exists(), 'Fresh Phase144 output required')


def prepare(out):
    fresh(out)
    qualified, parent, final, corpus, counts = map(read, [PARENT, PARENT_CANDIDATE, FINAL, CORPUS, COUNTS])
    require(qualified['complete'] and qualified['nativeQualified'] and final['complete'], 'Qualified parent/complete final plan required')
    require(parent['n2']==qualified['n2'] and parent['source']==qualified['source'], 'Parent candidate/qualification differ')
    parent_build_path=Path(parent['n2']['file']).parent/'report.json';parent_build=read(parent_build_path)
    require(parent_build['complete'] and parent_build['binary']==parent['n2'] and parent['runtime'] in parent_build['inputs'],'Parent runtime/build differ')
    n2_path = Path(final['paths']['n2'])/'report.json'; n2 = read(n2_path)
    q3_path = Path(final['paths']['q3'])/'report.json'; q3 = read(q3_path)
    focus_path = Path(final['paths']['n2-focused19'])/'report.json'; focus = read(focus_path)
    broad_path = Path(final['paths']['n2-full45'])/'report.json'; broad = read(broad_path)
    require(n2['complete'] and n2['source'] == final['sourceAdmission']['source'] and n2['runtime'] == final['runtime'], 'Final N2 identity differs')
    require(q3['complete'] and q3['byteExact'] and q3['image'] == n2['binary'] and q3['source'] == n2['source'], 'Final reproduction gate absent')
    require(focus['complete'] and focus['passed'] and broad['complete'] and broad['passed'], 'Final native gates incomplete')
    for gate in [focus, broad]:
        require(n2['binary'] in gate['inputs'] and final['runtime'] in gate['inputs'], 'Gate does not bind final image/runtime')
    require(len(corpus['cases']) == 45 and sum(c['ratioEligible'] for c in corpus['cases']) == 44, 'Frozen45/44 scope differs')
    require(counts['manifest'] == pin(CORPUS) and set(counts['cases']) == {c['name'] for c in corpus['cases']}, 'Count profile differs')
    old, emission = read(OLD_SCREEN), read(OLD_EMIT)
    require(old['complete'] and emission['complete'] and len(old['rows']) == 405, 'Historical reuse receipt incomplete')
    old_builds = {b['name']: b['report'] for b in old['builds']}
    old_qbe = {c['name']: c for c in emission['cases']}
    inputs = [pin(p) for p in [SELF, CORPUS, COUNTS, ORACLE, REQUEST, BUILDER, GUARD, PARENT, PARENT_CANDIDATE, parent_build_path, FINAL,
        n2_path, q3_path, focus_path, broad_path, OLD_SCREEN, OLD_EMIT]]
    inputs += [parent['n2'], n2['binary'], parent['runtime'], final['runtime'], final['carrierReceipt'],
        final['base'], final['carrier'], pin(shutil.which('gcc'))]
    carrier = read(final['carrierReceipt']['file'])
    require(carrier['complete'] and carrier['carrier'] == final['carrier'], 'Carrier differs')
    rows = []
    for c in corpus['cases']:
        name = c['name']; prior = old_qbe[name]; bp = old_builds[name]; build = read(bp['file'])
        require(prior['source'] == c['source'] and build['complete'], 'Historical source/build mismatch')
        require(prior['qbe'] in build['inputs'] and parent['runtime'] in build['inputs'], 'Historical QBE/runtime join differs')
        require(same(build['inputs'][0], pin(BUILDER)), 'Historical builder policy differs')
        require(all(r['correct'] and r['binary'] == build['binary'] for r in old['rows'] if r['name'] == name and r['role'] == 'candidate'), 'Historical executable join differs')
        inputs += [c['source'], c['expectedStdoutEvidence'], bp, prior['qbe'], build['binary'], build['object'], *build['inputs'][3:]]
        require(verify(c['expectedStdoutEvidence']).read_bytes() == c['expectedStdout'].encode(), 'Frozen output oracle differs')
        rows.append(dict(case=c, oldQbe=prior['qbe'], oldBuild=bp, oldObject=build['object'], oldBinary=build['binary']))
    unique = {}
    for item in inputs:
        verify(item); unique[item['file']] = item
    out.mkdir()
    plan = dict(kind='phase144-frozen45-native-runtime-plan', complete=True, targetsRun=False,
        inputs=list(unique.values()), parentImage=parent['n2'], candidateImage=n2['binary'],
        runtimes=dict(old=parent['runtime'], selected=final['runtime']), carrierReceipt=final['carrierReceipt'],
        carrier=final['carrier'], base=final['base'], stamp=final['stamp'], cases=rows, countScale=4,
        rounds=3, roleOrder=ROLES, gcc=pin(shutil.which('gcc')), methods=dict(request=pin(REQUEST), builder=pin(BUILDER), oracle=pin(ORACLE)),
        scope='Fresh Phase143/final03 native emissions on exact historical45 wrappers,44 timed. baseline=143+old runtime; codegen=144+old runtime; candidate=144+serial runtime. No fresh upstream ratio. All timings contemporaneous, same frozen counts/profile×4 and complete-output oracle.')
    save(out/'plan.json', plan)
    jobs = []
    for action, limit, rss in [('acquire',450,3072),('measure',300,2048)]:
        dest = out.parent/(out.name+'-'+action)
        jobs.append(dict(name=action, command=[sys.executable,'-B',str(GUARD),'--out',str(dest)+'-guard',
            '--seconds',str(limit),'--rss-mib',str(rss),'--available-mib','16384','--file-mib','128','--cpu','3','--',
            sys.executable,'-B',str(SELF),action,'--plan',str(out/'plan.json'),'--out',str(dest)]))
    save(out/'jobs.json',dict(complete=True,targetsRun=False,plan=pin(out/'plan.json'),jobs=jobs,
        estimatedSeconds='360–480 total; bounded450 acquisition +300 timing, serial root lane only'))
    print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out/'plan.json'),jobs=out.joinpath('jobs.json').as_posix())))


def run(action, plan_path, out):
    fresh(out); require(os.sched_getaffinity(0) == {3}, 'Root CPU3 guard required')
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']), 'Diagnostic environment refused')
    plan = read(plan_path); require(plan['complete'], 'Complete plan required')
    require(pin(SELF) in plan['inputs'], 'Method differs from frozen plan')
    for p in plan['inputs']: verify(p)
    out.mkdir(); start = time.monotonic()
    result = dict(kind='phase144-frozen45-native-'+action,complete=False,plan=pin(plan_path),inputs=plan['inputs'],jobs=[],rows=[],scope=plan['scope'])
    def persist():
        result['seconds'] = time.monotonic()-start; save(out/'report.json',result)
    def child(label, command, seconds=45):
        t=time.monotonic(); r=subprocess.run(list(map(str,command)),cwd=ROOT,capture_output=True,timeout=seconds)
        so=out/(label+'.stdout');se=out/(label+'.stderr');so.write_bytes(r.stdout);se.write_bytes(r.stderr)
        row=dict(label=label,command=list(map(str,command)),seconds=time.monotonic()-t,exitCode=r.returncode,stdout=pin(so),stderr=pin(se))
        result['jobs'].append(row); persist(); require(r.returncode == 0, 'Child failed: '+label)
        return r,row
    persist()
    try:
        if action == 'acquire':
            for entry in plan['cases']:
                case=entry['case'];name=case['name']; products={}; available=[dict(qbe=entry['oldQbe'],object=entry['oldObject'],binary=entry['oldBinary'],build=entry['oldBuild'])]
                for role,image in [('baseline',plan['parentImage']),('codegen',plan['candidateImage'])]:
                    dest=ROOT/'selfhost/build/phase130'/('p144-programs01-'+role+'-'+name)
                    require(not dest.exists(), 'Fresh native emission required')
                    child(name+'-'+role+'-emit',[sys.executable,'-B',REQUEST,'--image',image['file'],'--source',case['source']['file'],
                        '--carrier-receipt',plan['carrierReceipt']['file'],'--out',dest,'--seconds','30'])
                    er=read(dest/'report.json'); require(er['complete'] and er['image']==image and er['source']==case['source'] and not er['changedInputs'], 'Native source identity differs')
                    require(er['base']==plan['base'] and er['carrier']==plan['carrier'] and er['stamp']==plan['stamp'] and er['stderr']['bytes']==0,'Native transport differs')
                    qp=er['product']; verify(qp)
                    prior=next((p for p in available if same(p['qbe'],qp)),None)
                    if prior:
                        # Whole digest+length identity is supplemented by actual byte equality.
                        require(Path(prior['qbe']['file']).read_bytes()==Path(qp['file']).read_bytes(), 'QBE bridge differs')
                        product=dict(prior,reused=True)
                    else:
                        built=ROOT/'selfhost/build/phase111'/('p144-programs01-'+role+'-'+name)
                        require(not built.exists(),'Fresh aligned build required')
                        child(name+'-'+role+'-build',[sys.executable,'-B',BUILDER,'--source',qp['file'],'--runtime',plan['runtimes']['old']['file'],'--out',built,'--seconds','30'])
                        br=read(built/'report.json'); require(br['complete'] and qp in br['inputs'] and plan['runtimes']['old'] in br['inputs'],'Build identity differs')
                        product=dict(qbe=qp,object=br['object'],binary=br['binary'],build=pin(built/'report.json'),reused=False)
                        available.append(product)
                    products[role]=dict(product,qbe=qp,emission=pin(dest/'report.json'),runtime=plan['runtimes']['old'])
                binary=out/(name+'-serial');obj=products['codegen']['object']; verify(obj)
                _,link=child(name+'-serial-link',[plan['gcc']['file'],'-no-pie',obj['file'],plan['runtimes']['selected']['file'],'-pthread','-lm','-o',binary])
                require(link['stderr']['bytes']==0,'Unexpected linker diagnostics')
                products['candidate']=dict(products['codegen'],binary=pin(binary),runtime=plan['runtimes']['selected'],link=link,reusedObject=True)
                smoke=[]
                for role in ROLES:
                    c=dict(case,repetitions=1,warmups=0)
                    r,j=child(name+'-'+role+'-smoke',[products[role]['binary']['file'],'--threads','1','--gpu','off','--','1','0',*map(str,c['runtimeArgs'])])
                    elapsed=O.observation(r.stdout,r.stderr,r.returncode,c,j['seconds'])
                    smoke.append(dict(role=role,correct=True,elapsedMs=elapsed,job=j))
                result['rows'].append(dict(name=name,source=case['source'],products=products,smokes=smoke)); persist()
                print(name,'acquired',flush=True)
        else:
            acquisition=plan_path.parent.parent/(plan_path.parent.name+'-acquire')/'report.json'
            acquired=read(acquisition); require(acquired['complete'] and acquired['plan']==pin(plan_path),'Acquisition missing or foreign')
            require([x['name'] for x in acquired['rows']]==[x['case']['name'] for x in plan['cases']],'Acquired corpus differs')
            result['acquisition']=pin(acquisition); result['inputs'].append(pin(acquisition)); counts=read(COUNTS)
            for entry, built in zip(plan['cases'],acquired['rows']):
                c=entry['case'];name=c['name'];c=dict(c,repetitions=counts['cases'][name]['repetitions']*4,warmups=counts['cases'][name]['warmups'])
                for p in built['products'].values(): verify(p['binary']); verify(p['qbe']); verify(p['runtime'])
                for rnd in range(3):
                    roles=ROLES[rnd:]+ROLES[:rnd]
                    for role in roles:
                        binary=built['products'][role]['binary']
                        r,j=child(name+'-'+role+'-'+str(rnd),[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])],30)
                        elapsed=O.observation(r.stdout,r.stderr,r.returncode,c,j['seconds'])
                        result['rows'].append(dict(name=name,role=role,round=rnd,binary=binary,elapsedMs=elapsed,correct=True,job=j));persist()
                print(name,'measured',flush=True)
            gm=lambda xs:math.exp(statistics.mean(math.log(x) for x in xs))
            summary=[]
            for entry in plan['cases']:
                c=entry['case']; med={role:statistics.median(r['elapsedMs'] for r in result['rows'] if r['name']==c['name'] and r['role']==role) for role in ROLES}
                row=dict(name=c['name'],family=c['family'],ratioEligible=c['ratioEligible'],mediansMs=med)
                if c['ratioEligible']:
                    require(all(x>0 for x in med.values()),'Nonpositive timed interval')
                    row.update(codegenOverBaseline=med['codegen']/med['baseline'],candidateOverBaseline=med['candidate']/med['baseline'],candidateOverCodegen=med['candidate']/med['codegen'])
                summary.append(row)
            eligible=[r for r in summary if r['ratioEligible']]
            result['summary']=dict(cases=summary,timedCases=len(eligible),observations=len(result['rows']),
                geometric={key:gm([r[key] for r in eligible]) for key in ['codegenOverBaseline','candidateOverBaseline','candidateOverCodegen']},
                summedMedianBatchMs={role:sum(r['mediansMs'][role] for r in eligible) for role in ROLES},
                scope='Three contemporaneous rotating rounds,44 frozen timed points plus zero-work control. Ratios of medians, descriptive only; no new upstream ratio or confidence interval.')
        for item in plan['inputs']: verify(item)
        result['complete']=True
    except BaseException as error:
        result['error']=repr(error);raise
    finally:persist()
    print(json.dumps(dict(complete=True,seconds=result['seconds'],summary=result.get('summary',{}).get('geometric'))))


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','acquire','measure']);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--plan',type=Path)
    a=ap.parse_args();out=a.out.resolve()
    if a.action=='prepare':prepare(out)
    else:require(a.plan is not None,'Plan required');run(a.action,a.plan.resolve(),out)


if __name__=='__main__':main()
