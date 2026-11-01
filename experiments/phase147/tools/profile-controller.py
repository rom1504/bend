#!/usr/bin/env python3
"""Frozen Phase147 controller. Preparation is offline; build/capture are root-only."""
import argparse, hashlib, json, os, shutil, subprocess, sys
from pathlib import Path
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'selfhost/manifests/current.json').is_file())
P=ROOT/'selfhost/tools/profiler'
sys.dont_write_bytecode=True
sys.path.insert(0,str(P))
from run import pin,verify,save,execute
from freeze import freeze

def call(name,args,log):
    log.parent.mkdir(parents=True,exist_ok=True)
    with log.open('xb') as stream:
        subprocess.run([sys.executable,'-B',str(P/name),*map(str,args)],cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=120)

def read(path):return json.loads(Path(path).read_text())
def need(condition,message):
    if not condition:raise ValueError(message)
def item(path):return pin(ROOT/path)
def prepare(out):
    out.mkdir(parents=True,exist_ok=False)
    current=read(ROOT/'selfhost/manifests/current.json');native=read(ROOT/'selfhost/manifests/assets-native.json');runtime=read(ROOT/'selfhost/manifests/assets-runtime.json')
    original=ROOT/'selfhost/build/phase134/p146-context01-n2/report.json';build=read(original)
    selected=verify({**current['components']['qbe']['image'],'file':str(ROOT/current['components']['qbe']['image']['file'])})
    need(pin(selected)['sha256']==build['binary']['sha256'],'Selected executable differs from retained-object build')
    for key in ['object','expectedQbe','source','runtime']:verify(build[key])
    need(build['complete'] and build['comparedToReference'] and build['irDigest']['sha256']==build['expectedQbe']['sha256'],'Missing whole-IR product identity')
    need(build['irDigest']['sha256']==current['components']['qbe']['canonicalEquivalence']['qualifiedQbeIdentity']['sha256'],'Canonical bridge differs')
    acquired=out/'inputs';acquired.mkdir()
    for key,name in [('object','program.o'),('expectedQbe','program.ssa'),('source','image-source.bend')]:shutil.copyfile(verify(build[key]),acquired/name)
    # Explicit retained data acquisition; no historical implementation is imported.
    shutil.copyfile(original,acquired/'image-build.json')
    shutil.copyfile(ROOT/'selfhost/manifests/current.json',acquired/'current.json')
    shutil.copyfile(ROOT/'selfhost/manifests/assets-native.json',acquired/'assets-native.json')
    shutil.copyfile(ROOT/'selfhost/manifests/assets-runtime.json',acquired/'assets-runtime.json')
    call('owners.py',['--qbe',acquired/'program.ssa','--emitter-source',acquired/'image-source.bend','--output',out/'owners.json'],out/'logs/owners.txt')
    import attribute
    owners=read(out/'owners.json');_,linked,binding=attribute.bind_owners(owners,selected)
    save(out/'selected-elf-binding.json',{'complete':True,'selected':pin(selected),'binding':binding,'fids':len(linked)})
    previous=ROOT/'selfhost/build/phase127/libc-unwind01/table.json';table=read(previous)
    libc=verify(table['object'])
    ranges={'object':pin(libc),'ranges':[{'start':r['start'],'end':r['end']} for r in table['rows']], 'origin':pin(previous),'scope':'Retained explicit libc ranges rechecked against current ELF CFI; only these ranges receive physical caller inference.'}
    save(out/'libc-ranges.json',ranges)
    call('unwind.py',['--object',libc,'--ranges',out/'libc-ranges.json','--out',out/'unwind'],out/'logs/unwind.txt')
    oldspec=ROOT/'selfhost/build/phase144/final03-stages01/spec.json';spec=read(oldspec)
    # Current context-preserving verifier enters p146c_closed after ORIGINAL
    # close/finish; p128raw_lowered now belongs only to the fallback route.
    old_boundary,new_boundary='p128raw_lowered','p146c_closed'
    for marker in spec['markers']:
        if marker['label']==old_boundary:marker['label']=new_boundary
    spec['requiredOrder']=[new_boundary if x==old_boundary else x for x in spec['requiredOrder']]
    for interval in spec['intervals']:
        for endpoint in ('begin','end'):
            if interval[endpoint]==old_boundary:interval[endpoint]=new_boundary
    names={r['decoded']:r for r in owners['fids']}
    for marker in spec['markers']:
        row=names['$direct.'+marker['label']]
        need(row['role']=='direct_segment','Stage is not direct')
        marker.update(fid=row['fid'],symbol=row['symbol'])
    spec.update(ownerMap=pin(out/'owners.json'),programObject=pin(acquired/'program.o'),unwindTable=pin(out/'unwind/table.json'),scope='Current selected N2 exact object/IR, process-cold prepared-Base cache request. No numerical FID transfer. Diagnostic clocks and samples only.',boundaryDerivation=pin(oldspec))
    spec.pop('boundaryMapping',None)
    save(out/'spec.json',spec)
    recipe=runtime['runtimeRecipes']['serial-rfc']
    def asset(k):
        p=runtime['assets'][k];return {**p,'file':str((ROOT/p['file']).resolve())}
    runtime_input={'runtime':asset(recipe['source']),'headers':[asset(k)for k in recipe['headers']],'compiler':asset(recipe['compiler'])['file'],'linker':asset(recipe['compiler'])['file'],'compileFlags':recipe['flags'],'programObject':pin(acquired/'program.o')}
    save(out/'runtime-input.json',runtime_input)
    call('runtime.py',['--manifest',out/'runtime-input.json','--out',out/'base-runtime'],out/'logs/runtime.txt')
    ready={'complete':True,'targetsRun':False,'selected':pin(selected),'selectedSourceIdentity':current['components']['qbe']['sourceIdentity'],'canonicalSourceIdentity':current['source']['identity'],'current':pin(acquired/'current.json'),'nativeAssets':pin(acquired/'assets-native.json'),'spec':pin(out/'spec.json'),'inputs':[pin(__file__),pin(original),pin(selected),pin(acquired/'program.o'),pin(acquired/'program.ssa'),pin(acquired/'image-source.bend'),pin(out/'selected-elf-binding.json'),pin(out/'base-runtime/plan.json'),pin(out/'unwind/table.json')],'periodUs':32000,'interpretation':'Process-cold request with authenticated prepared Base cache; not live Base reconstruction or file-cache eviction.'}
    save(out/'ready.json',ready)

def build(prep,out):
    out.mkdir(parents=True,exist_ok=False);ready=read(prep/'ready.json')
    for p in ready['inputs']:verify(p)
    gcc=read(prep/'runtime-input.json')['compiler']
    call('build-sampler.py',['--out',out/'sampler-base','--cc',gcc,'--unwind-table',prep/'unwind/table.json'],out/'logs/sampler.txt')
    call('stages-build-v1.py',['--spec',prep/'spec.json','--runtime-plan',prep/'base-runtime/plan.json','--sampler-build',out/'sampler-base/report.json','--out',out/'runtime'],out/'logs/plan.txt')
    call('build-runtime.py',['--plan',out/'runtime/plan.json','--out',out/'build'],out/'logs/build.txt')
    import attribute
    _,linked,binding=attribute.bind_owners(read(prep/'owners.json'),out/'runtime/program')
    save(out/'report.json',{'complete':True,'preparation':pin(prep/'ready.json'),'build':pin(out/'build/report.json'),'diagnostic':pin(out/'runtime/program'),'sampler':pin(out/'runtime/sampler.so'),'binding':binding,'fids':len(linked),'scope':'Same generated object, only diagnostic runtime and loadable sampler changed; production runtime untouched.'})

def capture(prep,builddir,out,source,oracle,period,small):
    out.mkdir(parents=True,exist_ok=False);ready=read(prep/'ready.json');built=read(builddir/'report.json')
    for p in ready['inputs']:verify(p)
    need(built['complete'],'Diagnostic build incomplete')
    selected=verify(ready['selected']);verify(built['diagnostic']);verify(built['sampler'])
    native=read(prep/'inputs/assets-native.json')
    def asset(k):
        row=native['assets'][k];return verify({**row,'file':str((ROOT/row['file']).resolve())})
    base,carrier=asset('base'),asset('prepared-base')
    args=['--threads','1','--gpu','off','--','phase111',str(source.resolve()),str(base),'cache',str(carrier),native['preparedBase']['stamp']]
    source_pin=pin(source);empty=out/'empty.stderr';empty.write_bytes(b'')
    if small:
        clean=execute([str(selected),*args],out/'clean',str(ROOT),45,dict(os.environ))
        need(clean['returncode']==0 and not clean['timedOut'] and clean['stderr']['bytes']==0,'Clean selected request failed')
        save(out/'clean.json',clean);oracle=out/'clean/stdout'
    else:need(oracle is not None and oracle.is_file() and oracle.stat().st_size>0,'Exact independent clean oracle required')
    recipe={'cwd':str(ROOT),'sampler':str(builddir/'runtime/sampler.so'),'unwindTable':str(prep/'unwind/table.json'),'inputs':[str(prep/'spec.json'),str(prep/'ready.json'),str(builddir/'report.json'),str(builddir/'runtime/plan.json'),str(prep/'owners.json'),str(source),str(base),str(carrier)],'scope':'Current N2 diagnostic relink; exact complete selected-clean stdout oracle. Single sampled process. Stage exclusive sample counts, not runtime event counts.','workloads':[{'name':'small-current'if small else'full-current','timeoutSeconds':45 if small else 420,'variants':[{'name':'selected-n2-diagnostic','command':[str(builddir/'runtime/program'),*args],'stdout':str(oracle),'stderr':str(empty),'dispatchInstrumentation':True}]}]}
    save(out/'recipe.json',recipe);save(out/'manifest.json',freeze(recipe,out/'recipe.json'))
    # Sampling process can outlive ordinary metadata commands.
    with (out/'capture.log').open('xb')as stream:subprocess.run([sys.executable,'-B',str(P/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'capture'),'--modes','sample','--rounds','1','--periods-us',str(period)],cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=480)
    call('stages_v1.py',['observe','--spec',prep/'spec.json','--run',out/'capture/report.json','--row','0','--out',out/'stages.json'],out/'stages.log')
    stage=read(out/'stages.json');report=read(out/'capture/report.json')
    need(pin(source)==source_pin,'Request source changed')
    exclusive=[r for r in stage['intervals']if '(nested)'not in r['label']]
    save(out/'summary.json',{'complete':True,'source':source_pin,'capture':pin(out/'capture/report.json'),'stages':pin(out/'stages.json'),'profilesUsable':report['profilesUsable'],'quality':stage['quality'],'exclusiveIntervals':exclusive,'exclusiveSamples':sum(x.get('samples',0)for x in exclusive),'totalSamples':stage['samples'],'scope':'Exclusive stages partition observed boundaries, with one edge sample excluded at each side. Prelude before first marker and post-exit samples are unassigned. Small distributions remain descriptive below500 samples; clocks are diagnostic.'})

def main():
    a=argparse.ArgumentParser();a.add_argument('action',choices=['prepare','build','pilot','full']);a.add_argument('--out',required=True,type=Path);a.add_argument('--prep',type=Path);a.add_argument('--build',type=Path);a.add_argument('--source',type=Path);a.add_argument('--oracle',type=Path);a.add_argument('--period-us',type=int,default=32000);x=a.parse_args()
    out=x.out.resolve()
    if x.action=='prepare':prepare(out)
    elif x.action=='build':build(x.prep.resolve(),out)
    else:capture(x.prep.resolve(),x.build.resolve(),out,x.source.resolve(),x.oracle.resolve()if x.oracle else None,x.period_us,x.action=='pilot')
    print(json.dumps({'complete':True,'action':x.action,'out':str(out)}))
if __name__=='__main__':main()
