"""Run and record all model comparisons before building candidate executables."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import time

from candidates import CANDIDATES, transform
from regions import ROOT, BUILD, regions, digest, read, pretty


def main(out):
    acquisition = read(BUILD/'phase195/hardware-tool01/acquisition.json')
    for f in [acquisition['tool'], *acquisition['libraries']]:
        assert digest(f['file']) == f['sha256']
    tool = acquisition['tool']['file']
    out.mkdir(parents=True,exist_ok=False)
    receipt = dict(tool=acquisition['tool'], profiles={}, candidates=[], methodHashes={})
    for p in Path(__file__).parent.glob('*.py'):
        receipt['methodHashes'][p.name]=digest(p)
    cost = 0
    for c in CANDIDATES:
        src,elf,profiles,blocks = regions(c.case)
        symbol,block = next((s,b) for s,b in blocks if b[0][0]+1==c.line)
        before = [v[1] for v in block]
        after = transform(c,before)
        assert before != after
        weight = sum(v[3] for v in block)
        assert 0 < weight <= 1
        receipt['profiles'][c.case]=dict(assembly=str(src.relative_to(ROOT)),assemblySha=digest(src),
                elf=str(elf.relative_to(ROOT)),elfSha=digest(elf),
                captures=[(str(p.relative_to(ROOT)),digest(p)) for p in profiles])
        metrics={}
        for label,seq in [('before',before),('after',after)]:
            asm=out/(c.name+'-'+label+'.s')
            asm.write_text('.text\n'+ '\n'.join(seq)+'\n')
            cmd=[tool,'-mtriple=x86_64-unknown-linux-gnu','-mcpu=ivybridge','-iterations=100','-noalias=true',str(asm)]
            t=time.monotonic(); p=subprocess.run(cmd,capture_output=True,text=True,timeout=5);cost+=time.monotonic()-t
            (out/(c.name+'-'+label+'.stdout')).write_text(p.stdout)
            assert p.returncode==0 and not p.stderr,(c.name,p.stderr)
            def metric(field):
                return float(re.search('^'+field+r':\s*([\d.]+)',p.stdout,re.M)[1])
            assert metric('Iterations')==100 and metric('Instructions')==100*len(seq)
            metrics[label]=dict(cycles=metric('Total Cycles'),throughput=metric('Block RThroughput'),instructions=len(seq))
        before_m,after_m=metrics['before'],metrics['after']
        cycle_score=1-after_m['cycles']/before_m['cycles']
        receipt['candidates'].append(dict(name=c.name,case=c.case,line=c.line,symbol=pretty(symbol),rawSymbol=symbol,
                  address=hex(block[0][2]),blockWeight=weight,before=before,after=after,legality=c.legality,metrics=metrics,
                  scores=dict(count=1-len(after)/len(before),model=cycle_score,weighted=cycle_score*weight)))
    receipt['rankings']={key:[v['name'] for v in sorted(receipt['candidates'],key=lambda v:(-v['scores'][key],v['name']))]
                          for key in ('count','model','weighted')}
    receipt.update(modelWallSeconds=cost,workloadsTimed=False,planHash=digest(ROOT/'design/phase196/prospective-ranking.md'))
    (out/'freeze.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt['rankings']))


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--out',type=Path,required=True)
    main(parser.parse_args().out)
