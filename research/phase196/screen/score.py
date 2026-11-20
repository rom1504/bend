"""Score all three predeclared selection policies against the two timing sessions."""
import argparse
from collections import defaultdict
import json
import math
from pathlib import Path
import statistics as st
import sys
from regions import digest, read
from measure import bench, FROZEN, ROOT


def ranks(values):
    ordered=sorted(values.values(),reverse=True)
    return {k:st.mean(i for i,x in enumerate(ordered,1) if v==x) for k,v in values.items()}


def spearman(a,b):
    x,y=ranks(a),ranks(b)
    k=list(x)
    u,v=st.mean(x.values()),st.mean(y.values())
    return sum((x[i]-u)*(y[i]-v) for i in k)/math.sqrt(sum((z-u)**2 for z in x.values())*sum((z-v)**2 for z in y.values()))


def assess(built,measurements,out):
    frozen=read(FROZEN)
    products=read(built)
    assert products['complete'] and products['freeze']==digest(FROZEN)
    sessions=[]
    for idx,file in enumerate(measurements):
        report=read(file); assert report['complete'] and report['reverse']==bool(idx) and report['buildSha']==digest(built)
        assert len(report['rows'])==160
        groups=defaultdict(dict)
        for r in report['rows']:
            point=products['cases'][r['case']]['point']
            elapsed=bench.observation(r['stdout'].encode(),b'',0,{**point,'repetitions':r['repetitions'],'warmups':4},r['wall'])
            assert elapsed==r['elapsedMs'] and elapsed>=100
            group=groups[(r['case'],r['round'])]
            assert r['name'] not in group
            group[r['name']]=r
        results={}
        for c in frozen['candidates']:
            pairs=[]
            for i in range(8):
                group=groups[(c['case'],i)];a,b=group['baseline'],group[c['name']]
                assert len(group)==4 and a['repetitions']==b['repetitions']
                pairs.append(b['elapsedMs']/a['elapsedMs'])
            results[c['name']]=dict(pairs=pairs,median=st.median(pairs),faster=sum(x<1 for x in pairs))
        sessions.append(results)
    rows={}
    for r in frozen['candidates']:
        name=r['name'];s=[j[name] for j in sessions]
        ratio=st.geometric_mean(j['median'] for j in s)
        rows[name]=dict(case=r['case'], sessions=s,ratio=ratio,
                        win=all(j['median']<=.98 and j['faster']>=6 for j in s))
    observed={k:1-v['ratio'] for k,v in rows.items()}
    policies={}
    for key,names in frozen['rankings'].items():
        top=names[:4]
        wins=[k for k in top if rows[k]['win']]
        misses=[k for k in names[4:] if rows[k]['win']]
        policies[key]=dict(top=top,wins=wins,misses=misses,
            summedFractionSaved=sum(observed[k] for k in top),
            spearman=spearman({c['name']:c['scores'][key] for c in frozen['candidates']},observed))
    outcome=dict(rows=rows,policies=policies,inputs={str(p):digest(p) for p in [FROZEN,built,*measurements]})
    out.write_text(json.dumps(outcome,indent=2)+'\n')
    print(json.dumps(policies,indent=2))
    for name,r in sorted(rows.items(),key=lambda kv:kv[1]['ratio']):
        print(name,*['%.4f(%d)'%(v['median'],v['faster']) for v in r['sessions']],r['win'])


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('built',type=Path);p.add_argument('measurements',nargs=2,type=Path);p.add_argument('--out',required=True,type=Path)
    args=p.parse_args();assess(args.built,args.measurements,args.out)
