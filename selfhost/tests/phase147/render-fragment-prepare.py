#!/usr/bin/env python3
"""Freeze current whole-function fixtures and additive fragment-emitter check jobs."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('phase147_prepare', ROOT/'experiments/phase147/tools/prepare.py')
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
from common import verify


def bend(value):
    if isinstance(value, dict):
        P.require('$' in value, 'Expected constructor value')
        return value['$']+'{'+','.join(bend(v) for k,v in value.items() if k != '$')+'}'
    if isinstance(value, str): return json.dumps(value, ensure_ascii=False)
    if isinstance(value, bool): return 'True{}' if value else 'False{}'
    P.require(isinstance(value, int) and 0 <= value <= 4294967295, 'Unexpected fixture value')
    return str(value)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    capture = json.loads(args.capture.read_text())
    P.require(capture['complete'], 'Closed current captures required')
    out = P.fresh_output(args.out, ROOT)
    inputs = [P.pin(__file__), P.pin(P.__file__), P.pin(args.capture)]
    fixtures, declarations = [], []
    selections = [('coverage-map-churn-128',443), ('lexer',176), ('compiler-verifier-slice',0)]
    for index, (family, selected) in enumerate(selections):
        record = next(row for row in capture['rows'] if row['name'] == family)
        verify(record['data']); inputs.append(record['data'])
        data = json.loads(Path(record['data']['file']).read_text())
        P.require(data['complete'] and data['originalAccepted'], 'Original verifier did not accept captured IR')
        row = next(row for row in data['raw'] if row['index'] == selected)
        P.require(row['census']['branches'] == 0, 'Current small kernel requires whole branch-free bodies')
        function = row['function']; refs = {'functions':set(), 'constructors':set()}; counts = collections.Counter()
        def walk(value):
            if isinstance(value, dict):
                counts[value['$']] += 1
                if value['$'] == 'N111FuncId': refs['functions'].add(value['name'])
                if value['$'] == 'N111CtorId': refs['constructors'].add(value['name'])
                for k,v in value.items():
                    if k != '$': walk(v)
        # Lists are constructor chains in the captured ABI.
        walk(function)
        P.require(not refs['constructors'], 'Constructor arity requires an explicit new fixture transport')
        ids = {'functions':[], 'constructors':[]}
        for field, headers in [('functions',data['segments']),('constructors',data['constructors'])]:
            for name in sorted(refs[field]):
                positions = [i for i,h in enumerate(headers) if h['name'] == name]
                P.require(len(positions) == 1, 'Referenced identity missing or ambiguous')
                ids[field].append(dict(name=name, id=positions[0]))
        tree = 'missing()'
        for entry in ids['functions']:
            tree = 'p111q_insert('+tree+','+bend(entry['name'])+','+str(entry['id'])+')'
        declarations += ['@unsafe\ndef p147q_fixture_segment%d() -> N111Segment:\n  %s\n'%(index,bend(function)),
                         '@unsafe\ndef p147q_fixture_ids%d() -> N111Ids:\n  N111Ids{%s,missing()}\n'%(index,tree)]
        fixtures.append(dict(index=index, family=family, capture=record['data'], captureIndex=selected,
            definition=function['name'], completeSegment=function, referencedIds=ids,
            calls=row['census']['calls'], census=row['census'], statementTags={k:v for k,v in counts.items()
                if k in ['N111Call','N111Set','N111Bin','N111Store','N111Load','N111Offset','N111Return','N111Alloca']}))
    fixture_source=out/'fixtures.bend'; fixture_source.write_text('\n'.join(declarations))
    fixture_report=dict(kind='phase147-current-render-fixtures',version=1,complete=True,targetsRun=False,
        capture=P.pin(args.capture),bend=P.pin(fixture_source),fixtures=fixtures,
        scope='Exact complete current captured raw bodies. Only explicitly referenced function-ID bindings are retained; all three bodies are branch-free and contain no constructor-ID reference.')
    P.write_json(out/'fixtures.json',fixture_report)
    recipe=ROOT/'selfhost/src/compiler.json'
    canonical=P.assembly.maintained_assemble(recipe,ROOT/'selfhost','qbe')
    import hashlib
    identity=dict(bytes=len(canonical),sha256=hashlib.sha256(canonical).hexdigest())
    P.require(identity==capture['sourceIdentity'],'Capture and current canonical source differ')
    sources=[('canonical',canonical)]
    for name in ['render-call.bend','render-controls.bend','render-fragments.bend','render-fragment-controls.bend']:
        p=Path(__file__).with_name(name);sources.append((name,p.read_bytes()));inputs.append(P.pin(p))
    sources.append(('fixtures',fixture_source.read_bytes()))
    roots=['p147q_controls','p147f_controls','p147f_render_segment']+[
        'p147q_fixture_'+kind+str(i) for i in range(3) for kind in ['segment','ids']]
    source,inventory=P.extract(sources,roots); (out/'compiler.bend').write_bytes(source)
    P.write_json(out/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=roots,
        protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],scope='Experiment utility API only; not a compiler capability.'))
    inputs += [P.pin(recipe),P.pin(P.assembly.__file__),P.pin(fixture_source),P.pin(out/'fixtures.json')]
    for item in inputs:verify(item)
    acquisition=out/'api'
    jobs=[P.guard('checked-render-fragments',acquisition,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire',
        '--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66',
        '--engine',ROOT/'selfhost/.assets/bin/bun','--out',acquisition],150)]
    P.write_json(out/'manifest.json',dict(kind='phase147-fragment-render-kernel-preparation',version=1,complete=True,
        targetsRun=False,checked=False,source=P.pin(out/'compiler.bend'),exports=P.pin(out/'exports.json'),
        fixtures=P.pin(out/'fixtures.json'),canonicalSourceIdentity=identity,inputs=inputs,declarations=inventory,jobs=jobs))
    P.write_json(out/'jobs.json',jobs)
    print(json.dumps(dict(manifest=P.pin(out/'manifest.json'),jobs=P.pin(out/'jobs.json'),declarations=len(inventory))))


if __name__=='__main__':main()
