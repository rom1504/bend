"""Independent Patricia-trie replay of the collection workload's semantic key probes."""
import json
from collections import Counter
from pathlib import Path
from cursor import BorrowedCursor, build, controls, byte_prefix, prefix_bit, prefix_controls

ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
U32=(1<<32)-1


def word(c):
    return c if isinstance(c,int) else ord(c)


class Node:
    def __init__(self, position, lo, hi):
        self.position=position
        self.children=[lo,hi]


class ProbeTrace:
    def __init__(self):
        self.probes=[]
        self.walks=[]

    def start(self,operation,key):
        self.walks.append(dict(operation=operation,key=key,probes=[]))

    def bit(self,key,pos):
        ci,off=divmod(pos,33)
        exists=ci<len(key)
        value=exists and (off==0 or bool((word(key[ci])>>(32-off))&1))
        event=dict(ci=ci,off=off,exists=exists,position=pos,bit=int(value))
        assert self.walks[-1]['key']==key
        self.walks[-1]['probes'].append(event)
        self.probes.append(event)
        return int(value)


def diff(key,other):
    for i,(x,y) in enumerate(zip(key,other)):
        if x!=y:return 33*i+33-(word(x)^word(y)).bit_length()
    return 33*min(len(key),len(other))


def set_key(node,key,value,t):
    t.start('seek',key)
    leaf=node
    while isinstance(leaf,Node):leaf=leaf.children[t.bit(key,leaf.position)]
    if leaf is None:return (key,value)
    if leaf[0]==key:
        t.start('put',key)
        def attach(cur):
            if not isinstance(cur,Node):return (key,value)
            b=t.bit(key,cur.position);cur.children[b]=attach(cur.children[b]);return cur
        return attach(node)
    pos=diff(key,leaf[0])
    t.start('insert',key)
    def ins(cur):
        if isinstance(cur,Node):
            b=t.bit(key,cur.position)
            if cur.position<pos:
                cur.children[b]=ins(cur.children[b]);return cur
        b=t.bit(key,pos)
        return Node(pos,cur,(key,value)) if b else Node(pos,(key,value),cur)
    return ins(node)


def pop(node,key,t):
    t.start('pop',key)
    def drop(cur):
        if not isinstance(cur,Node):return None if cur and cur[0]==key else cur
        b=t.bit(key,cur.position);cur.children[b]=drop(cur.children[b])
        return cur if cur.children[b] else cur.children[1-b]
    return drop(node)


def digest(tree):
    def ordered(t):
        if isinstance(t,Node):
            yield from ordered(t.children[0]);yield from ordered(t.children[1])
        elif t is not None:yield t
    h=2166136261
    for key,val in ordered(tree):
        for c in key:h=(31*h+word(c))&U32
        h=((h*16777619)&U32)^val
    return h


def trace(n,seed,key=lambda i: 'key'+str(i)):
    root=None;t=ProbeTrace()
    for i in range(n):root=set_key(root,key(i),(seed+17*i)&U32,t)
    for i in range(0,n,3):root=set_key(root,key(i),seed^(31*i),t)
    for i in range(0,n,4):root=pop(root,key(i),t)
    # A proposed local cursor starts afresh at each seek/put/insert/pop.
    # A decreasing bit position requires restarting from the original root.
    original=cursor=fullreads=cachehits=rewinds=0
    concrete_cursor=packed_reads=packed_hits=packed_fallbacks=0
    for walk in t.walks:
        key_root=build([word(c) for c in walk['key']])
        local=BorrowedCursor(key_root)
        prefix,count=byte_prefix(key_root)
        if walk['probes']:packed_reads+=count
        last=None
        previous_visits=0
        for p in walk['probes']:
            assert local.query(p['position'])==p['bit']
            v=prefix_bit(prefix,p['position'])
            if v is None:packed_fallbacks+=1
            else:
                assert v==p['bit']
                packed_hits+=1
            ci=min(p['ci'],len(walk['key']))
            visits=ci+int(p['exists']);original+=visits
            if last is None or ci<last:
                cursor+=visits;rewinds+=int(last is not None)
            else:
                cursor+=visits-previous_visits
                cachehits+=ci==last
            last=ci;previous_visits=visits
            fullreads+=int(p['exists'] and p['off']!=0)
        concrete_cursor+=local.visits
    assert concrete_cursor==cursor
    operation_reads=sum(byte_prefix(build([word(c) for c in key(i)]))[1]
                        for step in [1,3,4] for i in range(0,n,step))
    return dict(n=n,seed=seed,digest=digest(root),wholeOperationBytePrefixConsVisits=operation_reads,probes=len(t.probes),dataBitProbes=fullreads,
                originalConsVisits=original,localCursorConsVisits=cursor,bytePrefixConsVisits=packed_reads,
                bytePrefixAnswered=packed_hits,bytePrefixFallback=packed_fallbacks,sameCharacterRequests=cachehits,
                cursorRestarts=rewinds,byPosition=dict(Counter(p['position'] for p in t.probes)),
                byOperation=dict(Counter({op:sum(len(w['probes']) for w in t.walks if w['operation']==op)
                    for op in ('seek','put','insert','pop')})))


if __name__=='__main__':
    count=ROOT/'selfhost/build/phase198/runtime-count01/report.json'
    checks=json.loads(count.read_bytes())['cases']
    catalog=json.loads((ROOT/'selfhost/build/phase195/references01/manifest.json').read_bytes())['cases']
    print('cursor checks',controls(),'prefix controls/fallbacks',prefix_controls())
    values=[]
    for n,seed in ((32,17),(128,123)):
        r=trace(n,seed);name='coverage-map-churn-'+str(n)
        actual=next(x for x in checks if x['id']==name)
        key=next(k for k,v in actual['siteNames'].items() if 'borrow.read.Map.bit.go' in v)
        oracle=next(x for x in catalog if x['id']==name)['point']['expectedStdout']
        print(r)
        assert r['digest']==int(oracle)
        r['measuredDataProbes']=[actual['first'][key],actual['second'][key]]
        assert r['measuredDataProbes']==[r['dataBitProbes']]*2
        values.append(r)
    (HERE/'traces.json').write_text(json.dumps(values,indent=2)+'\n')
