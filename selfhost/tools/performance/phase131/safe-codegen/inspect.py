"""Inspect existing proxy QBE and machine code; never execute/build a target."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(identity):
    assert pin(identity['file']) == identity, identity['file']
    return Path(identity['file'])


def decode(symbol):
    if '_FID_' not in symbol:
        return symbol
    prefix, raw = symbol.split('_FID_', 1)
    try:
        return prefix + ':' + ''.join(chr(int(x)) for x in raw.split('_') if x)
    except ValueError:
        return symbol


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case', nargs=3, action='append', required=True,
                        metavar=('LABEL', 'EMISSION_REPORT', 'BUILD_REPORT'))
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists()
    out.mkdir(parents=True)
    inputs, rows = [pin(__file__)], []
    for label, emission, build in args.case:
        assert re.fullmatch('[A-Za-z0-9_-]+', label)
        er, br = json.loads(Path(emission).read_text()), json.loads(Path(build).read_text())
        assert er['complete'] and br['complete'] and br['outputExact']
        qbe, binary = verify(er['product']), verify(br['binary'])
        inputs.extend([pin(emission), pin(build), pin(qbe), pin(binary)])
        functions = re.findall(r'(?m)^((?:export )?function[^\n]*\$([^ (]+)[^\n]*\{\n[\s\S]*?^\})', qbe.read_text())
        # Keep usage owners and their SCC workers; the dependency closure lets
        # a tiny forwarding entry point reveal the actual iterative worker.
        selected = {symbol for body, symbol in functions if '$direct.p131u_' in decode(symbol)}
        for body, symbol in functions:
            if symbol in selected:
                selected.update(c for c in re.findall(r'call \$([^ (]+)', body)
                                if '$p126scc.' in decode(c))
        for body, symbol in functions:
            if symbol not in selected:
                continue
            name = decode(symbol)
            stem = label + '-' + re.sub('[^A-Za-z0-9_-]', '_', name)
            qp = out / (stem + '.ssa')
            qp.write_text(body + '\n')
            asm = subprocess.check_output(['objdump', '-d', '--disassemble=' + symbol, str(binary)], text=True)
            ap = out / (stem + '.asm')
            ap.write_text(asm)
            instructions = [line for line in asm.splitlines()
                            if re.match(r'^\s*[0-9a-f]+:\s+(?:[0-9a-f]{2}\s+)+[a-zA-Z]', line)]
            calls = Counter(decode(c) for c in re.findall(r'call \$([^ (]+)', body))
            rows.append(dict(case=label, name=name, qbeLines=len(body.splitlines()),
                             machineInstructions=len(instructions), calls=dict(sorted(calls.items())),
                             qbe=pin(qp), assembly=pin(ap)))
    for identity in inputs:
        verify(identity)
    report = dict(complete=True, targetsRun=False, inputs=inputs, rows=rows,
                  scope='Static callsites and instruction counts, including cold error branches. These are not dynamic operation counts or runtime attribution.')
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(report=pin(out / 'report.json'), functions=len(rows))))


if __name__ == '__main__':
    main()
