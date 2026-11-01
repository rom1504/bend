#!/usr/bin/env python3
"""Extract exact current Bend declarations and print root-owned experiment jobs."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly
from common import fresh_output, pin, require, write_json

META = ['missing', 'p111v_functions', 'p111v_constructors', 'p113e_originals', 'ns_ctor_index', 'p113e_signatures']
ORIGINAL = ['p111v_segment', 'p113e_function']
CAPTURE = ['p86_prepare', 'p86_plan', 'p140or_empty', 'p140or_lower', 'p111_verify_program', 'p113e_functions']
WORDS = re.compile(r'\b[A-Za-z_][A-Za-z0-9_.]*\b')
LITERALS = re.compile(r'''"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\#[^\n]*''')


def referenced_words(data):
    # Char literals can contain quotes and '#'. Strip them as units before
    # looking for names; otherwise a quote char can swallow following source.
    return set(WORDS.findall(LITERALS.sub(' ', data.decode())))


def extract(sources, roots, limit=4_000_000):
    """Conservative declaration closure; checking stays with the Bend compiler."""
    rows, groups, owners = [], {}, {}
    for label, data in sources:
        _, blocks = assembly.blocks(data)
        for block in blocks:
            item = dict(block, source=label)
            if item['name'] in groups:
                require(all(x['source'] == label and x['kind'] != item['kind'] for x in groups[item['name']]),
                        'Duplicate or shadowed declaration: ' + item['name'])
            rows.append(item); groups.setdefault(item['name'], []).append(item)
            if item['kind'] == 'type':
                for name in re.findall(rb'^  ([A-Za-z_][A-Za-z0-9_.]*)\{', item['data'], re.M):
                    name = name.decode()
                    require(name not in owners or owners[name] == item['name'], 'Ambiguous constructor: ' + name)
                    owners[name] = item['name']
    def refs(data):
        return {owners.get(name, name) for name in referenced_words(data)} & groups.keys()
    todo, needed = list(roots), set()
    while todo:
        name = todo.pop()
        require(name in groups, 'Missing requested declaration: ' + name)
        if name in needed: continue
        needed.add(name)
        for row in groups[name]: todo.extend(refs(row['data']) - needed)
    selected = [row for row in rows if row['name'] in needed]
    body = b'import Base\n\n' + b'\n'.join(row['data'] for row in selected)
    require(len(body) <= limit, 'Extraction exceeds explicit source bound')
    inventory = [dict(name=r['name'], kind=r['kind'], source=r['source'], bytes=len(r['data']),
                      sha256=hashlib.sha256(r['data']).hexdigest()) for r in selected]
    return body, inventory


def guard(name, out, command, seconds, rss=3072, disk=256):
    return dict(name=name, command=['python3', '-B', str(ROOT/'selfhost/tools/build-retention/guard.py'),
        '--out', str(out.parent/(out.name+'-guard')), '--run-root', str(out), '--seconds', str(seconds),
        '--disk-mib', str(disk), '--rss-mib', str(rss), '--available-mib', '16384', '--file-mib', '256',
        '--cpu', '3', '--', *map(str, command)])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['baseline', 'candidate'])
    p.add_argument('--candidate', type=Path)
    p.add_argument('--observer', type=Path)
    p.add_argument('--extra-export', action='append', default=[])
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    require((a.mode == 'candidate') == bool(a.candidate), 'Candidate mode needs one explicit additive Bend module')
    recipe = ROOT/'selfhost/src/compiler.json'
    canonical = assembly.maintained_assemble(recipe, ROOT/'selfhost', 'qbe')
    selector = json.loads((ROOT/'selfhost/manifests/current.json').read_text())
    identity = dict(bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest())
    require(identity == selector['source']['identity'], 'Current source differs from the installed baseline; explicitly start a new experiment boundary')
    sources = [('canonical', canonical)]; inputs = [pin(__file__), pin(assembly.__file__), pin(recipe), pin(ROOT/'selfhost/manifests/current.json')]
    roots = META + ORIGINAL + (CAPTURE if a.mode == 'baseline' else ['p147v_segment', 'p147v_function']) + a.extra_export
    for label, file in [('candidate', a.candidate), ('observer', a.observer)]:
        if file: sources.append((label, file.read_bytes())); inputs.append(pin(file))
    body, declarations = extract(sources, roots)
    out = fresh_output(a.out, ROOT); (out/'compiler.bend').write_bytes(body)
    exports = dict(kind='bend-hosted-api-exports', version=1, exports=roots, protocol='hosted-api-v1',
                   targets=['qbe'], preparationModes=['live'], scope='Experiment-only checked functions; no public request or installed image capability.')
    write_json(out/'exports.json', exports)
    acquisition = out/'api'
    jobs = [guard('checked-'+a.mode, acquisition, [ROOT/'selfhost/.assets/bin/bun', ROOT/'selfhost/tools/build/hosted.mjs', 'acquire',
        '--source', out/'compiler.bend', '--exports', out/'exports.json', '--upstream', ROOT/'selfhost/.bootstrap/upstream-phase66',
        '--engine', ROOT/'selfhost/.assets/bin/bun', '--out', acquisition], 150)]
    extra = {}
    if a.mode == 'baseline':
        workload = b'def main() -> U32:\n  Bool.to_u32(String.is_empty(p111_verify_program(p111_empty())))\n'
        _, original = assembly.blocks(canonical)
        no_main = b''.join(row['data'] for row in original if row['name'] != 'main')
        program, selected = extract([('canonical', no_main), ('workload', workload)], ['main'])
        file = out/'compiler-verifier-workload.bend'; file.write_bytes(program)
        # This is actual compiler code, not a claim to cover the full self-hosting request.
        cases = [dict(name='compiler-verifier-slice', source=pin(file), scope='Dependency-closed original compiler verifier workload; not the full canonical compiler.'),
                 *[dict(name=name, source=pin(ROOT/'selfhost/tests/consolidation/native-broad'/(name+'.bend')), scope='Complete ordinary benchmark source.')
                   for name in ['lexer', 'coverage-map-churn-128']]]
        write_json(out/'capture-cases.json', dict(kind='phase147-verifier-capture-inputs', version=1, complete=True, cases=cases))
        extra = dict(captureCases=pin(out/'capture-cases.json'), compilerWorkloadDeclarations=selected)
    report = dict(kind='phase147-verifier-slice-preparation', version=1, complete=True, targetsRun=False, checked=False,
        mode=a.mode, canonicalSourceIdentity=identity, source=pin(out/'compiler.bend'), inputs=inputs,
        declarations=declarations, exports=pin(out/'exports.json'), acquisition=str(acquisition/'report.json'), jobs=jobs,
        originalBodiesUnchanged=True, **extra,
        scope='Exact declaration extraction only; baseline and additive candidate remain unqualified until checked acquisition and independent controls. No compiler algorithms in host tools.')
    write_json(out/'manifest.json', report); write_json(out/'jobs.json', jobs)
    print(json.dumps(dict(source=report['source'], declarations=len(declarations), jobs=str(out/'jobs.json'), targetsRun=False)))


if __name__ == '__main__': main()
