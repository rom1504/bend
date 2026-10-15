#!/usr/bin/env python3
"""Freeze the actual f_find operation, one isolated edit, oracles, and controls.

This preparer only reads/writes data. It never launches a compiler or target.
"""
import argparse
import difflib
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
from reference import cases, show_def, show_list, quote

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
D04 = ROOT / 'selfhost/build/phase92/upstream-checked01/compiler.bend'
D04_SHA = 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
NAMES = ['KTerm', 'KDef', 'kt', 'atom', 'dn', 'p88_string_eq_go', 'p88_string_eq', 'f_eq', 'f_find', 'f_find_next']


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=sha(data))


def declaration(source, name):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:def|type) ' + re.escape(name) + r'(?:\(| is )', source))
    assert len(matches) == 1, (name, len(matches))
    start = matches[0].start()
    end = source.find('\n\n', matches[0].end())
    assert end >= 0, name
    text = source[start:end + 1]
    return text, dict(name=name, startByte=len(source[:start].encode()), endByte=len(source[:end + 1].encode()),
                      startLine=source.count('\n', 0, start) + 1, sha256=sha(text.encode()))


def replace_once(source, before, after):
    assert source.count(before) == 1
    return source.replace(before, after, 1)


def diff(before, after, path):
    return ''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True), fromfile='a/' + path, tofile='b/' + path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase97') and not out.exists()
    source = D04.read_text()
    assert sha(source.encode()) == D04_SHA
    canonical_file = ROOT / 'selfhost/src/front/declarations.bend'
    canonical = canonical_file.read_text()
    old, location = declaration(source, 'f_find')
    canonical_old, canonical_location = declaration(canonical, 'f_find')
    assert canonical_old == old, 'The actual caller must match D04 exactly'
    new = (HERE / 'candidate.bend').read_text()
    assert new.endswith('\n')
    assert not re.search(r'(?m)^def f_find_fields\(', source), 'New helper name must be fresh'
    changed = replace_once(source, old, new)
    canonical_changed = replace_once(canonical, canonical_old, new)
    pieces, extractions = [], []
    for name in NAMES:
        text, where = declaration(source, name)
        pieces.append(text); extractions.append(where)
    base = 'import Base\n\n' + '\n'.join(pieces)
    # The accepted Phase96 full-value observer prefix only needs KTerm/KDef.
    serializer_file = ROOT / 'selfhost/proofs/phase96/production/serialize.bend'
    serializer_raw = serializer_file.read_text()
    serializer = serializer_raw[:serializer_raw.index('@unsafe\ndef p96.kind(')].replace('p96.', 'p97.')
    runner_file = ROOT / 'selfhost/proofs/phase96/production/run.mjs'
    runner = runner_file.read_bytes()
    rows = cases()
    wrappers = []
    for i, row in enumerate(rows):
        row['family'] = 'actual-f-find-first-match'
        row['exportName'] = f'p97_case_{i:03}'
        row['expectedWire'] = row.pop('expected')
        wrappers.append('@unsafe\ndef ' + row['exportName'] + '() -> String:\n' +
            '  +book : List<&2,KDef> = ' + show_list(row['book'], show_def) + '\n' +
            '  +key : String = ' + quote(row['key']) + '\n' +
            '  +found : KDef = f_find(key, book)\n' +
            '  "[" ++ p97.string(dn(found)) ++ "," ++ p97.def(found) ++ "," ++ p97.defs(book) ++ "," ++ p97.string(key) ++ "]"\n')
    checks = '\n'.join(wrappers)
    entry = '\n@unsafe\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'
    entry += ''.join('    Unit <- IO.print(' + row['exportName'] + '())\n' for row in rows[:-1])
    entry += '    IO.print(' + rows[-1]['exportName'] + '())\n'
    expected = ''.join(json.dumps(row['expectedWire'], separators=(',', ':')) + '\n' for row in rows)
    plan_file = ROOT / 'selfhost/build/phase91/continuity01/plan.json'
    plan = json.loads(plan_file.read_text())
    b2 = dict(api=plan['roles']['b2'], **{key: plan['host'][key] for key in ['driver', 'runtime', 'base', 'directRuntime']})
    for value in b2.values():
        assert pin(value['file']) == value
    canonical_sources = [canonical_file, ROOT / 'selfhost/src/core/term.bend', ROOT / 'selfhost/src/front/lexer.bend']
    original_pins = [pin(f) for f in [D04, *canonical_sources, serializer_file, runner_file, plan_file]]
    # Each common helper is authenticated against canonical production too.
    bridges = []
    for name, file in [('KTerm', canonical_sources[1]), ('KDef', canonical_sources[1]), ('kt', canonical_sources[1]),
                       ('atom', canonical_sources[1]), ('dn', canonical_sources[1]), ('f_eq', canonical_sources[2]),
                       ('f_find', canonical_file), ('f_find_next', canonical_file)]:
        a, aloc = declaration(file.read_text(), name)
        b, bloc = declaration(source, name)
        assert a.replace('String.eq(', 'p88_string_eq(') == b
        bridges.append(dict(name=name, canonicalFile=str(file), canonical=aloc, d04=bloc,
                            transform='String.eq -> p88_string_eq' if a != b else 'exact'))
    out.mkdir(parents=True)
    common = []
    def write(relative, data):
        path = out / relative; path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data.encode() if isinstance(data, str) else data)
        return pin(path)
    for file in sorted(HERE.iterdir()):
        if file.is_file(): common.append(write('methods/' + file.name, file.read_bytes()))
    common.append(write('methods/run.mjs', runner))
    common.append(write('observer.bend', serializer))
    common.append(write('cases.json', json.dumps(rows, indent=2, ensure_ascii=False) + '\n'))
    for file in canonical_sources:
        common.append(write('original-source/' + str(file.relative_to(ROOT / 'selfhost/src')), file.read_bytes()))
    common.append(write('f_find.d04.patch', diff(source, changed, str(D04.relative_to(ROOT)))))
    common.append(write('f_find.canonical.patch', diff(canonical, canonical_changed, str(canonical_file.relative_to(ROOT)))))
    common.append(write('compiler.bend', changed))
    recipes = json.loads((HERE / 'mutations.json').read_text())
    variants = [('baseline', old, None), ('candidate', new, None)]
    variants += [(r['id'], replace_once(new, r['before'], r['after']), r) for r in recipes]
    manifests = {}
    for role, body, mutation in variants:
        extracted = replace_once(base, old, body)
        library = extracted + '\n' + serializer + '\n' + checks
        generated = [write(role + '/extracted.bend', extracted), write(role + '/library.bend', library),
                     write(role + '/native.bend', library + entry), write(role + '/native.expected.txt', expected),
                     write(role + '/micro.bend', extracted + '\n' + serializer + '\n' + (HERE / 'micro-template.bend').read_text()),
                     write(role + '/methods/run.mjs', runner)]
        report = dict(kind='phase97-actual-f-find-contract', complete=True, targetsRun=False, role=role,
                      scope='Finite full-value constraints over the exact caller and dependencies; not a universal proof.',
                      compilerPlan=pin(plan_file), b2=b2, originalSources=original_pins,
                      frozenInputs=common + generated, extraction=extractions, canonicalBridge=bridges,
                      mutation=mutation, cases=rows, nativeCaseIds=[row['id'] for row in rows],
                      library=pin(out / role / 'library.bend'), native=pin(out / role / 'native.bend'))
        manifests[role] = write(role + '/manifest.json', json.dumps(report, indent=2, ensure_ascii=False) + '\n')
    replay = source.encode(); at = location['startByte']; before = old.encode(); after = new.encode()
    assert replay[at:at + len(before)] == before
    assert replay[:at] + after + replay[at + len(before):] == changed.encode()
    for p in original_pins:
        assert pin(p['file']) == p
    receipt = dict(kind='phase97-projection-consume-once', complete=True, targetsRun=False,
                   source=pin(D04), candidate=pin(out / 'compiler.bend'), methods=common,
                   manifests=manifests, extraction=extractions, canonicalBridge=bridges,
                   change=dict(function='f_find', location=location, canonicalLocation=canonical_location,
                               old=old, new=new, beforeSha256=D04_SHA, afterSha256=sha(changed.encode()),
                               canonicalBeforeSha256=sha(canonical.encode()), canonicalAfterSha256=sha(canonical_changed.encode()),
                               forwardReplayExact=True),
                   staticCounts=dict(baselineLines=len(old.splitlines()), candidateLines=len(new.splitlines()),
                                     baselineDefinitions=old.count('\ndef '), candidateDefinitions=new.count('\ndef '),
                                     baselineDnCalls=old.count('dn('), candidateDnCalls=new.count('dn('),
                                     baselineFfindNextCalls=old.count('f_find_next('), candidateFfindNextCalls=new.count('f_find_next(')),
                   observerDerivation=dict(source=pin(serializer_file), prefixBefore='@unsafe\ndef p96.kind(', rename='p96. -> p97.'),
                   expectedBytes=sha(expected.encode()))
    write('receipt.json', json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out), cases=len(rows), candidateSha256=sha(changed.encode()), roles=list(manifests))))


if __name__ == '__main__':
    main()
