#!/usr/bin/env python3
"""Offline exact ELF64 section comparison for the Phase144 atomic control."""
import argparse
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[5]


def elf(path):
    data = path.read_bytes()
    if data[:6] != b'\x7fELF\x02\x01':
        raise ValueError('expected little-endian ELF64')
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', data)
    offset, size, count, names_index = h[6], h[11], h[12], h[13]
    if size != 64 or not (0 < names_index < count):
        raise ValueError('unsupported section table')
    sections = [struct.unpack_from('<IIQQQQIIQQ', data, offset + i * size)
                for i in range(count)]
    names = sections[names_index]
    names = data[names[4]:names[4] + names[5]]
    rows = {}
    for s in sections:
        name = names[s[0]:].split(b'\0', 1)[0].decode()
        payload = data[s[4]:s[4] + s[5]] if s[1] != 8 else b''
        rows[name] = (s, payload)
    return data, rows


def pin(path, data):
    return {'file': str(path.relative_to(ROOT)), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}


def compare(a, b):
    x, xs = elf(a)
    y, ys = elf(b)
    if xs.keys() != ys.keys():
        raise ValueError('section name set differs')
    sections = []
    for name in xs:
        sx, dx = xs[name]
        sy, dy = ys[name]
        differences = [i for i in range(min(len(dx), len(dy))) if dx[i] != dy[i]]
        row = {'name': name, 'metadataEqual': sx == sy,
               'contentsEqual': dx == dy, 'allocated': bool(sx[2] & 2),
               'executable': bool(sx[2] & 4), 'bytes': sx[5],
               'originalSha256': hashlib.sha256(dx).hexdigest(),
               'controlSha256': hashlib.sha256(dy).hexdigest()}
        if dx != dy:
            row['differentBytes'] = len(differences) + abs(len(dx) - len(dy))
            row['firstDifferences'] = [
                {'sectionOffset': i, 'original': dx[max(0, i-8):i+12].hex(),
                 'control': dy[max(0, i-8):i+12].hex()}
                for i in differences[:8]]
        sections.append(row)
    return {
        'original': pin(a, x), 'control': pin(b, y),
        'differentFileBytes': sum(a != b for a, b in zip(x, y)) + abs(len(x)-len(y)),
        'sectionMetadataEqual': all(s['metadataEqual'] for s in sections),
        'executableSectionsEqual': all(s['contentsEqual'] for s in sections if s['executable']),
        'allocatedSectionsExceptBuildIdEqual': all(s['contentsEqual'] for s in sections
            if s['allocated'] and s['name'] != '.note.gnu.build-id'),
        'sections': sections,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True, help='fresh JSON file')
    args = ap.parse_args()
    pairs = [
        ('object', ROOT / 'selfhost/build/phase128/runtime-borrow01/runtime.o',
         ROOT / 'selfhost/build/phase144/serial-rfc01/atomic-control.o'),
        ('executable', ROOT / 'selfhost/build/phase111/p143-integrated-n2/program',
         ROOT / 'selfhost/build/phase144/serial-rfc01/atomic-control-compiler'),
    ]
    report = {'kind': 'phase144-atomic-control-elf-audit-v01',
              'method': pin(Path(__file__), Path(__file__).read_bytes()),
              'pairs': {label: compare(a, b) for label, a, b in pairs},
              'scope': 'Offline metadata and bytes only; no target execution.'}
    with args.out.open('x') as f:
        json.dump(report, f, indent=2)
        f.write('\n')
    print(json.dumps({name: {k: row[k] for k in (
        'differentFileBytes', 'sectionMetadataEqual', 'executableSectionsEqual',
        'allocatedSectionsExceptBuildIdEqual')} for name, row in report['pairs'].items()}))


if __name__ == '__main__':
    main()
