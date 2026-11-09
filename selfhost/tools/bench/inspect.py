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


def analyze_source(path, target):
    source = path.read_text()
    result = dict(source=pin(path), lines=len(source.splitlines()), bytes=len(source.encode()),
                  scope='Lexical occurrences include declarations/comments and are not parsed calls or costs.')
    if target == 'x86':
        symbols, instructions, calls = [], [], []
        label = re.compile(r'^([A-Za-z_.$][A-Za-z_0-9.$]*|[0-9]+):\s*')
        for line in source.splitlines():
            # This is the emitted GNU assembler syntax, not disassembly or a
            # general assembler parser. Directives do not count as instructions.
            text = line.split('#', 1)[0].strip()
            while (match := label.match(text)) is not None:
                symbols.append(match[1])
                text = text[match.end():]
            match = re.match(r'^([A-Za-z][A-Za-z0-9.]*)\b(?:\s+(.*))?$', text)
            if match:
                mnemonic, operands = match[1].lower(), (match[2] or '').strip()
                instructions.append(mnemonic)
                if mnemonic in ('call', 'callq'):
                    calls.append(operands)
        result.update(lexicalCalls=dict(sorted(Counter(calls).items())),
                      assemblySymbols=len(symbols), assemblyInstructions=len(instructions),
                      assemblyMnemonics=dict(sorted(Counter(instructions).items())),
                      scope='Line-oriented GNU assembly lexical counts; labels include local/data labels, '
                            'directives and hash comments are excluded, call operands may be indirect. '
                            'These are not parsed instructions, dynamic events or costs.')
    else:
        calls = (re.findall(r'\b([A-Za-z_][A-Za-z_0-9]*)\s*\(', source) if target == 'c'
                 else re.findall(r'\bcall\s+\$([^\s(]+)', source))
        result.update(lexicalCalls=dict(sorted(Counter(calls).items())),
                      qbeFunctions=len(re.findall(r'(?m)^(?:export )?function\b', source)) if target == 'qbe' else None)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', choices=('c', 'qbe', 'x86'), required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--binary', type=Path)
    parser.add_argument('--compare-source', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    report = dict(schema='bend-generated-native-inspection-v1', complete=False, target=args.target,
                  inputs=[pin(__file__)], sources=[analyze_source(args.source, args.target)], machine=[])
    try:
        if args.compare_source:
            report['sources'].append(analyze_source(args.compare_source, args.target))
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
