#!/usr/bin/env python3
"""Data-only split-dispatch plus small unregistered-entry successor."""
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
EXACT_OLD = "function invokeExact(f,all){\n  const code=f.code;\n  if(!hasExactCodes||!exactHas(code)||exactGetPrototype(code)!==exactPrototype||\n      exactDescriptor(code,'call'))return code.call(f.env,all);\n  const callProperty=exactDescriptor(exactPrototype,'call');\n  if(!callProperty||!exactOwn(callProperty,'value')||callProperty.value!==exactCall)\n    return code.call(f.env,all);\n  // Resolve .call before env, as the original invocation does. Environment\n  // getters may reenter; permission is installed only after they have returned.\n  const invoke=code.call,env=f.env,previous=exactEntry;\n  exactEntry={code,args:all,used:false};\n  try{return exactApply(code,env,[all]);}\n  finally{exactEntry=previous;}\n}\n"
EXACT_NEW = "function invokeExact(f,all){\n  const code=f.code;\n  if(!hasExactCodes)return code.call(f.env,all);\n  return invokeRegistered(f,all,code);\n}\nfunction invokeRegistered(f,all,code){\n  if(!exactHas(code)||exactGetPrototype(code)!==exactPrototype||\n      exactDescriptor(code,'call'))return code.call(f.env,all);\n  const callProperty=exactDescriptor(exactPrototype,'call');\n  if(!callProperty||!exactOwn(callProperty,'value')||callProperty.value!==exactCall)\n    return code.call(f.env,all);\n  // Resolve .call before env, as the original invocation does. Environment\n  // getters may reenter; permission is installed only after they have returned.\n  const invoke=code.call,env=f.env,previous=exactEntry;\n  exactEntry={code,args:all,used:false};\n  try{return exactApply(code,env,[all]);}\n  finally{exactEntry=previous;}\n}\n"
EDITS = [(OLD, NEW), (EXACT_OLD, EXACT_NEW)]

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
    parent = identity(Path(__file__).with_name('dispatch-prepare.py'))
    assert parent['sha256'] == '9ed8479a81a551f5b5155946cce5274ee983285b1d90d3e5570d701bac63a49b'
    inputs = [identity(__file__), identity(ROOT / 'selfhost/src/runtime/js/core.mjs'), identity(args.module), parent]
    assert inputs[1]['sha256'] == CORE_SHA and inputs[2]['sha256'] == args.sha256
    core = Path(inputs[1]['file']).read_text()
    source = Path(inputs[2]['file']).read_text()
    for old, new in EDITS:
        assert core.count(old) == source.count(old) == 1
    for name in ['applyIO', 'applyType', 'applyNonfunction', 'applyOverflow', 'invokeRegistered', '$dispatchProbe']:
        assert name not in source, name
    candidate = source
    for old, new in EDITS:
        candidate = candidate.replace(old, new)
    reversed_source = candidate
    for old, new in reversed(EDITS):
        assert reversed_source.count(new) == 1
        reversed_source = reversed_source.replace(new, old)
    assert reversed_source == source
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
        variant='split-and-exact-entry', edits=[dict(old=old, new=new) for old, new in EDITS],
        scope='Exactly two runtime function replacements; generated program definitions unchanged. Diagnostic exports are separate from clean timing modules.',
        coreSha256=CORE_SHA, originalApply=OLD, replacement=NEW, diagnosticSuffix=EXPORT)
    with (args.out / 'receipt.json').open('x') as stream:
        json.dump(report, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, executed=False, out=str(args.out.resolve()), candidate=outputs['candidate.mjs'])))


if __name__ == '__main__':
    main()
