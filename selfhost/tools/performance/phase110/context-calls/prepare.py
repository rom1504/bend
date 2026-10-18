#!/usr/bin/env python3
"""Append the isolated context-call facade to a checked closed-call source; no targets."""
import argparse
import ast
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('source_auth', HERE.parent / 'runtime-ir/stored-field-admit-v2.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    original = a.source.read_text()
    if 'nx110rtn_check(ownership,arity,next) && ' not in original or 'nx110rt_calls_ok(workers,nx110rt_callees(workers)) &&' not in original:
        raise ValueError('namespace and closed-call source required')
    modules = [HERE / (name + '.bend') for name in ['model', 'lower', 'verify', 'c', 'controls']]
    addition = '\n\n'.join(path.read_text() for path in modules)
    if set(S.definitions(original)) & set(S.definitions(addition)):
        raise ValueError('facade declaration collision')
    out.mkdir()
    source = out / 'source.bend'
    source.write_text(original + '\n\n' + addition + '\n')
    exports = ['nx110ctx_prepare', 'nx110ctx_verify', 'nx110ctx_qbe', 'nx110ctx_c',
               'nx110ctx_json', 'nx110ctx_control_report', 'nx110ctx_control_bad',
               'nx110rt_verify', 'nx110rt_qbe', 'nx110rt_c', 'nx110rt_lower_library',
               'nx_json_function', 'nxe_lower_runtime_library', 'nxe_source', 'nxe_close']
    exports = [name for name in exports if name in S.definitions(source.read_text())]
    command = [str(ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun'),
               str(ROOT / 'selfhost/tools/stage0-library.mjs'), str(source), str(out / 'api.mjs'), *exports]
    record = dict(kind='phase110-context-call-source', complete=True, targetsRun=False,
        diagnosticOnly=True, inputs=[S.pin(a.source), S.pin(Path(__file__)), *[S.pin(path) for path in modules]],
        source=S.pin(source), exports=exports, command=command,
        requiredBeforeEmission='Run context-calls/admit.py for these exact source bytes and the assertion-only runtime capsule; then guarded stage0-library command and all context controls',
        scope='Separate diagnostic after frozen heldouts; neither original profile nor selected candidate changes')
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, source=str(source), manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
