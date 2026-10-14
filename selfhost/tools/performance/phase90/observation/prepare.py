#!/usr/bin/env python3
"""Offline source/layout falsifier; never executes a compiler or benchmarks.

Creates standalone exact-product controls and, optionally, one source derivative.
This is lexical constructor transport, not a compiler algorithm in Python.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|[A-Za-z_][A-Za-z_0-9.]*|[^\s]', re.S)
FLAT = 'KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}'
PAYLOAD = ('type P90Payload<-D: Data> is Data:\n'
           '  P90Payload{+kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2,D>, +native: Bool, +unsafe: Bool}\n\n')
NAME_PATTERN = 'case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:\n      name'


def pin(path):
    b = path.read_bytes()
    return dict(file=str(path.resolve()), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def declaration(text, name):
    m = re.search(r'(?m)^@unsafe\ndef ' + re.escape(name) + r'\(', text)
    assert m, name
    end = re.search(r'(?m)^@unsafe\n|^type |^law |^def ', text[m.end():])
    return text[m.start():m.end() + end.start() if end else len(text)].rstrip() + '\n'


def split_layout(source):
    assert source.count(FLAT) == 1
    assert 'P90Payload' not in source
    assert source.count(NAME_PATTERN) == 1
    source = source.replace(FLAT, 'KDef{+name: String, +payload: P90Payload<KDef>}')
    source = source.replace('type KDef is Data:\n', PAYLOAD + 'type KDef is Data:\n', 1)
    source = source.replace(NAME_PATTERN, 'case KDef{name, payload}:\n      name', 1)
    tokens = list(TOKEN.finditer(source))
    edits = []
    rewritten = 0
    # Insertions retain every original non-layout byte, including comments.
    for i, token in enumerate(tokens[:-1]):
        if token[0] != 'KDef' or tokens[i + 1][0] != '{':
            continue
        depth = 0
        commas = []
        end = None
        previous = None
        for next_token in tokens[i + 2:]:
            value = next_token[0]
            if value == '>' and previous in ('-', '='):
                previous = value
                continue
            if value in ('{', '(', '[', '<'):
                depth += 1
            elif value in ('}', ')', ']', '>'):
                if value == '}' and depth == 0:
                    end = next_token.start()
                    break
                depth -= 1
                assert depth >= 0, (value, next_token.start())
            elif value == ',' and depth == 0:
                commas.append(next_token.start())
            previous = value
        assert end is not None
        if len(commas) == 1:
            fragment = source[token.start():end + 1]
            assert fragment in ('KDef{+name: String, +payload: P90Payload<KDef>}',
                                'KDef{name, payload}'), fragment
            continue
        assert len(commas) == 8, source[token.start():end + 1]
        edits.extend([(commas[0] + 1, ' P90Payload{'), (end, '}')])
        rewritten += 1
    for at, text in sorted(edits, reverse=True):
        source = source[:at] + text + source[at:]
    return source, rewritten


def ctor(tag, *fields):
    return dict(tag=tag, fields=list(fields))


def literal(value):
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, int):
        return str(value)
    if isinstance(value, list):
        return '[' + ', '.join(literal(v) for v in value) + ']'
    return value['tag'] + '{' + ', '.join(literal(v) for v in value['fields']) + '}'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--compiler', type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    core_path = ROOT / 'selfhost/src/core/term.bend'
    front_path = ROOT / 'selfhost/src/front/declarations.bend'
    eq_path = ROOT / 'selfhost/tools/performance/phase88/strings/helpers.bend'
    core, front = core_path.read_text(), front_path.read_text()
    types = core[core.index('type KTerm is Data:'):core.index('\n@unsafe\ndef kt(')]
    source = 'import Base\n\n' + eq_path.read_text().split('\ndef p88_string_order_go')[0] + '\n\n' + types + '\n\n'
    for name in ('kt', 'atom', 'dn'):
        source += declaration(core, name) + '\n'
    source += '@unsafe\ndef f_eq(+a: String, +b: String) -> Bool:\n  p88_string_eq(a, b)\n\n'
    for name in ('f_find', 'f_find_next'):
        source += declaration(front, name) + '\n'
    source += (HERE / 'controls-tail.bend').read_text()
    true, false = ctor('True'), ctor('False')
    absent = ctor('KTerm', 'Absent', '', 0, 0, [], [], 0, 0)
    def definition(name, n):
        typ = ctor('KLambda', 'binder' + str(n), n, 2,
                   [ctor('KTerm', 'Var', 'type', n + 1, 1, [], ['removed'], 11, 17)],
                   ['outer'], 2, 19, true)
        value = ctor('KLiteral', 'U32', n + 100, 'payloadé😀', 23, 41)
        child = ctor('KDef', 'Ctor' + str(n), 'Ctr', 3, 2, absent, absent, [], false, true)
        return ctor('KDef', name, 'Def' + str(n), n, n + 3, typ, value, [child],
                    true if n % 2 else false, false if n % 2 else true)
    first, duplicate = definition('same', 1), definition('same', 99)
    unicode = definition('é😀', 4)
    empty = definition('', 5)
    leaf = ctor('KIndexLeaf', 2166136261, [first, duplicate])
    node = ctor('KIndexNode', 17, 32, leaf, ctor('KIndexLeaf', 18, [unicode]))
    books = [[], [first, duplicate, unicode], [duplicate, first], [leaf, empty, first],
             [empty, leaf, first], [node, first], [unicode, definition('é😁', 8)],
             [definition('prefix.long.a', 10), definition('prefix.long.b', 11), first]]
    queries = ['', 'same', 'é😀', 'é😁', 'missing', 'prefix.long.a', 'prefix.long.c']
    expected = []
    rows = []
    def flattened(value):
        if isinstance(value, list):
            return [flattened(x) for x in value]
        if not isinstance(value, dict):
            return value
        tag = dict(KDef='P90FlatDef', KIndexLeaf='P90FlatLeaf', KIndexNode='P90FlatNode').get(value['tag'], value['tag'])
        return ctor(tag, *[flattened(x) for x in value['fields']])
    for book in books:
        for query in queries:
            result = next((d for d in book if (d['fields'][0] if d['tag'] == 'KDef' else '') == query),
                          ctor('KDef', query, 'Missing', 0, 0, absent, absent, [], false, false))
            number = len(rows)
            rows.append('p90_case(' + str(number) + ', ' + literal(query) + ', ' + literal(book) + ')')
            expected.append(ctor('P90Case', number, query, flattened(result), flattened(book)))
    source += '\n@unsafe\ndef main() -> List<&2,P90Case>:\n  [\n    ' + ',\n    '.join(rows) + '\n  ]\n'
    baseline = args.out / 'flat.bend'
    baseline.write_text(source)
    header, count = split_layout(source)
    candidate = args.out / 'header.bend'
    candidate.write_text(header)
    manifest = dict(kind='phase90-header-payload-controls', complete=True, targetExecuted=False,
                    cases=len(rows), expected=expected, controlsRewritten=count,
                    inputs=[pin(Path(__file__)), pin(HERE / 'controls-tail.bend'), pin(core_path), pin(front_path), pin(eq_path)],
                    outputs=[pin(baseline), pin(candidate)],
                    semantics='Complete returned product plus retained whole book; first matching event, empty index names and Missing fields preserved.')
    if args.compiler:
        text = args.compiler.read_text()
        derivative, count = split_layout(text)
        path = args.out / 'compiler-header.bend'
        path.write_text(derivative)
        manifest['inputs'].append(pin(args.compiler))
        manifest['outputs'].append(pin(path))
        manifest['compilerRewritten'] = count
        manifest['compilerLineDelta'] = len(derivative.splitlines()) - len(text.splitlines())
    (args.out / 'manifest.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps({k: manifest[k] for k in ('complete', 'targetExecuted', 'cases', 'controlsRewritten')}))


if __name__ == '__main__':
    main()
