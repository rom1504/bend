#!/usr/bin/env python3
"""Extract the experimental native Phase168-imports compiler; no targets run.

The existing extractor authenticates the qualified maintained parent, preserves
protected declarations, records the two experimental overrides, and follows the
ordinary main dependency closure. All compilation semantics remain Bend code.
"""
import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MODULES = [
    'phase163/direct-first', 'phase163/direct-optimize',
    'phase164/hybrid-adapter', 'phase164/hybrid-lower',
    *['phase167/demand-' + part for part in
      ['model', 'lower', 'verify', 'emit', 'controls', 'live', 'plain', 'observers']],
    'phase168/early-scalars', 'phase168/early-scalars-selective',
    'phase168/selective-controls', 'phase168/adapter-view', 'phase168/adapter-imports',
    'phase169/streaming', 'phase169/native-entry', 'phase169/publication',
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--api', action='store_true',
                        help='Extract hosted streaming/legacy comparison exports instead of main')
    args = parser.parse_args()
    command = [sys.executable, '-B', 'experiments/phase163/tools/prepare.py']
    for module in MODULES:
        command += ['--module', 'selfhost/tests/' + module + '.bend']
    exports = ['p169s_plan', 'p169s_collect_plan', 'p169s_controls', 'p168j_plan',
               'p86_prepare', 'p88_cache_prepare', 'p86_plan',
               'p134e_plan', 'p134e_begin', 'p134e_next',
               'p168tc_controls', 'p167e_controls', 'p167ob_controls',
               'p128bs_controls', 'p128br_call_controls', 'p128bl_controls'] if args.api else ['main']
    for name in exports:
        command += ['--export', name]
    command += ['--allow-overrides', '--out', str(args.out)]
    return subprocess.call(command, cwd=ROOT)


if __name__ == '__main__':
    raise SystemExit(main())
