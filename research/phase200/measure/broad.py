#!/usr/bin/env python3
"""Use the unchanged sampler; checkpoint its report after each complete case."""
import argparse,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p200_screen',HERE/'screen.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
ORIGINAL_RUN=M.R.run

def checkpointed_run(args):
 original_save=M.B.save;destination=(args.out/'report.json').resolve();last=-1
 def save(path,value,*pos,**kw):
  nonlocal last
  if Path(path).resolve()==destination and isinstance(value,dict) and value.get('kind')=='phase185-adaptive-native-runtime':
   finished=sum(len(case['samples'])==args.rounds*len(value['roles']) and all(row.get('correct') for row in case['samples']) for case in value['cases'])
   force='wallSeconds' in value or bool(value.get('error'))
   if finished==last and not force:return
   last=finished
  return original_save(path,value,*pos,**kw)
 M.B.save=save
 try:return ORIGINAL_RUN(args)
 finally:M.B.save=original_save

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
 M.R.run=checkpointed_run;M.execute(a.plan,a.out)
 result=M.B.read(a.out/'summary.json');result.update(timingWrapper=M.B.pin(__file__),reportCheckpointPolicy='Initial, each completed case, errors and final report. Every raw stream and every final pilot/timed observation retained; sampler/oracle/calibration logic unchanged.')
 result['scope']+=' Report serialization frequency changed; total harness wall time is separate from measured program intervals.'
 M.B.save(a.out/'summary.json',result);(a.out/'summary.md').write_text(M.S.markdown(result).replace('# Phase193 runtime summary','# Phase200 complete broad screen',1))
