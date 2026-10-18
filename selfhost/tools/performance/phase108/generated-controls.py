#!/usr/bin/env python3
"""Execute the six real compiled programs against independently retained outputs."""
import argparse,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('run',HERE/'run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
def main():
    p=argparse.ArgumentParser();p.add_argument('--comparison',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--threads',type=int,default=1);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase108') and not out.exists();out.mkdir(parents=True)
    planpin=R.pin(HERE/'coverage/full-compiler-plan.json');plan=json.loads(Path(planpin['file']).read_text());comparisonpin=R.pin(a.comparison/'report.json');comparison=json.loads(Path(comparisonpin['file']).read_text());assert comparison['complete'];report=dict(kind='phase108-real-generated-controls',complete=False,plan=planpin,comparison=comparisonpin,rows=[]);save=lambda:R.save(out/'report.json',report);save()
    def cmd(name,args):
        with (out/(name+'.stdout')).open('xb') as stdout,(out/(name+'.stderr')).open('xb') as stderr:r=R.P.run(list(map(str,args)),stdout=stdout,stderr=stderr,timeout=60,cwd=ROOT)
        if r.returncode:raise RuntimeError(name+' failed')
    try:
        for i,case in enumerate(plan['representatives']):
            matches=[r for r in comparison['rows'] if r['source']['sha256']==case['source']['sha256'] and r['round']==0]
            assert len(matches)==1 and matches[0]['exact'] and matches[0]['diagnosticExact']
            receiptpin=matches[0]['stages']['candidate']['receipt'];R.N.verify(receiptpin)
            receipt=json.loads(Path(receiptpin['file']).read_text());assert receipt['complete']
            generated=receipt['generatedC'];R.N.verify(generated);source=Path(generated['file'])
            oracle=case['optionalGeneratedProgram'];evidence=R.pin(ROOT/oracle['evidence']['file'])
            assert (evidence['sha256'],evidence['bytes'])==(oracle['evidence']['sha256'],oracle['evidence']['bytes'])
            assert Path(evidence['file']).read_bytes()==oracle['stdout'].encode()
            row=dict(name=case['id'],complete=False,emission=receiptpin,generatedC=generated,oracle=evidence);report['rows'].append(row);save();prefix=out/str(i)
            expected=out/(str(i)+'.expected');expected.write_text(oracle['stdout'])
            cmd(str(i)+'-build',[sys.executable,'-B',HERE/'run.py','build',source,'--out',str(prefix)+'-build'])
            cmd(str(i)+'-run',[sys.executable,'-B',HERE/'run.py','run',str(prefix)+'-build/program','--threads',a.threads,'--expected',expected,'--out',str(prefix)+'-run'])
            for item in [receiptpin,generated,evidence]:R.N.verify(item)
            row.update(complete=True,build=R.pin(str(prefix)+'-build/report.json'),run=R.pin(str(prefix)+'-run/report.json'));save()
        for item in [planpin,comparisonpin]:R.N.verify(item)
        report['complete']=True;save();print(json.dumps(dict(complete=True,cases=len(report['rows']))))
    except BaseException as e:report['error']=repr(e);save();raise
if __name__=='__main__':main()
