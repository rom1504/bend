#!/usr/bin/env python3
"""Actual native frontend/object-cache controls; run serially under an external guard."""
import argparse, hashlib, json, os, shutil, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MASK=2**32-1;MIX='function_f_109_105_120'
EDGES=[(0,0),(1,7),(7,1),(19,23),(2**31,1),(MASK,MASK),(MASK,0),(0,MASK),(MASK,7),(2**31-1,2**31)]
def pin(file):
    file=Path(file).resolve(strict=True);raw=file.read_bytes();return dict(file=str(file),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def answer(n,s,m):
    first=((n*m+1013904223)&MASK)^s;return ((first*m+1013904223)&MASK)^((s+7)&MASK)
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--image',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--mode',choices=['units','whole','both'],default='both');p.add_argument('--max-seconds',type=float,default=60)
    p.add_argument('--source',type=Path,default=HERE/'cases/arithmetic.bend');p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe')
    a=p.parse_args();assert 1<=a.max_seconds<=600;a.image=a.image.resolve(strict=True);a.qbe=a.qbe.resolve(strict=True)
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);work=out/'work';work.mkdir();source=work/'arithmetic.bend'
    original=a.source.read_bytes();assert original==(HERE/'cases/arithmetic.bend').read_bytes() and original.count(b'1664525')==1,'oracle requires the arithmetic fixture'
    edited=original.replace(b'1664525',b'1664527');(out/'original.bend').write_bytes(original);(out/'edited.bend').write_bytes(edited)
    compiler=HERE/'frontend/native/compile.py';known={};started=time.monotonic();deadline=started+a.max_seconds
    def remember(item):
        assert pin(item['file'])==item,item;assert known.setdefault(item['file'],item)==item,'input changed between jobs'
    methods=[Path(__file__),compiler,compiler.with_name('cache.py'),compiler.with_name('run.py')]
    for file in [*methods,a.image,a.qbe,a.source,HERE/'cases/arithmetic.bend',sys.executable,'/usr/bin/as','/usr/bin/gcc','/usr/bin/ld']:remember(pin(file))
    snapshots=[]
    for method in methods:
        dest=out/('method-'+method.name);shutil.copyfile(method,dest);snapshots.append(pin(dest))
    image=json.loads(a.image.read_text());assert image['kind']=='phase107-native-frontend-image' and image['complete']
    for key in ['manifest','source','binary','acquisition']:remember(image[key])
    manifest=json.loads(Path(image['manifest']['file']).read_text());assert manifest['source']==image['source'];remember(manifest['assets']['base']);remember(manifest['assets']['cache']['carrier'])
    report=dict(kind='phase107-native-cache-controls',complete=False,passed=False,started=time.time(),image=pin(a.image),inputs=[],snapshots=snapshots+[pin(out/'original.bend'),pin(out/'edited.bend')],mode=a.mode,maxSeconds=a.max_seconds,builds=[],jobs=[],observations=[],corruptions=[],affinity=sorted(os.sched_getaffinity(0)),scope='Finite arithmetic cache controls: raw separate units and optimized whole object are different policies, not a unit-granularity-only comparison or universal speedup.',clockScope='Outer subprocess wall includes host startup/authentication, native frontend, object-cache validation and link; child component clocks retained separately.',oracle='Independent masked U32 arithmetic; complete stdout and empty stderr checked.')
    def save():
        report['inputs']=list(known.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    def run(label,command,expected=None):
        remaining=deadline-time.monotonic();assert remaining>0,'campaign deadline reached'
        row=dict(label=label,command=list(map(str,command)),started=time.time(),complete=False);report['jobs'].append(row);save();begin=time.monotonic();so,se=out/(label+'.stdout'),out/(label+'.stderr')
        try:
            with so.open('xb') as x,se.open('xb') as y:r=subprocess.run(row['command'],cwd=ROOT,stdout=x,stderr=y,timeout=min(30,remaining))
            row.update(status=r.returncode,complete=True)
        except Exception as error:row['error']=repr(error);raise
        finally:
            row.update(seconds=time.monotonic()-begin,finished=time.time())
            for key,file in [('stdout',so),('stderr',se)]:
                if file.exists():row[key]=pin(file)
            save()
        assert r.returncode==0,(label,str(se))
        if expected is not None:assert so.read_bytes()==(str(expected)+'\n').encode() and se.read_bytes()==b'',label
        return row
    def build(mode,label,multiplier,salt=''):
        label=mode+'-'+label;dest=out/label;cache=out/(mode+'-cache');policy='raw' if mode=='units' else 'fast'
        job=run(label,[sys.executable,'-B',compiler,source,'--image',a.image,'--out',dest,'--entry','bench','--base','cache','--policy',policy,'--cache',cache,'--qbe',a.qbe,'--abi-salt',salt,'--'+('units' if mode=='units' else 'whole-object')])
        child=json.loads((dest/'report.json').read_text());assert child['kind']=='phase107-native-qbe-compilation' and child['complete'] and not child['generatedProgramExecuted']
        assert child['source']==pin(source) and child['identity']['image']==pin(a.image) and child['identity']['binary']==image['binary']
        assert child['options']==dict(entry='bench',policy=policy,base='cache',abiSalt=salt,objectMode=mode)
        for item in [*child['methods'],*child['tools'].values(),child['runner'],*child['identity'].values(),child['binary'],child['transport']]:
            if item is not None:remember(item)
        assert child['jobs'] and all(j['status']==0 for j in child['jobs'])
        rows={r['name']:r for r in child['cache']};assert len(rows)==len(child['cache']) and 'common_runner' in rows
        for row in rows.values():
            assert len(row['key'])==64 and all(c in '0123456789abcdef' for c in row['key']);folder=cache/row['key'];record=json.loads((folder/'record.json').read_text());assert record['key']==row['key']
            for field,name in [('object','object.o'),('assembly','assembly.s')]:
                if field in row:
                    remember(row[field]);actual=pin(folder/name);assert all(actual[k]==record[name][k]==row[field][k] for k in ['bytes','sha256'])
        shutil.copyfile(source,dest/'input-snapshot.bend');remember(pin(dest/'input-snapshot.bend'));remember(pin(dest/'report.json'))
        item=dict(id=label,sourceSnapshot=pin(dest/'input-snapshot.bend'),multiplier=multiplier,report=pin(dest/'report.json'),cache=child['cache'],binary=child['binary'],wallSeconds=job['seconds'],compilerSeconds=child['seconds'],authenticationSeconds=child['authenticationSeconds'],frontendSeconds=child['frontendSeconds'],backendSeconds=child['backendSeconds'],linkSeconds=child['linkSeconds']);report['builds'].append(item);save()
        for i,(n,s) in enumerate(EDGES):
            value=answer(n,s,multiplier);run(label+'-check-'+str(i),[child['binary']['file'],'--expect',value,n,s],value);report['observations'].append(dict(build=label,args=[n,s],expected=value))
        save();return rows
    try:
        for mode in (['units','whole'] if a.mode=='both' else [a.mode]):
            source.write_bytes(original);target_name=MIX if mode=='units' else 'program';cache=out/(mode+'-cache')
            cold=build(mode,'cold',1664525);assert target_name in cold and all(not r['hit'] for r in cold.values())
            assert (len(cold)>3 and {'entry','runtime'}<=cold.keys()) if mode=='units' else set(cold)=={'program','common_runner'}
            warm=build(mode,'warm',1664525);assert warm.keys()==cold.keys() and all(r['hit'] and r['key']==cold[n]['key'] for n,r in warm.items())
            source.write_bytes(edited);changed=build(mode,'edited',1664527);assert changed.keys()==cold.keys() and all(r['hit']==(n!=target_name) and (r['key']==cold[n]['key'])==(n!=target_name) for n,r in changed.items())
            warm_edit=build(mode,'warm-edited',1664527);assert warm_edit.keys()==changed.keys() and all(r['hit'] and r['key']==changed[n]['key'] for n,r in warm_edit.items())
            salt='phase107-native-cache-controls-v1';salted=build(mode,'abi-salt',1664527,salt);assert salted.keys()==changed.keys() and all(r['hit']==(n=='common_runner') and (r['key']==changed[n]['key'])==(n=='common_runner') for n,r in salted.items())
            target=cache/salted[target_name]['key']/'object.o';assert cache.resolve() in target.resolve().parents
            before=pin(target);data=bytearray(target.read_bytes());assert data;shutil.copyfile(target,out/(mode+'-object-before.o'));data[len(data)//2]^=1;target.write_bytes(data);shutil.copyfile(target,out/(mode+'-object-corrupt.o'))
            report['corruptions'].append(dict(mode=mode,target=str(target),key=salted[target_name]['key'],before=pin(out/(mode+'-object-before.o')),corrupt=pin(out/(mode+'-object-corrupt.o'))));save()
            rebuilt=build(mode,'corrupt-rebuild',1664527,salt);assert rebuilt.keys()==salted.keys() and all(r['key']==salted[n]['key'] and r['hit']==(n!=target_name) for n,r in rebuilt.items())
            assert rebuilt[target_name].get('corrupt') is True and pin(target)==before
        for item in known.values():assert pin(item['file'])==item
        report.update(complete=True,passed=True)
    except Exception as error:report['error']=repr(error);raise
    finally:report.update(finished=time.time(),wallSeconds=time.monotonic()-started);save()
    print(json.dumps(dict(complete=True,passed=True,mode=a.mode,builds=len(report['builds']),observations=len(report['observations']),report=pin(out/'report.json'))))
if __name__=='__main__':main()
