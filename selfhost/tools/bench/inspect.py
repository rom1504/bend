#!/usr/bin/env python3
"""Native generated-source lexical counts plus exact ELF disassembly; never execute it."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import shutil
import subprocess

from bench import pin, require, save


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', choices=('c', 'qbe'), required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--binary', type=Path)
    parser.add_argument('--compare-source', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    def analyze(path):
        source = path.read_text()
        # Explicitly lexical: do not mistake these for a C/QBE parser or dynamic events.
        calls = re.findall(r'\b([A-Za-z_][A-Za-z_0-9]*)\s*\(', source) if args.target == 'c' else re.findall(r'\bcall\s+\$([^\s(]+)', source)
        return dict(source=pin(path), lines=len(source.splitlines()), bytes=len(source.encode()),
                    lexicalCalls=dict(sorted(Counter(calls).items())),
                    qbeFunctions=len(re.findall(r'(?m)^(?:export )?function\b', source)) if args.target == 'qbe' else None,
                    scope='Lexical occurrences include declarations/comments and are not parsed calls or costs.')
    report = dict(schema='bend-generated-native-inspection-v1', complete=False, target=args.target,
                  inputs=[pin(__file__)], sources=[analyze(args.source)], machine=[])
    try:
        if args.compare_source:
            report['sources'].append(analyze(args.compare_source))
        if args.binary:
            report['inputs'].append(pin(args.binary))
            for name, flags in [('objdump', ['-d', '-C', '-w']), ('readelf', ['-W', '-S', '-s']), ('size', ['-A'])]:
                tool = shutil.which(name)
                require(tool, 'Missing ELF analysis tool: ' + name)
                report['inputs'].append(pin(tool))
                command = [tool, *flags, str(args.binary)]
                with (args.out / (name + '.txt')).open('xb') as stdout, (args.out / (name + '.stderr')).open('xb') as stderr:
                    result = subprocess.run(command, stdout=stdout, stderr=stderr, timeout=30)
                require(result.returncode == 0, name + ' failed')
                report['machine'].append(dict(command=command, output=pin(args.out / (name + '.txt'))))
        for entry in report['inputs'] + [row['source'] for row in report['sources']]:
            require(pin(entry['file']) == entry, 'Inspection input changed')
        report['complete'] = True
    finally:
        save(args.out / 'report.json', report, fresh=True)
    print(json.dumps(dict(complete=True, sources=len(report['sources']))))


if __name__ == '__main__':
    main()
