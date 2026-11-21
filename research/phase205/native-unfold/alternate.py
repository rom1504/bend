"""Retest the existing independently checked lexer objects with alternate inputs."""
import inspect
import json
import os
import statistics
import sys
from pathlib import Path
from importlib import import_module
m = import_module('scalar-screen')
assert os.sched_getaffinity(0) == {3}
out=Path(sys.argv[1]);out.mkdir(exist_ok=False)
run=Path('selfhost/build/phase201/p205scalarperf10')
parent=m.B.read(run/'report.json');assert parent['complete']
case=parent['cases']['lexer'];plan=m.B.read(m.HERE.parent/'unfold/plan.json')
r={'source':m.B.pin(run/'report.json'),'cases':{},'complete':False}
for point in plan['cases']['lexer']['alternates'][1:]:
    args=point['args'];rows=[];counts={}
    for role in ('06','08'):
        pin=case['products'][role]['executable'];m.B.verify(pin)
        pilot=m.M.probe(pin['file'],args,point['expected'],1024,1,plan['cases']['lexer']['expected'])
        counts[role]=max(1,int(1024*180/max(1,pilot['elapsedMs'])))
    for turn in range(4):
        for role in (('06','08') if turn%2==0 else ('08','06')):
            pin=case['products'][role]['executable'];m.B.verify(pin)
            s=m.M.probe(pin['file'],args,point['expected'],counts[role],1,plan['cases']['lexer']['expected'])
            assert s['elapsedMs']>=100
            rows.append(dict(role=role,**s))
    med={v:statistics.median(s['elapsedMs']/s['repetitions'] for s in rows if s['role']==v) for v in ('06','08')}
    r['cases'][str(args)]=dict(point=point,observations=rows,ratio=med['08']/med['06'])
r['complete']=True;m.B.save(out/'results.json',r)
