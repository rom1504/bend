#!/usr/bin/env python3
"""Construct the public CLI from authenticated Bend-produced C and its argv wrapper."""
import argparse
import json
from pathlib import Path
import shutil
import sys
import time
sys.dont_write_bytecode = True
import assets
from common import ROOT, clean_environment, fresh_output, pin, require, run, verify, write_json

def same(a,b):
    return isinstance(a,dict) and isinstance(b,dict) and all(a.get(k)==b.get(k) for k in ('bytes','sha256'))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    for name in ['profile','bridge-profile','bridge-build','emission','assets','out']:
        ap.add_argument('--'+name,type=Path,required=True)
    ap.add_argument('--seconds',type=float,default=420)
    args=ap.parse_args();clean_environment()
    profile=json.loads(args.profile.read_text());bridge=json.loads(args.bridge_profile.read_text())
    built=json.loads(args.bridge_build.read_text());emitted=json.loads(args.emission.read_text())
    require(profile.get('kind')=='bend-public-cli-source-profile' and profile.get('complete') and profile['allOtherBodiesIdentical'],'Exact public profile required')
    require(bridge.get('kind')=='bend-public-cli-build-bridge' and bridge.get('complete')
            and bridge['allOtherBodiesIdentical'] and same(bridge['publicSource'],profile['source'])
            and same(bridge['foreignProvider'],profile['foreignProvider']), 'Wrong exact-provider build-only bridge')
    require(built.get('kind')=='bend-native-build' and built.get('complete') and not built.get('changedInputs')
            and same(built['request']['source'],bridge['source'])
            and built['imageBinding']['protocol']=='native-c-source-v1','Actual bridge construction required')
    require(emitted.get('kind')=='bend-build-request' and emitted.get('complete') and not emitted.get('changedInputs')
            and emitted.get('host')=='native' and emitted.get('target')=='c'
            and same(emitted['image'],built['binary']) and same(emitted['source'],profile['source'])
            and same(emitted['request']['imageMetadata']['sourceIdentity'],bridge['source']),
            'Actual same-profile Bend-produced C required')
    require(same(emitted['request']['inputs'][0],bridge['assets']),'Emission did not use exact build-only provider map')
    document=assets.load_assets(args.assets,ROOT);clang=assets.asset(document,'clang')
    runtime=emitted['request']['providers']['runtime'];product=emitted['product']
    require(same(runtime,assets.asset(document,'c-runtime')),'Final C runtime differs')
    startup=ROOT/'selfhost/src/host/native-c-start.c'
    includes=document['toolchains']['c']['includeFlags']
    require(len(includes)==2 and includes[0]=='-isystem','Explicit Clang resource include required')
    text=verify(product).read_text()
    for macro,value in [('NATIVE_PACK_CTORS',1),('NATIVE_READONLY_OBSERVERS',1),('NATIVE_SCALAR_ARRAYS',0)]:
        require('#define '+macro+' '+str(value)+'\n' in text,'Required admitted C policy absent: '+macro)
    inputs=[pin(__file__),pin(Path(__file__).with_name('common.py')),pin(assets.__file__),pin(startup),
            pin(args.profile),pin(args.bridge_profile),pin(args.bridge_build),pin(args.emission),document['_manifest'],
            clang,pin(Path(includes[1])/'stdbool.h'),product,runtime,*profile['inputs'],*bridge['inputs'],
            *built['inputs'],*emitted['inputs'],*profile['assets'].values()]
    for row in inputs:verify(row)
    out=fresh_output(args.out,ROOT)
    report=dict(kind='bend-public-cli-package',version=1,complete=False,qualified=False,installed=False,
        host='native',stage='N1',targets=['c'],protocol='native-public-cli-v1',source=profile['source'],
        canonicalSource=profile['canonicalSource'],baseIdentity=profile['baseIdentity'],cacheStamp=profile['cacheStamp'],
        profile=pin(args.profile),bridgeProfile=pin(args.bridge_profile),bridgeBuild=pin(args.bridge_build),
        emission=pin(args.emission),runtime=runtime,startup=pin(startup),inputs=inputs,assets={},jobs=[],
        generatedCUnmodified=True,constructionBackend='c',
        scope='Bend-produced public CLI from the one canonical compiler through an exact-provider build-only bridge. '
              'The installed candidate retains ordinary admission. Independent public CLI qualification is still required.')
    start=time.monotonic();write_json(out/'BUILD.json',report)
    try:
        command=[clang['file'],'-O2',*includes,'-DBEND_NATIVE_HOST=1','-DBEND_IMAGE_C='+json.dumps(product['file']),
                 str(startup),'-lm','-pthread','-o',str(out/'bend')]
        job=run(command,cwd=ROOT,stdout=out/'construct.stdout',stderr=out/'construct.stderr',seconds=args.seconds)
        report['jobs'].append(dict(name='construct',**job));write_json(out/'BUILD.json',report)
        require(job['complete'] and job['stdout']['bytes']==0,'C construction failed')
        for name,row in profile['assets'].items():
            require(not Path(name).is_absolute() and '..' not in Path(name).parts,'Invalid asset path')
            dest=out/'assets'/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(row['file'],dest)
            report['assets'][name]=pin(dest);require(same(report['assets'][name],row),'Copied asset differs')
        report['image']=pin(out/'bend')
        for row in inputs:verify(row)
        report['complete']=True
        report['imageBinding']=dict(kind='bend-build-image-binding',version=1,complete=True,host='native',stage='N1',
            targets=['c'],protocol='native-public-cli-v1',image=report['image'],sourceIdentity=profile['source'],
            linkedRuntime=runtime,producer=emitted['image'],packageAssets=report['assets'],
            baseIdentity=profile['baseIdentity'],cacheStamp=profile['cacheStamp'],targetRuntime=runtime,
            qualification='Constructed; separate public CLI qualification required.')
    except BaseException as error:report['error']=repr(error)
    report['seconds']=time.monotonic()-start;write_json(out/'BUILD.json',report)
    print(json.dumps({k:report.get(k) for k in ['complete','image','error']}))
    return 0 if report['complete'] else 1

if __name__=='__main__':raise SystemExit(main())
