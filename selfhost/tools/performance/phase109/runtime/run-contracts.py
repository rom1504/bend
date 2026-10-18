#!/usr/bin/env python3
"""Compile and check the small runtime ABI contracts; run under an outer guard."""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('phase109_contract_process',
    ROOT / 'selfhost/tools/performance/phase108/run.py')
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)
NEGATIVE = {
    'unknown-constructor': 'zero constructor arity mismatch',
    'wrong-arity': 'take requires binary constructor',
    'wrong-field-type': 'constructor tail type mismatch',
    'invalid-char': 'Char must be a Unicode scalar',
    'duplicate-field': 'invalid or repeated scratch transfer',
    'pending-take': 'untransferred scratch children',
    'pending-close': 'unreleased scratch children',
    'leaked-owner': 'unreleased heap ownership',
    'invalid-context': 'invalid context',
    'second-context': 'only one live context admitted',
    'impossible-branch': 'impossible source branch',
}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    runtime, out = a.runtime.resolve(), a.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase109') or out.exists():
        raise ValueError('output must be fresh under selfhost/build/phase109')
    if (runtime / 'abi.h').read_bytes() != (HERE / 'abi.h').read_bytes():
        raise ValueError('materialized runtime header is stale')
    out.mkdir(parents=True)
    gcc = Path(shutil.which('gcc'))
    report = dict(kind='phase109-runtime-contract-controls', version=1, complete=False,
                  inputs=[R.pin(x) for x in [Path(__file__).resolve(),
                    HERE / 'contract-controls.c', HERE / 'abi.h', runtime / 'runtime.c',
                    runtime / 'abi.h', runtime / 'manifest.json', gcc]], jobs=[])
    def save():
        R.save(out / 'report.json', report)
    def command(name, args, status, stdout, stderr):
        item = dict(name=name, command=list(map(str, args)))
        report['jobs'].append(item)
        save()
        begin = time.monotonic()
        with (out / (name + '.stdout')).open('xb') as so, (out / (name + '.stderr')).open('xb') as se:
            child = R.P.run(item['command'], cwd=ROOT, stdout=so, stderr=se, timeout=30)
        item.update(seconds=time.monotonic() - begin, status=child.returncode,
                    stdout=R.pin(out / (name + '.stdout')), stderr=R.pin(out / (name + '.stderr')))
        save()
        if child.returncode != status:
            raise RuntimeError(name + ': wrong exit code')
        if stdout is not None and (out / (name + '.stdout')).read_bytes() != stdout:
            raise RuntimeError(name + ': wrong stdout')
        if stderr is not None and (out / (name + '.stderr')).read_bytes() != stderr:
            raise RuntimeError(name + ': wrong stderr')
    save()
    try:
        for item in report['inputs']:
            R.N.verify(item)
        binary = out / 'contracts'
        command('build', [gcc, '-O2', '-std=gnu11', '-I', runtime,
            HERE / 'contract-controls.c', runtime / 'runtime.c', '-pthread', '-lm', '-o', binary],
            0, b'', None)
        report['binary'] = R.pin(binary)
        for name, message in NEGATIVE.items():
            command(name, [binary, name], 1, b'', ('bend: nx ABI: ' + message + '\n').encode())
        command('repeat-context', [binary, 'repeat-context'], 0, b'repeat-context:ok\n', b'')
        for name in ['rebuild-unique', 'rebuild-shared', 'rebuild-static', 'rebuild-keep-tail']:
            command(name, [binary, name], 0, b'rebuild:ok\n', b'')
        for item in report['inputs']:
            R.N.verify(item)
        report['complete'] = True
        save()
        print(json.dumps(dict(complete=True, negative=len(NEGATIVE), positive=5)))
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
