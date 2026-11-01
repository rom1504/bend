#!/usr/bin/env python3
"""Argument/provenance refusal controls; never execute a Bend compiler."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    if args.report.exists():
        raise ValueError('Fresh report required')
    root = Path(__file__).resolve().parents[3]
    engine = shutil.which('node')
    assert engine
    rows = []

    def run(method, arguments, success, diagnostic=None):
        result = subprocess.run([engine, str(root / method), *arguments],
                                cwd=root, text=True, capture_output=True, timeout=10)
        assert (result.returncode == 0) == success, result.stderr
        if diagnostic:
            assert diagnostic in result.stdout + result.stderr, result.stderr
        rows.append(dict(method=method, arguments=arguments,
                         exitCode=result.returncode, passed=True))

    verify = 'selfhost/tools/verify.mjs'
    template = 'selfhost/tools/build/native-template.mjs'
    for method in [verify, template]:
        run(method, ['--help'], True, 'Usage:')
        run(method, [], False, 'Missing --')
        run(method, ['--unknown', 'value'], False, 'Usage:')
    with tempfile.TemporaryDirectory(prefix='bend-entrypoint-controls-') as scratch:
        tmp = Path(scratch)
        run(verify, ['--out', str(tmp), '--upstream', str(root),
                     '--engine', engine], False, 'fresh output directory')
        authority = tmp / 'incomplete.json'
        authority.write_text('{"complete": false}\n')
        output = tmp / 'output'
        run(template, ['--authority', str(authority), '--runtime', str(tmp/'absent.c'),
                       '--out', str(output)], False, 'Incomplete producer authority')
        assert not output.exists()
    methods = [root / verify, root / template, Path(__file__).resolve()]
    report = dict(kind='bend-maintained-entrypoint-controls', complete=True,
                  compilerExecuted=False, rows=rows,
                  methods=[dict(file=str(p.relative_to(root)), bytes=p.stat().st_size,
                                sha256=hashlib.sha256(p.read_bytes()).hexdigest())
                           for p in methods])
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(complete=True, controls=len(rows), compilerExecuted=False,
                         report=str(args.report))))


if __name__ == '__main__':
    main()
