#!/usr/bin/env python3
"""Offline full-product oracle: require four byte-identical stdout files.

Usage: compare.py manifest.json flat-js flat-c header-js header-c new-report.json
The tiny display reader handles only constructors, lists, strings and U32 values.
It neither evaluates Bend nor uses a hash/checksum in place of product equality.
"""
import hashlib
import json
import re
import sys
from pathlib import Path


class Reader:
    def __init__(self, text):
        self.text, self.at = text, 0

    def space(self):
        while self.at < len(self.text) and self.text[self.at].isspace():
            self.at += 1

    def take(self, expected):
        self.space()
        assert self.text.startswith(expected, self.at), (expected, self.at, self.text[self.at:self.at + 100])
        self.at += len(expected)

    def sequence(self, end):
        result = []
        self.space()
        if self.text.startswith(end, self.at):
            self.take(end)
            return result
        while True:
            result.append(self.value())
            self.space()
            if self.text.startswith(end, self.at):
                self.take(end)
                return result
            self.take(',')

    def value(self):
        self.space()
        char = self.text[self.at]
        if char == '[':
            self.at += 1
            return self.sequence(']')
        if char == '"':
            result, size = json.JSONDecoder().raw_decode(self.text[self.at:])
            self.at += size
            return result
        match = re.match(r'[0-9]+', self.text[self.at:])
        if match:
            self.at += match.end()
            return int(match[0])
        match = re.match(r'[A-Za-z_][A-Za-z_0-9.]*', self.text[self.at:])
        assert match, (self.at, self.text[self.at:self.at + 100])
        self.at += match.end()
        self.take('{')
        fields = self.sequence('}')
        if match[0] == 'Nil':
            assert not fields
            return []
        if match[0] == 'Con':
            assert len(fields) == 2 and isinstance(fields[1], list)
            return [fields[0]] + fields[1]
        return dict(tag=match[0], fields=fields)


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    assert len(sys.argv) == 7, __doc__
    manifest, *logs, out = map(Path, sys.argv[1:])
    meta = json.loads(manifest.read_text())
    contents = [p.read_bytes() for p in logs]
    assert len(set(contents)) == 1, 'Complete flat/header JS/C stdout differs'
    reader = Reader(contents[0].decode())
    actual = reader.value()
    reader.space()
    assert reader.at == len(reader.text), ('Trailing output', reader.text[reader.at:reader.at + 100])
    assert len(actual) == meta['cases']
    for i, (observed, expected) in enumerate(zip(actual, meta['expected'])):
        assert observed == expected, ('Whole product disagreement', i, observed, expected)
    report = dict(kind='phase90-header-payload-controls', complete=True, passed=True,
                  cases=len(actual), exactFourOutputs=True, retainedWholeBooks=True,
                  independentOracle='Python ordered first-match over retained literal fixture products; every field compared',
                  inputs=[pin(manifest)] + [pin(p) for p in logs], method=pin(Path(__file__)))
    with out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, passed=True, cases=len(actual))))


if __name__ == '__main__':
    main()
