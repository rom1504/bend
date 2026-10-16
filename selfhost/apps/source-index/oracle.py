#!/usr/bin/env python3
"""Independent lexical source-index oracle and deterministic input generator."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
NAME = re.compile(r'[A-Za-z0-9_.\u0080-\U0010ffff]+')
QUOTED = re.compile(r'"(?:\\[^\n]|[^"\\\n])*(?:"|\\)?')


def declaration(line: str):
    """Recognize a column-one keyword and its first lexical operand."""
    head = NAME.match(line)
    if not head or head.group() not in {'def', 'type', 'import'}:
        return None
    remaining = line[head.end():].lstrip(' \t\r')
    operand = (QUOTED if remaining.startswith('"') else NAME).match(remaining)
    return (head.group(), operand.group()) if operand else None


def field(value: str) -> str:
    return value.replace('\\', '\\\\').replace('\t', '\\t').replace('\r', '\\r')


def inventory(data: bytes) -> str:
    text = data.decode('utf-8', errors='strict')
    # Only LF ends a physical line. CR remains a character, including in CRLF.
    lines = text.split('\n')
    if not text or text.endswith('\n'):
        lines.pop()
    quote = None
    escaped = False
    comments = 0
    entries = []
    for number, line in enumerate(lines, 1):
        if quote is None:
            candidate = line.removeprefix('\ufeff') if number == 1 else line
            found = declaration(candidate)
            if found:
                entries.append((found[0], number, found[1]))
        for char in line:
            if quote is not None:
                if escaped:
                    escaped = False
                elif char == '\\':
                    escaped = True
                elif char == quote:
                    quote = None
            elif char == '#':
                comments += 1
                break
            elif char in {'"', "'"}:
                quote = char
        # A backslash before LF escapes that newline, not the next line's head.
        escaped = False
    counts = {kind: sum(row[0] == kind for row in entries) for kind in ['def', 'type', 'import']}
    rows = [
        'format\tbend-source-index-v1', f'bytes\t{len(data)}',
        f'characters\t{len(text)}', f'lines\t{len(lines)}',
        f'comment_lines\t{comments}', f'definitions\t{counts["def"]}',
        f'types\t{counts["type"]}', f'imports\t{counts["import"]}',
        f'unterminated_quote\t{int(quote is not None)}', 'kind\tline\tname',
    ]
    rows.extend(f'{kind}\t{number}\t{field(name)}' for kind, number, name in entries)
    return '\n'.join(rows) + '\n'


def generate(definitions: int) -> bytes:
    assert 0 <= definitions <= 10000
    lines = ['# Generated source inventory workload.', 'import Base', '',
             'type Label is Data:', '  Label{text: String}', '']
    for number in range(definitions):
        lines += [f'def label_{number:05d}() -> String:',
                  f'  "label {number}: # def decoy_{number}()"', '']
    lines += ['def main() -> IO(Unit):', '  IO.print("source-index input")', '']
    return '\n'.join(lines).encode()


def selected_compiler():
    """Follow the installed selection, verifying its admission and source pins."""
    selection_file = ROOT / 'selfhost/tools/native/selection.json'
    selection_data = selection_file.read_bytes()
    selection = json.loads(selection_data)

    def read_pinned(pin):
        file = (ROOT / pin['file']).resolve()
        data = file.read_bytes()
        if len(data) != pin['bytes'] or hashlib.sha256(data).hexdigest() != pin['sha256']:
            raise ValueError(f'selected compiler input identity mismatch: {file}')
        return file, data

    admission_file, admission_data = read_pinned(selection['admission'])
    admission = json.loads(admission_data)
    file, data = read_pinned(admission['source'])
    return file, data, {
        'selection_file': str(selection_file),
        'selection_sha256': hashlib.sha256(selection_data).hexdigest(),
        'admission_file': str(admission_file),
        'admission_sha256': selection['admission']['sha256'],
        'original_sha256': admission['source']['sha256'],
    }


def cases(out_dir, depth='smoke', selected=None):
    """Shared-runner contract: complete stdout oracles and runtime file argv."""
    if depth not in {'smoke', 'survey'}:
        raise ValueError('depth must be smoke or survey')
    out = Path(out_dir).resolve()
    out.mkdir(parents=True, exist_ok=True)
    rows = []

    def add(name, data):
        assert len(data) <= 8 * 1024 * 1024
        file = out / (name + '.bend')
        file.write_bytes(data)
        rows.append(dict(id=name, argv=['--file', str(file)], expected=inventory(data),
                         input_files=[str(file)], utf8_bytes=len(data)))

    add('sample', (HERE / 'fixtures/sample.bend').read_bytes())
    add('unicode-crlf', ('\ufeffimport Base\r\n# λ and 🙂 are text, not bytes.\r\n'
        'def café() -> String:\r\n  "λ🙂 # type Hidden"\r\n'
        'import "./module with space.bend"\r\n'
        'def final() -> Char:\r\n  \'#\'').encode())
    add('empty', b'')
    rows.append(dict(id='usage', argv=['--file'], expected='usage: source-index --file PATH\n', input_files=[]))
    if depth == 'survey':
        add('multiline-escape', ('import Base\n'
            'def message() -> String:\n'
            '  "first line\\\n'
            'def hidden() # still quoted\n'
            'last line" # real comment\n'
            'def visible() -> String:\n'
            '  "escaped quote: \\" and slash: \\\\"\n').encode())
        add('unterminated', b'import Base\ndef broken() -> String:\n  "unfinished\ndef hidden()\n')
        for definitions in [512, 4096, 10000]:
            add(f'generated-{definitions}', generate(definitions))
        for name, file in [('real-base', ROOT / 'bend2/base.bend'), ('real-tool', HERE / 'main.bend')]:
            data = file.read_bytes()
            assert len(data) <= 1024 * 1024
            add(name, data)
            rows[-1]['original_source'] = str(file)
        file, data, identity = selected_compiler()
        add('real-compiler', data)
        rows[-1].update(identity, original_source=str(file))
        absent = out / 'not-created-source.bend'
        assert not absent.exists()
        rows.append(dict(id='missing-file', argv=['--file', str(absent)], expected='error\topen\n', input_files=[]))
    return [row for row in rows if selected is None or row['id'] in selected]


def self_check():
    assert inventory(b'').splitlines()[1:4] == ['bytes\t0', 'characters\t0', 'lines\t0']
    simple = inventory(b'import Base\n# def fake()\ndef real() -> Char:\n  \'#\'')
    assert 'comment_lines\t1\n' in simple and 'definitions\t1\n' in simple
    assert simple.endswith('import\t1\tBase\ndef\t3\treal\n')
    unicode = inventory('def café() -> String:\n  "🙂"\n'.encode())
    assert 'bytes\t32\n' in unicode and 'characters\t28\n' in unicode
    assert inventory(b'def a() -> String:\n "x\ndef hidden()\n').endswith('def\t1\ta\n')
    assert 'unterminated_quote\t1\n' in inventory(b'"')
    assert declaration('import "unfinished\\') == ('import', '"unfinished\\')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('file', nargs='?', type=Path)
    parser.add_argument('--generate', type=Path)
    parser.add_argument('--definitions', type=int, default=512)
    parser.add_argument('--self-check', action='store_true')
    args = parser.parse_args()
    if args.self_check:
        self_check()
    if args.generate:
        args.generate.write_bytes(generate(args.definitions))
    if args.file:
        print(inventory(args.file.read_bytes()), end='')
    if not (args.file or args.generate or args.self_check):
        parser.error('provide FILE, --generate, or --self-check')


if __name__ == '__main__':
    main()
