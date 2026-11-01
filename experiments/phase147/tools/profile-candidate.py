#!/usr/bin/env python3
"""Explicit candidate profiler; new identities, unchanged strict stage semantics.

Baseline profile-controller.py remains immutable. Preparation only derives files;
build and capture must run in the root-owned guarded measurement lane.
"""
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
def same(a,b):
    return all(a.get(k)==b.get(k) for k in ('bytes','sha256'))

def source_locations(source, source_map, owners):
    # Validate this exact assembly map, never borrow an earlier image's spans.
    import bisect
    data=source.read_bytes();rows=read(source_map)
    need(isinstance(rows,list) and rows,'Nonempty assembly map required')
    breaks=[i for i,c in enumerate(data) if c==10]
    locations={};cursor=rows[0]['generatedStartByte']
    for row in rows:
        start=row['generatedStartByte'];size=row['spanBytes'];at=row['generatedByte']
        need(start==cursor and size>0 and start<=at<start+size<=len(data),'Noncontiguous source-map span')
        need(0<row['bytes']<=start+size-at,'Source-map body exceeds its span')
        need(data.startswith((row['kind']+' '+row['name']).encode(),at),'Source-map header differs')
        need(row['generatedLine']==bisect.bisect_left(breaks,at)+1,'Source-map line differs')
        need(not Path(row['file']).is_absolute() and '..'not in Path(row['file']).parts,'Unconfined source-map module')
        locations.setdefault(row['name'],[]).append({k:row[k]for k in ('file','sourceLine','generatedLine','kind','name','generatedByte','bytes')})
        cursor=start+size
    need(cursor==len(data),'Source map omits tail')
    mapped=[]
    for group in owners['groups']:
        name=group['lowered_owner']
        spans=locations.get(name,[]) if group['valid_under_emitter_contract'] else []
        mapped.append(dict(loweredOwner=name,firstFid=group['first_fid'],lastFid=group['last_fid'],sourceDeclarations=spans))
    return dict(kind='bend-profile-lexical-source-map-v1',complete=True,source=pin(source),assemblyMap=pin(source_map),groups=mapped,
        mappedGroups=sum(bool(r['sourceDeclarations'])for r in mapped),totalGroups=len(mapped),
        scope='Exact named declaration locations under the emitted lexical-owner contract; not dynamic logical ancestry or inline origin. Unmatched Base/composite owners remain unmapped.')

def prepare(out,args):
    required=['image_build','image','program_object','qbe','image_source','source_map','stage_spec','unwind_ranges']
    need(all(getattr(args,k) is not None for k in required),'Prepare requires explicit image receipt, image/object/QBE/source/map, stage spec and unwind ranges')
    build=read(args.image_build)
    need(build.get('kind')=='bend-native-build' and build.get('complete') and not build.get('changedInputs'),'Completed immutable native build required')
    need(build.get('retainIR') is True and build.get('compilerExitCode')==0 and build.get('qbeExitCode')==0,'Retained successful compiler/QBE build required')
    binding=build.get('imageBinding',{})
    need(binding.get('complete') and binding.get('protocol')=='qbe-source-v1' and binding.get('host')=='native' and binding.get('targets')==['qbe'],'Explicit QBE compiler image binding required')
    selected=args.image.resolve();program_object=args.program_object.resolve();qbe=args.qbe.resolve();source=args.image_source.resolve()
    for actual,expected in [(selected,build['binary']),(selected,binding['image']),(program_object,build['object']),
                            (source,build['request']['source']),(source,binding['sourceIdentity'])]:
        verify(expected);need(same(pin(actual),expected),'Explicit image input differs from build receipt: '+str(actual))
    need(same(pin(qbe),build['irDigest']),'Retained QBE differs from successful build stream')
    for value in build['inputs']:verify(value)
    native=read(args.native_assets);runtime=read(args.runtime_assets)
    linked=verify(build['runtime']);verify(binding['linkedRuntime'])
    need(same(pin(linked),binding['linkedRuntime']),'Compiler binding runtime differs')
    expected_runtime=native['assets']['qbe-runtime']
    need(same(pin(linked),expected_runtime),'Candidate uses another runtime; explicit matching diagnostic recipe required')
    recipe=runtime['runtimeRecipes']['serial-rfc']
    out.mkdir(parents=True,exist_ok=False);acquired=out/'inputs';acquired.mkdir()
    for p,name in [(program_object,'program.o'),(qbe,'program.ssa'),(source,'image-source.bend'),
                   (args.source_map,'source-map.json'),(args.image_build,'image-build.json'),
                   (args.native_assets,'assets-native.json'),(args.runtime_assets,'assets-runtime.json'),
                   (args.stage_spec,'stage-template.json'),(args.unwind_ranges,'unwind-ranges.json')]:
        shutil.copyfile(p,acquired/name)
    call('owners.py',['--qbe',acquired/'program.ssa','--emitter-source',acquired/'image-source.bend','--output',out/'owners.json'],out/'logs/owners.txt')
    import attribute
    owners=read(out/'owners.json');_,linked_fids,elf_binding=attribute.bind_owners(owners,selected)
    save(out/'selected-elf-binding.json',{'complete':True,'selected':pin(selected),'binding':elf_binding,'fids':len(linked_fids)})
    save(out/'source-owners.json',source_locations(acquired/'image-source.bend',acquired/'source-map.json',owners))
    ranges=read(args.unwind_ranges);libc=verify(ranges['object'])
    save(out/'libc-ranges.json',dict(object=pin(libc),ranges=ranges['ranges'],origin=pin(args.unwind_ranges),
        scope='Same explicit libc range semantics, freshly verified against this exact libc ELF CFI. No candidate-program addresses or FIDs reused.'))
    call('unwind.py',['--object',libc,'--ranges',out/'libc-ranges.json','--out',out/'unwind'],out/'logs/unwind.txt')
    template=read(args.stage_spec)
    need(template.get('schema')=='bend-native-stage-spec-v1','Unsupported stage template')
    need('p146c_closed' in template['requiredOrder'] and 'p128raw_lowered' not in template['requiredOrder'],'Use the successful retained-context stage contract')
    # Transfer only semantic labels, multiplicities and interval boundaries.
    spec={k:template[k]for k in ('schema','requiredOrder','intervals')}
    spec['markers']=[];names={r['decoded']:r for r in owners['fids']}
    for marker in template['markers']:
        row=names.get('$direct.'+marker['label'])
        need(row is not None and row['role']=='direct_segment','Missing exact direct stage owner: '+marker['label'])
        spec['markers'].append(dict(label=marker['label'],multiplicity=marker['multiplicity'],fid=row['fid'],symbol=row['symbol']))
    spec.update(ownerMap=pin(out/'owners.json'),programObject=pin(acquired/'program.o'),unwindTable=pin(out/'unwind/table.json'),
        scope='Explicit candidate compiler image; fresh FIDs/ELF bindings and same strict semantic stage contract. Diagnostic clocks only.',boundaryDerivation=pin(args.stage_spec))
    save(out/'spec.json',spec)
    def asset(k):
        p=runtime['assets'][k];value={**p,'file':str((ROOT/p['file']).resolve())};verify(value);return value
    runtime_input={'runtime':asset(recipe['source']),'headers':[asset(k)for k in recipe['headers']],
        'compiler':asset(recipe['compiler'])['file'],'linker':asset(recipe['compiler'])['file'],
        'compileFlags':recipe['flags'],'programObject':pin(acquired/'program.o')}
    save(out/'runtime-input.json',runtime_input)
    call('runtime.py',['--manifest',out/'runtime-input.json','--out',out/'base-runtime'],out/'logs/runtime.txt')
    ready=dict(complete=True,targetsRun=False,selected=pin(selected),imageStage=binding['stage'],
        selectedSourceIdentity=binding['sourceIdentity'],nativeAssets=pin(acquired/'assets-native.json'),
        spec=pin(out/'spec.json'),sourceOwners=pin(out/'source-owners.json'),periodUs=32000,
        inputs=[pin(__file__),pin(args.image_build),pin(selected),pin(acquired/'program.o'),pin(acquired/'program.ssa'),
                pin(acquired/'image-source.bend'),pin(acquired/'source-map.json'),pin(acquired/'assets-native.json'),
                pin(acquired/'assets-runtime.json'),pin(args.stage_spec),pin(args.unwind_ranges),pin(out/'owners.json'),
                pin(out/'source-owners.json'),pin(out/'spec.json'),pin(out/'selected-elf-binding.json'),
                pin(out/'base-runtime/plan.json'),pin(out/'unwind/table.json')],
        interpretation='Fresh-process request with authenticated prepared Base; not live Base reconstruction or file-cache eviction. Candidate acquisition is not semantic promotion.')
    for value in ready['inputs']:verify(value)
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
    need(built['complete'],'Diagnostic build incomplete');need(same(built['preparation'],pin(prep/'ready.json')),'Diagnostic build belongs to another preparation')
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
    recipe={'cwd':str(ROOT),'sampler':str(builddir/'runtime/sampler.so'),'unwindTable':str(prep/'unwind/table.json'),'inputs':[str(prep/'spec.json'),str(prep/'ready.json'),str(builddir/'report.json'),str(builddir/'runtime/plan.json'),str(prep/'owners.json'),str(source),str(base),str(carrier)],'scope':'Explicit candidate diagnostic relink; exact complete clean stdout oracle. Single sampled process. Stage exclusive sample counts, not runtime event counts.','workloads':[{'name':'small-current'if small else'full-current','timeoutSeconds':45 if small else 420,'variants':[{'name':'candidate-'+ready['imageStage'].lower()+'-diagnostic','command':[str(builddir/'runtime/program'),*args],'stdout':str(oracle),'stderr':str(empty),'dispatchInstrumentation':True}]}]}
    save(out/'recipe.json',recipe);save(out/'manifest.json',freeze(recipe,out/'recipe.json'))
    # Sampling process can outlive ordinary metadata commands.
    with (out/'capture.log').open('xb')as stream:subprocess.run([sys.executable,'-B',str(P/'run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'capture'),'--modes','sample','--rounds','1','--periods-us',str(period)],cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=480)
    call('stages_v1.py',['observe','--spec',prep/'spec.json','--run',out/'capture/report.json','--row','0','--out',out/'stages.json'],out/'stages.log')
    stage=read(out/'stages.json');report=read(out/'capture/report.json')
    need(pin(source)==source_pin,'Request source changed')
    exclusive=[r for r in stage['intervals']if '(nested)'not in r['label']]
    save(out/'summary.json',{'complete':True,'source':source_pin,'capture':pin(out/'capture/report.json'),'stages':pin(out/'stages.json'),'profilesUsable':report['profilesUsable'],'quality':stage['quality'],'exclusiveIntervals':exclusive,'exclusiveSamples':sum(x.get('samples',0)for x in exclusive),'totalSamples':stage['samples'],'scope':'Exclusive stages partition observed boundaries, with one edge sample excluded at each side. Prelude before first marker and post-exit samples are unassigned. Small distributions remain descriptive below500 samples; clocks are diagnostic.'})

def main():
    a=argparse.ArgumentParser(description=__doc__)
    a.add_argument('action',choices=['prepare','build','pilot','full'])
    a.add_argument('--out',required=True,type=Path)
    for name in ['prep','build','source','oracle','image-build','image','program-object','qbe','image-source','source-map','stage-spec','unwind-ranges']:
        a.add_argument('--'+name,type=Path)
    a.add_argument('--native-assets',type=Path,default=ROOT/'selfhost/manifests/assets-native.json')
    a.add_argument('--runtime-assets',type=Path,default=ROOT/'selfhost/manifests/assets-runtime.json')
    a.add_argument('--period-us',type=int,default=32000)
    x=a.parse_args();out=x.out.resolve()
    if x.action=='prepare':prepare(out,x)
    elif x.action=='build':
        need(x.prep is not None,'Build requires --prep');build(x.prep.resolve(),out)
    else:
        need(x.prep is not None and x.build is not None and x.source is not None,'Capture requires --prep/--build/--source')
        need(x.period_us==32000,'This paired campaign fixes the sampler period at 32000us')
        capture(x.prep.resolve(),x.build.resolve(),out,x.source.resolve(),x.oracle.resolve()if x.oracle else None,x.period_us,x.action=='pilot')
    print(json.dumps({'complete':True,'action':x.action,'out':str(out)}))
if __name__=='__main__':main()
