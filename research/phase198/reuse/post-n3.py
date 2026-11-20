"""Run the three authorized commands serially and preserve independent failures."""
from pathlib import Path
import json
import subprocess
import sys

py = [sys.executable, '-B']
job = [*py, 'research/phase198/qualification/job.py']
root = Path('selfhost/build/phase198')
here = Path('research/phase198/reuse')
bun = 'selfhost/.assets/bin/bun'

def guarded(*args):
    return subprocess.run([*job, *map(str,args)]).returncode

em = guarded('--rss-mib','3072','reuse-emission01','90','48',bun,here/'emit.mjs',
             '--api',root/'reuse-api02/report.json','--out',root/'reuse-emission01','--cases','tree-bitonic')
status = [em]
if em == 0:
    row=json.loads((root/'reuse-emission01/report.json').read_text())
    sym='p113d_FID_'+''.join(str(ord(c))+'_' for c in '$direct.warp_zip')
    if row['complete'] and [r['plans'] for r in row['cases']] == [[sym]]:
        status.append(guarded('reuse-compiled01','70','28',*py,here/'compile-check.py',
                       '--emission',root/'reuse-emission01/report.json','--out',root/'reuse-compiled01'))
    else:
        print('local rule declined, preserving original plans',[(r['id'],r['plans']) for r in row['cases']]);status.append(1)
apiroot=root/'reuse-fusion-api-src03'
status.append(guarded('--rss-mib','3072','reuse-fusion-api01','95','100',bun,'selfhost/tools/build/hosted.mjs','acquire',
              '--source',apiroot/'compiler.bend','--exports',apiroot/'exports.json','--out',root/'reuse-fusion-api01',
              '--engine',bun,'--upstream','selfhost/.bootstrap/upstream-phase182'))
raise SystemExit(max(status))
