#!/usr/bin/env python3
"""Freeze a scoped checked driver that also retains canonical descriptor roots."""
import argparse,hashlib,json,difflib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];TOOLS=ROOT/'selfhost/tools'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();source=a.source.resolve();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda file:dict(file=str(Path(file).resolve()),bytes=Path(file).stat().st_size,sha256=hashlib.sha256(Path(file).read_bytes()).hexdigest())
original=TOOLS/'typed-driver.mjs';old=original.read_text();text=old;edits=[]
def replace(before,after,count=1,role='mechanical module relocation'):
 global text
 if text.count(before)!=count:raise ValueError('exact driver anchor count changed: '+before)
 text=text.replace(before,after);edits.append(dict(old=before,new=after,count=count,role=role))
helpers=['assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs']
for name in helpers:replace("'./"+name+"'",json.dumps((TOOLS/name).as_uri()),2 if name in ['node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs'] else 1)
replace("export const project=path.resolve(import.meta.dirname,'..');",'export const project='+json.dumps(str(ROOT/'selfhost'))+';')
replace("path.join(path.dirname(driverPath),name)","path.join(project,'tools',name)")
replace("const selected=api.reach_book(contextBook,list(['main']),stops);","const selected=api.reach_book(contextBook,list(['main','List','String','Char']),stops);",role='retain canonical checked descriptor roots from the same context')
out.mkdir();(out/'typed-driver.mjs').write_text(text)
(out/'driver.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),text.splitlines(True),fromfile=str(original),tofile=str(out/'typed-driver.mjs'))))
method=HERE/'capture-descriptors.mjs';(out/'capture.mjs').write_bytes(method.read_bytes())
control=ROOT/'selfhost/tools/performance/phase110/controls/admission/string-append/manifest.json';frozen=json.loads(control.read_text())
if (pin(source)['sha256'],pin(source)['bytes'])!=(frozen['source']['sha256'],frozen['source']['bytes']):raise ValueError('source differs from frozen actual Base wrapper')
inputs=[pin(Path(__file__)),pin(method),pin(original),pin(source),pin(control),*[pin(TOOLS/name) for name in helpers],pin(ROOT/'selfhost/dist/typed-api.mjs'),pin(ROOT/'selfhost/dist/base.bend')]
record=dict(kind='phase110-checked-descriptor-capture-source',complete=True,targetsRun=False,inputs=inputs,original=pin(original),driver=pin(out/'typed-driver.mjs'),method=pin(out/'capture.mjs'),source=pin(source),diff=pin(out/'driver.diff'),edits=edits,roots=['main','List','String','Char'],command=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(out/'capture.mjs'),str(out/'manifest.json'),'FRESH_CAPTURE_OUTPUT'],scope='Only annotation reachability roots change. Actual same-source checking, annotation and erasure remain mature Bend API operations; no reflected facts are fabricated or merged.')
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,manifest=str(out/'manifest.json'),edits=len(edits))))
