#!/usr/bin/env python3
"""Guarded native Bend compiler pilot: one source importing Base, three IO effects.

All parsing/checking/compilation runs in the Bend native image. Python only
authenticates transport, supervises the process, and publishes successful C.
"""
import argparse
import datetime
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from native_support import ROOT, DEFAULT_CACHE, authenticate, native_args, pin, require


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('-o', '--output', type=Path, required=True)
    parser.add_argument('--image', type=Path, required=True, help='Checked native image with .build.json')
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--live', action='store_true', help='Check/prepare Base in this process')
    modes.add_argument('--cache-receipt', type=Path, default=DEFAULT_CACHE)
    parser.add_argument('--calls', type=int, choices=(1, 5), default=1)
    parser.add_argument('--seconds', type=int, default=60)
    args = parser.parse_args()
    log_root = ROOT / 'selfhost/build/native/requests'
    log_root.mkdir(parents=True, exist_ok=True)
    directory = Path(tempfile.mkdtemp(prefix=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-'), dir=log_root))
    report = dict(complete=False, method=pin(__file__), log=str(directory))
    status = 1
    try:
        require(0 < args.seconds <= 600, 'Seconds must be 1..600')
        source, output = args.source.resolve(), args.output.resolve()
        require(not output.exists(), 'Output already exists: ' + str(output))
        report['source'] = pin(source)
        require(report['source']['bytes'] <= 16 * 1024**2, 'Source exceeds 16 MiB')
        auth = authenticate(args.image, None if args.live else args.cache_receipt)
        report['authentication'] = auth
        command = native_args(auth, source, directory / 'output', args.calls)
        report['command'] = command
        guard = ROOT / 'selfhost/tools/performance/phase86/guard.py'
        result = subprocess.run([sys.executable, str(guard), '--out', str(directory / 'guard'),
                                 '--seconds', str(args.seconds), '--cpu', '3', '--', *command],
                                capture_output=True, text=True)
        (directory / 'launcher.stdout').write_text(result.stdout)
        (directory / 'launcher.stderr').write_text(result.stderr)
        stderr = directory / 'guard/stderr.log'
        if stderr.exists():
            sys.stderr.write(stderr.read_text())
        require(result.returncode == 0, 'Native request/guard failed; see ' + str(directory))
        require(pin(source) == report['source'], 'Source changed during request')
        require(authenticate(args.image, None if args.live else args.cache_receipt) == auth,
                'Compiler inputs changed during request')
        outputs = [pin(directory / f'output.{i}.c') for i in range(1, args.calls + 1)]
        require(len({p['sha256'] for p in outputs}) == 1, 'Repeated requests produced different C')
        report['outputs'] = outputs
        output.parent.mkdir(parents=True, exist_ok=True)
        # A failed copy (including ENOSPC) must not leave a partial public C file.
        with tempfile.NamedTemporaryFile(prefix='.' + output.name + '.', dir=output.parent) as dest:
            with Path(outputs[-1]['file']).open('rb') as src:
                shutil.copyfileobj(src, dest)
            dest.flush()
            require(pin(dest.name)['sha256'] == outputs[-1]['sha256'], 'Output copy mismatch')
            os.link(dest.name, output)  # Atomic publication; refuses an existing path.
        report.update(complete=True, output=pin(output))
        status = 0
    except (OSError, ValueError, KeyError, TypeError) as error:
        report['error'] = str(error)
        print('native compiler: ' + str(error), file=sys.stderr)
    finally:
        (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print('Native request evidence: ' + str(directory), file=sys.stderr)
    return status


if __name__ == '__main__':
    sys.exit(main())
