#!/usr/bin/env python3
"""Root-only execution of one pinned prepared command through the existing guard."""
import argparse
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
PHASE = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('promotion_guard', PHASE / 'guarded.py')
G = importlib.util.module_from_spec(spec); spec.loader.exec_module(G)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--prepared', type=Path, required=True)
    p.add_argument('--guard', type=Path, required=True)
    args = p.parse_args()
    prepared = G.read(args.prepared); prepared_pin = G.pin(args.prepared)
    assert prepared['complete'] and prepared['targetsRun'] is False
    assert not args.guard.exists() and not args.guard.parent.joinpath(args.guard.name + '-job.json').exists()
    for item in prepared['inputs']: G.R.verify(item)
    limits = prepared['targetGuard']
    assert limits == dict(seconds=180, rssMiB=2048, availableMiB=4096, cpu=3)
    G.guarded(args.guard.resolve(), prepared['command'], seconds=limits['seconds'], cpu=str(limits['cpu']))
    for item in [prepared_pin, *prepared['inputs']]: G.R.verify(item)


if __name__ == '__main__': main()
