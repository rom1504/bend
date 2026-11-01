#!/usr/bin/env python3
"""Freeze exact helper declarations, independent oracles and executable wrappers."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
import importlib.util
REFERENCE = Path(__file__).resolve().parents[2]/'tests/laws/production/reference.py'
spec=importlib.util.spec_from_file_location('independent_law_cases',REFERENCE)
reference=importlib.util.module_from_spec(spec);spec.loader.exec_module(reference)
make_cases=reference.make_cases

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FIXTURES=ROOT/'selfhost/tests/laws/production'
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from assets import load_assets, asset
NATIVE_REPRESENTATIVES = {
    'children-update': ['007', '005'], 'span-update': ['017', '007'], 'projections': ['005', '002'],
    'structural-rebuild': ['003', '005'], 'substitution-beta': ['012', '015'], 'stable-substitution': ['003', '006'],
    'membership': ['019', '016'], 'lookup-shadowing': ['021', '012'], 'cached-lookup': ['022', '012'],
    'book-update': ['007', '006'], 'final-events': ['005', '006'], 'occurrence-analysis': ['004', '009'],
    'environment-selection': ['004', '005'], 'environment-partition': ['005', '007'],
    'constructor-encoding': ['008', '011'], 'text-assembly': ['002', '003'],
}


def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def declarations(source, file):
    starts = list(re.finditer(r'(?m)^(?:@unsafe\n)?(def|law|type) ([A-Za-z_][A-Za-z_0-9.]*)', source))
    rows = []
    prefix=source[:starts[0].start()] if starts else ''
    byte_offset,line_number=len(prefix.encode()),prefix.count('\n')+1
    for i, match in enumerate(starts):
        end = starts[i + 1].start() if i + 1 < len(starts) else len(source)
        text = source[match.start():end]
        encoded=text.encode()
        rows.append(dict(kind=match[1], name=match[2], file=file, text=text,
                         startByte=byte_offset, endByte=byte_offset+len(encoded),
                         startLine=line_number, sha256=hashlib.sha256(encoded).hexdigest()))
        byte_offset+=len(encoded);line_number+=text.count('\n')
    return rows


def extract(sources, harness):
    rows = [r for name, text in sources.items() for r in declarations(text, name)]
    by_name = {}
    for row in rows:
        by_name.setdefault(row['name'], []).append(row)
    constructor_owner = {}
    for row in rows:
        if row['kind'] == 'type':
            for ctor in re.findall(r'(?m)^  ([A-Za-z_][A-Za-z_0-9.]*)\{', row['text']):
                constructor_owner[ctor] = row['name']

    def references(text):
        # Remove strings/comments: constructor-name text is not a dependency.
        text = re.sub(r'"(?:\\.|[^"\\])*"|(?m:#[^\n]*)', '', text)
        names = set(re.findall(r'\b[A-Za-z_][A-Za-z_0-9.]*\b', text))
        return {constructor_owner.get(name, name) for name in names} & by_name.keys()

    wanted, done = references(harness), set()
    while wanted - done:
        name = sorted(wanted - done)[0]
        done.add(name)
        for row in by_name[name]:
            wanted.update(references(row['text']))
    selected = [row for row in rows if row['name'] in wanted]
    body = 'import Base\n\n' + '\n'.join(row['text'] for row in selected)
    return body, [{k: v for k, v in row.items() if k != 'text'} for row in selected]


def mutate(body, recipe):
    rows = [row for row in declarations(body, 'extracted.bend')
            if row['kind'] == 'def' and row['name'] == recipe['function']]
    assert len(rows) == 1
    row = rows[0]
    assert row['text'].count(recipe['before']) == 1, recipe['id']
    changed = row['text'].replace(recipe['before'], recipe['after'], 1)
    raw = body.encode()
    result = raw[:row['startByte']] + changed.encode() + raw[row['endByte']:]
    return result.decode(), dict(recipe, sourceDeclarationSha256=row['sha256'],
                                 originalModuleSha256=hashlib.sha256(raw).hexdigest(),
                                 changedModuleSha256=hashlib.sha256(result).hexdigest())


def serializer_for(source, profile):
    original=FIXTURES/'serialize.bend'
    if profile=='frozen':return original.read_text(),[original],dict(profile=profile)
    spec_path=FIXTURES/'serializer-current.json';spec=json.loads(spec_path.read_text())
    current=FIXTURES/'serialize-current.bend'
    for key,path in [('original',original),('current',current)]:
        row=pin(path)
        if any(row[k]!=spec[key][k] for k in ['bytes','sha256']):raise ValueError('Frozen serializer extension input changed')
    old=original.read_text();new=current.read_text()
    if old.count(spec['before'])!=1 or new.count(spec['after'])!=1 or old.replace(spec['before'],spec['after'],1)!=new:
        raise ValueError('Serializer extension must be exactly the declared additive branch')
    declarations_found=[row for row in declarations(source,'compiler.bend') if row['kind']=='type' and row['name']=='N_WordKind']
    if len(declarations_found)!=1:raise ValueError('Unique current N_WordKind declaration required')
    ctors=re.findall(r'(?m)^  ([A-Za-z_][A-Za-z_0-9.]*)\{\}',declarations_found[0]['text'])
    if ctors!=spec['expectedCurrentConstructors']:raise ValueError('Current N_WordKind differs from explicit observer profile')
    return new,[original,current,spec_path],dict(profile=profile,specification=pin(spec_path),
        productionDeclaration={k:v for k,v in declarations_found[0].items() if k!='text'},
        scope=spec['scope'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--source', type=Path, required=True, help='Exact current assembled compiler source; no historical fallback')
    p.add_argument('--assets', type=Path, required=True)
    p.add_argument('--families', help='Comma-separated subset; omitted means all families')
    p.add_argument('--cases', help='Comma-separated exact case IDs')
    p.add_argument('--mutant', help='Deliberate bad extracted-helper edit; defaults to its single frozen witness')
    p.add_argument('--supplements', action='store_true', help='Add two separately labeled frozen Phase97 gap witnesses')
    p.add_argument('--serializer', choices=['word-kind-v2','frozen'],default='word-kind-v2',help='Explicit current exhaustive observer, or unchanged original fixture')
    args = p.parse_args()
    out = args.out.resolve()
    assert not out.exists(), 'Use a fresh immutable output directory'
    cases = make_cases()
    if args.supplements:
        cases += json.loads((FIXTURES/'supplements.json').read_text())
    mutation = None
    if args.mutant:
        mutations = json.loads((FIXTURES / 'mutations.json').read_text())
        mutation = next(row for row in mutations if row['id'] == args.mutant)
        if not args.cases and not args.families:
            args.cases = mutation['case']
    if args.families:
        wanted = set(args.families.split(','))
        assert wanted <= {row['family'] for row in cases}
        cases = [row for row in cases if row['family'] in wanted]
    if args.cases:
        wanted = set(args.cases.split(','))
        assert wanted <= {row['id'] for row in cases}
        cases = [row for row in cases if row['id'] in wanted]
    assert cases
    source_path=args.source.resolve();source_text=source_path.read_text()
    serializer,serializer_inputs,serializer_binding=serializer_for(source_text,args.serializer)
    wrappers = []
    for i, row in enumerate(cases):
        row['exportName'] = f'p96_case_{i:04}'
        body = '\n'.join('  ' + line for line in row['expression'].splitlines())
        wrappers.append(f'@unsafe\ndef {row["exportName"]}() -> String:\n{body}\n')
    harness = serializer + '\n' + '\n'.join(wrappers)
    sources = {source_path.name: source_text}
    extracted, extraction = extract(sources, harness)
    if mutation:
        extracted, mutation = mutate(extracted, mutation)
    library = extracted + '\n' + harness
    native_cases = []
    for family in dict.fromkeys(row['family'] for row in cases):
        group = [row for row in cases if row['family'] == family]
        selected = [row for suffix in NATIVE_REPRESENTATIVES.get(family,[]) for row in group if row['id'] == family + '-' + suffix]
        native_cases.extend(selected or group[:2])
    native = library + '\n@unsafe\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'
    native += ''.join('    Unit <- IO.print(' + row['exportName'] + '())\n' for row in native_cases[:-1])
    native += '    IO.print(' + native_cases[-1]['exportName'] + '())\n'
    originals = [pin(source_path)]
    assets=load_assets(args.assets,ROOT)
    b2={key:asset(assets,'law-'+key) for key in ['api','driver','runtime','base','directRuntime']}
    out.mkdir(parents=True, exist_ok=False)
    snapshots = []
    for name, text in sources.items():
        dest = out / 'production-source' / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(text)
        snapshots.append(pin(dest))
    methods = []
    for original in [Path(__file__), REFERENCE, *serializer_inputs, HERE/'finite-run.mjs', FIXTURES/'catalog.json', FIXTURES/'mutations.json', *([FIXTURES/'supplements.json'] if args.supplements else [])]:
        dest=out/'methods'/('run.mjs' if original.name=='finite-run.mjs' else original.name)
        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(original.read_bytes());methods.append(pin(dest))
    generated = []
    for name, text in [('extracted.bend', extracted), ('library.bend', library), ('native.bend', native)]:
        (out / name).write_text(text)
        generated.append(pin(out / name))
    expected = ''.join(json.dumps(row['expectedWire'], separators=(',', ':')) + '\n' for row in native_cases)
    (out / 'native.expected.txt').write_text(expected)
    generated.append(pin(out / 'native.expected.txt'))
    for item in originals:
        assert pin(item['file']) == item
    report = dict(kind='bend-extracted-production-finite-controls-v1', complete=True, targetsRun=False,
                  scope='Finite executable constraints over exact production helper declarations; not a universal proof.',
                  operationalAssets=pin(args.assets), b2=b2, originalSources=originals,
                  frozenInputs=snapshots + methods + generated, extraction=extraction,
                  mutation=mutation,
                  supplemented=args.supplements,
                  observer=serializer_binding,
                  cases=cases, nativeCaseIds=[row['id'] for row in native_cases],
                  library=pin(out / 'library.bend'), native=pin(out / 'native.bend'),
                  serializer='JSON arrays; every String is an array of Unicode scalar values. Complete ordered constructor fields are retained.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(cases), families=sorted({r['family'] for r in cases}), manifest=pin(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
