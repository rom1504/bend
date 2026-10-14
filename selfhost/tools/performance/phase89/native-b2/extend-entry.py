#!/usr/bin/env python3
"""Offline exact-definition patch: SOURCE.bend NEW_SOURCE.bend.

Only p86_effect_file is replaced. A whole-source check/build and new consumer
admission are still required. Never launches or edits a compiler/runtime.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def verify(record):
    actual = pin(record['file'])
    assert actual == record, ('Changed asset', record['file'])
    return actual


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('source', type=Path)
    p.add_argument('output', type=Path)
    a = p.parse_args()
    source, output = a.source.resolve(), a.output.resolve()
    receipt = Path(str(output) + '.derivation.json')
    assert source != output and not output.exists() and not receipt.exists()
    manifest_file = HERE / 'nine-effects.json'
    manifest = json.loads(manifest_file.read_text())
    assert manifest['kind'] == 'phase89-private-native-entry-effect-assets'
    names = ['args.c', 'print.c', 'now.c', 'print_err.c', 'file_open.c',
             'file_read.c', 'file_size.c', 'file_write.c', 'file_close.c']
    assert [p['name'] for p in manifest['admittedEffects']] == names
    inputs = [pin(source), pin(__file__), pin(manifest_file)]
    inputs += [verify(manifest[k]) for k in ['base', 'runtime', 'runtimeTemplate',
                                            'oldEntry', 'oldDefinition', 'newDefinition']]
    for effect in manifest['admittedEffects']:
        inputs.append(verify({k: effect[k] for k in ['file', 'sha256', 'bytes']}))
    old = Path(manifest['oldDefinition']['file']).read_bytes()
    new = Path(manifest['newDefinition']['file']).read_bytes()
    data = source.read_bytes()
    assert data.startswith(b'import Base\n'), 'Expected assembled compiler source'
    assert data.count(b'\ndef p86_effect_file(') == 1
    assert data.count(old) == 1, 'Unknown or already changed p86_effect_file definition'
    assert data.count(b'\ndef p86_effects(') == 1
    at = data.index(old)
    before, after = data[:at], data[at+len(old):]
    # Assembly inserts exactly one source-map marker before the next definition.
    # Accept that marker or the unassembled immediate boundary; preserve it all.
    boundary = re.match(rb'(?P<module># Module: [^\r\n]+\.bend:[1-9][0-9]*\n)?@unsafe\ndef p86_effects\(', after)
    assert boundary is not None, 'Definition boundary changed'
    result = before + new + after
    assert result[:at] == before and result[at+len(new):] == after
    assert result.count(new) == 1 and result.count(old) == 0
    for record in inputs:
        verify(record)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as stream:
        stream.write(result)
    report = dict(
        kind='phase89-native-nine-effect-entry-derivative', complete=True, checked=False,
        inputs=inputs, output=pin(output), replacementCount=1,
        definition='p86_effect_file', offset=at,
        followingModuleMarker=(boundary.group('module') or b'').decode('utf8'),
        oldDefinitionBytes=len(old), newDefinitionBytes=len(new),
        unchangedPrefixSha256=hashlib.sha256(before).hexdigest(),
        unchangedSuffixSha256=hashlib.sha256(after).hexdigest(),
        remainingBytesExact=True, admittedEffects=manifest['admittedEffects'],
        scope='Exact private Base foreign-path allowlist only. Compiler algorithms, entry checking, '
              'foreign parsing, ns_definitions, runtime, argv and cache admission remain byte-identical. '
              'New file effects still fail the unchanged three-name scalar/observer certificate.',
        requires='Check the whole derivative, acquire a distinct native image, bind all nine effect bytes '
                 'before/after use, qualify live/cache behavior and add an explicit new consumer identity. '
                 'This receipt records source transport, not completed compiler checking.')
    with receipt.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(output=report['output'], receipt=str(receipt), checked=False)))


if __name__ == '__main__':
    main()
