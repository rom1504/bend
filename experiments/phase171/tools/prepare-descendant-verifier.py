#!/usr/bin/env python3
"""Prepare the real verifier's complete diagnostic values, without execution."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'selfhost/build/phase167/verifier-source03/compiler.bend'
SHA = 'ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3'
OLD = b'def main() -> U32:\n  p167w_round(256,0)\n#| 768\n'
EXPECTED = ['', 'main: segment return must be U64', 'invalid/duplicate segment name: main']

def pin(path):
    data = path.read_bytes()
    return {'file': str(path.relative_to(ROOT)), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    source = SOURCE.read_bytes()
    assert hashlib.sha256(source).hexdigest() == SHA
    assert source.endswith(OLD) and source.count(OLD) == 1
    anchors = [b'"segment return must be U64"', b'"invalid/duplicate segment name: " ++ name',
               b'name ++ ": " ++ error']
    assert all(x in source for x in anchors)
    out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase171') and not out.exists()
    out.mkdir(parents=True)
    calls = ['p111_verify_program(P111Program{p167w_segments(31,7,' + str(bad) + '),[],[0],[],[],True{}})' for bad in range(3)]
    bodies = {'actual': 'def main() -> List<&2,String>:\n  [' + ',\n   '.join(calls) + ']\n',
              'expected': 'def main() -> List<&2,String>:\n  ' + json.dumps(EXPECTED) + '\n'}
    for name, body in bodies.items():
        (out / (name + '.bend')).write_bytes(source[:-len(OLD)] + body.encode())
    (out / 'expected-values.json').write_text(json.dumps(EXPECTED, indent=2) + '\n')
    report = {'kind': 'phase171-full-verifier-diagnostics', 'complete': True, 'targetsRun': False,
        'inputs': [pin(Path(__file__).resolve()), pin(SOURCE)], 'onlyMainChanged': True,
        'unchangedPrefix': {'bytes': len(source)-len(OLD), 'sha256': hashlib.sha256(source[:-len(OLD)]).hexdigest()},
        'actual': pin(out/'actual.bend'), 'expected': pin(out/'expected.bend'),
        'literalOracle': pin(out/'expected-values.json'), 'sourceAnchors': [x.decode() for x in anchors],
        'oracleDerivation': ['Valid 32-segment arithmetic/branch program: empty diagnostic.',
            'Only main returns missing local: unchanged segment verifier error prefixed with main.',
            'All headers named main: unchanged header scanner rejects the second header before body verification.'],
        'scope': 'All actual final verifier/index/ownership helper definitions preserved exactly. Valid Bend programs inspect IR data and return full strings; no malformed native program or runtime failure probe. Expected main is literal and does not call the verifier. Native stdout comparison is still required.'}
    (out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({'actual': report['actual'], 'expected': report['expected']}))

if __name__ == '__main__': main()
