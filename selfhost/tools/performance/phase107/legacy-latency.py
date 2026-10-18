#!/usr/bin/env python3
"""Paired installed Bend/C/Clang versus native Bend/QBE main compilation and execution."""
import argparse, hashlib, json, math, os, shutil, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MASK=2**32-1;CASES=['arithmetic','recurrence','compiler_classify']
sys.path.insert(0,str(HERE/'frontend/native'))
from process import run as run_process
def pin(file):
    file=Path(file).resolve(strict=True);raw=file.read_bytes();return dict(file=str(file),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def same(a,b):return all(a[k]==b[k] for k in ['bytes','sha256'])
def answer(name):
    n,s=19,23
    if name=='arithmetic':
        x=((n*1664525+1013904223)&MASK)^s;return ((x*1664525+1013904223)&MASK)^((s+7)&MASK)
    if name=='compiler_classify':return int(65<=n<=90 or 97<=n<=122 or 48<=n<=57 or n in (95,46))+2*int(s==32 or 9<=s<=13)
    assert name=='recurrence'
    for x in range(n,0,-1):s=((s*33+x)&MASK)^2654435769
    return s
def main(suite=None):
    suite=suite or {};cases=list(suite.get('sources',CASES));source_for=lambda name:Path(suite['sources'][name]) if suite else HERE/'cases'/(name+'.bend')
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--image',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--case',action='append',choices=cases);p.add_argument('--rounds',type=int,default=3);p.add_argument('--max-seconds',type=float,default=60)
    p.add_argument('--installed',type=Path,default=ROOT/'selfhost/bend');p.add_argument('--package',type=Path,default=ROOT/'selfhost/tools/native/releases/phase103-cli01/receipt.json')
    p.add_argument('--clang',type=Path,default=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang'));p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe')
    a=p.parse_args();assert 1<=a.rounds<=10 and 1<=a.max_seconds<=600;names=list(dict.fromkeys(a.case or cases));start=time.monotonic();known={}
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);a.image=a.image.resolve(strict=True);installed=a.installed.resolve(strict=True);a.clang=a.clang.resolve(strict=True);a.qbe=a.qbe.resolve(strict=True);compiler=HERE/'frontend/native/compile.py'
    for name,item in suite.get('identity',{}).items():assert pin(getattr(a,name))==item,'suite identity changed: '+name
    if suite:assert names==cases and a.rounds==3,'frozen suite requires all sources and three rounds'
    def remember(item):
        assert pin(item['file'])==item,item;assert known.setdefault(item['file'],item)==item,'changed input'
    methods=[Path(__file__),compiler,compiler.with_name('cache.py'),compiler.with_name('run.py'),compiler.with_name('process.py'),*suite.get('methods',[])];snapshots=[]
    for file in [*methods,a.image,a.package,installed,a.clang,a.qbe,sys.executable,'/usr/bin/as','/usr/bin/gcc','/usr/bin/ld',*[source_for(n) for n in names]]:remember(pin(file))
    for item in suite.get('inputs',[]):remember(item)
    package=json.loads(a.package.read_text());assert package['complete'] and package['kind']=='phase103-native-cli-package'
    for item in package['files']:
        file=(installed.parent/item['file']).resolve(strict=True);assert installed.parent in file.parents;actual=pin(file);assert same(actual,item);remember(actual)
    bundle=json.loads((installed.parent/'BUILD.json').read_text());assert bundle['native']['complete'] and same(pin(installed),bundle['native']['binary']) and same(pin(a.clang),bundle['native']['toolchain'])
    image=json.loads(a.image.read_text());assert image['complete'] and image['kind']=='phase107-native-frontend-image'
    for k in ['source','binary','manifest','acquisition']:remember(image[k])
    manifest=json.loads(Path(image['manifest']['file']).read_text());assert manifest['source']==image['source'] and manifest['fastPipeline']['expression']=='nx_reachable(nx_optimize(nx_inline_entry(nx_tail_optimize(program), 4096)))'
    assert same(manifest['assets']['base'],bundle['inputs']['assets']['base.bend']) and same(manifest['assets']['cache']['carrier'],bundle['inputs']['assets']['base.p88']) and manifest['assets']['cache']['stamp']==bundle['inputs']['cache']['stamp']
    include=a.clang.parents[1]/'include/clang';assert include.is_dir()
    for file in sorted(p for p in include.rglob('*') if p.is_file()):remember(pin(file))
    for name in ['libLLVM.so.22.1','libclang-cpp.so.22.1']:remember(pin(a.clang.parents[1]/'lib'/name))
    for file in methods:
        dest=out/('method-'+file.name);shutil.copyfile(file,dest);snapshots.append(pin(dest))
    expected={name:suite['expected'][name] if suite else answer(name) for name in names}
    for name,value in expected.items():(out/(name+'-expected.stdout')).write_bytes((str(value)+'\n').encode())
    report=dict(kind=suite.get('kind','phase107-incumbent-native-latency'),complete=False,passed=False,started=time.time(),inputs=[],snapshots=snapshots,installed=pin(installed),package=pin(a.package),image=pin(a.image),cases=names,rounds=a.rounds,maxSeconds=a.max_seconds,expectedMain=expected,oracle='Independent masked U32 evaluation of fixture main()=bench(19,23); exact decimal stdout plus LF and empty stderr for both programs.',scope='Installed native Bend CLI to C to Clang-O2 versus experimental native Bend frontend to QBE/binutils, both prepared Base, same zero-argument main. No object caches, every object rebuilt. Finite source-to-executable/result comparison, not compiler-wide qualification or a universal speedup.',clockScope='Primary source-to-executable seconds sum complete compiler subprocess walls; source-to-result adds program process wall. Full supervisor interval also retained. Native driver wall includes Python startup/authentication and cache-capable orchestration with object cache disabled; installed Bend authenticates its assets internally. One-time tool/version/input audit is excluded from paired measurements.',affinity=sorted(os.sched_getaffinity(0)),jobs=[],builds=[],pairs=[])
    def save():
        report['inputs']=list(known.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    if suite:report.update(oracle=suite['oracle'],scope=suite['scope'],freeze=suite['freeze'])
    report['waitPolicy']='Same pidfd outer wait for legacy and native arms; native driver inner waits also use pinned helper; unsupported kernels retain polling fallback.'
    report['setupSeconds']=time.monotonic()-start;deadline=time.monotonic()+a.max_seconds;save()
    def run(label,command,stdout=None):
        remaining=deadline-time.monotonic();assert remaining>0,'batch deadline reached';row=dict(label=label,command=list(map(str,command)),started=time.time(),complete=False);report['jobs'].append(row);save();before=time.monotonic();so,se=out/(label+'.stdout'),out/(label+'.stderr')
        try:
            with so.open('xb') as x,se.open('xb') as y:r=run_process(row['command'],cwd=ROOT,stdout=x,stderr=y,timeout=min(30,remaining))
            row.update(status=r.returncode,complete=True,pid=r.pid,waitMethod=r.wait_method,waitFallback=r.wait_fallback)
        except Exception as error:
            row.update(error=repr(error),pid=getattr(error,'pid',None),waitMethod=getattr(error,'wait_method',None),killedChildReturncode=getattr(error,'returncode',None));raise
        finally:
            row.update(seconds=time.monotonic()-before,finished=time.time())
            for key,file in [('stdout',so),('stderr',se)]:
                if file.exists():row[key]=pin(file)
            save()
        assert r.returncode==0,(label,str(se))
        if stdout is not None:assert so.read_bytes()==stdout and se.read_bytes()==b'',(label,'unexpected literal output',str(so))
        return row
    def build(name,turn,engine):
        label=name+'-'+str(turn)+'-'+engine;dest=out/label;source=source_for(name);begin=time.monotonic();source_pin=pin(source);value=expected[name]
        if engine=='legacy':
            dest.mkdir();generated=dest/'program.c';binary=dest/'program'
            emit=run(label+'-emit',[installed,source,'-o',generated]);remember(pin(generated));assert generated.stat().st_size>0
            link=run(label+'-clang',[a.clang,'-O2','-isystem',include,generated,'-lm','-pthread','-o',binary]);remember(pin(binary))
            components=dict(frontendWallSeconds=emit['seconds'],clangWallSeconds=link['seconds']);seconds=emit['seconds']+link['seconds'];product=pin(generated);receipt=None;command=[binary,'--threads','1','--gpu','off']
        else:
            compile_job=run(label+'-compile',[sys.executable,'-B',compiler,source,'--image',a.image,'--out',dest,'--entry','main','--policy','fast','--base','cache','--qbe',a.qbe,'--whole-object'])
            child=json.loads((dest/'report.json').read_text());assert child['complete'] and child['kind']=='phase107-native-qbe-compilation' and child['source']==source_pin and child['identity']['image']==pin(a.image) and child['identity']['binary']==image['binary']
            assert child['options']==dict(entry='main',policy='fast',base='cache',abiSalt='',objectMode='whole') and all(j['status']==0 for j in child['jobs'])
            assert {r['name'] for r in child['cache']}=={'program','common_runner'} and all(not r['hit'] for r in child['cache'])
            for item in [*child['methods'],*child['tools'].values(),child['runner'],*child['identity'].values(),child['binary'],child['transport']]:
                if item is not None:remember(item)
            receipt=pin(dest/'report.json');remember(receipt);binary=Path(child['binary']['file']);product=child['transport'];seconds=compile_job['seconds'];components={k:v for k,v in child.items() if k.endswith('Seconds')};components['driverTotalSeconds']=child['seconds'];command=[binary,'--expect',value]
        executable_wall=time.monotonic()-begin;execution=run(label+'-execute',command,(str(value)+'\n').encode());assert pin(source)==source_pin
        item=dict(id=label,case=name,round=turn,engine=engine,source=source_pin,binary=pin(binary),product=product,receipt=receipt,sourceToExecutableSeconds=seconds,executionSeconds=execution['seconds'],sourceToResultSeconds=seconds+execution['seconds'],supervisorToExecutableSeconds=executable_wall,supervisorToResultSeconds=time.monotonic()-begin,components=components,output=execution['stdout'],stderr=execution['stderr'],expected=value);report['builds'].append(item);save();return item
    try:
        version=run('clang-version',[a.clang,'--version']);assert 'clang version 22.' in Path(version['stdout']['file']).read_text();report['clangVersion']=version['stdout'];save()
        for turn in range(a.rounds):
            for index,name in enumerate(names):
                order=['legacy','native'] if (turn+index)%2==0 else ['native','legacy'];pair={engine:build(name,turn,engine) for engine in order}
                assert same(pair['legacy']['output'],pair['native']['output']);report['pairs'].append(dict(case=name,round=turn,order=order,stdoutEqual=True,ratios={metric:pair['native'][metric]/pair['legacy'][metric] for metric in ['sourceToExecutableSeconds','sourceToResultSeconds']}));save()
        summaries=[]
        for name in names:
            for metric in ['sourceToExecutableSeconds','sourceToResultSeconds']:
                samples={engine:[b[metric] for b in report['builds'] if b['case']==name and b['engine']==engine] for engine in ['legacy','native']};medians={k:statistics.median(v) for k,v in samples.items()};ratio=medians['native']/medians['legacy'];summaries.append(dict(case=name,metric=metric,samples=samples,medianSeconds=medians,nativeToLegacyMedianRatio=ratio,atLeast25PercentShorter=ratio<=0.75))
        for item in known.values():assert pin(item['file'])==item
        assert pin(a.installed)==pin(installed),'installed selection changed'
        report.update(complete=True,passed=True,summaries=summaries,geometricMeanRatios={metric:math.exp(statistics.mean(math.log(r['nativeToLegacyMedianRatio']) for r in summaries if r['metric']==metric)) for metric in ['sourceToExecutableSeconds','sourceToResultSeconds']})
    except Exception as error:report['error']=repr(error);raise
    finally:report.update(finished=time.time(),wallSeconds=time.monotonic()-start);save()
    print(json.dumps(dict(complete=True,passed=True,pairs=len(report['pairs']),report=pin(out/'report.json'))))
if __name__=='__main__':main()
