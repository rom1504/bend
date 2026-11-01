#!/usr/bin/env python3
"""Fresh-root profiler smoke using maintained methods under one outer disk guard.

The compiler branch samples an actual native Bend compiler. Its first clean
product is a stability reference, not independent language-conformance proof.
"""
import argparse
import json
from pathlib import Path
import re
import shutil
import sys

ROOT=Path(__file__).resolve().parents[3]
PROF=ROOT/'selfhost/tools/profiler'
BUILD=ROOT/'selfhost/tools/build'
sys.path.insert(0,str(BUILD))
from assets import load_assets,asset
from common import pin,verify,run,write_json,fresh_output,timeout


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--kind',choices=['all','events','compiler'],default='all')
    p.add_argument('--assets',type=Path)
    p.add_argument('--runtime-assets',type=Path)
    p.add_argument('--source',type=Path)
    p.add_argument('--image-key',default='qbe-n2')
    p.add_argument('--stage',default='N2')
    p.add_argument('--mode',choices=['cache','live'],default='live')
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--seconds',type=float,default=90)
    a=p.parse_args();timeout(a.seconds)
    compiler=a.kind in ['all','compiler'];events=a.kind in ['all','events']
    if compiler and (a.assets is None or a.source is None):p.error('Compiler smoke requires --assets and --source')
    if events and a.runtime_assets is None:p.error('Event smoke requires --runtime-assets')
    out=fresh_output(a.out,ROOT);(out/'inputs').mkdir();(out/'steps').mkdir();(out/'methods').mkdir()
    report=dict(schema='bend-maintained-profiler-smoke-v1',complete=False,kind=a.kind,
                inputs=[pin(__file__),pin(BUILD/'common.py'),pin(BUILD/'assets.py'),pin(sys.executable)],steps=[],
                nativeCompilerProfile=compiler,runtimeABIControl=events,
                ownershipOrWholeCompilerProof=False,compiledProgramSpeedMeasured=False,
                scope='Existing profiler methods under one outer guard; fresh output root; no diagnostic time reported as clean speed.')
    def save():write_json(out/'report.json',report)
    def snapshot(path,name):
        path=Path(path).resolve();identity=pin(path);target=out/'inputs'/name
        shutil.copyfile(path,target);copied=pin(target)
        if (copied['bytes'],copied['sha256'])!=(identity['bytes'],identity['sha256']):raise ValueError('Snapshot differs')
        report['inputs'].append(identity);report.setdefault('snapshots',[]).append(dict(original=identity,snapshot=copied))
        return target
    def invoke(label,command):
        process=run(command,cwd=ROOT,stdout=out/'steps'/(label+'.stdout'),stderr=out/'steps'/(label+'.stderr'),seconds=a.seconds)
        report['steps'].append(dict(name=label,process=process));save()
        if not process['complete']:raise ValueError('Smoke step failed/refused: '+label)
    def tool(label,name,*arguments):invoke(label,[sys.executable,'-B',str(PROF/name),*map(str,arguments)])
    try:
        names={'run.py','analyze.py','elf.py','freeze.py','build-sampler.py'} if compiler else set()
        if events:names|={'runtime.py','concat_v1.py','build-runtime.py','check-runtime.py','run.py','runtime-support.inc.c',
                         'controls/runtime-control.c','controls/runtime-control.expected.json','controls/migration.json'}
        for name in sorted(names):
            source=PROF/name;row=pin(source);report['inputs'].append(row)
            shutil.copyfile(source,out/'methods'/(row['sha256']+'-'+source.name))
        if compiler:
            report['inputs'].append(pin(BUILD/'request.py'))
            source=snapshot(a.source,'program.bend')
            if set(re.findall(r'^import\s+(\S+)',source.read_text(),re.M))-{'Base'}:
                raise ValueError('Smoke source must be self-contained apart from explicit Base')
            assets_path=snapshot(a.assets,'compiler-assets.json')
            document=load_assets(assets_path,ROOT)
            cc=asset(document,'linker');report['inputs'].append(cc)
            command=[sys.executable,'-B',str(BUILD/'request.py'),'--assets',str(assets_path),
                     '--image-key',a.image_key,'--host','native','--target','qbe','--stage',a.stage,
                     '--source',str(source),'--mode',a.mode,'--seconds',str(a.seconds),'--out',str(out/'clean-request')]
            # Preflight and its exact argv are captured before the first target.
            invoke('request-preflight',command+['--plan'])
            request=json.loads((out/'steps/request-preflight.stdout').read_text())
            write_json(out/'request-plan.json',request)
            report['inputs']+=request['inputs']
        if events:
            runtime_assets=snapshot(a.runtime_assets,'runtime-assets.json');document=load_assets(runtime_assets,ROOT)
            recipe=document['runtimeRecipes']['serial-rfc']
            cc=asset(document,recipe['compiler']);runtime=asset(document,recipe['source'])
            headers=[asset(document,key) for key in recipe['headers']]
            report['inputs'] += [cc,runtime,*headers]
            write_json(out/'runtime-input.json',dict(runtime=runtime,headers=headers,compiler=cc['file'],linker=cc['file'],compileFlags=recipe['flags']))
        save()
        if events:
            tool('runtime-plan','runtime.py','--manifest',out/'runtime-input.json','--out',out/'runtime','--concat-v1')
            tool('runtime-build','build-runtime.py','--plan',out/'runtime/plan.json','--out',out/'runtime-build')
            tool('runtime-control','check-runtime.py','--runtime-plan',out/'runtime/plan.json','--build-report',out/'runtime-build/report.json',
                 '--expected',out/'runtime/expected-control.json','--out',out/'runtime-control')
            control=json.loads((out/'runtime-control/report.json').read_text())
            if not control['complete']:raise ValueError('Runtime ABI control incomplete')
            report['eventControl']=pin(out/'runtime-control/report.json')
            report['concatPositiveBranches']='Source-audited only; independent fixture qualifies old channels and seven zero columns.'
        if compiler:
            invoke('clean-request',command)
            clean=json.loads((out/'clean-request/report.json').read_text())
            if not clean['complete'] or clean['changedInputs'] or clean['request']['command']!=request['command']:
                raise ValueError('Clean native compiler request is incomplete or differs from preflight')
            for row in clean['inputs']+[clean['product'],clean['process']['stderr']]:verify(row)
            if clean['process']['stderr']['bytes']!=0 or clean['process']['stdout']!=clean['product']:
                raise ValueError('Clean QBE output contract differs')
            document=load_assets(assets_path,ROOT);cc=asset(document,'linker')
            tool('sampler-build','build-sampler.py','--cc',cc['file'],'--out',out/'sampler')
            sampler=json.loads((out/'sampler/report.json').read_text())
            if not sampler['complete']:raise ValueError('Sampler build incomplete')
            recipe=dict(cwd=str(ROOT),sampler=sampler['sampler']['file'],
                scope='Actual native Bend compiler whole request including '+a.mode+' Base preparation; emitted lexer execution is not measured. Fresh clean output is stability reference only.',
                inputs=list(dict.fromkeys([r['file'] for r in report['inputs']]+[str(out/'clean-request/report.json'),str(out/'sampler/report.json')])),
                workloads=[dict(name='lexer-compile',timeoutSeconds=a.seconds,variants=[dict(name=a.image_key,command=request['command'],
                    stdout=clean['product']['file'],stderr=clean['process']['stderr']['file'])])])
            write_json(out/'recipe.json',recipe)
            tool('freeze','freeze.py','--recipe',out/'recipe.json','--out',out/'workload.json')
            tool('capture','run.py','--manifest',out/'workload.json','--out',out/'capture','--modes','clean,sample','--rounds','1','--periods-us','250')
            capture=json.loads((out/'capture/report.json').read_text())
            if not capture['complete'] or not capture['passed']:raise ValueError('Native compiler profile/output smoke failed')
            report.update(capture=pin(out/'capture/report.json'),profilesUsable=capture['profilesUsable'],
                          oracleRole='Fresh same-image clean stability oracle, not independent conformance.',
                          ownerBoundary='The emitted program QBE cannot be used as the sampled compiler ELF owner map.')
        for row in report['inputs']:verify(row)
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()
    print(json.dumps({key:report.get(key) for key in ['complete','kind','profilesUsable','compiledProgramSpeedMeasured']}))


if __name__=='__main__':main()
