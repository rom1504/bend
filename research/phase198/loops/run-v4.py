"""Run only after an explicit shared-lane GO. Stop early on failed predictions."""
import json,subprocess,sys
from pathlib import Path
R=Path('research/phase198/loops')
def argv(n):return json.loads((R/n).read_text())
def run(a):subprocess.run(a,check=True)
mode=sys.argv[1]
if mode=='check':
 run(argv('acquire-argv04.json'))
 run(argv('controls-argv04.json'))
elif mode=='screen':
 run(['taskset','-c','0',*argv('emission-prepare-argv03.json')])
 jobs=argv('screen-argv03.json')
 run(jobs[0])
 run(jobs[2])
 d=json.loads((R/'emission-evidence03/report.json').read_text());rows={v['case']:v for v in d['rows']}
 assert (R/'emission-evidence03/editdist.diff').read_text()=='','Edit hotbody changed; stop'
 for c in ['local-fold','variation-local-fold-8192-123']:
  p=rows[c]['loop']['loops'];assert p['bodyInstructions']==13 and p['frameOperands']==0,'V1 placement not restored; stop'
 run(jobs[1])
 run(['python3','research/phase198/qualification/job.py','loops-edges03','30','16','python3','research/phase198/loops/edge-oracle-v4.py','selfhost/build/phase198/loops-edges03'])
 run(jobs[3])
 run(jobs[4]);run(jobs[5])
 run(['taskset','-c','0','python3',str(R/'summarize-v4.py')])
else:raise ValueError('check or screen')
