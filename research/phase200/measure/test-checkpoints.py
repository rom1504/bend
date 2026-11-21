#!/usr/bin/env python3
"""Metadata-only checkpoint retention tests; no compiler or benchmark processes."""
import importlib.util,json
from pathlib import Path
from types import SimpleNamespace
p=Path(__file__).with_name('broad.py');spec=importlib.util.spec_from_file_location('broad_test',p);M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
original_save=M.M.B.save;original_run=M.ORIGINAL_RUN

def check(fail):
 writes=[]
 def retain(path,value,*args,**kwargs):writes.append((str(path),json.loads(json.dumps(value))))
 def fake_run(args):
  doc=dict(kind='phase185-adaptive-native-runtime',roles=['c','baseline','candidate'],cases=[dict(samples=[])])
  save=lambda:M.M.B.save(args.out/'report.json',doc)
  save()
  for i in range(9):
   doc['cases'][0]['samples'].append(dict(correct=False,index=i));save()
   doc['cases'][0]['samples'][-1]['correct']=True;save()
   if fail and i==2:
    doc.update(error='fixture refusal',wallSeconds=1);save();break
  else:doc.update(complete=True,wallSeconds=2);save()
  M.M.B.save(args.out/'other.json',dict(retained=True));return doc
 M.M.B.save=retain;M.ORIGINAL_RUN=fake_run
 try:
  result=M.checkpointed_run(SimpleNamespace(out=Path('/tmp/phase200-checkpoint-test'),rounds=3))
  assert M.M.B.save is retain
  reports=[row for path,row in writes if path.endswith('/report.json')]
  assert len(reports)==(2 if fail else 3)
  assert reports[-1]==result and len(result['cases'][0]['samples'])==(3 if fail else 9)
  assert writes[-1][1]==dict(retained=True)
 finally:M.M.B.save=original_save;M.ORIGINAL_RUN=original_run
check(False);check(True);print('PASS: initial/completed/final and failure checkpoints retained; other saves unchanged; no target processes')
