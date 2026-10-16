#!/usr/bin/env python3
"""Preserve the original focused controls and add exact cold-policy source oracles."""
import argparse
import hashlib
import json
from pathlib import Path


def pin(path):
    path = Path(path).resolve(); raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['base', 'cold', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args(); inputs = {}
    def bind(value):
        actual = pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict):
            assert actual == {key: value[key] for key in ['file', 'bytes', 'sha256']}
        assert inputs.setdefault(actual['file'], actual) == actual
        return actual
    def tree(value):
        if isinstance(value, list):
            for child in value: tree(child)
        elif isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys(): bind(value)
            else:
                for child in value.values(): tree(child)
    base_pin, cold_pin = bind(args.base), bind(args.cold)
    base, cold = json.loads(args.base.read_text()), json.loads(args.cold.read_text())
    assert base['complete'] and cold['complete']
    assert base_pin['sha256'] == 'a7595d329409fb39009f4e7cccba597430bbeb266b224ce0403c2db841ff1b82'
    assert cold['kind'] == 'phase102-trmc-destination-policy-controls'
    assert [row['id'] for row in cold['records']] == ['mixed', 'shared']
    tree(base); tree(cold); bind(__file__)
    rows = list(base['records'])
    assert len(rows) == 27
    for row in cold['records']:
        rows.append(dict(id='cold-' + row['id'], source=row['source']['file'],
            expected=row['stdout']['file'], stderr=row['stderr'], returncode=row['exit'],
            argv=[], workers=row['workers'],
            scope='Unmodified natural-policy source execution with exact independent full-value oracle. Explicit generated-C policy matrix is a separate control.'))
    assert len({row['id'] for row in rows}) == 29
    for row in rows:
        bind(row['source'])
        if 'expected' in row: bind(row['expected'])
    for item in list(inputs.values()): assert pin(item['file']) == item
    args.out.mkdir(parents=True, exist_ok=False)
    dest = args.out / 'controls.json'
    dest.write_text(json.dumps(dict(complete=True, targetsRun=False,
        parents=[base_pin, cold_pin], pins=list(inputs.values()), records=rows,
        scope='All 27 original records retained exactly, followed by two cold-policy controls adapted only to the existing manifest schema. No expected bytes, source bytes or original worker counts changed.'), indent=2) + '\n')
    print(json.dumps(dict(manifest=pin(dest), records=len(rows),
                         executions=sum(3 * len(row.get('workers', [1])) for row in rows))))


if __name__ == '__main__': main()
