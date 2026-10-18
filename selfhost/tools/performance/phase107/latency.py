#!/usr/bin/env python3
"""Bounded serial source-to-executable native/JS latency pairs, with exact QBE/output checks."""
import argparse, hashlib, json, os, shutil, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MASK=2**32-1
CASES={'arithmetic':[(0,0),(19,23),(2**31,1),(MASK,MASK)],'recurrence':[(0,MASK),(19,23),(127,MASK)],'compiler_classify':[(65,9),(46,32),(MASK,0),(91,14)]}
def pin(file):
    file=Path(file).resolve(strict=True);b=file.read_bytes();return dict(file=str(file),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def answer(name,n,s):
    if name=='arithmetic':
        x=((n*1664525+1013904223)&MASK)^s;return ((x*1664525+1013904223)&MASK)^((s+7)&MASK)
    if name=='compiler_classify':return int(65<=n<=90 or 97<=n<=122 or 48<=n<=57 or n in (95,46))+2*int(s==32 or 9<=s<=13)
    assert name=='recurrence'
    for x in range(n,0,-1):s=((s*33+x)&MASK)^2654435769
    return s
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--image',type=Path,required=True);p.add_argument('--api',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--case',action='append',choices=list(CASES));p.add_argument('--rounds',type=int,default=3);p.add_argument('--max-seconds',type=float,default=60);p.add_argument('--native-base',choices=['cache','live'],default='cache')
    p.add_argument('--bun',type=Path,default=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun');p.add_argument('--qbe',type=Path,default=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe')
    a=p.parse_args();assert 1<=a.rounds<=10 and 1<=a.max_seconds<=600;names=list(dict.fromkeys(a.case or CASES));a.image=a.image.resolve(strict=True);a.api=a.api.resolve(strict=True)
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);native=HERE/'frontend/native/compile.py';js=HERE/'compile.mjs';known={};start=time.monotonic();deadline=start+a.max_seconds
    def remember(item):
        assert pin(item['file'])==item,item;assert known.setdefault(item['file'],item)==item,'changed input'
    methods=[Path(__file__),native,native.with_name('cache.py'),native.with_name('run.py'),js];snapshots=[]
    for file in [*methods,a.image,a.api,a.bun,a.qbe,sys.executable,'/usr/bin/as','/usr/bin/gcc','/usr/bin/ld',*[HERE/'cases'/(n+'.bend') for n in names]]:remember(pin(file))
    for file in methods:
        dest=out/('method-'+file.name);shutil.copyfile(file,dest);snapshots.append(pin(dest))
    image=json.loads(a.image.read_text());assert image['complete'] and image['kind']=='phase107-native-frontend-image'
    for k in ['source','binary','manifest','acquisition']:remember(image[k])
    manifest=json.loads(Path(image['manifest']['file']).read_text());assert manifest['source']==image['source'] and manifest['fastPipeline']['expression']=='nx_reachable(nx_optimize(nx_inline_entry(nx_tail_optimize(program), 4096)))' and manifest['qbeEntryFusion']['fast']
    report=dict(kind='phase107-source-executable-latency',complete=False,passed=False,started=time.time(),image=pin(a.image),api=pin(a.api),cases=names,rounds=a.rounds,maxSeconds=a.max_seconds,inputs=[],snapshots=snapshots,jobs=[],builds=[],comparisons=[],observations=[],affinity=sorted(os.sched_getaffinity(0)),pipeline='tail, entry inline budget4096, fold, reachable, fused QBE, whole object',scope='Matched source and exact emitted QBE ignoring trailing LF; native Base mode '+a.native_base+' versus JS normal frontend. Source-to-executable interface comparison, not host-only or universal speedup.',clockScope='Outer build wall includes process startup, authentication/checking, lowering/emission, object-cache validation and link; generated-program checks are separate. Cold means a fresh object-cache directory, not cold OS pages. Warm repeats frontend work and reuses verified objects; native authentication is reported separately, JS has no corresponding isolated clock.')
    def save():
        report['inputs']=list(known.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    def run(label,command,expected=None):
        remaining=deadline-time.monotonic();assert remaining>0,'batch deadline reached';row=dict(label=label,command=list(map(str,command)),started=time.time(),complete=False);report['jobs'].append(row);save();begin=time.monotonic();so,se=out/(label+'.stdout'),out/(label+'.stderr')
        try:
            with so.open('xb') as x,se.open('xb') as y:r=subprocess.run(row['command'],cwd=ROOT,stdout=x,stderr=y,timeout=min(30,remaining))
            row.update(status=r.returncode,complete=True)
        except Exception as error:row['error']=repr(error);raise
        finally:
            row.update(seconds=time.monotonic()-begin,finished=time.time())
            for k,file in [('stdout',so),('stderr',se)]:
                if file.exists():row[k]=pin(file)
            save()
        assert r.returncode==0,(label,str(se))
        if expected is not None:assert so.read_bytes()==(str(expected)+'\n').encode() and se.read_bytes()==b'',label
        return row
    def build(name,turn,engine,state):
        label=name+'-'+str(turn)+'-'+engine+'-'+state;dest=out/label;source=HERE/'cases'/(name+'.bend');cache=out/(name+'-'+str(turn)+'-'+engine+'-cache')
        common=[source,'--out',dest,'--entry','bench','--cache',cache,'--qbe',a.qbe.resolve(),'--whole-object']
        cmd=[sys.executable,'-B',native,*common,'--image',a.image,'--policy','fast','--base',a.native_base] if engine=='native' else [a.bun.resolve(),js,*common,'--api',a.api,'--backend','qbe','--budget','4096','--inline','entry','--prune']
        job=run(label,cmd);child=json.loads((dest/'report.json').read_text());assert child['complete'] and child['source']==pin(source) and all(j['status']==0 for j in child['jobs'])
        if engine=='native':
            assert child['kind']=='phase107-native-qbe-compilation' and child['identity']['image']==pin(a.image) and child['identity']['binary']==image['binary']
            assert child['options']==dict(entry='bench',policy='fast',base=a.native_base,abiSalt='',objectMode='whole')
            for item in [*child['methods'],*child['tools'].values(),child['runner'],*child['identity'].values()]:
                if item is not None:remember(item)
            il=child['transport'];runner='common_runner'
        else:
            opts=child['options'];assert opts['entry']=='bench' and opts['backend']=='qbe' and opts['budget']==4096 and opts['inline']=='entry' and opts['prune'] and opts['tail'] and opts['fuse'] and not opts['units']
            for item in child['inputs']+child['frontendFiles']:remember(item)
            il=pin(dest/(hashlib.sha256(b'program').hexdigest()+'.ssa'));runner='runner'
        remember(il);remember(child['binary']);remember(pin(dest/'report.json'));rows={r['name']:r for r in child['cache']};assert set(rows)=={'program',runner}
        assert all(r['hit']==(state=='warm') for r in rows.values()),label
        item=dict(id=label,case=name,round=turn,engine=engine,state=state,source=pin(source),report=pin(dest/'report.json'),binary=child['binary'],qbe=il,cache=child['cache'],wallSeconds=job['seconds'],compilerSeconds=child['seconds'],authenticationSeconds=child.get('authenticationSeconds'),frontendSeconds=child['frontendSeconds'],components={k:v for k,v in child.items() if k.endswith('Seconds')},childSeconds=sum(j['seconds'] for j in child['jobs']));report['builds'].append(item);save()
        for i,(n,s) in enumerate(CASES[name]):
            value=answer(name,n,s);run(label+'-check-'+str(i),[child['binary']['file'],'--expect',value,n,s],value);report['observations'].append(dict(build=label,args=[n,s],expected=value))
        save();return item
    try:
        for turn in range(a.rounds):
            for index,name in enumerate(names):
                pair={};order=['native','js'] if (turn+index)%2==0 else ['js','native']
                for engine in order:
                    for state in ['cold','warm']:pair[engine,state]=build(name,turn,engine,state)
                    cold,warm=(pair[engine,s] for s in ['cold','warm']);assert [(r['name'],r['key']) for r in cold['cache']]==[(r['name'],r['key']) for r in warm['cache']]
                for state in ['cold','warm']:
                    left,right=pair['native',state],pair['js',state];assert Path(left['qbe']['file']).read_bytes().rstrip(b'\n')==Path(right['qbe']['file']).read_bytes().rstrip(b'\n'),(name,turn,state,'QBE mismatch')
                    report['comparisons'].append(dict(case=name,round=turn,state=state,order=order,native=left['qbe'],js=right['qbe'],qbeEqual=True,nativeToJsWallRatio=left['wallSeconds']/right['wallSeconds']));save()
        summaries=[]
        for name in names:
            for state in ['cold','warm']:
                samples={engine:[b['wallSeconds'] for b in report['builds'] if b['case']==name and b['state']==state and b['engine']==engine] for engine in ['native','js']};medians={k:statistics.median(v) for k,v in samples.items()};summaries.append(dict(case=name,state=state,samples=samples,medianSeconds=medians,nativeToJsMedianRatio=medians['native']/medians['js']))
        for item in known.values():assert pin(item['file'])==item
        report.update(complete=True,passed=True,summaries=summaries)
    except Exception as error:report['error']=repr(error);raise
    finally:report.update(finished=time.time(),wallSeconds=time.monotonic()-start);save()
    print(json.dumps(dict(complete=True,passed=True,builds=len(report['builds']),comparisons=len(report['comparisons']),report=pin(out/'report.json'))))
if __name__=='__main__':main()
