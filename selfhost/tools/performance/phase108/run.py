#!/usr/bin/env python3
"""Bounded Phase108 transport/build driver; compiler algorithms remain in Bend.
Run inside the Phase86 process-tree guard. Every command retains a receipt.
"""
import argparse, hashlib, importlib.util, json, os, shutil, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def module(name,path):
    s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
N=module('native',ROOT/'selfhost/tools/native/launch.py')
P=module('process',HERE.parent/'phase107/frontend/native/process.py')
def pin(path):return N.pin(path)
def save(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
def main():
    p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest='op',required=True)
    emit=sub.add_parser('emit');emit.add_argument('source',type=Path);emit.add_argument('--runtime',type=Path,required=True);emit.add_argument('--compiler',type=Path);emit.add_argument('--live',action='store_true')
    build=sub.add_parser('build');build.add_argument('source',type=Path);build.add_argument('--backend',choices=['qbe','gcc','clang'],default='qbe');build.add_argument('--metadata',type=Path)
    run=sub.add_parser('run');run.add_argument('binary',type=Path);run.add_argument('--threads',type=int,default=1);run.add_argument('--expected',type=Path);run.add_argument('args',nargs='*')
    for s in [emit,build,run]:s.add_argument('--out',type=Path,required=True);s.add_argument('--seconds',type=float,default=300)
    a=p.parse_args();out=a.out.resolve()
    if not out.is_relative_to(ROOT/'selfhost/build/phase108') or out.exists():raise ValueError('fresh output under phase108 required')
    if shutil.disk_usage(ROOT).free<180*1024**2:raise ValueError('need180MiB headroom')
    out.mkdir(parents=True);report=dict(kind='phase108-'+a.op,version=1,complete=False,method=pin(__file__),jobs=[],inputs=[])
    save(out/'report.json',report);start=time.monotonic()
    def command(label,argv):
        for x in report['inputs']:N.verify(x)
        job=dict(label=label,command=list(map(str,argv)));report['jobs'].append(job);save(out/'report.json',report)
        before=time.monotonic()
        with (out/(label+'.stdout')).open('xb') as stdout,(out/(label+'.stderr')).open('xb') as stderr:
            result=P.run(job['command'],stdout=stdout,stderr=stderr,timeout=a.seconds,cwd=ROOT)
        job.update(status=result.returncode,seconds=time.monotonic()-before,waitMethod=result.wait_method,stdout=pin(out/(label+'.stdout')),stderr=pin(out/(label+'.stderr')))
        save(out/'report.json',report)
        if result.returncode:raise RuntimeError(label+' failed: '+str(out/(label+'.stderr')))
    try:
        if a.op=='emit':
            release,binding=N.load();argv=N.native_args(release,a.source,out/'program',live=a.live)
            runtime=a.runtime.resolve(strict=True)
            argv[argv.index(release['assets']['runtime']['file'])]=str(runtime)
            if a.compiler:argv[0]=str(a.compiler.resolve(strict=True))
            assert runtime.read_bytes()==b''.join(Path(str(runtime)+'.part'+str(i)).read_bytes() for i in range(5)), 'runtime parts differ from template'
            assets=release['assets']
            report['inputs']=[pin(a.source),pin(argv[0]),pin(runtime),*[pin(str(runtime)+'.part'+str(i)) for i in range(5)],binding['selection'],binding['admission'],assets['base'],assets['cache']['carrier'],*assets['effects']]
            if a.compiler:
                lineage=a.compiler.resolve().parent/'report.json'
                record=json.loads(lineage.read_text())
                assert record['complete'] and record['binary']==pin(a.compiler), 'compiler build lineage missing'
                report['inputs'].append(pin(lineage))
            report.update(selection=binding,live=a.live,source=pin(a.source),runtime=pin(runtime),compiler=pin(argv[0]))
            command('emit',argv);report['generatedC']=pin(out/'program.1.c')
        elif a.op=='build':
            source=a.source.resolve(strict=True);report['inputs']=[pin(source)];obj=out/'program.o';binary=out/'program'
            flags=['-DWL_PORTABLE=1']
            if a.metadata:flags+=['-include',str(a.metadata.resolve(strict=True))];report['inputs'].append(pin(a.metadata))
            if a.backend=='qbe':
                tc=ROOT/'selfhost/build/phase108/toolchain';inc=HERE/'toolchain/include';compiler=tc/'cproc-src/cproc';shim=tc/'atomic-shim.o'
                flags+=['-DBEND_CPROC=1','-I',str(inc),'-include',str(inc/'bend-cproc.h')]
                report['inputs'] += [pin(compiler),pin(tc/'cproc-src/cproc-qbe'),pin(tc/'qbe-1.3/qbe'),pin(tc/'cproc-src/config.h'),*[pin(shutil.which(t)) for t in ['gcc','cpp','as','ld']],pin(shim),*[pin(f) for f in sorted(inc.glob('*.h'))]]
                command('object',[compiler,*flags,'-c',source,'-o',obj]);report['object']=pin(obj)
                command('link',['gcc','-no-pie',obj,shim,'-pthread','-lm','-o',binary])
            else:
                compiler=Path(shutil.which('gcc')) if a.backend=='gcc' else Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
                report['inputs'].append(pin(compiler))
                if a.backend=='clang':flags+=['-isystem',str(compiler.parents[1]/'include/clang')]
                command('link',[compiler,'-O2',*flags,source,'-pthread','-lm','-o',binary])
            report.update(binary=pin(binary),backend=a.backend)
        else:
            binary=a.binary.resolve(strict=True);report['inputs']=[pin(binary)]
            if a.expected:report['inputs'].append(pin(a.expected))
            command('execute',[binary,'--threads',str(a.threads),'--gpu','off','--',*a.args])
            if a.expected:
                report['expected']=pin(a.expected)
                if (out/'execute.stdout').read_bytes()!=a.expected.read_bytes():raise RuntimeError('stdout differs from independent expected output')
                report['exactOutput']=True
        for item in report['inputs']:N.verify(item)
        report.update(complete=True,seconds=time.monotonic()-start);save(out/'report.json',report)
        print(json.dumps(dict(complete=True,seconds=report['seconds'],receipt=str(out/'report.json'))))
    except BaseException as error:
        report.update(error=repr(error),seconds=time.monotonic()-start);save(out/'report.json',report);raise
if __name__=='__main__':main()
