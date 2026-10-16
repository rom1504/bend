#!/usr/bin/env python3
"""Materialize independent complete-output controls; runs no compiler/program."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def codes(words):
    return ''.join(str(word) + ',' for word in words)


def value_output():
    text = list(map(ord, 'A\0λ🙂z'))
    tail = text[1:]
    words = [0, 127, 128, 2047, 2048, 55295, 55296, 57343, 57344,
             65535, 65536, 1114111, 1114112, 4294967295]
    large = list(map(ord, 'aλ🙂\0')) * 33
    values = [
        ('empty', []), ('literal', text), ('alias-tail', tail),
        ('alias-root', text), ('escaped', tail),
        ('match-twice', tail + tail + text),
        ('append-empty-left', text), ('append-empty-right', text),
        ('append-self', text + text), ('append-shared-tail', text + tail),
        ('reverse', text[::-1]), ('take-0', []), ('take-3', text[:3]),
        ('take-beyond', text), ('drop-beyond', []), ('list-roundtrip', text),
        ('all-u32', words), ('all-u32-tail', words[7:]),
        ('all-u32-reverse', words[::-1]), ('chunk-boundaries', large),
        ('chunk-middle', large[31:97]),
    ]
    lines = [f'{name}\t{len(value)}\t{codes(value)}' for name, value in values]
    pairs = [('cmp-empty', [], text), ('cmp-self', text, text),
             ('cmp-prefix', [65], text),
             ('cmp-late', list(map(ord, 'aλ🙂x')), list(map(ord, 'aλ🙂y'))),
             ('cmp-earlier', [98], [97, 97]),
             ('cmp-u32', [4294967295], [1114111])]
    for name, left, right in pairs:
        order = 'LT' if left < right else 'GT' if left > right else 'EQ'
        lines.append(f'{name}\t{order}\t{codes(left)}\t{codes(right)}')
    lines += ['eq-high-bits\t0', 'eq-nul-tail\t0', 'eq-rebuilt\t1',
              f'live-after-observers\t{len(text + tail)}\t{codes(text + tail)}']
    return ('\n'.join(lines) + '\n').encode('ascii')


def parallel_output():
    source = 'λ\0🙂X'
    # Traversal is lexicographic branch order; prepending reverses each path.
    leaves = [''.join(reversed(path)) + source + '\n'
              for path in itertools.product('LR', repeat=4)]
    return (''.join(leaves) + '\n' + source + '\n').encode('utf-8')


def array_output():
    source = 'λ\0🙂X'
    tail = source[1:]
    rows = [source] * 64
    rows[0] = 'first:' + tail
    rows[31] = 'middle:' + source
    rows[63] = 'last:' + tail
    return ('array\n' + '\n'.join(rows) + '\n\n'
            + 'escaped:' + source + '\n'
            + 'source:' + source + '\n'
            + 'tail:' + tail + '\n'
            + 'survivor:' + tail + '\n1\n').encode('utf-8')


def file_output(data):
    text = data.decode('utf-8', errors='replace')
    numeric = f'{len(text)}\t{codes(map(ord, text))}\n'
    result = numeric + text[::-1] + '\n' + text + '\n'
    for offset in [60, 61, 62]:
        tail = text[offset:]
        for label, value in [('forward', text + tail), ('backward', tail + text),
                             ('root', text), ('tail', tail)]:
            result += f'{label}-{offset}\t{codes(map(ord, value))}\n'
    return result.encode('utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    records = []
    for name, expected in [('values', value_output()), ('parallel', parallel_output()),
                           ('array-sharing', array_output())]:
        path = out / (name + '.stdout')
        path.write_bytes(expected)
        records.append(dict(id=name, source=str(HERE / (name + '.bend')),
                            argv=[], expected=str(path), workers=[1, 2, 4]))
    payloads = {
        'empty': b'',
        'unicode-nul': 'A\0λ🙂\r\n\uFEFF\uFFFF\U0010FFFFz'.encode('utf-8'),
        'replacement-decoding': b'A\xc0\xaf\xed\xa0\x80\xe2\x82X\xf4\x90\x80\x80Z\xf0\x9f',
        'chunk-boundaries': ('aλ🙂\0' * 65).encode('utf-8'),
    }
    for size in [60, 61, 62]:
        payloads[f'boundary-{size}'] = ('aλ🙂\0' * 16)[:size].encode('utf-8')
    for name, data in payloads.items():
        path = out / (name + '.input')
        expected = out / (name + '.stdout')
        path.write_bytes(data)
        expected.write_bytes(file_output(data))
        records.append(dict(id=name, source=str(HERE / 'file-input.bend'),
                            argv=['--file', str(path)], input=str(path),
                            expected=str(expected), workers=[1, 2, 4]))
    def pin(path):
        data = Path(path).read_bytes()
        return dict(path=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    sources = [HERE / name for name in ['prepare.py', 'values.bend', 'parallel.bend',
                                       'array-sharing.bend', 'file-input.bend']]
    report = dict(kind='phase101-independent-string-controls', generated=True,
                  executed=False, records=records,
                  pins=[pin(path) for path in sources + sorted(out.iterdir())])
    (out / 'controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(out=str(out), controls=len(records), executed=False)))


if __name__ == '__main__':
    main()
