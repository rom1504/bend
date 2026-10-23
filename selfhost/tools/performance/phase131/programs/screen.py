"""Phase128 screen derivative: frozen oracles, checked-build reuse and smoke mode."""
import argparse,importlib.util,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('oracle',ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
p=argparse.ArgumentParser();p.add_argument('--emission',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--label',required=True);p.add_argument('--manifest',type=Path);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--rounds',type=int,default=3);p.add_argument('--scale',type=int,default=4);p.add_argument('--build-map',type=Path);p.add_argument('--check-only',action='store_true');a=p.parse_args()
assert sorted(os.sched_getaffinity(0))==[3]
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131');out.mkdir(parents=True)
e=O.read(a.emission);assert e['complete']
for x in e['inputs']:O.verify(x)
assert a.baseline.resolve().is_relative_to(ROOT/'selfhost/build/phase128')
broad=O.read(a.baseline);assert broad['complete']
for x in broad['inputs']:O.verify(x)
manifest=a.manifest or ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';m=O.read(manifest)
counts_file=ROOT/'selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json';counts=O.read(counts_file)
report=dict(complete=False,inputs=[O.pin(__file__),O.pin(O.__file__),O.pin(a.emission),O.pin(a.baseline),O.pin(manifest),O.pin(counts_file),*e['inputs']],builds=[],rows=[],label=a.label,correctnessOnly=a.check_only,scope='Original source and exact candidate QBE with branch-aligned assembler policy; aligned candidate/explicit frozen Phase128 baseline/pinned upstream products; full output/count oracle unchanged. No native-image qualification.')
reuse=O.read(a.build_map) if a.build_map else {}
if a.build_map:report['inputs'].append(O.pin(a.build_map))
if a.check_only:report['scope']='Correctness smoke only: exact historical wrappers and runtime arguments, one repetition/no warmup, original complete-output oracle. Not ordinary full45 qualification or historical runtime measurements.'
save=lambda:O.save(out/'report.json',report);save();start=time.monotonic()
try:
    for x in e['cases']:
        name=x['name'];case=next(c for c in m['cases'] if c['name']==name);assert case['source']==x['source'];O.verify(x['qbe'])
        dest=ROOT/'selfhost/build/phase111'/('p131-'+a.label+'-'+name+'-build')
        cmd=['python3','-B',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),'--source',x['qbe']['file'],'--runtime',e['runtime']['file'],'--out',str(dest),'--seconds','30']
        if a.build_map:
            binding=reuse[name];O.verify(binding);br=O.read(binding['file']);assert br['complete']
            for item in br['inputs']+[br['binary']]:O.verify(item)
            assert x['qbe'] in br['inputs'] and e['runtime'] in br['inputs']
            assert Path(br['inputs'][0]['file']).read_bytes()==(ROOT/'selfhost/tools/performance/phase123/build-aligned.py').read_bytes()
            report['builds'].append(dict(name=name,reused=True,seconds=0,status=0,report=binding));save()
        else:
            t=time.monotonic();r=subprocess.run(cmd,capture_output=True,timeout=55)
            (out/(name+'.build.stdout')).write_bytes(r.stdout);(out/(name+'.build.stderr')).write_bytes(r.stderr)
            br=O.read(dest/'report.json');report['builds'].append(dict(name=name,command=cmd,seconds=time.monotonic()-t,status=r.returncode,report=O.pin(dest/'report.json')));save();assert r.returncode==0 and br['complete']
        baseline=next(r['binary'] for r in broad['rows'] if r['name']==case.get('parentName',name) and r['role']=='candidate')
        products={'candidate':br['binary'],'baseline':baseline,'upstream':case['upstream']['binary']}
        for binary in products.values():O.verify(binary)
        c=dict(case,repetitions=counts['cases'][case.get('parentName',name)]['repetitions']*a.scale,warmups=counts['cases'][case.get('parentName',name)]['warmups'])
        if a.check_only:c=dict(case,repetitions=1,warmups=0)
        for rnd in range(1 if a.check_only else a.rounds):
            roles=['candidate'] if a.check_only else list(products);roles=roles[rnd%3:]+roles[:rnd%3]
            for role in roles:
                binary=products[role];cmd=[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])]
                t=time.monotonic();child=subprocess.run(cmd,capture_output=True,timeout=30);wall=time.monotonic()-t
                stem=f'{name}-{role}-{rnd}';(out/(stem+'.stdout')).write_bytes(child.stdout);(out/(stem+'.stderr')).write_bytes(child.stderr)
                row=dict(name=name,role=role,round=rnd,command=cmd,binary=binary,wallSeconds=wall,status=child.returncode,stdout=O.pin(out/(stem+'.stdout')),stderr=O.pin(out/(stem+'.stderr')));report['rows'].append(row);save()
                row['elapsedMs']=O.observation(child.stdout,child.stderr,child.returncode,c,wall);row['correct']=True;save()
        print(name,'complete',flush=True)
    report['complete']=True
finally:report['seconds']=time.monotonic()-start;save()
