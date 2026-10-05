#!/usr/bin/env python3
"""Pinned publication adapter; parent tools perform all freezing and verification.

Runs no compiler or generated program. Root schedules compression separately
from timing. Parent receipts retain their historical kind and labels unchanged.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
METHODS = {
    'candidate': ('phase52/freeze-candidate.py', 'ae18fd864032239c20cdffff7081bbd6bf6dff087f30abb37f5897d8b718b41e'),
    'verify': ('phase52/verify-portable.py', 'a7a554df8c2b95c6421a350388c3dc1719382b807be72e87a9f3ea9825448877'),
    'archive': ('phase42/validation/archive-campaign-v1.py', '4d393286e9a3e26892ff52bb242f53f1ea3211a82caeee3ef79a52b4597cfaa6'),
}
DEPENDENCIES = {
    'programs/run.py': '825f16ea085b2000595371a0b69bfc7c76b0630ae11079ae02480d7dac746a2e',
    'programs/prepare.py': '0ecb4e405f377965e62cfba407785370fa7ee83cb81b6e0c24e1d5384b0faa4d',
    'programs/support.py': '36e000b43f92809e2de0bcdb462e6e42005fad7341f6ec2122734311073d1cef',
    'phase44/products/freeze-candidate-v1.py': 'ff3954c285b83db99698b29ec83ae745ba3b749b6dd537ea7bb2e02ac40b360b',
}


def identity(file):
    file = Path(file).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), bytes=file.stat().st_size, sha256=h.hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    p.add_argument('mode', choices=METHODS)
    p.add_argument('--phase53-receipt', type=Path, required=True)
    argv = sys.argv[1:]
    assert '--' in argv, 'Separate the unchanged parent CLI with --'
    split = argv.index('--')
    a = p.parse_args(argv[:split])
    args = argv[split+1:]
    assert args, 'Pass the unchanged parent CLI after --'
    receipt = a.phase53_receipt.resolve()
    assert not receipt.exists(), 'Fresh Phase53 receipt required'
    def option(key):
        assert args.count(key) == 1, 'Use one explicit '+key+' VALUE'
        return Path(args[args.index(key)+1]).resolve()
    output = option('--out')
    assert not output.exists(), 'Fresh parent output required'
    assert receipt != output and not receipt.is_relative_to(output)
    if a.mode == 'archive':
        assert not receipt.is_relative_to(option('--raw')), 'Closed raw root cannot receive adapter output'
    relative, expected = METHODS[a.mode]
    method = identity(HERE.parent / relative)
    assert method['sha256'] == expected
    inputs = [identity(__file__), method, identity(sys.executable)]
    if a.mode != 'archive':
        for relative, expected in DEPENDENCIES.items():
            entry = identity(HERE.parent / relative)
            assert entry['sha256'] == expected
            inputs.append(entry)
    command = [sys.executable, '-B', method['file'], *args]
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    report = dict(kind='phase53-publication-adapter', complete=False, dataOnly=True,
        mode=a.mode, displayLabel='Phase53 selected publication' if a.mode == 'candidate' else 'Phase53 '+a.mode,
        producer=inputs[0], parentMethod=method, command=command, returncode=result.returncode,
        stdout=result.stdout, stderr=result.stderr, inputs=inputs,
        scope='Unchanged pinned parent algorithm and artifacts. Historical parent labels are provenance; this Phase53 wrapper adds context only. No compiler or target execution, semantic waiver, qualification or promotion.')
    if result.returncode == 0:
        artifact = output / ('manifest.json' if a.mode == 'candidate' else 'archive.json') if a.mode != 'verify' else output
        data = json.loads(artifact.read_text())
        assert data['complete'] is True
        if a.mode == 'candidate':
            assert len(data['cases']) == 45 and data['preservation']['reopenedVerified'] and data['preservation']['byteExact']
        elif a.mode == 'verify':
            assert data['passGate'] and data['rolePointMappings'] == 135 and data['inputsUnchanged']
        else:
            assert data['reopenedVerified'] and data['inputStabilityVerified']
        report.update(complete=True, artifact=identity(artifact))
    for item in inputs:
        assert identity(item['file']) == item
    report['inputsUnchanged'] = True
    receipt.parent.mkdir(parents=True, exist_ok=True)
    with receipt.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=report['complete'], receipt=identity(receipt))))
    return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
