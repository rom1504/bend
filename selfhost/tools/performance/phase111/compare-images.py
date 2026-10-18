#!/usr/bin/env python3
"""Read-only comparison of authenticated Phase111 native generations.

Never executes, relinks, strips, or modifies an input. The only normalization
allowed is zeroing parsed GNU build-id descriptor bytes in comparison buffers.
Raw file equality, allocated-section equality and normalized PT_LOAD equality
remain distinct verdicts. All original files and earlier receipts are retained.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys
import time

ROOT = Path(__file__).resolve().parents[4]
EH_KEYS = ('ident', 'type', 'machine', 'version', 'entry', 'phoff', 'shoff',
           'flags', 'ehsize', 'phentsize', 'phnum', 'shentsize', 'shnum', 'shstrndx')
PH_KEYS = ('type', 'flags', 'offset', 'vaddr', 'paddr', 'filesz', 'memsz', 'align')
SH_KEYS = ('nameOffset', 'type', 'flags', 'address', 'offset', 'size',
           'link', 'info', 'align', 'entsize')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = Path(path).resolve(strict=True)
    digest = hashlib.sha256()
    size = 0
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
            size += len(block)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def authenticate(row):
    actual = pin(row['file'])
    require(all(actual[k] == row[k] for k in ('bytes', 'sha256')), 'Changed input: ' + row['file'])
    return actual


def exact_pair(left, right):
    left, right = pin(left), pin(right)
    equal = left['bytes'] == right['bytes']
    if equal:
        with open(left['file'], 'rb') as a, open(right['file'], 'rb') as b:
            while True:
                x, y = a.read(1024 * 1024), b.read(1024 * 1024)
                if x != y:
                    equal = False
                    break
                if not x:
                    break
    return dict(left=left, right=right, byteExact=equal)


class Elf:
    def __init__(self, path):
        self.data = Path(path).read_bytes()
        require(len(self.data) >= 64, 'Short ELF header')
        self.header = dict(zip(EH_KEYS, struct.unpack_from('<16sHHIQQQIHHHHHH', self.data)))
        h = self.header
        h['ident'] = h['ident'].hex()
        require(self.data[:7] == b'\x7fELF\x02\x01\x01' and
                h['type'] == 2 and h['machine'] == 62 and h['ehsize'] == 64,
                'Only ELF64 little-endian x86-64 ET_EXEC is admitted')
        require(h['phentsize'] == 56 and h['shentsize'] == 64 and
                0 < h['phnum'] < 65535 and 0 < h['shnum'] < 65535 and
                h['shstrndx'] < h['shnum'], 'Unsupported ELF table layout')
        self.phbytes = self.read(h['phoff'], h['phnum'] * 56)
        self.programs = [dict(zip(PH_KEYS, struct.unpack_from('<IIQQQQQQ', self.phbytes, i * 56)))
                         for i in range(h['phnum'])]
        shbytes = self.read(h['shoff'], h['shnum'] * 64)
        self.sections = [dict(zip(SH_KEYS, struct.unpack_from('<IIQQQQIIQQ', shbytes, i * 64)))
                         for i in range(h['shnum'])]
        names = self.section_data(self.sections[h['shstrndx']])
        for section in self.sections:
            section['name'] = self.string(names, section['nameOffset'])
            if section['type'] != 8:
                self.section_data(section)
        for program in self.programs:
            self.read(program['offset'], program['filesz'])
            if program['type'] == 1:
                require(program['filesz'] <= program['memsz'], 'PT_LOAD file exceeds memory size')
        section_notes = [note for s in self.sections if s['type'] == 7
                         for note in self.notes(s['offset'], s['size'])]
        program_notes = [note for p in self.programs if p['type'] == 4
                         for note in self.notes(p['offset'], p['filesz'])]
        build_ids = [n for n in section_notes if n['name'] == 'GNU' and n['type'] == 3]
        require(len(build_ids) == 1 and build_ids[0] in program_notes,
                'Expected one GNU build-id note present in both section and program metadata')
        self.build_id = build_ids[0]
        require(self.build_id['descriptorBytes'] > 0, 'Empty GNU build-id')

    def read(self, offset, size):
        require(0 <= offset <= len(self.data) and 0 <= size <= len(self.data) - offset,
                'ELF range outside file')
        return self.data[offset:offset + size]

    @staticmethod
    def string(table, offset):
        require(0 <= offset < len(table), 'ELF string offset outside table')
        end = table.find(b'\0', offset)
        require(end >= 0, 'Unterminated ELF string')
        return table[offset:end].decode('utf-8', errors='strict')

    def section_data(self, section):
        return b'' if section['type'] == 8 else self.read(section['offset'], section['size'])

    def notes(self, offset, size):
        result = []
        cursor, end = offset, offset + size
        while cursor < end:
            require(cursor + 12 <= end, 'Truncated ELF note')
            namesz, descsz, kind = struct.unpack('<III', self.read(cursor, 12))
            name_at = cursor + 12
            desc_at = name_at + ((namesz + 3) & ~3)
            next_at = desc_at + ((descsz + 3) & ~3)
            require(next_at <= end, 'ELF note exceeds container')
            name = self.read(name_at, namesz).rstrip(b'\0').decode('ascii', errors='strict')
            result.append(dict(offset=cursor, name=name, type=kind,
                               descriptorOffset=desc_at, descriptorBytes=descsz,
                               descriptorHex=self.read(desc_at, descsz).hex()))
            cursor = next_at
        return result

    def normalized(self, offset, size):
        data = bytearray(self.read(offset, size))
        note = self.build_id
        lo = max(offset, note['descriptorOffset'])
        hi = min(offset + size, note['descriptorOffset'] + note['descriptorBytes'])
        if lo < hi:
            data[lo - offset:hi - offset] = bytes(hi - lo)
        return bytes(data)

    def symbols(self):
        result = []
        for section in self.sections:
            if section['type'] != 2:
                continue
            require(section['entsize'] == 24 and section['size'] % 24 == 0 and
                    section['link'] < len(self.sections), 'Unsupported symbol table')
            strings = self.section_data(self.sections[section['link']])
            for offset in range(section['offset'], section['offset'] + section['size'], 24):
                name, info, other, index, value, size = struct.unpack('<IBBHQQ', self.read(offset, 24))
                result.append(dict(name=self.string(strings, name), info=info, other=other,
                                   sectionIndex=index, value=value, size=size))
        return result


def difference(left, right):
    return {key: dict(left=left.get(key), right=right.get(key))
            for key in left.keys() | right.keys() if left.get(key) != right.get(key)}


def compare_elf(left, right):
    a, b = Elf(left), Elf(right)
    note_layout = all(a.build_id[k] == b.build_id[k] for k in
                      ('offset', 'name', 'type', 'descriptorOffset', 'descriptorBytes'))
    require(note_layout, 'GNU build-id note layouts differ; normalization refused')
    headers_equal = a.data[:64] == b.data[:64]
    programs_equal = a.phbytes == b.phbytes
    loads = []
    for i in range(max(len(a.programs), len(b.programs))):
        x = a.programs[i] if i < len(a.programs) else None
        y = b.programs[i] if i < len(b.programs) else None
        if not ((x and x['type'] == 1) or (y and y['type'] == 1)):
            continue
        row = dict(index=i, left=x, right=y, metadataEqual=x == y,
                   rawBytesEqual=False, buildIdNormalizedBytesEqual=False)
        if x is not None and y is not None:
            xb, yb = a.read(x['offset'], x['filesz']), b.read(y['offset'], y['filesz'])
            xn, yn = a.normalized(x['offset'], x['filesz']), b.normalized(y['offset'], y['filesz'])
            row.update(rawBytesEqual=xb == yb, buildIdNormalizedBytesEqual=xn == yn,
                       rawSha256=[sha(xb), sha(yb)], normalizedSha256=[sha(xn), sha(yn)])
        loads.append(row)
    sections = []
    for i in range(max(len(a.sections), len(b.sections))):
        x = a.sections[i] if i < len(a.sections) else None
        y = b.sections[i] if i < len(b.sections) else None
        row = dict(index=i, name=(x or y)['name'], metadataEqual=x == y,
                   metadataDifferences=difference(x or {}, y or {}),
                   allocated=bool((x or {}).get('flags', 0) & 2 or (y or {}).get('flags', 0) & 2),
                   rawBytesEqual=False, buildIdNormalizedBytesEqual=False)
        if x is not None and y is not None:
            xb, yb = a.section_data(x), b.section_data(y)
            xn = xb if x['type'] == 8 else a.normalized(x['offset'], x['size'])
            yn = yb if y['type'] == 8 else b.normalized(y['offset'], y['size'])
            row.update(left=x, right=y, rawBytesEqual=xb == yb,
                       buildIdNormalizedBytesEqual=xn == yn, nobits=x['type'] == y['type'] == 8,
                       rawSha256=[sha(xb), sha(yb)])
        sections.append(row)
    sa, sb = a.symbols(), b.symbols()
    symbol_changes = [dict(index=i, left=sa[i] if i < len(sa) else None,
                           right=sb[i] if i < len(sb) else None)
                      for i in range(max(len(sa), len(sb)))
                      if i >= len(sa) or i >= len(sb) or sa[i] != sb[i]]
    allocated = [row for row in sections if row['allocated']]
    load_equal = bool(loads) and programs_equal and all(
        row['metadataEqual'] and row['buildIdNormalizedBytesEqual'] for row in loads)
    allocated_equal = bool(allocated) and all(
        row['metadataEqual'] and row['buildIdNormalizedBytesEqual'] for row in allocated)
    return dict(rawFileByteExact=a.data == b.data, elfHeaderByteExact=headers_equal,
                elfHeaderDifferences=difference(a.header, b.header),
                entry=dict(left=a.header['entry'], right=b.header['entry'],
                           equal=a.header['entry'] == b.header['entry']),
                programHeadersByteExact=programs_equal,
                programHeaders=dict(left=a.programs, right=b.programs),
                normalization=dict(kind='GNU-build-id-descriptor-only', left=a.build_id, right=b.build_id),
                loadSegments=loads, allocatedSections=allocated,
                otherSectionDifferences=[row for row in sections if not row['allocated'] and
                                         (not row['metadataEqual'] or not row['rawBytesEqual'])],
                symbols=dict(leftCount=len(sa), rightCount=len(sb), semanticDifferences=symbol_changes),
                loadImageEqualIgnoringGnuBuildId=load_equal,
                allAllocatedSectionsEqualIgnoringGnuBuildId=allocated_equal,
                matchedEntryHeadersAndNormalizedLoadImage=headers_equal and load_equal and allocated_equal)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--parent-build', required=True, type=Path)
    parser.add_argument('--successor-build', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase111'),
            'Fresh Phase111 output directory required')
    start = time.monotonic()
    parent_path, successor_path = args.parent_build.resolve(), args.successor_build.resolve()
    parent, successor = (json.loads(path.read_text()) for path in (parent_path, successor_path))
    require(parent.get('complete') and parent['kind'] == 'phase111-direct-qbe-runtime-relink',
            'Complete runtime-relink parent required')
    require(successor.get('complete') and successor['kind'] == 'phase111-direct-qbe-build',
            'Complete direct-QBE successor required')
    original_pin = authenticate(parent['originalBuild'])
    original_path = Path(original_pin['file'])
    original = json.loads(original_path.read_text())
    require(original.get('complete') and original['kind'] == 'phase111-direct-qbe-build',
            'Complete original object build required')
    inputs = [pin(__file__), pin(parent_path), pin(successor_path), original_pin]
    for report in (parent, successor):
        inputs.extend(authenticate(report[name]) for name in ('binary', 'object'))
    require(parent['object'] == original['object'], 'Relink original object identity mismatch')

    def only_input(report, suffix):
        rows = [row for row in report['inputs'] if row['file'].endswith(suffix)]
        require(len(rows) == 1, 'Expected one input ending ' + suffix)
        row = authenticate(rows[0])
        inputs.append(row)
        return row['file']

    comparisons = dict(
        qbe=exact_pair(only_input(original, '/program.ssa'), only_input(successor, '/program.ssa')),
        assembly=exact_pair(original_path.parent / 'program.s', successor_path.parent / 'program.s'),
        object=exact_pair(parent['object']['file'], successor['object']['file']),
        runtime=exact_pair(only_input(parent, '/runtime.o'), only_input(successor, '/runtime.o')))
    for pair in comparisons.values():
        inputs.extend((pair['left'], pair['right']))
    elf = compare_elf(parent['binary']['file'], successor['binary']['file'])
    for row in inputs:
        require(pin(row['file']) == row, 'Input changed during comparison: ' + row['file'])
    inputs = list({row['file']: row for row in inputs}.values())
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase111-native-image-comparison', version=1, complete=True,
                  command=[sys.executable, *sys.argv], inputs=inputs,
                  exactComparisons=comparisons, elf=elf,
                  qualified=all(row['byteExact'] for row in comparisons.values()) and
                            elf['matchedEntryHeadersAndNormalizedLoadImage'],
                  seconds=time.monotonic() - start,
                  scope='Data-only comparison; neither image executed or modified. '
                  'The verdict establishes identical QBE, assembly, compiler object and cached runtime, '
                  'matching entry/header/program layout, and identical allocated/load bytes after '
                  'masking only GNU build-id descriptor bytes. NOBITS metadata is compared explicitly. '
                  'It does not assert raw binary equality, identical build-id metadata, arbitrary '
                  'self-inspection behavior, or a new semantic execution result.')
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    summary = dict(complete=True, qualified=report['qualified'],
                   rawFileByteExact=elf['rawFileByteExact'],
                   loadImageEqualIgnoringGnuBuildId=elf['loadImageEqualIgnoringGnuBuildId'],
                   symbolDifferences=len(elf['symbols']['semanticDifferences']),
                   report=str(out / 'report.json'))
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))


if __name__ == '__main__':
    main()
