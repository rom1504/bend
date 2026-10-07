#!/usr/bin/env python3
"""Correct qualified-input assembly in the unexecuted first Phase61 method."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];RAW=ROOT/'selfhost/build/phase61'
parent=RAW/'latency-method01'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
def identity(file):
 file=Path(file).resolve(strict=True);b=file.read_bytes();return dict(file=str(file),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
pins={'setup.mjs':'c14cf7172a856d8b72f550de4f27e3c493058522ad6f9e5b69bc4eeb8fb4165a',
 'profile.mjs':'6bbb65cf02b47a06a3193ca595f8fcdcd0ca73c408233ac28ee1dfb183348068',
 'worker.mjs':'8a5e3c59f40d21f0d9521dc00bd7631aa5b354f6a05fc9ad1cc7ce59074794fd',
 'run.py':'298e03d330552f15bf130a49542b7e1c22d876c2bed100451607d70738e5b42e'}
outputs={};rows=[]
for name,sha in pins.items():
 before=identity(parent/name);assert before['sha256']==sha;text=(parent/name).read_text();edits=[]
 old=str(parent);new=str(out);count=text.count(old)
 if count:text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if name=='run.py':
  old=" *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]+oracle_inputs]+oracle_inputs"
  new=" *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]]+oracle_inputs"
  assert text.count(old)==1;text=text.replace(old,new);edits.append(dict(old=old,new=new,count=1));ast.parse(text)
 outputs[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
report=dict(kind='phase61-candidate-fast-loop-method',complete=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),parentDerivation=identity(parent/'derivation.json'),derivations=rows,
 scope='Only qualified-oracle identity-list assembly corrected plus fresh method paths. No target had consumed method01. First/capture clocks, cache and oracle behavior otherwise unchanged.')
report['pass']=True;(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({name:identity(out/name) for name in [*outputs,'derivation.json']}))
