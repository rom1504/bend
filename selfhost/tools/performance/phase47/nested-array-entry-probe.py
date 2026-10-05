#!/usr/bin/env python3
"""Produce exact-parent, counter-only array04 entry diagnostics. Never run targets.

Usage: nested-array-entry-probe.py ARRAY04_MANIFEST NEW_DIRECTORY
The emitted runner checks the maintained local-pair and three editdist points.
"""
import argparse
import hashlib
import json
from pathlib import Path

PINS = {
    'local-row': ('7c4189c223634ad528b31c2d21f5d0e3ab4dca2cd5de13170d5e59237f482c63', 148609),
    'editdist': ('9fdb5e6dff177aafbd503e79a0a1d9dc1cda19261d101b474ba8a39afb892ebc', 147698),
}
API = '1accfefd906c6bcfd25b2e3f65788cf083c7f14a6f2cefc8165c6073731416a7'
RUNTIME = '82781f5c8cecb14df370112a210974f55d52e32fa34cd71bfb03caec5e4c1fc5'
CASE_IDS = ['local-pair', 'editdist', 'variation-editdist-0-17', 'variation-editdist-3-123']
PAIR = 'function $R_112_97_105_114($p0){'
RAW = '/* private raw array root */'
TREE = '/* private scalar tree */'


def identity(file):
    p = Path(file).resolve(strict=True)
    data = p.read_bytes()
    return {'file': str(p), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}


def once(text, old, new):
    assert text.count(old) == 1, ('Missing or ambiguous anchor', old)
    return text.replace(old, new, 1)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('manifest', type=Path)
    ap.add_argument('output', type=Path)
    args = ap.parse_args()
    source_manifest = args.manifest.resolve(strict=True)
    source = json.loads(source_manifest.read_text())
    assert source['kind'] == 'bend-program-bundle' and source['complete']
    compiler = source['roles']['candidate']['compiler']
    assert compiler['api']['sha256'] == API and compiler['runtime']['sha256'] == RUNTIME
    inputs = [identity(__file__), identity(source_manifest)]

    def bind(record):
        actual = identity(record.get('file', record.get('path', record.get('canonicalPath'))))
        assert actual['sha256'] == record['sha256']
        if 'bytes' in record:
            assert actual['bytes'] == record['bytes']
        inputs.append(actual)
        return actual

    cases = []
    for case_id in CASE_IDS:
        matches = [case for case in source['cases'] if case['id'] == case_id]
        assert len(matches) == 1
        case = matches[0]
        cases.append({'id': case_id, 'point': case['point'],
                      'module': Path(case['modules']['candidate']['path']).stem})
    assert cases[0]['point'] == {'exportName': 'pair', 'args': [0], 'expected': 1866542166}
    assert [case['point']['args'] for case in cases[1:]] == [[2, 0], [0, 17], [3, 123]]
    outputs = {}
    for name, (sha, size) in PINS.items():
        module = source_manifest.parent / 'modules' / (name + '.mjs')
        parent = identity(module)
        assert (parent['sha256'], parent['bytes']) == (sha, size)
        inputs.extend([parent, identity(str(module) + '.json')])
        receipt = json.loads(Path(str(module) + '.json').read_text())
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
        assert receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
        assert receipt['output']['sha256'] == sha
        assert receipt['compiler']['api']['sha256'] == API
        assert receipt['compiler']['runtime']['sha256'] == RUNTIME
        for record in [receipt['input'], receipt['attempt'], receipt['catalog']]:
            bind(record)
        for role in ['api', 'runtime', 'base', 'driver']:
            bind(receipt['compiler'][role])
        attempt = json.loads(Path(receipt['attempt']['file']).read_text())
        bind(attempt['node'])
        text = module.read_text()
        assert '$p47Nested' not in text and 'phase47NestedArrayCounters' not in text
        pair_start = text.index('G["pair"]=')
        pair_end = text.index('\n', pair_start)
        batch_start = text.index('G["batch"]=')
        batch_end = text.index('\n', batch_start)
        pair_decl, batch_decl = text[pair_start:pair_end], text[batch_start:batch_end]
        assert pair_decl.count(RAW) == 1 and pair_decl.count('/* private scalar root */') == 1
        assert batch_decl.count(PAIR) == 1 and batch_decl.count(TREE) == 1
        assert RAW not in batch_decl and 'regionProofOpen(' not in batch_decl
        changed_pair = once(pair_decl, '/* private scalar root */',
            '/* private scalar root */++$p47Nested.publicPair;$p47Nested.publicGranted+=$entered?1:0;'
            '$p47Nested.publicNested+=regionProof!==null?1:0;')
        changed_pair = once(changed_pair, 'if(arrayViewHostGuard()&&', 'if($p47NestedGuard()&&')
        changed_pair = once(changed_pair, RAW, RAW + '++$p47Nested.raw;')
        changed_batch = once(batch_decl, PAIR, PAIR + '++$p47Nested.treePair;'
            '$p47Nested.treePairNested+=regionProof!==null?1:0;')
        changed_batch = once(changed_batch, TREE, TREE + '++$p47Nested.tree;')
        derived = text[:pair_start] + changed_pair + text[pair_end:batch_start] + changed_batch + text[batch_end:]
        derived = "let $p47Nested={publicPair:0,publicGranted:0,publicNested:0,guards:0,guardNested:0,guardTrue:0,raw:0,tree:0,treePair:0,treePairNested:0};\n" + derived
        derived += "\nfunction $p47NestedGuard(){++$p47Nested.guards;$p47Nested.guardNested+=regionProof!==null?1:0;const ok=arrayViewHostGuard();$p47Nested.guardTrue+=ok?1:0;return ok;}\n"
        derived += "export function phase47NestedArrayCounters(){return {...$p47Nested};}\n"
        outputs[name] = {'text': derived, 'parent': parent, 'spans': {
            'pair': {'start': pair_start, 'end': pair_end, 'sha256': hashlib.sha256(pair_decl.encode()).hexdigest()},
            'batch': {'start': batch_start, 'end': batch_end, 'sha256': hashlib.sha256(batch_decl.encode()).hexdigest()}}}
    inputs = list({item['file']: item for item in inputs}.values())
    for item in inputs:
        assert identity(item['file']) == item
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    derivation = {'kind': 'phase47-nested-array-entry-derivation', 'complete': True,
        'diagnosticOnly': True, 'timingEligible': False, 'targetsExecuted': False,
        'scope': 'Exact checked-array04 modules; counter stores and one guard wrapper only. Additional frames/allocation exclude timing and host-introspection claims.',
        'inputs': inputs, 'cases': cases, 'modules': {}}
    for name, item in outputs.items():
        file = out / (name + '.mjs')
        file.write_text(item.pop('text'))
        derivation['modules'][name] = {**item, 'derived': identity(file)}
    runner = """import fs from 'node:fs';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [reportPath]=process.argv.slice(2);assert(reportPath&&!fs.existsSync(reportPath));
const manifest=JSON.parse(fs.readFileSync(new URL('./derivation.json',import.meta.url),'utf8'));
const hash=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const inputs=[...manifest.inputs,...Object.values(manifest.modules).map(m=>m.derived),manifest.runner];
const recheck=()=>{for(const x of inputs){assert.equal(hash(x.file),x.sha256);assert.equal(fs.statSync(x.file).size,x.bytes);}};
recheck();assert(inputs.some(x=>x.file===fs.realpathSync(process.execPath)&&x.sha256===hash(process.execPath)));
const report={kind:'phase47-nested-array-entry-controls',complete:false,pass:false,diagnosticOnly:true,timingEligible:false,inputs,observations:[]};
try{const loaded={};for(const [name,item]of Object.entries(manifest.modules))loaded[name]=await import(pathToFileURL(item.derived.file));
for(const row of manifest.cases){const m=loaded[row.module],before=m.phase47NestedArrayCounters();const value=m.default[row.point.exportName](...row.point.args);const after=m.phase47NestedArrayCounters();
 const delta=Object.fromEntries(Object.keys(before).map(k=>[k,after[k]-before[k]]));
 const depth=row.id==='local-pair'?0:row.point.args[0],tree=depth>0;
 const expected={publicPair:tree?0:1,publicGranted:tree?0:1,publicNested:0,guards:tree?0:1,guardNested:0,guardTrue:tree?0:1,raw:tree?0:1,tree:tree?1:0,treePair:tree?2**depth:0,treePairNested:0};
 const observation={id:row.id,point:row.point,value,counters:delta,expectedCounters:expected};report.observations.push(observation);
 assert.equal(value,row.point.expected,'Maintained value oracle');assert.deepEqual(delta,expected,'Static path prediction');}
recheck();report.complete=report.pass=true;}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\\n',{flag:'wx'});console.log(JSON.stringify(report));
"""
    runner_path = out / 'run-entry-controls.mjs'
    runner_path.write_text(runner)
    derivation['runner'] = identity(runner_path)
    for item in inputs:
        assert identity(item['file']) == item
    (out / 'derivation.json').write_text(json.dumps(derivation, indent=2) + '\n')
    print(json.dumps({'complete': True, 'executed': False, 'output': str(out), 'cases': CASE_IDS}))


if __name__ == '__main__':
    main()
