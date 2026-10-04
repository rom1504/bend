#!/usr/bin/env python3
"""Derive five unchecked ablations from checked-array01 local-fold JS.

Usage: array-checked-probe.py MODULE.mjs NEW_DIRECTORY
No target execution. Separate counter output is never eligible for timing.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

PARENT_SHA = 'a6ec676a1ed5d3a2027c8d0341f7ef9156ede0c8e2d37ace7aabcac9c1b4e753'
FUNCTION_SHA = '20cd8054598d4cf9e3383bffef949f86b77ebfdbae004c9cdcfc6e64de2f10f7'
START = 'const $arrayViewBody=(()=>{'
FUNCTION = 'function $R_102_111_108_100_46_108_111_111_112($p0,$p1,$p2){'
ZERO = 'if($p0===0n){return (($p0,$p1)=>{return $p1;})($p1,$p2);}'
VALUE = '(/* primitive */(((x3420)^($p0))>>>0))'
WRITE = '$n2_0=((_t,a,i,v)=>{a[Number(i)%a.length]=v;return a;})(null,$p3,$p0,' + VALUE + ',);'
ENTRY = '/* private raw array root */'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def identity(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(path=str(file), sha256=digest(data), bytes=len(data))


def once(text, old, new):
    assert text.count(old) == 1, 'Missing/ambiguous exact anchor: ' + old
    return text.replace(old, new, 1)


def transform(function, inline, invariant):
    result = function
    if inline:
        result = once(result, WRITE,
            'const $p47a=$p3;const $p47i=$p0;const $p47v=' + VALUE + ';'
            '$p47a[Number($p47i)%$p47a.length]=$p47v;$n2_0=$p47a;')
    if invariant:
        # This exact loop's only array update returns its original input.
        # Remove only that loop-carried alias, not stores or result transport.
        result = once(result, 'let $w0=$p2[0];', 'const $w0=$p2[0];')
        result = once(result, '$w0=$n2_0;', '')
    assert result.startswith(FUNCTION + ZERO)
    assert len(re.findall(r'(?<![\w$])Number\(', result)) == 2
    assert result.count('.length') == 2
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('module', type=Path)
    p.add_argument('output', type=Path)
    args = p.parse_args()
    source = args.module.resolve(strict=True)
    inputs = [identity(source), identity(str(source) + '.json'), identity(__file__)]
    assert inputs[0]['sha256'] == PARENT_SHA and inputs[0]['bytes'] == 91192
    receipt = json.loads(Path(str(source) + '.json').read_text())
    assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
    assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
    assert receipt['output']['sha256'] == PARENT_SHA
    assert receipt['compiler']['kind'] == 'checked-development-attempt'
    for record in [receipt['attempt'], receipt['compiler']['api'], receipt['compiler']['runtime'], receipt['input']]:
        file = record.get('path', record.get('file', record.get('canonicalPath')))
        actual = identity(file)
        assert actual['sha256'] == record['sha256']
        inputs.append(actual)
    original = source.read_text()
    assert '$p47' not in original and 'phase47ArrayProbeCounters' not in original
    assert original.count(START) == 1 and original.count(ENTRY) == 1
    start = original.index(START) + len(START)
    assert original.startswith(FUNCTION, start)
    # The exact entire module and function are pinned; reject a changed boundary.
    end = original.index('}function ', start) + 1
    function = original[start:end]
    assert (start, end) == (86573, 87491) and digest(function.encode()) == FUNCTION_SHA
    variants = {}
    for name, inline, invariant in [('original', False, False), ('write-inline', True, False),
                                     ('invariant-alias', False, True), ('combined', True, True)]:
        replacement = transform(function, inline, invariant)
        variants[name] = original[:start] + replacement + original[end:]
    assert variants['original'].encode() == source.read_bytes()
    variants['guard-bypass'] = once(original, 'if(arrayViewHostGuard()&&', 'if(true&&')
    assert len({digest(v.encode()) for v in variants.values()}) == 5
    counter = 'let $p47RawEntries=0;\n' + once(original, ENTRY, ENTRY + '++$p47RawEntries;')
    counter += '\nexport const phase47ArrayProbeCounters=()=>({rawEntries:$p47RawEntries});\n'
    for item in inputs:
        assert identity(item['path']) == item
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    manifest = dict(kind='phase47-checked-array-ablation', schemaVersion=1, complete=True,
        diagnosticOnly=True, productionSafe=False, checkedDerivative=False,
        correctness='not-run', timing='not-run', inputs=inputs,
        parentCompiler=receipt['compiler'], source=receipt['input'],
        function=dict(start=start, end=end, sha256=FUNCTION_SHA, bytes=end-start),
        scope='Four loop variants preserve all bytes outside one exact raw function. The fifth changes only the single raw-entry host-guard call to true; it is explicitly unsafe outside the standard-host diagnostic.',
        preserved='Zero-trip branch, write argument order, two Number conversions and two length reads per iteration.',
        interpretation='Factorial write-IIFE expansion versus invariant backing alias, plus original body with host-guard bypass to isolate entry cost. The exact loop always returns the same raw array from its write; no general alias proof is implemented.',
        variants={})
    for name, body in variants.items():
        folder = out / name
        folder.mkdir()
        module = folder / 'program.mjs'
        module.write_text(body)
        manifest['variants'][name] = dict(module=identity(module), timingEligible=True,
            transformation=dict(inlineWrite=name in ('write-inline', 'combined'),
                                invariantBacking=name in ('invariant-alias', 'combined'),
                                unsafeGuardBypass=name == 'guard-bypass'))
    diagnostic = out / 'activation-only.mjs'
    diagnostic.write_text(counter)
    control = out / 'check-activation.mjs'
    control.write_text("""import assert from 'node:assert/strict';
import program,{phase47ArrayProbeCounters} from './activation-only.mjs';
const points=[[0,17],[1,17],[4096,17]],observations=[];
function oracle(n,seed){const a=Array(128).fill(seed);let acc=0;
  for(let i=0;i<n;i++){acc=(acc+a[i%128])>>>0;a[i%128]=(acc^i)>>>0;}return acc;}
assert.equal(phase47ArrayProbeCounters().rawEntries,0);
for(const [n,seed]of points){const before=phase47ArrayProbeCounters().rawEntries;
  const value=program.bench(n,seed),after=phase47ArrayProbeCounters().rawEntries;
  assert.equal(value,oracle(n,seed));assert.equal(after-before,1);
  observations.push({n,seed,value,rawEntries:after-before});}
console.log(JSON.stringify({kind:'phase47-local-fold-raw-activation',pass:true,diagnosticOnly:true,observations}));
""")
    manifest['activationOnly'] = dict(module=identity(diagnostic), controller=identity(control),
                                      timingEligible=False, status='not-run')
    for item in inputs:
        assert identity(item['path']) == item
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(complete=True, output=str(out), variants=list(variants), executed=False)))


if __name__ == '__main__':
    main()
