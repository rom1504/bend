#!/usr/bin/env python3
"""Select the frozen full45 corpus, then reuse the unchanged native supervisor."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

ADAPTER = Path(__file__).resolve().parent
ROOT = ADAPTER.parents[4]
HERE = ROOT / "selfhost/tools/performance/phase111/coverage/full45"


def main():
    selector = argparse.ArgumentParser(add_help=False)
    selector.add_argument('--partition', choices=['all45', 'representatives6', 'remaining39'])
    args, forwarded = selector.parse_known_args()
    manifest = json.loads((HERE / 'manifest.json').read_text())
    runner_path = HERE.parent / 'native-run.py'
    binding = manifest['supervisor']
    data = runner_path.read_bytes()
    if (str(runner_path.resolve()) != binding['file'] or len(data) != binding['bytes'] or
            hashlib.sha256(data).hexdigest() != binding['sha256']):
        raise ValueError('Native supervisor differs from frozen full45 binding')
    if args.partition:
        if any(x == '--names' or x == '--suite' or x.startswith(('--names=', '--suite=')) for x in forwarded):
            raise ValueError('--partition cannot be combined with --names or --suite')
        forwarded += ['--names', *manifest['partitions'][args.partition]]
    for option, value in [('--seconds', '120'), ('--build-seconds', '10')]:
        if not any(x == option or x.startswith(option + '=') for x in forwarded):
            forwarded += [option, value]
    # Authenticate the original corpus-bound supervisor before selecting the explicit aligned derivative.
    derivation = json.loads((ADAPTER / 'derivation01.json').read_text())
    derived = [r for r in derivation['adapters'] if Path(r['derived']['file']).name == 'coverage.py']
    if len(derived) != 1 or derived[0]['original'] != binding:
        raise ValueError('Aligned coverage derivative is not bound to the frozen supervisor')
    runner_path = ADAPTER / 'coverage.py'
    data = runner_path.read_bytes()
    if (len(data) != derived[0]['derived']['bytes'] or hashlib.sha256(data).hexdigest() != derived[0]['derived']['sha256']):
        raise ValueError('Aligned supervisor differs from derivation receipt')
    spec = importlib.util.spec_from_file_location('phase125_aligned_native_supervisor', runner_path)
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    # Original full45 data/oracles and supervision remain; the separately pinned
    # derivative selects Phase123 aligned builds for every native product.
    runner.HERE = HERE
    sys.argv = [str(Path(__file__).resolve()), *forwarded]
    return runner.main()


if __name__ == '__main__':
    raise SystemExit(main())
