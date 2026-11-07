#!/usr/bin/env python3
"""Read-only, exact-pair ELF audit; never executes either compiler."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location(
    'phase174_elf_audit', ROOT / 'selfhost/tests/phase174/elf-audit.py')
elf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(elf)
require = elf.require


def audit():
    paths = [ROOT / f'selfhost/build/phase175/full-native-n{n}/program' for n in (1, 2)]
    old, new = [elf.parse(p) for p in paths]
    require(old['headerBytes'] == new['headerBytes'], 'ELF headers differ')
    require(old['programHeaderBytes'] == new['programHeaderBytes'], 'Program headers differ')
    require(old['pin']['bytes'] == new['pin']['bytes'], 'ELF sizes differ')
    require(len(old['sections']) == len(new['sections']), 'Section count differs')
    sections = []
    by_name = [{s['name']: s for s in e['sections']} for e in (old, new)]
    old_object, new_object = [str(p.with_name('program.o')).encode() for p in paths]
    require(len(old_object) == len(new_object), 'Object path lengths differ')
    changed_sections = []
    for a, b in zip(old['sections'], new['sections']):
        require(a['name'] == b['name'], 'Section order differs')
        require(all(a[k] == b[k] for k in elf.SECTION_KEYS), 'Section metadata differs')
        same = a.get('sha256') == b.get('sha256')
        if not same:
            changed_sections.append(a['name'])
        sections.append(dict(name=a['name'], allocatable=bool(a['flags'] & 2),
            type=a['type'], offset=a['offset'], bytes=a['size'],
            oldSha256=a.get('sha256'), newSha256=b.get('sha256'), contentEqual=same))
    require(changed_sections == ['.strtab'],
        'Changes extend beyond one object pathname')
    note = by_name[0]['.note.gnu.build-id']
    require(note['type'] == 7 and note['flags'] == 2 and note['size'] == 36,
        'Unexpected GNU build-id note layout')
    a, b = [elf.bytes_region(p, note['offset'], 36) for p in paths]
    require(a[:16] == b[:16] == elf.struct.pack('<III', 4, 20, 3) + b'GNU\0',
        'Unexpected GNU build-id note header/name')
    require(a == b, 'GNU build-id differs')
    build_id = dict(offset=note['offset'] + 16, bytes=20, old=a[16:].hex(), new=b[16:].hex(), equal=True)
    tables = [elf.bytes_region(p, index['.strtab']['offset'], index['.strtab']['size'])
        for p, index in zip(paths, by_name)]
    require(tables[0].count(old_object + b'\0') == 1, 'Original object path not unique')
    position = tables[0].index(old_object + b'\0')
    require(tables[0][:position] + new_object + tables[0][position + len(old_object):] == tables[1],
        'String table changes extend beyond exact object pathname')
    table = by_name[0]['.symtab']
    require(table['entryBytes'] == 24 and table['size'] % 24 == 0, 'Unexpected symbol format')
    records = elf.bytes_region(paths[0], table['offset'], table['size'])
    symbols = []
    for i in range(table['size'] // 24):
        row = elf.struct.unpack('<IBBHQQ', records[i * 24:i * 24 + 24])
        if row[0] == position:
            require(row[1:] == (4, 0, 65521, 0, 0), 'Path symbol is not STT_FILE')
            symbols.append(i)
    require(len(symbols) == 1, 'Expected one object filename symbol')
    old_gaps, new_gaps = elf.gaps(old), elf.gaps(new)
    require(old_gaps == new_gaps, 'Bytes outside sections differ')
    segments, loaded_differences = [], []
    for i, h in enumerate(old['programHeaders']):
        if h['type'] != 1:
            continue
        differences = []
        with paths[0].open('rb') as a, paths[1].open('rb') as b:
            a.seek(h['offset']); b.seek(h['offset'])
            left, offset = h['fileBytes'], h['offset']
            while left:
                aa = a.read(min(elf.CHUNK, left)); bb = b.read(len(aa))
                require(aa and len(aa) == len(bb), 'Truncated load segment')
                differences.extend(elf.differences(aa, bb, offset))
                left -= len(aa); offset += len(aa)
        require(not differences, 'Mapped bytes differ')
        loaded_differences.extend(differences)
        segments.append(dict(programHeader=i, flags=h['flags'], offset=h['offset'],
            fileBytes=h['fileBytes'], memoryBytes=h['memoryBytes'],
            exactBytesEqual=not differences, differingBytes=len(differences)))
    require(not loaded_differences, 'Unexpected mapped-byte difference')
    require([elf.common.pin(p) for p in paths] == [old['pin'], new['pin']], 'Inputs changed')
    return dict(kind='phase175-elf-metadata-audit', version=1, complete=True,
        targetsRun=False, old=old['pin'], new=new['pin'],
        method=elf.common.pin(__file__), parserMethod=elf.common.pin(spec.origin),
        headersEqual=True, programHeadersEqual=True, sectionHeadersEqual=True,
        sections=sections, gaps=old_gaps, buildId=build_id,
        stringTableEdit=dict(offset=by_name[0]['.strtab']['offset'] + position,
            bytes=len(old_object), old=old_object.decode(), new=new_object.decode(),
            differences=elf.differences(old_object, new_object,
                by_name[0]['.strtab']['offset'] + position), exactSingleReplacement=True),
        symbols=dict(count=table['size'] // 24, rawSymbolTableEqual=True,
            changedDecodedNameRecords=symbols, allOtherDecodedSymbolsEqual=True),
        loadSegments=segments, loadedByteDifferences=loaded_differences,
        wholeELFEqual=False, loadedSegmentsEqual=True, allocatedSectionsEqual=True,
        compiledCodeDataEqual=True, loaderRelevantHeadersEqual=True,
        runtimeImageEquivalent=True, allNonloadedDifferencesExplained=True,
        equivalenceScope='Exactly identical ELF/program/section headers, all mapped '
            'bytes, all allocatable sections, GNU build-id, code/data, dynamic-linking '
            'metadata and zero-fill layout. No mapped-byte exceptions. Nonloaded '
            'differences are exclusively the one same-length STT_FILE object pathname. '
            'Assumes ordinary ELF loading and excludes executable-file/symbol-table '
            'introspection; no claim of universal observational equivalence or linker '
            'build-id hashing causation.')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    args = p.parse_args()
    require(not args.out.exists(), 'Refuse replacing retained audit')
    result = audit()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    elf.common.write_json(args.out, result)
    print(json.dumps({k: result[k] for k in ('complete', 'wholeELFEqual',
        'runtimeImageEquivalent', 'buildId', 'stringTableEdit', 'symbols', 'loadSegments')}))


if __name__ == '__main__':
    main()
