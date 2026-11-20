"""Serialize full-rule acquisition, proof, emission and target checks in a granted lane."""
from pathlib import Path
import argparse
import subprocess
import sys

p=argparse.ArgumentParser();p.add_argument('--version',type=int,required=True);p.add_argument('--source-version',type=int,required=True)
p.add_argument('--stages',default='api,emit,verify');p.add_argument('--cases',default='tree-bitonic,envelope,changed-zip,changed-recur,changed-predicate,changed-order')
a=p.parse_args();seq=a.stages.split(',');root=Path('selfhost/build/phase198');here=Path('research/phase198/reuse/pairwise');py=[sys.executable,'-B'];bun='selfhost/.assets/bin/bun';guard=[*py,'research/phase198/qualification/job.py'];n=f'{a.version:02d}'
source=root/('reuse-fusion-api-src'+f'{a.source_version:02d}');api='reuse-fusion-api'+n;emit='reuse-fusion-emit'+n;verify='reuse-fusion-product'+n
steps={'api':['--rss-mib','3072',api,'95','96',bun,'selfhost/tools/build/hosted.mjs','acquire','--source',source/'compiler.bend','--exports',source/'exports.json','--out',root/api,'--engine',bun,'--upstream','selfhost/.bootstrap/upstream-phase182'],
       'emit':['--rss-mib','3072',emit,'110','48',bun,here/'emit.mjs','--api',root/api/'report.json','--out',root/emit,'--cases',a.cases],
       'verify':[verify,'75','32',*py,here/'verify.py','--emission',root/emit/'report.json','--out',root/verify]}
for k in seq:
    r=subprocess.run([*guard,*map(str,steps[k])]);
    if r.returncode:raise SystemExit(r.returncode)
