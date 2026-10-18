#!/usr/bin/env python3
"""Authenticate prepared controls and exact source excerpts; runs no compiler."""
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def declarations(path):
    text = path.read_text()
    starts = list(re.finditer(
        r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', text, re.M))
    return {
        (match.group(1), match.group(2)):
        text[match.start():starts[i + 1].start() if i + 1 < len(starts)
             else len(text)].strip() + '\n'
        for i, match in enumerate(starts)
    }


def main():
    manifest = json.loads((HERE / 'manifest.json').read_text())
    fixtures = {row['name']: row for row in manifest['fixtures']}
    for row in fixtures.values():
        path = HERE / row['file']
        raw = path.read_bytes()
        assert digest(raw) == row['sha256'], ('changed fixture', path)
        if row['expect']['stage'] == 'execute':
            golden = ''.join(line[2:] + '\n' for line in raw.decode().splitlines()
                             if line.startswith('#|'))
            assert golden == row['expect']['stdout'], ('golden disagreement', path)
    for origin in manifest['origins']:
        path = ROOT / origin['source']
        assert digest(path.read_bytes()) == origin['sha256'], ('changed source', path)
        blocks = declarations(path)
        fixture = (HERE / fixtures[origin['fixture']]['file']).read_text()
        for row in origin['declarations']:
            block = blocks[row['kind'], row['name']]
            assert digest(block.encode()) == row['sha256'], ('changed declaration', row)
            if origin['embedded']:
                assert fixture.count(block) == 1, ('declaration not exact', row)
    selected = manifest['selectedCompilerSource']
    path = ROOT / selected['file']
    raw = path.read_bytes()
    assert len(raw) == selected['bytes'] and digest(raw) == selected['sha256'], \
        ('changed selected compiler source', path)
    selected_blocks = declarations(path)
    for row in manifest['selectedSourceWitnesses']:
        source_block = declarations(ROOT / row['source'])[row['kind'], row['name']]
        selected_block = selected_blocks[row['kind'], row['name']]
        # Assembly adds location comments between unchanged declarations.
        selected_block = '\n'.join(line for line in selected_block.splitlines()
                                   if not line.startswith('# Module:')).strip() + '\n'
        assert selected_block == source_block, ('selected source witness changed', row)
    print(json.dumps(dict(complete=True, preparedOnly=True, targetsRun=False,
                          fixtures=len(fixtures), origins=len(manifest['origins']))))


if __name__ == '__main__':
    main()
