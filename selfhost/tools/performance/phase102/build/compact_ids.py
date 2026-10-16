#!/usr/bin/env python3
"""Offline, reversible renaming of generated FID identifiers; no code elision."""
import re

# Preserve comments, string/character literals and every non-identifier byte.
TOKEN = re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_][A-Za-z_0-9]*')
FID = re.compile(r'FID_(?:[0-9]+_)+$')


def transform(source):
    declared = re.findall(r'^#define (FID_(?:[0-9]+_)+) ([0-9]+)\s*$', source, re.M)
    assert declared and len({name for name, _ in declared}) == len(declared)
    mapping = {name: 'FID_P102_' + value for name, value in declared}
    assert len(set(mapping.values())) == len(mapping)
    tokens = {m.group() for m in TOKEN.finditer(source)}
    assert not set(mapping.values()) & tokens
    counts = dict(definitions=len(mapping), replacements=0, stringsAndCommentsPreserved=True,
                  branchesRemoved=0, functionsRemoved=0, onlyIdentifiersChanged=True)
    def rename(match):
        word = match.group()
        prefix = 'WL_' if word.startswith('WL_FID_') else ''
        name = word[len(prefix):]
        if FID.fullmatch(name):
            assert name in mapping, 'Undeclared generated FID: ' + name
            counts['replacements'] += 1
            return prefix + mapping[name]
        return word
    result = TOKEN.sub(rename, source)
    reverse = {v:k for k,v in mapping.items()}
    def restore(match):
        word=match.group();prefix='WL_' if word.startswith('WL_FID_P102_') else ''
        return prefix + reverse[word[len(prefix):]] if word[len(prefix):] in reverse else word
    assert TOKEN.sub(restore, result) == source
    counts.update(inputBytes=len(source.encode()), outputBytes=len(result.encode()),
                  savedBytes=len(source.encode())-len(result.encode()), exactInverse=True)
    return result, counts
