#!/usr/bin/env python3
"""Data-only cold-branch prototype over one exact saved generated module."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
CORE_SHA = 'd427d2433cee7585d002ea178a694e552deb7cbf8e21ce4caaf9804a1463e971'
OLD = """function apply(f,args,owned=false){
  if(f===null)return null;
  if(f?.io&&args.length===0)return f;
  if(f?.io)return apply(fn(2,a=>Object.hasOwn(f,'pureValue')?call(a[1],[f.pureValue]):{request:true,action:f,k:a[1]}),args);
  if(f?.typeName)return {typeName:f.typeName,typeArgs:[...(f.typeArgs||[]),...args]};
  if(!f?.code){if(!args.length)return f;bad('attempt to call non-function '+String(f));}
  const all=f.bound.length?f.bound.concat(args):owned?args:args.slice();
  if(all.length===f.arity)return invokeExact(f,all);
  if(all.length<f.arity)return fn(f.arity,f.code,f.env,all);
  let r=f.code.call(f.env,all.slice(0,f.arity));
  if(all.length>f.arity)r=jump(force(r),all.slice(f.arity));
  return r;
}
"""
NEW = """function applyIO(f,args){
  return apply(fn(2,a=>Object.hasOwn(f,'pureValue')?call(a[1],[f.pureValue]):{request:true,action:f,k:a[1]}),args);
}
function applyType(f,args){
  return {typeName:f.typeName,typeArgs:[...(f.typeArgs||[]),...args]};
}
function applyNonfunction(f,args){
  if(!args.length)return f;bad('attempt to call non-function '+String(f));
}
function applyOverflow(f,all){
  let r=f.code.call(f.env,all.slice(0,f.arity));
  if(all.length>f.arity)r=jump(force(r),all.slice(f.arity));
  return r;
}
function apply(f,args,owned=false){
  if(f===null)return null;
  if(f?.io&&args.length===0)return f;
  if(f?.io)return applyIO(f,args);
  if(f?.typeName)return applyType(f,args);
  if(!f?.code)return applyNonfunction(f,args);
  const all=f.bound.length?f.bound.concat(args):owned?args:args.slice();
  if(all.length===f.arity)return invokeExact(f,all);
  if(all.length<f.arity)return fn(f.arity,f.code,f.env,all);
  return applyOverflow(f,all);
}
"""
EXPORT = '\nexport const $dispatchProbe={apply,force,fn,jump,build,call,callOwned,exactCode,get,pure,G};\n'


def identity(p):
    p = Path(p).resolve(strict=True)
    raw = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('module', type=Path)
    parser.add_argument('sha256')
    parser.add_argument('out', type=Path)
    args = parser.parse_args()
    args.out.mkdir()  # Exclusive; never overwrite consumed artifacts.
    inputs = [identity(__file__), identity(ROOT / 'selfhost/src/runtime/js/core.mjs'), identity(args.module)]
    assert inputs[1]['sha256'] == CORE_SHA and inputs[2]['sha256'] == args.sha256
    core = Path(inputs[1]['file']).read_text()
    source = Path(inputs[2]['file']).read_text()
    assert core.count(OLD) == source.count(OLD) == 1
    for name in ['applyIO', 'applyType', 'applyNonfunction', 'applyOverflow', '$dispatchProbe']:
        assert name not in source, name
    candidate = source.replace(OLD, NEW)
    assert candidate.replace(NEW, OLD) == source
    outputs = {}
    for name, text in [('baseline.mjs', source), ('candidate.mjs', candidate),
                       ('baseline-controls.mjs', source + EXPORT), ('candidate-controls.mjs', candidate + EXPORT),
                       ('dispatch.patch', ''.join(difflib.unified_diff(source.splitlines(True), candidate.splitlines(True),
                           fromfile='baseline.mjs', tofile='candidate.mjs')))]:
        p = args.out / name
        with p.open('x') as stream:
            stream.write(text)
        outputs[name] = identity(p)
    for item in inputs:
        assert identity(item['file']) == item
    report = dict(kind='phase51-dispatch-prototype', complete=True, executed=False, inputs=inputs, outputs=outputs,
        scope='Exactly one runtime apply-body replacement; generated program definitions unchanged. Diagnostic exports are separate from clean timing modules.',
        coreSha256=CORE_SHA, originalApply=OLD, replacement=NEW, diagnosticSuffix=EXPORT)
    with (args.out / 'receipt.json').open('x') as stream:
        json.dump(report, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, executed=False, out=str(args.out.resolve()), candidate=outputs['candidate.mjs'])))


if __name__ == '__main__':
    main()
