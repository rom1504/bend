"""Compare two checked compiler APIs. Require stage1 objects to match native N1."""
import importlib.util
import inspect  # Load stdlib before the benchmark tool directory, which also contains inspect.py.
import os
import statistics
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'measure'))
from support import B, ROOT
sys.path.insert(0, str(HERE.parent / 'unfold'))
spec = importlib.util.spec_from_file_location('native_transfer', HERE.parent / 'unfold/native-transfer.py')
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)

def run(out):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir(exist_ok=False)
    plan = B.read(HERE.parent / 'unfold/plan.json')
    B.verify(plan['runtime'])
    report = dict(complete=False, cases={}, inputs=[B.pin(__file__),B.pin(HERE/'object.mjs'),B.pin(HERE.parent/'unfold/plan.json')])
    roots = ROOT / 'selfhost/build'
    try:
        for name, reference in [('lexer', roots/'phase205/final-broad06/cases/lexer/candidate/build.json'),
                                ('packet', roots/'phase201/p205unfoldnative01/report.json')]:
            point = plan['cases'][name]
            B.verify(point['original'])
            native = B.read(reference)
            expected = native['object'] if name == 'lexer' else native['products']['candidate']['build']['object']
            B.verify(expected)
            row = dict(products={}, native=expected, preflight=[], samples=[])
            report['cases'][name] = row
            for version in ['06','08']:
                rec = roots/'phase201'/('p205oa'+version)/'report.json'
                obj = out/(name+version+'.o')
                exe = out/(name+version)
                begin = time.monotonic()
                subprocess.run([str(ROOT/'selfhost/.assets/bin/bun'),str(HERE/'object.mjs'),str(rec),point['original']['file'],str(obj)], check=True, timeout=22)
                if version=='06':
                    assert B.pin(obj)['sha256']==expected['sha256'], 'Native N1 and checked API emitted different objects'
                args={'{object}':str(obj),'{runtime}':plan['runtime']['file'],'{output}':str(exe)}
                subprocess.run([args.get(t,t) for t in plan['linkCommand']],check=True,capture_output=True)
                row['products'][version]=dict(receipt=B.pin(rec), object=B.pin(obj), executable=B.pin(exe), buildSeconds=time.monotonic()-begin)
                for test in [point,*point['alternates']]:
                    sample=M.probe(exe,test['args'],test['expected'],1,0,point['expected'])
                    row['preflight'].append(dict(version=version,args=test['args'],output=sample['stdout']))
            reps={}
            for v in ['06','08']:
                count=8
                for attempt in range(10):
                    s=M.probe(out/(name+v),point['args'],point['expected'],count,1,point['expected'])
                    if s['elapsedMs']>=150: break
                    count=max(count+1,int(count*190/max(1,s['elapsedMs'])))
                reps[v]=count
            for i in range(4):
                for v in (['06','08'] if i%2==0 else ['08','06']):
                    s=M.probe(out/(name+v),point['args'],point['expected'],reps[v],1,point['expected'])
                    assert s['elapsedMs']>=100
                    row['samples'].append(dict(round=i,version=v,**s))
            med={v:statistics.median(s['elapsedMs']/s['repetitions'] for s in row['samples'] if s['version']==v) for v in reps}
            row.update(medianMs=med,scalarOverSpine=med['08']/med['06'])
            B.save(out/'report.json',report)
        report['complete']=True
    finally:
        B.save(out/'report.json',report)

if __name__=='__main__':
    run(Path(sys.argv[1]).resolve())
