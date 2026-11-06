#!/usr/bin/env python3
"""Run the independent pinned source checker; record unsafe proof refusal separately."""
import argparse, json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, fresh_output, run, write_json, require
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=fresh_output(a.out,ROOT)
engine=ROOT/'selfhost/.assets/bin/bun'; upstream=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2'
inputs=[pin(__file__),pin(a.source),pin(engine),*[pin(upstream/f) for f in ['main.ts','bend.ts','comp.ts','base.bend']]]
report=dict(complete=False,inputs=inputs,sourceChecked=False,proofAccepted=False)
try:
 job=run([str(engine),str(upstream/'main.ts'),str(a.source.resolve()),'--check-only'],cwd=ROOT,
         stdout=out/'stdout',stderr=out/'stderr',seconds=60)
 report['job']=job
 stdout=(out/'stdout').read_text();stderr=(out/'stderr').read_text()
 match=re.fullmatch(r'SOME PROOFS FAIL\nError: ([0-9]+) defs rely on unsafe or foreign code:\n((?:- [^\n]+\n)+)',stderr)
 require(job['exitCode']==1 and not job.get('timedOut',False) and stdout=='' and match is not None,
         'Expected successful body checking followed solely by explicit unsafe/foreign proof refusal')
 require(len(match[2].splitlines())==int(match[1]),'Truncated proof-refusal list')
 report.update(complete=True,sourceChecked=True,unsafeDependentDefinitions=int(match[1]),
  scope='Pinned upstream checks definitions, then explicitly refuses proof completeness for unsafe/foreign dependencies. This is not a BendTT proof or semantic compiler qualification.')
 for item in inputs:verify(item)
finally:
 write_json(out/'report.json',report);print(json.dumps(dict(complete=report['complete'],sourceChecked=report['sourceChecked'],proofAccepted=False)))
