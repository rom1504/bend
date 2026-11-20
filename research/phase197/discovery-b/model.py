"""Score every frozen site through the project's authenticated Ivy Bridge model."""
import argparse
from pathlib import Path
import os
import re
import subprocess
import time

from freeze import HERE, BUILD, digest, read, save


def main(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    plan=read(HERE/'frozen.json')
    acquisition=read(BUILD/'phase195/hardware-tool01/acquisition.json')
    for pin in [acquisition['tool'],*acquisition['libraries']]:
        assert digest(pin['file'])==pin['sha256']
    result=dict(freeze=digest(HERE/'frozen.json'),tool=acquisition['tool'],candidates=[])
    for row in plan['candidates']:
        sites=[]
        score=0
        for site in row['sites']:
            stats={}
            for role in ['before','after']:
                path=out/f"{row['name']}-{site['line']}-{role}"
                source=path.with_suffix('.s')
                source.write_text('.text\n'+'\n'.join(site[role])+'\n')
                cmd=[acquisition['tool']['file'],'-mtriple=x86_64-unknown-linux-gnu','-mcpu=ivybridge',
                     '-iterations=100','-noalias=true',str(source)]
                t=time.monotonic()
                p=subprocess.run(cmd,capture_output=True,text=True,timeout=5,check=True)
                assert not p.stderr
                path.with_suffix('.stdout').write_text(p.stdout)
                def metric(key):
                    return float(re.search('^'+key+r':\s*([\d.]+)',p.stdout,re.M)[1])
                assert metric('Instructions')==100*len(site[role])
                stats[role]=dict(cycles=metric('Total Cycles'),throughput=metric('Block RThroughput'),instructions=len(site[role]),seconds=time.monotonic()-t)
            change=1-stats['after']['cycles']/stats['before']['cycles']
            score+=change*site['weight']
            sites.append(dict(line=site['line'],weight=site['weight'],cycleSaving=change,**stats))
        result['candidates'].append(dict(name=row['name'],score=score,sites=sites))
    save(out/'model.json',result)


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    main(p.parse_args().out)
