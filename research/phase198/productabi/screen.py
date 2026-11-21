"""Ordinary two-input, two-layout comparison with exact native compiler products."""
import argparse
import json
import os
import statistics
import subprocess
import sys
from pathlib import Path
from project import BUILD, ROOT, HERE, CASES, rewrite, sha
from count import counts

sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from measure import ASSETS, REFERENCES, checked_tool, execute, read

def run(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    freeze=read(HERE/'frozen.json')
    assert freeze['implementation']==sha(HERE/'project.py')
    refs={r['id']:r for r in read(REFERENCES)['cases']}
    assets=read(ASSETS)
    asm,ld,rt=[checked_tool(assets['assets'][k]) for k in ('assembler','linker','qbe-runtime')]
    report=dict(complete=False,script=sha(Path(__file__)),freeze=sha(HERE/'frozen.json'),cases={})
    def save(): (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    for ci,case in enumerate(CASES):
        folder=out/case
        folder.mkdir()
        receipt=BUILD/'phase198/native45-01'/case/'machine/report.json'
        native=read(receipt)
        assert sha(Path(native['object']['file']))==native['object']['sha256']
        cmd=native['compilerCommand'].copy()
        assert cmd.count('x86-object')==1 and sha(Path(cmd[0]))==native['request']['image']['sha256']
        cmd[cmd.index('x86-object')]='x86'
        src=folder/'baseline.s'
        with src.open('wb') as stream:
            child=subprocess.run(cmd,stdout=stream,stderr=subprocess.PIPE,timeout=15)
        assert child.returncode==0,child.stderr[-2000:]
        derived,stats=rewrite(src.read_text())
        assert stats['calls']==freeze['cases'][case]['stats']['calls']
        alt=folder/'register.s'
        alt.write_text(derived)
        point=refs[case]['point']
        row=dict(compiler=cmd,nativeReceipt=sha(receipt),object=native['object']['sha256'],asm=sha(src),candidate=sha(alt),
                 sites=stats,checks=[],products={},calibration=[],pairs=[],results={})
        report['cases'][case]=row
        save()
        products={}
        for layout,flags in [('project',native['toolchain']['assemblerFlags']),('default',[])]:
            for role,path in [('baseline',src),('register',alt)]:
                product=folder/(layout+'-'+role)
                obj=product.with_suffix('.o')
                for command in [[asm,*flags,'-o',obj,path],[ld,*native['toolchain']['linkerFlags'],obj,rt,*native['toolchain']['libraries'],'-o',product]]:
                    proc=subprocess.run(command,capture_output=True,timeout=12)
                    assert proc.returncode==0,proc.stderr[-2000:]
                products[product.name]=product
                row['products'][product.name]={'elf':sha(product),'object':sha(obj)}
        row['callCounts']=counts(folder,src.read_text(),asm,ld,rt,native['toolchain'],point)
        save()
        reference=refs[case]['products']['c']
        for i,args in enumerate([point['runtimeArgs'],[2,3],[6,17],[10,123]]):
            n=int(i==0)
            c,expected=execute(checked_tool(reference['artifact']),args,n,0,point['expectedStdout'] if n else None,reference['runtimeArgumentConvention'])
            observations={name:execute(prod,args,n,0,expected)[0]['stdout'] for name,prod in [('current_direct',Path(native['binary']['file'])),*products.items()]}
            row['checks'].append(dict(args=args,c=c,observations=observations))
        def sample(bin,n):
            return execute(bin,point['runtimeArgs'],n,3,point['expectedStdout'])[0]['elapsedMs']
        n=max(1,point['repetitions']//3)
        elapsed=sample(products['project-baseline'],n)
        row['calibration']=[n,elapsed]
        n=max(1,round(n*160/max(elapsed,1)))
        for round_ in range(4):
            layouts=['project','default']
            if (ci+round_)%2:layouts.reverse()
            for pos,layout in enumerate(layouts):
                roles=['baseline','register']
                if (ci+round_+int(layout=='default'))%2:roles.reverse()
                times={role:sample(products[layout+'-'+role],n) for role in roles}
                row['pairs'].append(dict(layout=layout,order=roles,layoutPosition=pos,round=round_,reps=n,times=times,ratio=times['register']/times['baseline']))
            save()
        for layout in layouts:
            ratios=[r['ratio'] for r in row['pairs'] if r['layout']==layout]
            row['results'][layout]={'ratios':ratios,'median':statistics.median(ratios),'faster':sum(v<1 for v in ratios)}
        save()
    report['complete']=True
    save()
    print(json.dumps({k:v['results'] for k,v in report['cases'].items()}))
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',required=True,type=Path)
    run(p.parse_args().out)
