#!/usr/bin/env python3
"""Serial native JSON/QBE equivalence and finite runtime checks; root supplies guard."""
import argparse, hashlib, json, os, shutil, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MASK=2**32-1
POSITIVES={'arithmetic','branches','compiler_classify','erased','recurrence','default_bool_arm','erased_function','erased_local'}
REFUSALS={'refuse_nat','refuse_shift','refuse_bool_entry','refuse_box','refuse_higher_order','refuse_named_u32'}
EDGES=[(0,0),(1,7),(7,1),(19,23),(2**31,1),(MASK,MASK),(MASK,0),(0,MASK),(65,9),(123,32)]
def answer(name,n,s):
    if name=='arithmetic':
        x=((n*1664525+1013904223)&MASK)^s;return ((x*1664525+1013904223)&MASK)^((s+7)&MASK)
    if name=='branches':return (n+7)&MASK if n<s else n^2**31
    if name=='erased':return ((n+s)&MASK)^2654435769
    if name=='compiler_classify':return int(65<=n<=90 or 97<=n<=122 or 48<=n<=57 or n in (95,46))+2*int(s==32 or 9<=s<=13)
    if name=='default_bool_arm':return min(n,s)
    if name=='erased_function':return n
    if name=='erased_local':return (n+s)&MASK
    assert name=='recurrence'
    for x in range(n,0,-1):s=((s*33+x)&MASK)^2654435769
    return s
def pin(file):
    file=Path(file).resolve(strict=True);b=file.read_bytes();return dict(file=str(file),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--image',type=Path,required=True);p.add_argument('--api',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--graphs',type=Path,default=ROOT/'selfhost/build/phase107/source-graphs01');p.add_argument('--review-graphs',type=Path,default=ROOT/'selfhost/build/phase107/review-graphs01')
    p.add_argument('--prune',action='store_true');p.add_argument('--exclude',action='append',default=[],choices=sorted(POSITIVES|REFUSALS));a=p.parse_args()
    selection=dict(excluded=sorted(set(a.exclude)),included=sorted((POSITIVES|REFUSALS)-set(a.exclude)));assert POSITIVES-set(a.exclude),'selection needs a positive case';out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun';qbe=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe';launcher=HERE/'frontend/native/run.py';runner=HERE.parent/'phase106/cranelift/runner.c';expected=HERE/'native-expected.mjs';known={}
    def remember(item):
        assert pin(item['file'])==item,item;assert known.setdefault(item['file'],item)==item
    for file in [__file__,expected,launcher,runner,bun,qbe,a.image,a.api,sys.executable,'/usr/bin/as','/usr/bin/gcc','/usr/bin/ld']:remember(pin(file))
    image=json.loads(a.image.read_text());assert image['complete'] and image['kind']=='phase107-native-frontend-image'
    for key in ['manifest','source','binary','acquisition']:remember(image[key])
    manifest=json.loads(Path(image['manifest']['file']).read_text());assert manifest['source']==image['source']
    remember(manifest['assets']['base']);remember(manifest['assets']['cache']['carrier'])
    report=dict(kind='phase107-native-controls',complete=False,passed=False,started=time.time(),prune=a.prune,selection=selection,inputs=[],image=pin(a.image),jobs=[],comparisons=[],observations=[],refusals=[],live=[],affinity=sorted(os.sched_getaffinity(0)),scope='Finite native frontend/JSON/QBE controls for explicitly included cases; exclusions are not passes. No units-format, compiler fixed-point, production admission or universal speedup claim.',clockScope='Outer process wall includes Python authentication/supervision; each native receipt separately retains authentication, native process and total seconds.')
    def save():
        report['inputs']=list(known.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    for src in [Path(__file__),expected]:shutil.copyfile(src,out/src.name)
    report['snapshots']=[pin(out/Path(__file__).name),pin(out/expected.name)];save()
    def run(label,command,status=0,stdout=None,timeout=90):
        cmd=list(map(str,command));row=dict(label=label,command=cmd,started=time.time(),complete=False);report['jobs'].append(row);save();before=time.perf_counter()
        so,se=out/(label+'.stdout'),out/(label+'.stderr')
        try:
            with so.open('xb') as x,se.open('xb') as y:r=subprocess.run(cmd,cwd=ROOT,stdout=x,stderr=y,timeout=timeout)
            row.update(returncode=r.returncode,complete=True)
        except Exception as e:row['error']=repr(e);raise
        finally:
            row.update(seconds=time.perf_counter()-before,finished=time.time(),stdout=pin(so),stderr=pin(se));save()
        assert r.returncode==status,(label,r.returncode,str(se))
        if stdout is not None:assert so.read_bytes()==stdout.encode() and se.read_bytes()==b'',label
        return row
    def native(name,source,policy,fmt,base='cache',refusal=None,reference_refusal=None):
        label=name+'-'+policy+'-'+fmt+'-'+base;dest=out/label
        job=run(label,[sys.executable,'-B',launcher,source,'--image',a.image.resolve(),'--entry','bench','--format',fmt,'--policy',policy,'--base',base,'--out',dest],1 if refusal else 0)
        receipt=json.loads((dest/'report.json').read_text());assert receipt['executed'] and receipt['input']==pin(source) and receipt['binary']==image['binary'] and receipt['image']==pin(a.image)
        assert receipt['options']==dict(entry='bench',format=fmt,policy=policy,base=base)
        remember(pin(dest/'report.json'));remember(receipt['output']);stderr=pin(dest/'stderr.txt');remember(stderr)
        item=dict(name=name,policy=policy,format=fmt,base=base,report=pin(dest/'report.json'),output=receipt['output'],stderr=stderr,wallSeconds=job['seconds'],nativeSeconds=receipt['nativeSeconds'],authenticationSeconds=receipt['authenticationSeconds'])
        if refusal:
            text=Path(stderr['file']).read_text();assert receipt['status']==1 and not receipt['complete'] and receipt['output']['bytes']==0 and text
            if refusal=='load: pilot requires import Base\n':assert text==refusal
            elif refusal.startswith('native subset: ') or refusal=='check: ':assert text.startswith(refusal)
            else:assert text.startswith('compile: ') and refusal[len('frontend: '):].removeprefix('Error: ') in text,text
            report['refusals'].append(dict(**item,expected=refusal,nativeStage='load' if refusal.startswith('load: ') else 'lowerer' if refusal.startswith('native subset: ') else 'check' if refusal=='check: ' else 'compile',nativeLowererClaim=None if not refusal.startswith('native subset: ') else 'exact reference diagnostic',jsReference=reference_refusal));save()
        else:assert receipt['status']==0 and receipt['complete'] and receipt['output']['bytes']>0 and stderr['bytes']==0
        return item
    def equal(actual,want):
        remember(want);assert Path(actual['output']['file']).read_bytes().rstrip(b'\n')==Path(want['file']).read_bytes().rstrip(b'\n'),actual
    try:
        run('expected',[bun,expected,a.api.resolve(),a.graphs.resolve(),a.review_graphs.resolve(),out/'expected']+(['--prune'] if a.prune else [])+[arg for name in selection['excluded'] for arg in ['--exclude',name]])
        want=json.loads((out/'expected/report.json').read_text());assert want['complete'] and want['passed'] and want['prune']==a.prune and want['selection']==selection
        remember(pin(out/'expected/report.json'))
        for item in want['inputs']:remember(item)
        assert {r['name'] for r in want['rows'] if not r.get('refusal')}==POSITIVES-set(a.exclude)
        run('runner-build',['/usr/bin/gcc','-O2','-c',runner,'-o',out/'runner.o'])
        cached={}
        for row in want['rows']:
            name=row['name'];source=row['source']['file']
            if row.get('refusal'):
                reason='native subset: '+row['error'] if row['refusal']=='lowerer' else 'frontend: '+row['error']
                if name=='refuse_named_u32':reason='load: pilot requires import Base\n'
                for policy in ['raw','fast']:native(name,source,policy,'json',refusal=reason,reference_refusal=dict(stage=row['refusal'],diagnostic=row['error']))
                continue
            for product in row['outputs']:
                policy=product['policy'];ir=native(name,source,policy,'json');equal(ir,product['json']);cached[name,policy]=ir;report['comparisons'].append(ir)
                emitted=native(name,source,policy,'qbe');equal(emitted,product['qbe']);report['comparisons'].append(emitted);stem=out/(name+'-'+policy)
                run(name+'-'+policy+'-qbe',[qbe,'-t','amd64_sysv','-o',str(stem)+'.s',emitted['output']['file']])
                run(name+'-'+policy+'-as',['/usr/bin/as','-o',str(stem)+'.o',str(stem)+'.s'])
                run(name+'-'+policy+'-link',['/usr/bin/gcc',out/'runner.o',str(stem)+'.o','-o',str(stem)+'.bin']);binary=pin(str(stem)+'.bin');remember(binary)
                edges=[(n,s) for n in [0,1,2,19,127] for s in [0,23,2**31,MASK]] if name=='recurrence' else EDGES
                for i,(n,s) in enumerate(edges):
                    value=answer(name,n,s);run(name+'-'+policy+'-check-'+str(i),[binary['file'],'--expect',value,n,s],stdout=str(value)+'\n',timeout=30)
                    report['observations'].append(dict(name=name,policy=policy,binary=binary,args=[n,s],expected=value))
                save()
        for name in ['arithmetic','recurrence','default_bool_arm']:
            if name in a.exclude:continue
            row=next(r for r in want['rows'] if r['name']==name)
            for policy in ['raw','fast']:
                actual=native(name,row['source']['file'],policy,'json','live');equal(actual,cached[name,policy]['output']);report['live'].append(actual);save()
        bad=out/'illtyped.bend';bad.write_text('import Base\ndef bench(n: U32, seed: U32) -> U32:\n  "wrong"\ndef main() -> U32:\n  bench(19, 23)\n');remember(pin(bad))
        for policy in ['raw','fast']:native('illtyped',bad,policy,'json',refusal='check: ')
        for item in known.values():assert pin(item['file'])==item
        report.update(complete=True,passed=True)
    except Exception as e:report['error']=repr(e);raise
    finally:report.update(finished=time.time(),wallSeconds=time.time()-report['started']);save()
    print(json.dumps(dict(complete=True,passed=True,selection=selection,comparisons=len(report['comparisons']),observations=len(report['observations']),refusals=len(report['refusals']),live=len(report['live']),report=pin(out/'report.json'))))
if __name__=='__main__':main()
