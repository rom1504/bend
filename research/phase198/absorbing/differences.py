"""Extract the emitted function-level causal witness without executing code."""
from argparse import ArgumentParser
from difflib import unified_diff
from hashlib import sha256
import json
from pathlib import Path
import re


def function_bodies(source):
    functions = {}
    start = None
    rows = []
    for line in source.splitlines():
        if start is None:
            match = re.fullmatch(r'\.type (\S+), @function', line)
            if match:
                start = match.group(1)
                rows = [line]
        else:
            rows.append(line)
            if line.startswith('.size ' + start + ','):
                assert start not in functions
                functions[start] = rows
                start = None
    assert start is None and functions
    return functions


def artifact(pin):
    data = Path(pin['file']).read_bytes()
    assert len(data) == pin['bytes'] and sha256(data).hexdigest() == pin['sha256']
    return data.decode()


def main(report, out):
    receipts = json.loads(report.read_bytes())
    assert receipts['complete']
    result = {}
    for row in receipts['cases']:
        case = row['id']
        if 'refusal' in row:
            result[case] = row['refusal']
            continue
        source = {k: artifact(r['assembly']) for k, r in row['products'].items()}
        before, after = [function_bodies(source[k]) for k in ('base', 'candidate')]
        assert set(before) == set(after)
        changed = [k for k in before if before[k] != after[k]]
        output = []
        for symbol in changed:
            pretty = re.sub(r'FID_((?:\d+_)+)', lambda m: 'FID_' + ''.join(
                chr(int(i)) for i in m[1].split('_') if i), symbol)
            a = [line.replace(symbol, pretty) for line in before[symbol]]
            b = [line.replace(symbol, pretty) for line in after[symbol]]
            output.append(dict(symbol=symbol, display=pretty, beforeLines=len(a), afterLines=len(b),
                               diff=list(unified_diff(a, b, 'base', 'candidate', n=4, lineterm=''))))
        same_assembly = source['base'] == source['candidate']
        assert (not changed) == same_assembly == (not row['changed'])
        result[case] = dict(functionsCompared=len(before), changed=output,
                            baselineObject=row['products']['base']['object']['sha256'],
                            candidateObject=row['products']['candidate']['object']['sha256'])
    out.write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    main(args.report, args.out)
