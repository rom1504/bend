#!/usr/bin/env python3
"""Frozen, bounded native two-revision experiment; no compiler implementation.

--prepare creates only metadata/fixtures. --run requires a completed native build
and acquisition chain. An outer guard owns CPU affinity and memory limits.
"""
import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import re
import signal
import stat
import subprocess
import sys
import threading
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/build/phase134'
HERE = Path(__file__).resolve().parent
METHOD = ROOT / 'selfhost/tools/performance/phase130/native-request.py'
spec = importlib.util.spec_from_file_location('p134_native_request', METHOD)
N = importlib.util.module_from_spec(spec); spec.loader.exec_module(N)
pin, verify, require = N.pin, N.verify, N.require


def load(path):
    return json.loads(Path(path).read_text())


def save(path, data):
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(data, indent=2) + '\n'); tmp.replace(path)


def prepare(args):
    directory = args.plan.absolute().parent
    require(directory == directory.resolve() and directory.is_relative_to(PHASE), 'Real Phase134 plan directory required')
    require(not directory.exists(), 'Plan directory must be fresh')
    source_dir = PHASE / 'session-source04'
    source_manifest = load(source_dir / 'manifest.json')
    api_path = ROOT / 'selfhost/build/phase111/p134-session-api02/report.json'
    api = load(api_path)
    finite_path, bridge_path = PHASE/'session-finite02/report.json', PHASE/'session-bridge02/report.json'
    finite, bridge = load(finite_path), load(bridge_path)
    require(api['complete'] and api['checked'] and source_manifest['source'] in api['inputs'], 'Checked session source required')
    require(finite['complete'] and finite['source'] == source_manifest['source'] and bridge['complete'], 'Session controls/bridge required')
    require(api['api'] in bridge['inputs'] and source_manifest['source'] in bridge['inputs'], 'Raw bridge must bind this checked session source/API')
    require(sum(g['expectedCount'] for g in finite['groups']) == 109 and all(g['complete'] for g in finite['groups']), '109 controls required')
    selected_path = ROOT / 'implementation/phase131/final/candidate.json'
    selected = load(selected_path)
    require(selected['complete'] and selected['nativeQualified'], 'Independent qualified oracle required')
    oracle_path = PHASE / 'selected-qualification01.json'; oracle=load(oracle_path)
    require(oracle['complete'] and oracle['nativeQualified'] and oracle['runtime']==selected['runtime'], 'Qualified core N2 oracle required')
    carrier, base, carrier_inputs = N.carrier_inputs(verify(selected['preferredCarrierReceipt']))
    inputs = [pin(__file__), pin(METHOD), pin(N.METHOD), pin(sys.executable),
              pin(source_dir/'manifest.json'), source_manifest['source'], *source_manifest['inputs'],
              pin(api_path), api['api'], pin(finite_path), pin(bridge_path), pin(selected_path),
              pin(oracle_path), oracle['finalImage'], selected['runtime'], selected['runtimeReport'], *carrier_inputs]
    reference_path = PHASE / 'reference03.json'; reference = load(reference_path)
    inputs.append(pin(reference_path))
    cases = []
    for name, folder, reference_name in [('lexer','units-lexer01','lexer'), ('map','units-map01','coverage-map-churn-128')]:
        evidence_path = PHASE/folder/'report.json'; evidence = load(evidence_path)
        require(evidence['complete'], 'Complete real-edit evidence required')
        before, after = evidence['edit']['original'], evidence['edit']['edited']
        old = next(c for c in reference['cases'] if c['name'] == reference_name)
        require(old['source'] == before and before['sha256'] != after['sha256'], 'Real edit/reference identity mismatch')
        cases.append(dict(name=name, a=before, b=after, frozenOld=old['expectedQbe']))
        inputs.extend([pin(evidence_path), before, after, old['expectedQbe']])
    # The plan records every consumed immutable source/producer dependency.
    inputs = list({(x['file'],x['sha256']):x for x in inputs}.values())
    for row in inputs: verify(row)
    directory.mkdir(parents=True)
    tiny, invalid = directory/'tiny.bend', directory/'invalid.bend'
    tiny.write_text('def main() -> U32:\n  7\n')
    invalid.write_text('def main(\n')
    inputs.extend([pin(tiny),pin(invalid)])
    plan = dict(kind='phase134-native-session-plan', complete=True, inputs=inputs,
        source=source_manifest['source'], sourceManifest=pin(source_dir/'manifest.json'),
        checkedApi=pin(api_path), finite=pin(finite_path), bridge=pin(bridge_path),
        oracleImage=oracle['finalImage'], oracleQualification=pin(oracle_path),
        runtime=selected['runtime'], base=base, carrier=carrier['carrier'], stamp=carrier['stamp'],
        acquisition=str(args.acquisition.resolve()), build=str(args.build.resolve()),
        out=str(args.out.absolute()), cases=cases, tiny=pin(tiny), invalid=pin(invalid),
        rounds=2, schedule=[dict(round=r,case=c['name'],mode=m)
            for r in range(2) for c in (cases if r==0 else list(reversed(cases)))
            for m in (['warm','cold'] if r==0 else ['cold','warm'])],
        limitSeconds=120, timingScope='Whole child wall/CPU/RSS; optional source IO.now preparation/A/B milliseconds. All files close before success.',
        oracleScope='Independent qualified Phase134 core N2 ordinary no-unit-cache path, using actual distinct A/B source paths. No text normalization.',
        scope='Experimental two-revision session only; no full bootstrap qualification, promotion, machine build or compiler-source edit.')
    save(args.plan,plan)
    print(json.dumps(dict(complete=True, plan=pin(args.plan), targetsRun=False)))


def parse_stats(path):
    rows, prep = {}, None
    for line in path.read_text().splitlines():
        line=line.rstrip(' ')  # v03's list printer leaves a final separator.
        match = re.fullmatch(r'phase134 prepare_ms (\d+)',line)
        if match:
            require(prep is None,'Duplicate preparation time'); prep=int(match[1]); continue
        match = re.fullmatch(r'phase134 ([AB]) (\d+) (\d+) (\d+) (\d+) (\d+)(?: ms=(\d+))?',line)
        require(match is not None,'Unexpected session stdout: '+line)
        side=match[1]; require(side not in rows,'Duplicate session stats')
        rows[side]=dict(counts=[int(match[i]) for i in range(2,7)], milliseconds=int(match[7]) if match[7] else None)
    require(set(rows)=={'A','B'},'Both session stat rows required')
    require((prep is None)==(rows['A']['milliseconds'] is None)==(rows['B']['milliseconds'] is None),'Partial timing format')
    return dict(preparationMilliseconds=prep, **rows)


def safe_outputs(folder, forbidden):
    require(folder == folder.resolve() and not folder.exists(),'Fresh real execution directory required')
    folder.mkdir()
    paths=[folder/'a.ssa',folder/'b.ssa']
    require(len(set(paths))==2 and not any(x.exists() or x.is_symlink() or x in forbidden for x in paths),'Unsafe output alias')
    return paths


def regular(path):
    require(stat.S_ISREG(path.lstat().st_mode) and not path.is_symlink(),'Regular output required: '+str(path))
    return pin(path)


def run(args):
    plan=load(args.plan); require(plan['complete'] and plan['kind']=='phase134-native-session-plan','Frozen plan required')
    require(pin(__file__) in plan['inputs'],'Runner changed after plan')
    require(not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS')),'Ambient instrumentation forbidden')
    inputs=[pin(args.plan),*plan['inputs'],plan['oracleQualification']]
    acquisition, build=load(plan['acquisition']), load(plan['build'])
    require(acquisition['source']==plan['source'],'Acquisition/source mismatch')
    require(build['complete'],'Complete native build required')
    if build['kind']=='phase134-reviewed-pipe-machine-finish':
        require(acquisition['kind']=='phase134-supervised-qbe-stdin-build' and not acquisition['complete'], 'Expected preserved incomplete pipe receipt')
        require(acquisition['compilerExitCode']==acquisition['qbeExitCode']==0 and acquisition['error']=="ValueError('assemble failed or diagnosed an error')", 'Unreviewed pipe failure')
        require(build['originalPipe']==pin(plan['acquisition']), 'Resumed build does not bind original failure')
        review=load(verify(build['warningReview']))
        require(review['complete'] and review['kind']=='phase134-reviewed-split-immediate-warnings' and review['originalPipe']==build['originalPipe'], 'Exact warning review required')
        require(build['source']==plan['source'] and build['image']==plan['oracleImage'] and build['runtime']==plan['runtime'], 'Resumed source/producer/runtime mismatch')
        require(build['irDigest']==acquisition['irDigest']==review['irDigest'] and build['assembly']==acquisition['assembly']==review['assembly'], 'Resumed IR/assembly identity mismatch')
        require(build['retainedObject']==review['retainedObject'] and all(build['object'][k]==build['retainedObject'][k] for k in ['bytes','sha256']), 'Reassembly differs from original successful object')
        require(all(j['exitCode']==0 for j in build['jobs']) and {j['label'] for j in build['jobs']} >= {'assemble','link'}, 'Resumed machine build incomplete')
        require(acquisition['maximumRelayBytes']<=65536 and not acquisition['retainIR'], 'Bounded complete pipe required')
        inputs.extend([build['warningReview'],*review['inputs'],build['assembly'],build['retainedObject'],build['object']])
        acquisition_products=[]
    elif build['kind']=='phase134-supervised-qbe-stdin-build':
        require(acquisition['complete'],'Complete pipe acquisition required')
        require(plan['acquisition']==plan['build'] and build['source']==plan['source'] and build['runtime']==plan['runtime'], 'Pipe source/runtime identity mismatch')
        require(build['image']==plan['oracleImage'] and build['compilerExitCode']==build['qbeExitCode']==0, 'Qualified pipe producer required')
        require(build['irDigest']['bytes']>0 and build['maximumRelayBytes']<=65536 and not build['retainIR'], 'Bounded complete pipe required')
        require(all(j['exitCode']==0 for j in build['jobs']) and {j['label'] for j in build['jobs']} >= {'assemble','link'}, 'Pipe machine build incomplete')
        acquisition_products=[]
    else:
        require(acquisition['complete'],'Complete acquisition required')
        require(build['kind']=='phase123-branch-aligned-qbe-build','Known aligned native build required')
        require(acquisition['product'] in build['inputs'] and plan['runtime'] in build['inputs'],'Native QBE/runtime build identity mismatch')
        acquisition_products=[acquisition['product']]
    image=verify(build['binary']); require(os.access(image,os.X_OK),'Executable session image required')
    inputs.extend([pin(plan['acquisition']),pin(plan['build']),*acquisition['inputs'],*acquisition_products,*build['inputs'],build['binary']])
    inputs=list({(x['file'],x['sha256']):x for x in inputs}.values())
    for row in inputs: verify(row)
    out=Path(plan['out']); require(out==out.resolve() and out.is_relative_to(PHASE) and not out.exists(),'Fresh real Phase134 result directory required')
    out.mkdir(parents=True)
    forbidden={Path(x['file']).resolve() for x in inputs}
    report=dict(kind='phase134-native-two-revision-session',complete=False,experimental=True,
        plan=pin(args.plan),inputs=inputs,image=build['binary'],source=plan['source'],runtime=plan['runtime'],
        oracleImage=plan['oracleImage'],rows=[],oracles=[],negativeControls=[],inheritedAffinity=sorted(os.sched_getaffinity(0)),
        acquisitionCost=dict(nativeSeconds=acquisition.get('nativeSeconds'),buildSeconds=build.get('buildSeconds'),
            combinedPipeWallSeconds=acquisition.get('wallSeconds') if acquisition['kind']=='phase134-supervised-qbe-stdin-build' else None,
            resumedMachineSeconds=build.get('wallSeconds') if build['kind']=='phase134-reviewed-pipe-machine-finish' else None,
            scope='Already paid outside this experiment; not hidden inside warm/cold speed ratios.'),scope=plan['scope'])
    started=time.monotonic(); deadline=started+plan['limitSeconds']
    def persist():
        report['totalSeconds']=time.monotonic()-started; save(out/'report.json',report)
    def execute(command, folder, cwd=ROOT):
        require(time.monotonic()<deadline,'Overall native experiment deadline reached')
        row=dict(command=command,cwd=str(cwd))
        with (folder/'stdout').open('xb') as so,(folder/'stderr').open('xb') as se:
            before=time.monotonic(); child=subprocess.Popen(command,cwd=cwd,stdout=so,stderr=se,start_new_session=True)
            expired=threading.Event()
            def stop():
                expired.set()
                try: os.killpg(child.pid,signal.SIGKILL)
                except ProcessLookupError: pass
            timer=threading.Timer(max(.001,deadline-before),stop); timer.daemon=True; timer.start()
            try:
                _,status,usage=os.wait4(child.pid,0); child.returncode=os.waitstatus_to_exitcode(status)
            except BaseException:
                stop(); child.wait(); raise
            finally:
                timer.cancel(); timer.join()
            row.update(exitCode=child.returncode,wallSeconds=time.monotonic()-before,userSeconds=usage.ru_utime,
                systemSeconds=usage.ru_stime,cpuSeconds=usage.ru_utime+usage.ru_stime,peakRssKiB=usage.ru_maxrss,
                stdout=pin(folder/'stdout'),stderr=pin(folder/'stderr'),timedOut=expired.is_set())
        require(not expired.is_set(),'Native experiment deadline exceeded')
        return row
    def ordinary(source, label):
        folder=out/label; folder.mkdir()
        command=[plan['oracleImage']['file'],'--threads','1','--gpu','off','--','phase111',source,
                 plan['base']['file'],'cache',plan['carrier']['file'],plan['stamp']]
        row=execute(command,folder); report['oracles'].append(row); persist()
        require(row['exitCode']==0 and row['stdout']['bytes']>0 and row['stderr']['bytes']==0,'Independent fresh oracle failed')
        return row['stdout']
    def session(a,b,oa,ob,mode):
        return [str(image),'--threads','1','--gpu','off','--','phase134-session',a,b,
                plan['base']['file'],plan['carrier']['file'],plan['stamp'],str(oa),str(ob),mode]
    try:
        persist(); oracles={}
        for case in plan['cases']:
            for side in ['a','b']:
                result=ordinary(case[side]['file'],'oracle-'+case['name']+'-'+side)
                oracles[(case['name'],side)]=result
                if side=='a': require(N.same_bytes(result['file'],case['frozenOld']['file']),'Frozen historical A oracle differs')
            require(oracles[(case['name'],'a')]['sha256']!=oracles[(case['name'],'b')]['sha256'],'Real edit disappeared')
        tiny_oracle=ordinary(plan['tiny']['file'],'oracle-tiny')
        for kind in ['relative-output','output-collision','input-collision','invalid-a','invalid-b']:
            folder=out/('negative-'+kind); oa,ob=safe_outputs(folder,forbidden)
            a=b=plan['tiny']['file']; before=None
            if kind=='relative-output': oa='not-absolute.ssa'
            if kind=='output-collision': ob=oa
            if kind=='input-collision':
                # A sacrificial fresh copy proves input preservation without risking real inputs.
                victim=folder/'sacrificial.bend'; victim.write_bytes(Path(a).read_bytes()); before=pin(victim); a=str(victim); oa=victim
            if kind=='invalid-a': a=plan['invalid']['file']
            if kind=='invalid-b': b=plan['invalid']['file']
            # A failed relative-path guard must still only write in fresh scratch.
            row=execute(session(a,b,oa,ob,'warm'),folder,cwd=folder); row['control']=kind
            report['negativeControls'].append(row); persist()
            require(row['exitCode']>0 and row['stderr']['bytes']>0,'Expected ordinary compiler refusal')
            if before: verify(before)
            elif kind=='invalid-b': require(N.same_bytes(oa,tiny_oracle['file']),'A not complete before B refusal')
            else: require(not (folder/'a.ssa').exists(),'Refused request opened output A')
            require(not (folder/'b.ssa').exists(),'Refused request opened output B')
            require(not (folder/'not-absolute.ssa').exists(),'Relative output guard failed')
            row['complete']=True
        for index,job in enumerate(plan['schedule']):
            case=next(c for c in plan['cases'] if c['name']==job['case'])
            folder=out/f"{index:02d}-{job['case']}-{job['mode']}"; oa,ob=safe_outputs(folder,forbidden)
            row=execute(session(case['a']['file'],case['b']['file'],oa,ob,job['mode']),folder); row.update(job)
            report['rows'].append(row); persist()
            require(row['exitCode']==0 and row['stderr']['bytes']==0,'Native session failed')
            row['products']={s:regular(p) for s,p in [('a',oa),('b',ob)]}
            for side in ['a','b']:
                require(N.same_bytes(row['products'][side]['file'],oracles[(job['case'],side)]['file']),'Session differs from independent fresh oracle')
            row['stats']=parse_stats(folder/'stdout')
            require(row['stats']['A']['counts'][0]==row['stats']['A']['counts'][2]==0,'A unexpectedly has prior cache hits')
            if job['mode']=='cold': require(row['stats']['B']['counts'][0]==row['stats']['B']['counts'][2]==0,'Cold reset retained prior cache')
            else: row['warmReuseObserved']=row['stats']['B']['counts'][0]>0 or row['stats']['B']['counts'][2]>0
            row['byteExact']=True; row['complete']=True; persist()
        report['comparisons']=[]
        for case in plan['cases']:
            pairs=[]
            for r in range(plan['rounds']):
                rows={x['mode']:x for x in report['rows'] if x['case']==case['name'] and x['round']==r}
                w,c=rows['warm'],rows['cold']; pair=dict(round=r,wallRatio=w['wallSeconds']/c['wallSeconds'],cpuRatio=w['cpuSeconds']/c['cpuSeconds'])
                if w['stats']['B']['milliseconds'] is not None:
                    pair['bMillisecondsWarm']=w['stats']['B']['milliseconds']; pair['bMillisecondsCold']=c['stats']['B']['milliseconds']
                    if pair['bMillisecondsCold']>0: pair['bRatio']=pair['bMillisecondsWarm']/pair['bMillisecondsCold']
                pairs.append(pair)
            summary=dict(case=case['name'],pairs=pairs)
            for metric in ['wallRatio','cpuRatio','bRatio']:
                values=[p[metric] for p in pairs if metric in p and p[metric]>0]
                if len(values)==len(pairs): summary[metric+'Geomean']=math.exp(sum(map(math.log,values))/len(values))
            report['comparisons'].append(summary)
        report['complete']=True
    except BaseException as error:
        report['error']=repr(error)
    finally:
        report['changedInputs']=[]
        for row in inputs:
            try: verify(row)
            except (ValueError,OSError): report['changedInputs'].append(row['file'])
        if report['changedInputs']: report['complete']=False
        persist()
    print(json.dumps({k:report.get(k) for k in ['complete','totalSeconds','comparisons','error','changedInputs']}))
    return 0 if report['complete'] else 1


def main():
    ap=argparse.ArgumentParser(description=__doc__); mode=ap.add_mutually_exclusive_group(required=True)
    mode.add_argument('--prepare',action='store_true'); mode.add_argument('--run',action='store_true')
    ap.add_argument('--plan',type=Path,required=True)
    for name in ['build','acquisition','out']: ap.add_argument('--'+name,type=Path)
    args=ap.parse_args()
    if args.prepare:
        require(all(getattr(args,k) for k in ['build','acquisition','out']),'Preparation needs future build/acquisition/result paths')
        return prepare(args)
    return run(args)


if __name__=='__main__': sys.exit(main())
