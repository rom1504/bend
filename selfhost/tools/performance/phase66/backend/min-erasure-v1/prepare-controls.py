#!/usr/bin/env python3
"""Source-only focused recipe for a checked image containing the Min patch."""
from pathlib import Path
import argparse,json,hashlib,subprocess,sys,copy
ROOT=Path(__file__).resolve().parents[6]
def pin(p):
 p=p.resolve(strict=True);b=p.read_bytes();return {'file':str(p),'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--attempt',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();a.out=a.out.resolve();assert not a.out.exists() and a.out.is_relative_to(ROOT/'selfhost/build/phase66')
 attempt=a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt;m=json.loads(attempt.read_text());candidate=Path(__file__).with_name('candidate.json');c=json.loads(candidate.read_text());actual=Path(m['snapshot']['root'])/'src/back/js/direct/core.bend';assert pin(actual)['sha256']==c['after']['sha256'],'Candidate must actually be in checked snapshot'
 producer=Path(__file__).parents[1]/'prepare-source-controls-v1.py';subprocess.run([sys.executable,str(producer),'--attempt',str(attempt),'--out',str(a.out),'--roles','bend-direct','--lanes','js'],check=True)
 parent=a.out/'recipe.json';r=json.loads(parent.read_text());command=copy.deepcopy(r['commands'][0]);selection=a.out/'min-selection.json';original=Path(__file__).with_name('selection.json');selection.write_bytes(original.read_bytes());cmd=command['command'];cmd[cmd.index('--selection')+1]=str(selection);report=a.out/'min-report.json';cmd[cmd.index('--output')+1]=str(report);idx=next(i for i,x in enumerate(cmd) if x.endswith('/supervisor'));cmd[idx]=str(a.out/'min-supervisor');command.update({'expectedObservations':2,'selection':pin(selection),'report':str(report),'excludedDeclaredGaps':[]})
 result={'kind':'phase66-direct-min-focused-recipe','targetExecuted':False,'producer':pin(Path(__file__)),'candidate':pin(candidate),'actualSnapshotCore':pin(actual),'parent':pin(parent),'commands':[command],'scope':'Fresh actual direct JS source checks on checked snapshot that contains exact Min patch. Reuses existing two passing TS reference observations; not source-token JavaScript surgery.'};path=a.out/'min-recipe.json';path.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'recipe':pin(path)}))
if __name__=='__main__':main()
