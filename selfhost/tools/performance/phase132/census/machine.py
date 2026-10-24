#!/usr/bin/env python3
"""ELF symbol-size attribution, independently bounded to the census inventory."""
import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path
import struct
from census import category, decode, pin


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--census', required=True)
    p.add_argument('--out', required=True)
    args = p.parse_args()
    census = json.loads(Path(args.census).read_text())
    binary = census['inputs']['binary']
    assert pin(binary['file']) == binary
    with open(binary['file'], 'rb') as f:
        head = struct.unpack('<16sHHIQQQIHHHHHH', f.read(64))
        assert head[0][:6] == b'\x7fELF\x02\x01'
        f.seek(head[6])
        sections = [struct.unpack('<IIQQQQIIQQ', f.read(64)) for _ in range(head[12])]
        symbols = next(x for x in sections if x[1] == 2)
        assert symbols[9] == 24
        strings = sections[symbols[6]]
        f.seek(strings[4])
        names = f.read(strings[5])
        f.seek(symbols[4])
        table = f.read(symbols[5])
    groups = defaultdict(Counter)
    other = Counter()
    largest = []
    zero = 0
    seen = set()
    for offset in range(0, len(table), 24):
        nameoff, info, visibility, section, address, size = struct.unpack_from('<IBBHQQ', table, offset)
        if info & 15 != 2 or not section:
            continue
        name = names[nameoff:].split(b'\0', 1)[0].decode()
        if name == 'main' or any(name.startswith(prefix + '_FID_') for prefix in ['p111', 'p112w', 'p113d', 'p114r']):
            assert name not in seen
            seen.add(name)
            zero += not size
            record = {'symbol': name, 'decoded': decode(name), 'blocks': 0, 'callsByTarget': {}}
            group = category(record)
            groups[group].update({'functions': 1, 'symbolCodeBytes': size})
            largest.append({'symbol': name, 'decoded': record['decoded'], 'category': group,
                            'address': address, 'symbolCodeBytes': size})
        else:
            other.update({'functions': 1, 'symbolCodeBytes': size})
    assert len(seen) == census['functions']
    for name, group in groups.items():
        assert group['functions'] == census['disjointFunctionCategories'][name]['functions']
        group['qbeTextBytes'] = census['disjointFunctionCategories'][name]['bytes']
        group['qbeInstructions'] = census['disjointFunctionCategories'][name]['instructions']
    textbytes = next(s['bytes'] for s in census['elf']['sections'] if s['name'] == '.text')
    qbytes = sum(x['symbolCodeBytes'] for x in groups.values())
    out = Path(args.out)
    assert not out.exists()
    out.write_text(json.dumps({'kind': 'phase132-elf-symbol-size-census-v1', 'complete': True,
                              'inputs': [pin(args.census), binary, pin(__file__), pin(Path(__file__).with_name('census.py'))],
                              'qbeFunctions': len(seen), 'zeroSizeQbeFunctions': zero,
                              'qbeFunctionSymbolBytes': qbytes, 'otherDefinedFunctions': other,
                              'textSectionBytes': textbytes,
                              'unattributedTextBytesIncludingPadding': textbytes - qbytes - other['symbolCodeBytes'],
                              'categories': groups, 'largestFunctions': sorted(largest, key=lambda x: x['symbolCodeBytes'], reverse=True)[:30],
                              'scope': 'Exact ELF64 STT_FUNC sizes for all QBE function names. Function padding and unnamed text remain separate. This measures static machine code, not runtime cost or inlined source provenance.'}, indent=2) + '\n')
    print(json.dumps({'qbeFunctionSymbolBytes': qbytes, 'otherDefinedFunctions': other, 'zeroSizeQbeFunctions': zero, 'categories': groups}, indent=2))


if __name__ == '__main__':
    main()
