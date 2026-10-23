#!/usr/bin/env python3
"""Compose one experimental transport-certificate repair; no checking or execution."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PARENT = ROOT / 'selfhost/build/phase126/observer-divmod-source32/compiler.bend'
PARENT_SHA = '40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb'
RUNTIME = ROOT / 'selfhost/build/phase126/runtime-divmod01/runtime.c'
RUNTIME_SHA = '2125198f0a44bac52de957754190d759161a289c5d6f8c802248ae24b41bfc52'
HOOK = re.compile(r'(?ms)^@unsafe\ndef p118z_runtime\(.*?(?=^@unsafe\ndef p118z_nonpointer\()')
DECL = re.compile(r'^(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
EXPORTS = ['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
           'p111_emit_admitted', 'p111_compile_source', 'p127lb_controls',
           'p118z_controls', 'p126dp_controls', 'p126dp_app_controls']


def require(ok, message):
    if not ok:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    parent_pin, runtime_pin = pin(PARENT), pin(RUNTIME)
    require(parent_pin['sha256'] == PARENT_SHA, 'Pinned Phase126 source32 changed')
    require(runtime_pin['sha256'] == RUNTIME_SHA, 'Reviewed runtime contract changed')
    original = PARENT.read_bytes()
    source = original.decode('utf-8')
    matches = list(HOOK.finditer(source))
    require(len(matches) == 1, 'Exactly one transport whitelist required')
    old = matches[0].group(0)
    repair = (HERE / 'repair.bend').read_text().rstrip() + '\n\n\n'
    expected = old.rstrip() + ' ||\n    String.eq(symbol,"p126_rt_nat_divmod")\n\n\n'
    require(repair == expected, 'Only one exact audited import may be added')
    controls = (HERE / 'controls.bend').read_text()
    old_names, new_names = set(DECL.findall(source)), DECL.findall(controls)
    require(len(new_names) == len(set(new_names)) and not old_names.intersection(new_names),
            'Control declarations must be fresh and unique')
    require(controls.count('p126dpc_row(') == 20, 'Expected twenty finite controls')
    suffix = '\n# Phase127 experimental transport-certificate controls.\n' + controls
    changed = source[:matches[0].start()] + repair + source[matches[0].end():]
    result = changed + suffix
    require(changed.count(repair) == 1, 'Repair must be uniquely reversible')
    reconstructed = result[:-len(suffix)].replace(repair, old, 1).encode('utf-8')
    require(reconstructed == original, 'Inverse reconstruction must recover every parent byte')
    require(DECL.findall(changed) == DECL.findall(source), 'Original declaration inventory changed')
    out = args.out.resolve()
    require(out.is_relative_to(ROOT / 'selfhost/build/phase127') and not out.exists(),
            'Use a fresh Phase127 output directory')
    inputs = [pin(__file__), pin(HERE / 'repair.bend'), pin(HERE / 'controls.bend'), parent_pin,
              pin(PARENT.parent / 'manifest.json'), runtime_pin]
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_bytes(result.encode('utf-8'))
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase127-experimental-live-bank-source', complete=True, checked=False,
                  targetsRun=False, selected=False, installed=False, source=pin(out / 'compiler.bend'),
                  parent=parent_pin, runtime=runtime_pin, inputs=inputs, overrides=['p118z_runtime'],
                  added=new_names, exports=EXPORTS, finiteGroups={'p127lb_controls': 20,
                      'p118z_controls': 8, 'p126dp_controls': 16, 'p126dp_app_controls': 5},
                  transform=dict(old=old, new=repair, appended=suffix),
                  inverseByteIdentity=True, allOtherOriginalBytesUnchanged=True,
                  originalVerifierAndControlsUnchanged=True,
                  scope='One audited transport-safe import added after ordinary verification; '
                        'no runtime/ABI/default changes, no raw capability edit, and no concat admission. '
                        'Composition alone is not checking, target execution, or native qualification.')
    for entry in inputs:
        require(pin(entry['file']) == entry, 'Input changed during composition: ' + entry['file'])
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(source=report['source'], manifest=str(out / 'manifest.json'), exports=EXPORTS)))


if __name__ == '__main__':
    main()
