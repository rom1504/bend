#!/usr/bin/env python3
"""Acquire a prepared native frontend image; run inside the external Phase86 guard."""
import argparse
import json
import os
import resource
import signal
import subprocess
import time
from pathlib import Path
from run import pin, verify

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[5]


def same_content(actual,expected):
    if any(actual[k]!=expected[k] for k in ['bytes','sha256']):
        raise ValueError('changed admitted file: '+actual['file'])


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source-dir',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--emit-timeout',type=float,default=240)
    p.add_argument('--link-timeout',type=float,default=600)
    p.add_argument('--plan-only',action='store_true')
    a=p.parse_args();begin=time.monotonic();source_dir=a.source_dir.resolve(strict=True);out=a.out.resolve()
    if not out.is_relative_to(ROOT/'selfhost/build/phase107') or out.exists():
        raise ValueError('use a fresh output under selfhost/build/phase107')
    if not 0<a.emit_timeout<=1800 or not 0<a.link_timeout<=1800:
        raise ValueError('timeouts must be positive and at most1800seconds')
    manifest_pin=pin(source_dir/'manifest.json');manifest=json.loads(Path(manifest_pin['file']).read_text())
    if manifest.get('kind')!='phase107-native-frontend-source' or manifest.get('version')!=1 or manifest.get('prepared') is not True:
        raise ValueError('source directory lacks a prepared native frontend manifest')
    source=verify(manifest['source'])
    if Path(source['file'])!=(source_dir/'compiler.bend').resolve():
        raise ValueError('source manifest points outside its prepared compiler path')
    release=ROOT/'selfhost/tools/native/releases/phase103-cli01'
    native_pin=pin(release/'records/native.json');native=json.loads(Path(native_pin['file']).read_text())
    package_pin=pin(release/'receipt.json');package=json.loads(Path(package_pin['file']).read_text())
    if not native.get('complete') or not native.get('generatedCUnmodified') or not package.get('complete') or package.get('kind')!='phase103-native-cli-package':
        raise ValueError('installed compiler acquisition is incomplete')
    emitter=pin(ROOT/'selfhost/bend');same_content(emitter,native['binary'])
    toolchain,startup=verify(native['toolchain']),verify(native['startup'])
    assets=[]
    for expected in package['files']:
        if expected['file'].startswith('assets/'):
            actual=pin(Path(emitter['file']).parent/expected['file']);same_content(actual,expected);assets.append(actual)
    if len(assets)!=16:
        raise ValueError('unexpected installed compiler asset inventory')
    inputs=[pin(__file__),pin(HERE/'run.py'),manifest_pin,source,native_pin,package_pin,emitter,toolchain,startup,*assets,
            verify(manifest['assets']['base']),verify(manifest['assets']['cache']['carrier'])]
    generated,binary=out/'compiler.c',out/'compiler'
    include=Path(toolchain['file']).parents[1]/'include/clang'
    if not include.is_dir():
        raise ValueError('pinned Clang include directory unavailable')
    commands=[('emit',[emitter['file'],source['file'],'-o',str(generated)],a.emit_timeout),
              ('link',[toolchain['file'],'-O2','-isystem',str(include),'-DBEND_NATIVE_HOST=1',
                       '-DBEND_IMAGE_C='+json.dumps(str(generated)),startup['file'],'-lm','-pthread','-o',str(binary)],a.link_timeout)]
    out.mkdir(parents=True)
    report=dict(kind='phase107-native-frontend-acquisition',version=1,complete=False,
                source=source,manifest=manifest_pin,emitter=emitter,toolchain=toolchain,startup=startup,
                inputs=inputs,plannedCommands=[dict(label=n,command=c,timeoutSeconds=t) for n,c,t in commands],
                jobs=[],generatedCUnmodified=False,targetsExecuted=False,
                scope='Image acquisition only; native semantic/runtime qualification is a separate gate.')
    save=lambda:(out/'acquisition.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    if a.plan_only:
        report.update(planned=True,seconds=time.monotonic()-begin);save()
        print(json.dumps(dict(planned=True,complete=False,targetsExecuted=False,receipt=str(out/'acquisition.json'))));return
    try:
        for label,command,timeout in commands:
            for item in inputs:verify(item)
            if label=='link':verify(report['generatedC'])
            before=time.monotonic();job=dict(label=label,command=command,status=None);report['jobs'].append(job);save()
            with (out/(label+'.stdout')).open('xb') as stdout,(out/(label+'.stderr')).open('xb') as stderr:
                child=subprocess.Popen(command,stdout=stdout,stderr=stderr,start_new_session=True)
                try:job['status']=child.wait(timeout=timeout)
                except subprocess.TimeoutExpired:
                    try:os.killpg(child.pid,signal.SIGKILL)
                    except ProcessLookupError:pass
                    child.wait();job['failure']='timeout'
            job.update(seconds=time.monotonic()-before,
                       childrenPeakRssKiBSoFar=resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
                       stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')))
            report['targetsExecuted']=True;save()
            if job['status']!=0:raise RuntimeError(label+' failed; retained acquisition receipt/logs')
            if label=='emit':
                report['generatedC']=pin(generated)
                if not report['generatedC']['bytes']:raise RuntimeError('empty generated C')
                save()
        for item in inputs:verify(item)
        verify(report['generatedC']);report['binary']=pin(binary)
        if not report['binary']['bytes'] or not os.access(binary,os.X_OK):
            raise RuntimeError('link did not produce a nonempty executable')
        report.update(complete=True,generatedCUnmodified=True,seconds=time.monotonic()-begin);save()
        image=dict(kind='phase107-native-frontend-image',version=1,complete=True,manifest=manifest_pin,
                   source=source,binary=report['binary'],acquisition=pin(out/'acquisition.json'))
        (out/'image.json').write_text(json.dumps(image,indent=2)+'\n')
        print(json.dumps(dict(complete=True,image=str(out/'image.json'),seconds=report['seconds'])))
    except Exception as error:
        report.update(error=str(error),seconds=time.monotonic()-begin);save();raise


if __name__=='__main__':main()
