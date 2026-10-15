#!/usr/bin/env python3
"""Data-only scratch-root controls for the Phase98 evidence archive method."""
import argparse
import ast
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import tempfile
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def refused(action, message):
    try: action()
    except AssertionError as error: assert message in str(error), str(error)
    else: raise AssertionError('Expected refusal: ' + message)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True); args = parser.parse_args()
    assert not args.out.exists(); source = HERE/'evidence.py'; ast.parse(source.read_text())
    with tempfile.TemporaryDirectory(prefix='phase98-evidence-controls-') as scratch:
        root = Path(scratch); method = root/'selfhost/tools/performance/phase98/evidence.py'
        method.parent.mkdir(parents=True); shutil.copyfile(source, method)
        raw = root/'selfhost/build/phase98'; (raw/'empty').mkdir(parents=True)
        a, b = raw/'a.bin', raw/'b.bin'; a.write_bytes(bytes(range(256))*16); b.write_bytes(a.read_bytes())
        os.chmod(a, 0o644); os.chmod(b, 0o755)
        spec = importlib.util.spec_from_file_location('phase98_evidence_control', method)
        module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
        module.PART_BYTES = 128  # Exercise split boundaries without large fixtures.
        out = module.PACKAGES/'control01'; options = argparse.Namespace(frozen=True, out=out, root=['selfhost/build/phase98'], public_assets=[])
        original_usage = module.shutil.disk_usage
        try:
            module.shutil.disk_usage = lambda path: SimpleNamespace(free=module.RESERVE+7000)
            refused(lambda: module.seal(options), 'Need spool and split archive space')
            assert not out.exists()
        finally: module.shutil.disk_usage = original_usage
        capture = io.StringIO()
        with contextlib.redirect_stdout(capture):
            module.seal(options); receipt_path = out/'receipt.json'
            verify = argparse.Namespace(receipt=receipt_path, verify_only=True)
            restore = argparse.Namespace(receipt=receipt_path, verify_only=False)
            module.restore(verify); b.unlink(); module.restore(verify); assert not b.exists()
            module.restore(restore); assert b.read_bytes() == a.read_bytes() and b.stat().st_mode & 0o777 == 0o755
        manifest = json.loads((out/'manifest.json').read_text()); receipt = json.loads(receipt_path.read_text())
        assert len(manifest['blobs']) == 1 and len(receipt['parts']) > 1
        b.write_bytes(b'changed'); refused(lambda: module.restore(restore), 'Refusing changed existing evidence')
        b.write_bytes(a.read_bytes()); os.chmod(b, 0o644)
        refused(lambda: module.restore(verify), 'Refusing changed existing evidence')
        first = out/'evidence.zip.part001'; data = first.read_bytes(); first.write_bytes(bytes([data[0]^1])+data[1:])
        refused(lambda: module.restore(verify), 'Changed evidence')
        result = dict(kind='phase98-evidence-method-data-controls', complete=True, targetsRun=False,
            productionArchiveSealed=False, method=pin(source), controlMethod=pin(Path(__file__)),
            controls=['Python AST parse', 'Single-archive disk allowance refused before output creation',
                'Identical bytes stored once with distinct original modes', 'Forced128byte multipart ZIP reopen',
                'Read-only verification does not restore missing files', 'Missing-only restoration recovers bytes and executable mode',
                'Changed existing bytes refused', 'Changed existing mode refused', 'Corrupt archive part refused'],
            testArchiveParts=len(receipt['parts']), stdout=capture.getvalue(),
            scope='Temporary-root data controls with128byte part limit. Production64MiB split and final campaign seal remain separate.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, controls=len(result['controls']), report=pin(args.out))))


if __name__ == '__main__': main()
