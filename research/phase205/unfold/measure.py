"""Freeze or run paired source specialization under the campaign's CPU3 guard."""
import argparse,bisect,collections,hashlib,json,math,os,re,statistics,struct,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
from make_fixtures import HERE,ROOT,oracle
from stage import transform
sys.path.insert(0,str(ROOT/'research/phase205/measure'))
from support import B,REFERENCE,image_binding,c_reference,module
M=module('unfold_native_driver',ROOT/'research/phase205/measure/screen.py')
# The existing harness validates full stdout, all repetitions, stderr and status.
from support import P
from importlib.util import module_from_spec,spec_from_file_location
sys.path.insert(0,str(ROOT/'research/phase196/screen'));sp=spec_from_file_location('unfold_runtime_observe',ROOT/'research/phase196/screen/measure.py');timing=module_from_spec(sp);sp.loader.exec_module(timing)

PLAN=HERE/'plan.json'

def save(path,obj):path.write_text(json.dumps(obj,indent=2)+'\n')

def freeze():
    source=ROOT/'selfhost/build/phase201/p204image03';image=image_binding(source/'program.gz',source/'results.json')
    ref=B.read(REFERENCE);cmd=ref['compilerCommand'].copy();assert cmd[8]=='x86-object';cmd[0]='{image}';cmd[9]='{source}'
    link=next(j['command'].copy() for j in ref['jobs'] if j['label']=='link');link[2]='{object}';link[3]='{runtime}';link[-1]='{output}'
    runtime=B.read(ROOT/'research/phase199/broad/integrated-pins.json')['live'];B.verify(runtime)
    summary,_,cdata=c_reference();lex_points=B.read(ROOT/'research/phase200/lex/oracles-v2.json')['program']
    rows={};inputs=[B.pin(p) for p in [__file__,HERE/'stage.py',HERE/'make_fixtures.py',HERE/'fixtures.json',M.__file__,timing.__file__,REFERENCE,cmd[10],cmd[12],link[0],ROOT/'research/phase200/lex/oracles-v2.json']]
    for n,meta in B.read(HERE/'fixtures.json').items():
        original=B.pin(ROOT/meta['original']);staged=B.pin(ROOT/meta['staged']);generated,sites=transform(Path(original['file']).read_text());assert generated.encode()==Path(staged['file']).read_bytes() and sites==meta['sites']
        inputs.extend([original,staged]);row=dict(original=original,staged=staged,sites=sites)
        if n=='packet':
            row.update(args=[512,17],expected=oracle(512,17),alternates=[dict(args=[n,s],expected=oracle(n,s)) for n,s in [(0,0),(1,7),(3,123),(17,4294967295)]])
        else:
            c=cdata[n];assert original==c['source'];point=c['point'];product=c['products']['c'];row.update(args=point['runtimeArgs'],expected=point['expectedStdout'],c=product['artifact'],cConvention=product['runtimeArgumentConvention'],alternates=[r for r in lex_points if r['args'] in [[0,4294967295],[3,7],[4,123]]]);inputs.extend([product['artifact'],c['expectedFile']]);assert Path(c['expectedFile']['file']).read_text()==point['expectedStdout']
        rows[n]=row
    inputs.extend([runtime,summary['references'],image['gzip'],image['receipt'],image['source']]);
    record=dict(kind='phase205-bounded-spine-unfold-screen',image=image,runtime=runtime,compilerCommand=cmd,linkCommand=link,cases=rows,minimumMs=100,targetMs=180,balancedRounds=3,inputs=B.unique_inputs(inputs));save(PLAN,record);return record

def machine(obj):
    d=Path(obj).read_bytes();assert d[:6]==b'\x7fELF\x02\x01';shoff=struct.unpack_from('<Q',d,40)[0];sz,num,st=struct.unpack_from('<HHH',d,58);sects=[struct.unpack_from('<IIQQQQIIQQ',d,shoff+sz*i) for i in range(num)]
    def data(s):return d[s[4]:s[4]+s[5]]
    def name(t,k):return t[k:t.index(0,k)].decode()
    tb=data(sects[st]);names={name(tb,s[0]):s for s in sects};sym=names['.symtab'];pool=data(sects[sym[6]]);syms=list(struct.iter_unpack('<IBBHQQ',data(sym)));symbols=[name(pool,s[0])for s in syms];text=names['.text'];targets={};totals=collections.Counter()
    def decode(n):
        m=re.fullmatch(r'(.+)_FID_((?:[0-9]+_)+)',n)
        if not m:return n
        return m[1]+':'+''.join(chr(int(a)) for a in m[2][:-1].split('_'))
    fun=sorted((v,v+length,decode(symbols[i])) for i,(_,info,_,section,v,length) in enumerate(syms) if info&15==2 and section==sects.index(text) and length);starts=[r[0] for r in fun]
    tracked={'line','gen','gen.at','expand','slot','slot.go','packet.fold','packet.step','packet.apply','packet.choose','p205unfold_fn0'}
    for a,b,n in fun:
        if n.split(':',1)[-1] in tracked:targets[n]=dict(bytes=b-a,calls={})
    for off,packed,addend in struct.iter_unpack('<QQq',data(names['.rela.text'])):
        k=bisect.bisect_right(starts,off)-1
        if k<0 or off>=fun[k][1] or packed&0xffffffff!=4:continue
        src=fun[k][2];dst=decode(symbols[packed>>32]);totals[dst]+=1
        if src in targets:counts=targets[src]['calls'];counts[dst]=counts.get(dst,0)+1
    return dict(textBytes=text[5],functionCount=len(fun),trackedFunctions=targets,incomingCallSites={n:c for n,c in totals.items() if n.split(':',1)[-1] in tracked})

def run(out,smoke=False):
    if os.sched_getaffinity(0)!={3}:raise ValueError('CPU3 guard required')
    start=time.monotonic();out=out.resolve();out.mkdir(parents=True,exist_ok=False);plan=B.read(PLAN);deadline=start+(19 if smoke else 120);fd=None;r=dict(complete=False,mode='source-smoke' if smoke else 'full',plan=B.pin(PLAN),cases={})
    def checkpoint():save(out/'report.json',r)
    checkpoint()
    try:
        for pin in plan['inputs']:B.verify(pin)
        fd,r['image']=M.load_image(plan['image'])
        for n,c in plan['cases'].items():
            if smoke and n not in ('lexer','packet'):continue
            item=r['cases'][n]=dict(builds={},machine={},oracles=[],calibration={},observations=[]);binary={};convention={}
            for role in (('staged',) if smoke else ('original','staged')):
                _,record=M.build(plan,plan['image'],fd,c[role],out/n/role,deadline);item['builds'][role]=record;binary[role]=record['binary']['file'];convention[role]='bend-rts-v1';item['machine'][role]=machine(record['object']['file']);checkpoint()
            if 'c' in c:binary['c']=c['c']['file'];convention['c']=c['cConvention']
            for point in [dict(args=c['args'],expected=c['expected']),*c['alternates']]:
                check={}
                for role,exe in binary.items():check[role]=timing.execute(exe,point['args'],0,0,point['expected'],convention[role])[0]
                item['oracles'].append(dict(args=point['args'],expected=point['expected'],observed=check));checkpoint()
            if smoke:
                item['complete']=True;checkpoint();continue
            counts={}
            for role,exe in binary.items():
                reps=32;rec=item['calibration'][role]=[]
                for _ in range(8):
                    obs=timing.execute(exe,c['args'],reps,3,c['expected'],convention[role])[0];ms=obs['elapsedMs'];rec.append(dict(repetitions=reps,**obs))
                    if 145<=ms<=450:break
                    reps=min(1048576,max(1,math.ceil(reps*plan['targetMs']/max(1,ms))))
                else:raise ValueError('calibration '+n+' '+role)
                counts[role]=reps
            order=list(binary);times={k:[] for k in order}
            for turn in range(plan['balancedRounds'] if len(order)==3 else 4):
                for role in order[turn%len(order):]+order[:turn%len(order)]:
                    obs=timing.execute(binary[role],c['args'],counts[role],3,c['expected'],convention[role])[0];ms=obs['elapsedMs'];assert ms>=plan['minimumMs'],(n,role,'timing too short',ms);times[role].append(ms/counts[role]);item['observations'].append(dict(round=turn,role=role,repetitions=counts[role],**obs));checkpoint()
            med={k:statistics.median(v) for k,v in times.items()};item.update(medianMsPerInvocation=med,stagedOverOriginal=med['staged']/med['original'],complete=True)
            if 'c' in med:item['stagedOverC']=med['staged']/med['c'];item['originalOverC']=med['original']/med['c']
            checkpoint()
        r['complete']=True
    except BaseException as error:r['error']=repr(error);raise
    finally:
        if fd is not None:os.close(fd)
        r['wallSeconds']=time.monotonic()-start;checkpoint()
    print(json.dumps({k:[v.get('stagedOverOriginal'),v.get('stagedOverC'),v['complete']] for k,v in r['cases'].items()}))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--freeze',action='store_true');p.add_argument('--out',type=Path);p.add_argument('--smoke',action='store_true');a=p.parse_args();freeze() if a.freeze else run(a.out,a.smoke)
