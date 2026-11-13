#!/usr/bin/env python3
"""Extract checked-API source from an explicit x86 snapshot; runs no compiler.

--set changes only a parameterless U32/Bool source constant. Every resulting
source still requires ordinary independent checking and API acquisition.
Other --module/--replace/--export options use the Phase181 lexical extractor.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
EXPORTS = ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'x181_prepared',
           'x188_many', 'x188_render', 'x188_assemble']


def digest(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def override_constants(data, settings, protected):
    """Literal source edits only: no compiler analysis, checking or lowering."""
    edits, seen = [], set()
    for setting in settings:
        name, separator, value = setting.partition('=')
        if not separator or not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9.]*', name):
            raise ValueError('--set requires NAME=U32 or NAME=true/false')
        if name in seen or name in protected:
            raise ValueError('Duplicate or protected constant: ' + name)
        seen.add(name)
        pattern = re.compile(rb'(?m)^def ' + re.escape(name.encode()) +
            rb'\(\) -> (U32|Bool):[ \t]*(\d+|True\{\}|False\{\})[ \t]*$')
        matches = list(pattern.finditer(data))
        if len(matches) != 1:
            raise ValueError('Unique parameterless U32/Bool literal required: ' + name)
        match = matches[0]
        typ = match[1].decode()
        if typ == 'Bool':
            literals = {'true': 'True{}', 'false': 'False{}', 'True{}': 'True{}', 'False{}': 'False{}'}
            if value not in literals:
                raise ValueError('Bool literal required: ' + setting)
            literal = literals[value]
        else:
            if not re.fullmatch(r'0|[1-9][0-9]*', value) or int(value) > 4294967295:
                raise ValueError('U32 literal required: ' + setting)
            literal = value
        before = match[0]
        after = b'def ' + name.encode() + b'() -> ' + match[1] + b': ' + literal.encode()
        data = data[:match.start()] + after + data[match.end():]
        edits.append(dict(name=name, type=typ, before=match[2].decode(), after=literal,
                          original=digest(before), replacement=digest(after)))
    return data, edits


def main():
    parser = argparse.ArgumentParser(description=__doc__, add_help=False)
    parser.add_argument('--parent-source', type=Path, required=True)
    parser.add_argument('--set', action='append', default=[])
    own, forwarded = parser.parse_known_args()
    source = own.parent_source.resolve(strict=True)
    original = source.read_bytes()
    config = json.loads((ROOT / 'selfhost/src/compiler.json').read_text())
    data, changes = override_constants(original, own.set, config.get('protectedDeclarations', {}))
    method = ROOT / 'selfhost/tests/phase175/frontend-prepare.py'
    spec = importlib.util.spec_from_file_location('phase190_source_transport', method)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    bridge = Path(__file__).with_name('api-bridge.bend')
    _, original_rows = module.assembly.blocks(data)
    _, bridge_rows = module.assembly.blocks(bridge.read_bytes())
    present = {(row['kind'], row['name']) for row in original_rows}
    additions = [row for row in bridge_rows if (row['kind'], row['name']) not in present]
    if additions:
        data += b'\n' + b'\n'.join(row['data'] for row in additions)
    module.PARENT = digest(data)
    module.DEFAULTS = EXPORTS
    module.assembly.maintained_assemble = lambda *a, **k: (data, [])
    write_original = module.write_json

    def write_manifest(path, value):
        if Path(path).name == 'exports.json':
            value = dict(value, scope='Phase190 typed x86 experiment exports. qbe is the hosted API transport tag; no target qualification or promotion.')
        if Path(path).name == 'manifest.json':
            value = dict(value)
            value.update(kind='phase190-api-source', snapshot=module.pin(source),
                         snapshotIdentity=digest(original), sourceConstantOverrides=changes,
                         bridgedExportDeclarations=[row['name'] for row in additions],
                         parentScope='Explicit immutable snapshot plus recorded literal source overrides. No source map or inherited checking claim.')
            value['inputs'] += [module.pin(source), module.pin(__file__), module.pin(bridge)]
        write_original(path, value)

    module.write_json = write_manifest
    sys.argv = [str(method), *forwarded]
    module.main()
    module.require(source.read_bytes() == original, 'Snapshot changed during extraction')


if __name__ == '__main__':
    main()
