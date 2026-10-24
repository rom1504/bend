#!/usr/bin/env python3
"""Metadata-only refusal tests of the actual native statistics admission code."""
import importlib.util,json,pathlib,tempfile
HERE=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('session',HERE/'session-build-v01.py');M=importlib.util.module_from_spec(s);s.loader.exec_module(M)
base='phase134 prepare_ms 7\nphase134 A 0 3 0 1 2 ms=10\nphase134 B 2 1 1 0 2 ms=8\n'
stages='phase135 stages A frontend_ms=1 lowering_ms=2 optimize_ms=3 render_ms=4\nphase135 stages B frontend_ms=1 lowering_ms=2 optimize_ms=2 render_ms=3\n'
variants=[('old-format',base,True),('staged',base+stages,True),('missing-preparation',base.split('\n',1)[1],False),('missing-B',base[:base.index('phase134 B')],False),('duplicate-A',base+base.splitlines()[1]+'\n',False),('unknown-output',base+'debug\n',False),('negative-time',base.replace('ms=8','ms=-8'),False),('one-stage',base+stages.splitlines()[0]+'\n',False),('wrong-stage-sum',base+stages.replace('render_ms=3','render_ms=4'),False),('duplicate-stage',base+stages+stages.splitlines()[0]+'\n',False),('stage-field-typo',base+stages.replace('frontend_ms=','front_ms='),False),('extra-count',base.replace('0 3 0 1 2','0 3 0 1 2 0'),False)]
rows=[]
with tempfile.TemporaryDirectory(prefix='p135-session-control-',dir='/tmp')as d:
 p=pathlib.Path(d)/'stdout'
 for name,data,expected in variants:
  p.write_text(data)
  try:r=M.parse_stats(p);accepted=True;error=None
  except ValueError as e:accepted=False;error=str(e)
  assert accepted==expected,(name,accepted,expected)
  rows.append(dict(name=name,accepted=accepted,expected=expected,error=error))
print(json.dumps(dict(complete=True,targetsRun=False,method=M.pin(HERE/'session-build-v01.py'),controls=rows),indent=2))
