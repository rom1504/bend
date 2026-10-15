#!/usr/bin/env python3
"""Root-owned serial minimal origin fix gates; one bounded old failure, one native control."""
import argparse
import importlib.util
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('qualifier',HERE/'qualify-v5.py');Q=importlib.util.module_from_spec(spec);spec.loader.exec_module(Q)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--prepare-only',action='store_true');args=p.parse_args()
    out=args.out.resolve();assert out.is_relative_to(Q.BUILD) and not out.exists();out.mkdir(parents=True)
    inputs={};report=dict(kind='phase98-origin-guard-qualification',complete=False,targetsRun=False,rows=[])
    def bind(path):
        row=Q.pin(path);assert inputs.setdefault(row['file'],row)==row;return row
    def verify(v):
        if isinstance(v,dict):
            if {'file','bytes','sha256'}<=v.keys():assert bind(v['file'])==v
            else:
                for x in v.values():verify(x)
        elif isinstance(v,list):
            for x in v:verify(x)
    def save():report['inputs']=list(inputs.values());Q.save(out/'report.json',report)
    try:
        recipe_path=Q.BUILD/'origin-guard-source01/changes.json';recipe=Q.read(recipe_path);verify(recipe);bind(recipe_path)
        assert recipe['candidate']['sha256']=='2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
        replay=Path(recipe['source']['file']).read_text()
        for c in recipe['changes']:
            at=c['offset'];assert replay[at:at+len(c['old'])]==c['old'];replay=replay[:at]+c['new']+replay[at+len(c['old']):]
        assert replay==Path(recipe['candidate']['file']).read_text()
        audit=Q.read(HERE/'source-audit.json');verify(audit)
        inherited_path=Q.BUILD/'observer-cost-controls02/report.json';inherited=Q.read(inherited_path);verify(inherited);assert inherited['complete'];bind(inherited_path)
        values=Q.read(inherited['controls']['file']);verify(values);assert values['complete'];bind(inherited['controls']['file'])
        expected={r['id']:r['c'] for r in values['rows'] if r['kind']=='complete-C-and-diagnostic'}
        plan=dict(kind='phase98-minimal-origin-inputs',recipe=bind(recipe_path),audit=bind(HERE/'source-audit.json'),parentCQualification=bind(inherited_path),
            apis={r:str(out/(r+'.mjs')) for r in ['baseline','candidate']},sources={'baseline':recipe['parentSource'],'candidate':recipe['candidate']},
            controls=[dict(id='real-io',source=bind(HERE.parent/'comparison/held-io-smoke01.bend'),expectedC=expected['real-io']),
                      dict(id='generic-array',source=bind(HERE/'generic-array-string-v2.bend'),expectedC=expected['generic-array']),
                      dict(id='schema-refusals',source=bind(HERE/'schema-refusals.bend'),expectedC=expected['schema-refusals']),
                      dict(id='origin-swap',source=bind(HERE/'origin-swap01.bend'),declinedOwner='p98_origin_swap',stdout='1\n',stderr='observer-origin\n')])
        Q.save(out/'plan.json',plan);bind(out/'plan.json')
        node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
        for f in [__file__,HERE/'qualify-v5.py',HERE/'origin-controls.mjs',Q.STAGE0,Q.GUARD,Q.CLANG,node,Q.ROOT/'selfhost/tools/typed-driver.mjs',Q.ROOT/'selfhost/dist/typed-api.mjs']:bind(f)
        upstream_path=Q.ROOT/'selfhost/build/phase86/upstream.json';upstream=Q.read(upstream_path);verify(upstream);bind(upstream_path);assert upstream['revision']=='059266225b77c8ca256ac6b25ee5c21449bab151'
        commands=[]
        for role in ['baseline','candidate']:
            exports=['noa_below','kt']+(['nc_compile_checked','nc_foreign_paths'] if role=='candidate' else [])
            commands.append(dict(name='api-'+role,seconds=120,rss=4096,available=16384,argv=['env','BEND_UPSTREAM='+str(Q.UPSTREAM),str(node),'--stack-size=65536','--max-old-space-size=3072',str(Q.STAGE0),plan['sources'][role]['file'],plan['apis'][role],*exports]))
        for mode,seconds,stack in [('old-positive',10,1024),('old-mismatch',3,1024),('candidate',120,16384)]:
            commands.append(dict(name=mode,seconds=seconds,rss=4096 if mode=='candidate' else 512,available=16384 if mode=='candidate' else 4096,
                expectedFailure=mode=='old-mismatch',argv=[str(node),'--stack-size='+str(stack),'--max-old-space-size=3072' if mode=='candidate' else '--max-old-space-size=256',str(HERE/'origin-controls.mjs'),mode,str(out/'plan.json'),str(out/'values')]))
        commands.extend([dict(name='swap-clang',seconds=90,rss=2048,available=4096,argv=[str(Q.CLANG),'-isystem',str(Q.CLANG.parent.parent/'include/clang'),'-O2',str(out/'values/origin-swap.c'),'-o',str(out/'swap-program'),'-lm','-pthread']),
                         dict(name='swap-run',seconds=15,rss=1024,available=4096,argv=[str(out/'swap-program'),'--threads','1','--gpu','off'])])
        Q.save(out/'commands.json',commands);report.update(plan=bind(out/'plan.json'),commands=commands);save()
        if args.prepare_only:report.update(complete=True,preparedOnly=True);save();return
        for command in commands:
            folder=out/(command['name']+'-guard');argv=[sys.executable,'-B',str(Q.GUARD),'--out',str(folder),'--seconds',str(command['seconds']),'--rss-mib',str(command['rss']),'--available-mib',str(command['available']),'--cpu','3','--',*command['argv']]
            report['targetsRun']=True;save();job=subprocess.run(argv,cwd=Q.ROOT,capture_output=True,text=True)
            (out/(command['name']+'.stdout')).write_text(job.stdout);(out/(command['name']+'.stderr')).write_text(job.stderr)
            process=Q.read(folder/'process.json');row=dict(name=command['name'],launcherExit=job.returncode,guard=bind(folder/'process.json'),process=process);report['rows'].append(row);save()
            if command.get('expectedFailure'):
                assert not(process['complete'] and process['returncode']==0 and not process.get('stoppedFor'))
                assert not(folder/'stdout.log').read_text().strip(),'old mismatch unexpectedly returned'
                row['interpretation']='Bounded pre-fix failure/nontermination witness; no semantic success credited.'
            else:assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),command['name']
            if command['name']=='old-positive':assert (folder/'stdout.log').read_text()=='true\n'
            if command['name']=='swap-run':
                assert (folder/'stdout.log').read_text()=='1\n' and (folder/'stderr.log').read_text()=='observer-origin\n';row['fullOutputExact']=True
        result=Q.read(out/'values/report.json');assert result['complete'];verify(result);report['controls']=bind(out/'values/report.json');bind(out/'swap-program')
        for row in inputs.values():assert Q.pin(row['file'])==row
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:report['error']=repr(error);raise
    finally:save()


if __name__=='__main__':main()
