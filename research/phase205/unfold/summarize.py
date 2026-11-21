"""Authenticate both native receipts and attribute emitted changes to logical function names."""
import argparse,bisect,collections,gzip,hashlib,json,statistics,struct
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def read(p):return json.loads(Path(p).read_bytes())
def pin(p):p=Path(p);b=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p,p

def census(p):
    data=Path(p).read_bytes();off=struct.unpack_from('<Q',data,40)[0];stride,depth,index=struct.unpack_from('<HHH',data,58);ss=[struct.unpack_from('<IIQQQQIIQQ',data,off+stride*i) for i in range(depth)];raw=lambda s:data[s[4]:s[4]+s[5]];nt=raw(ss[index]);name=lambda s,k:s[k:s.index(0,k)].decode();by={name(nt,s[0]):s for s in ss};sym=by['.symtab'];strings=raw(ss[sym[6]]);symbols=list(struct.iter_unpack('<IBBHQQ',raw(sym)))
    def decoded(v):
        n=name(strings,v);base,mid,tail=n.partition('_FID_');
        if mid and tail.endswith('_') and all(x.isdigit() for x in tail[:-1].split('_')):return base+':'+''.join(chr(int(x)) for x in tail[:-1].split('_'))
        return n
    labels=[decoded(k) for k,*_ in symbols];text=by['.text'];functions=sorted((a,a+n,labels[i]) for i,(_,t,_,s,a,n) in enumerate(symbols) if t&15==2 and s==ss.index(text) and n);starts=[r[0]for r in functions];tracked=['p205unfold_fn0','packet.fold','packet.choose','packet.apply','packet.step','line','gen.at','gen','expand','slot.go','slot','salt','prng','ident','num','op','lex'];owned={};incoming=collections.Counter()
    def logical(n):
        s=n.split(':',1)[-1]
        return next((k for k in tracked if s==k or s.endswith('.'+k)),None)
    for a,b,n in functions:
        if logical(n):owned[n]=dict(logical=logical(n),bytes=b-a,calls={})
    for at,info,add in struct.iter_unpack('<QQq',raw(by['.rela.text'])):
        if info&0xffffffff!=4:continue
        j=bisect.bisect_right(starts,at)-1
        if j<0 or at>=functions[j][1]:continue
        dst=labels[info>>32];src=functions[j][2];dstOwner=logical(dst)
        if dstOwner:incoming[dstOwner]+=1
        if src in owned:counts=owned[src]['calls'];counts[dst]=counts.get(dst,0)+1
    return dict(textBytes=text[5],functions=len(functions),tracked=owned,logicalIncomingRelocatedCalls=dict(incoming))

def retain(name):
    out=ROOT/'selfhost/build/phase201'/name;guard=out.with_name(name+'-guard');close=ROOT/'selfhost/build-retention/phase201'/(name+'-close');r=read(out/'report.json');g=read(guard/'process.json');assert r['complete'] and g['complete'] and g['returncode']==0;verify(r['plan']);plan=read(r['plan']['file']);assert len(r['cases'])==4
    evidence={};summary={};weights=read(ROOT/'research/phase205/weights/results01.json');weightsById={v['id']:v['candidate']['seconds']for v in weights['cases']};saved=0.0;catalogOrig=catalogStaged=catalogC=0.
    for n,v in r['cases'].items():
        assert v['complete'];fp=plan['cases'][n];med={};machine={}
        for role,o in v['builds'].items():
            assert o['source']==fp[role] and o['runtime']==plan['runtime'];verify(o['object']);verify(o['binary']);machine[role]=census(o['object']['file']);assert machine[role]['textBytes']==v['machine'][role]['textBytes']
        for role in v['medianMsPerInvocation']:
            obs=[o for o in v['observations'] if o['role']==role];assert len(obs)==(4 if n=='packet' else 3);assert all(o['elapsedMs']>=100 for o in obs);med[role]=statistics.median(o['elapsedMs']/o['repetitions']for o in obs);assert med[role]==v['medianMsPerInvocation'][role]
        assert len(v['oracles'])==(5 if n=='packet' else 4);summary[n]=dict(mediansMs=med,stagedOverOriginal=med['staged']/med['original'],stagedOverC=med['staged']/med['c'] if 'c'in med else None,oracleInputs=[o['args']for o in v['oracles']],acceptedTimedObservations=len(v['observations']),machine=machine)
        if n in weightsById:
            saved+=weightsById[n]*(1-med['staged']/med['original']);case=next(cc for cc in weights['cases'] if cc['id']==n);reps=case['catalogRepetitions'];catalogOrig+=reps*med['original']/1000;catalogStaged+=reps*med['staged']/1000;catalogC+=reps*med['c']/1000
    def archive(f):
        f=Path(f);evidence[str(f.relative_to(ROOT))]=dict(sha256=pin(f)['sha256'],data=read(f))
    for f in [out/'report.json',guard/'process.json',guard/'retention.json',close/'report.json',close/'intent.json',Path(r['plan']['file'])]:archive(f)
    for f in sorted(out.glob('*/*/build.json')):archive(f)
    info=dict(run=name,guardWallSeconds=g['wallSeconds'],nativeImage=plan['image']['elfSha256'],runtime=plan['runtime']['sha256'],sampledCases=summary,projectedSecondsSavedOnPhase200Weights=saved,actualThreeRowFixedSeconds=dict(original=catalogOrig,staged=catalogStaged,c=catalogC),actualThreeRowStagedOverC=catalogStaged/catalogC)
    (HERE/(name+'-summary.json')).write_text(json.dumps(info,indent=2)+'\n');(HERE/(name+'-receipts.json.gz')).write_bytes(gzip.compress(json.dumps(evidence,indent=2).encode(),mtime=0));print(json.dumps(dict(guard=g['wallSeconds'],saved=saved,fixed=info['actualThreeRowFixedSeconds'],ratio=info['actualThreeRowStagedOverC'])))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('run');retain(p.parse_args().run)
