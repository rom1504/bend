#!/usr/bin/env python3
"""Read-only bounded QBE declaration and ELF-load comparison; never run a target."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

ROOT = Path(__file__).resolve().parents[3]
CHUNK = 131072
MAX_HEADER = 65536
MAX_DECLARATIONS = 250000
MAX_CHANGES_BYTES = 64 * 1024 * 1024
SPECIAL = re.compile(rb'[{}"#\\\n]')
HEADERS = [
    ('function', re.compile(rb'(?:export\s+)?function\s+(?:(?:[wlbsd]|:[\w.$]+)\s+)?\$([\w.$]+)\s*\([^{}]*\)\s*\{\Z')),
    ('data', re.compile(rb'(?:export\s+)?(?:thread\s+)?data\s+\$([\w.$]+)\s*=\s*(?:align\s+\d+\s*)?\{\Z')),
    ('type', re.compile(rb'type\s+:([\w.$]+)\s*=\s*(?:align\s+\d+\s*)?\{\Z')),
]


def need(ok, message):
    if not ok:
        raise ValueError(message)


def identity(path):
    path = Path(path).resolve(strict=True)
    before = path.stat()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(CHUNK), b''):
            digest.update(chunk)
    after = path.stat()
    need((before.st_ino, before.st_size, before.st_mtime_ns) ==
         (after.st_ino, after.st_size, after.st_mtime_ns), 'Input changed: ' + str(path))
    return dict(file=str(path), bytes=after.st_size, sha256=digest.hexdigest())


def equal_identity(actual, expected, label):
    need(all(actual[k] == expected[k] for k in ['bytes', 'sha256']), label + ' identity mismatch')


def checked_report(path):
    pin = identity(path)
    data = json.loads(Path(pin['file']).read_text())
    need(data.get('kind') == 'bend-native-build' and data.get('complete'), 'Completed native build report required')
    need(data.get('compilerExitCode') == 0 and data.get('qbeExitCode') == 0 and not data.get('changedInputs'), 'Clean successful producer required')
    return data, pin


class Census:
    """Hash bytes through each balanced declaration; never buffer its body."""
    def __init__(self):
        self.whole = hashlib.sha256()
        self.padding = hashlib.sha256()
        self.bytes = self.newlines = self.padding_bytes = 0
        self.header = bytearray()
        self.current = None
        self.records = {}
        self.depth = 0
        self.string = self.escape = self.comment = self.outer_comment = False

    def pad(self, value):
        self.padding.update(value)
        self.padding_bytes += len(value)

    def body(self, value):
        self.current[0].update(value)
        self.current[1] += len(value)
        self.current[2] += value.count(b'\n')

    def begin(self):
        header = bytes(self.header)
        for kind, pattern in HEADERS:
            match = pattern.fullmatch(header)
            if match:
                key = (kind, match[1].decode('ascii'))
                need(key not in self.records, 'Duplicate declaration: ' + str(key))
                need(len(self.records) < MAX_DECLARATIONS, 'Declaration bound exceeded')
                self.current = [hashlib.sha256(), 0, 0, key]
                self.depth = 1
                self.body(header)
                self.header.clear()
                return
        raise ValueError('Unsupported generated declaration header: ' + repr(header[:240]))

    def feed(self, data):
        self.whole.update(data)
        self.bytes += len(data)
        self.newlines += data.count(b'\n')
        pos = 0
        while pos < len(data):
            if self.current is None:
                if self.outer_comment:
                    end = data.find(b'\n', pos)
                    end = len(data) if end < 0 else end + 1
                    self.pad(data[pos:end])
                    self.outer_comment = end == len(data) and data[end-1:end] != b'\n'
                    pos = end
                    continue
                if not self.header:
                    end = pos + len(data[pos:]) - len(data[pos:].lstrip())
                    self.pad(data[pos:end])
                    pos = end
                    if pos == len(data):
                        continue
                    if data[pos:pos+1] == b'#':
                        self.outer_comment = True
                        continue
                end = data.find(b'{', pos)
                if end < 0:
                    self.header.extend(data[pos:])
                    need(len(self.header) <= MAX_HEADER, 'Header bound exceeded')
                    return
                self.header.extend(data[pos:end+1])
                need(len(self.header) <= MAX_HEADER, 'Header bound exceeded')
                self.begin()
                pos = end + 1
                continue
            start = pos
            scan = pos
            if self.escape:
                scan += 1
                self.escape = False
            closed = False
            while True:
                match = SPECIAL.search(data, scan)
                if not match:
                    break
                at = match.start()
                char = data[at]
                scan = at + 1
                if self.comment:
                    if char == 10:
                        self.comment = False
                elif self.string:
                    if char == 92:
                        scan = at + 2
                        self.escape = scan > len(data)
                    elif char == 34:
                        self.string = False
                elif char == 35:
                    self.comment = True
                elif char == 34:
                    self.string = True
                elif char == 123:
                    self.depth += 1
                elif char == 125:
                    self.depth -= 1
                    if self.depth == 0:
                        self.body(data[start:at+1])
                        digest, size, lines, key = self.current
                        self.records[key] = (size, digest.hexdigest(), lines)
                        self.current = None
                        pos = at + 1
                        closed = True
                        break
            if not closed:
                self.body(data[start:])
                return

    def finish(self):
        need(self.current is None and not self.header and not self.string and not self.escape, 'Truncated QBE declaration')
        totals = {}
        for (kind, _), (size, _, _) in self.records.items():
            row = totals.setdefault(kind, dict(declarations=0, bytes=0))
            row['declarations'] += 1
            row['bytes'] += size
        need(sum(x['bytes'] for x in totals.values()) + self.padding_bytes == self.bytes, 'Byte partition mismatch')
        return dict(bytes=self.bytes, sha256=self.whole.hexdigest(), newlines=self.newlines,
                    outsideDeclarations=dict(bytes=self.padding_bytes, sha256=self.padding.hexdigest()), totals=totals)


def consume(stream):
    census = Census()
    for data in iter(lambda: stream.read(CHUNK), b''):
        census.feed(data)
    return census, census.finish()


def display(name):
    match = re.fullmatch(r'(.*?)FID_((?:[0-9]+_)+)', name)
    if not match:
        return dict(family=name.split('_', 1)[0], decodedIdentity=None)
    points = [int(x) for x in match[2][:-1].split('_')]
    if any(x > 0x10ffff or 0xd800 <= x <= 0xdfff for x in points):
        return dict(family=match[1].rstrip('_'), decodedIdentity=None)
    return dict(family=match[1].rstrip('_'), decodedIdentity=''.join(map(chr, points)))


def loaded_elf(pin):
    actual = identity(pin['file'])
    equal_identity(actual, pin, 'ELF')
    with Path(actual['file']).open('rb') as stream:
        raw = stream.read(64)
        need(len(raw) == 64 and raw[:7] == b'\x7fELF\x02\x01\x01', 'ELF64 little-endian required')
        fields = struct.unpack('<16sHHIQQQIHHHHHH', raw)
        _, typ, machine, version, entry, phoff, _, flags, ehsize, phsize, phnum, _, _, _ = fields
        need(typ in [2, 3] and machine == 62 and version == 1 and ehsize == 64 and phsize == 56 and phnum < 4096, 'Unsupported ELF header')
        segments = []
        for index in range(phnum):
            stream.seek(phoff + index * phsize)
            header = stream.read(phsize)
            need(len(header) == phsize, 'Truncated program header')
            kind, perm, offset, vaddr, paddr, size, memory, align = struct.unpack('<IIQQQQQQ', header)
            if kind != 1:
                continue
            need(size <= memory and offset + size <= actual['bytes'], 'Invalid PT_LOAD bounds')
            stream.seek(offset)
            digest = hashlib.sha256()
            left = size
            while left:
                data = stream.read(min(left, CHUNK))
                need(data, 'Truncated load segment')
                digest.update(data)
                left -= len(data)
            segments.append(dict(offset=offset, virtualAddress=vaddr, physicalAddress=paddr, fileBytes=size,
                                 memoryBytes=memory, flags=perm, alignment=align, sha256=digest.hexdigest()))
    need(segments, 'No PT_LOAD segments')
    equal_identity(identity(actual['file']), actual, 'ELF stable after segment reads')
    return dict(binary=actual, type=typ, machine=machine, entry=entry, flags=flags, segments=segments)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--old-capsule', type=Path, required=True)
    parser.add_argument('--old-report', type=Path, required=True)
    parser.add_argument('--new-report', type=Path, required=True)
    parser.add_argument('--successor-report', type=Path, required=True, help='N3 report for N2/N3 PT_LOAD comparison')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.absolute()
    need(out.resolve() == out and out.is_relative_to(ROOT / 'selfhost/build') and not out.exists(), 'Fresh nonsymlink workspace build directory required')
    out.mkdir()
    report = dict(kind='phase173-streaming-qbe-generation-diff', version=1, complete=False, targetsRun=False,
                  method=identity(__file__), scope='Exact declaration bytes and ELF PT_LOAD metadata/content, not semantic equivalence or execution timing.')
    start = time.monotonic()
    try:
        old_report, old_pin = checked_report(args.old_report)
        new_report, new_pin = checked_report(args.new_report)
        third_report, third_pin = checked_report(args.successor_report)
        for other in [new_report, third_report]:
            for key in ['source','base','carrier','stamp','mode','providers','outputContract']:
                need(old_report['request'][key] == other['request'][key], 'Request comparison differs: ' + key)
            need(old_report['runtime'] == other['runtime'] and old_report['toolchain'] == other['toolchain'], 'Runtime/toolchain differs')
        report['comparisonContract'] = dict(source=old_report['request']['source'],mode=old_report['request']['mode'],
            runtime=old_report['runtime'],toolchain=old_report['toolchain'],
            producerImages=[r['request']['image'] for r in [old_report,new_report,third_report]])
        capsule = args.old_capsule.resolve(strict=True)
        receipt_pin = identity(capsule / 'receipt.json')
        receipt = json.loads(Path(receipt_pin['file']).read_text())
        need(receipt.get('kind') == 'build-retention-run-capsule-v1' and receipt.get('complete') and receipt.get('reopenedVerified') and receipt.get('inputStabilityVerified'), 'Verified complete retention capsule required')
        equal_identity(old_pin, receipt['writersClosed']['report'], 'Archived producer report')
        need(receipt['archive']['path'] == 'files.tar.gz', 'Expected fixed archive leaf')
        archive_pin = identity(capsule / 'files.tar.gz')
        equal_identity(archive_pin, receipt['archive'], 'Archive')
        need(receipt['files']['program.ssa'] == old_report['irDigest'], 'Archive/member producer disagreement')
        report['inputs'] = [old_pin, new_pin, third_pin, receipt_pin, archive_pin]
        with tarfile.open(archive_pin['file'], mode='r|gz', bufsize=CHUNK) as archive:
            old = old_meta = None
            for member in archive:
                if member.name == 'program.ssa':
                    need(member.isfile() and member.size == receipt['files']['program.ssa']['bytes'], 'Exact regular SSA archive member required')
                    with archive.extractfile(member) as stream:
                        old, old_meta = consume(stream)
                    break
            need(old is not None, 'Exact program.ssa member missing; no extraction attempted')
        equal_identity(old_meta, receipt['files']['program.ssa'], 'Archived SSA stream')
        new_path = Path(new_report['retainedIR']['file']).resolve(strict=True)
        before = new_path.stat()
        with new_path.open('rb') as stream:
            new, new_meta = consume(stream)
        after = new_path.stat()
        need((before.st_ino,before.st_size,before.st_mtime_ns) == (after.st_ino,after.st_size,after.st_mtime_ns), 'Hot SSA changed during reading')
        equal_identity(new_meta, new_report['irDigest'], 'Hot SSA stream')
        equal_identity(new_meta, new_report['retainedIR'], 'Retained SSA pin')
        report['old'] = dict(producerReport=old_pin, member='program.ssa', archive=archive_pin, **old_meta)
        report['new'] = dict(producerReport=new_pin, file=str(new_path), **new_meta)
        changes = out / 'changed-declarations.jsonl'
        counts = {'identical':0,'changed':0,'added':0,'removed':0}
        families = {}
        written = 0
        with changes.open('x') as stream:
            for key in sorted(old.records.keys() | new.records.keys()):
                a, b = old.records.get(key), new.records.get(key)
                status = 'added' if a is None else 'removed' if b is None else 'identical' if a == b else 'changed'
                counts[status] += 1
                if status == 'identical':
                    continue
                row = dict(kind=key[0],symbol=key[1],status=status,**display(key[1]),
                           old=None if a is None else dict(bytes=a[0],sha256=a[1],newlines=a[2]),
                           new=None if b is None else dict(bytes=b[0],sha256=b[1],newlines=b[2]),
                           byteDelta=(b[0] if b else 0)-(a[0] if a else 0))
                families[row['family']] = families.get(row['family'],0)+1
                text = json.dumps(row,ensure_ascii=True,separators=(',',':'))+'\n'
                written += len(text.encode())
                need(written <= MAX_CHANGES_BYTES, 'Change-report bound exceeded')
                stream.write(text)
        report['declarationComparison'] = dict(counts=counts,changedFamilies=families,details=identity(changes),
            byteDelta=new_meta['bytes']-old_meta['bytes'],fullProductEqual=old_meta['sha256']==new_meta['sha256'],
            outsideDeclarationBytesEqual=old_meta['outsideDeclarations']==new_meta['outsideDeclarations'])
        left, right = loaded_elf(new_report['binary']), loaded_elf(third_report['binary'])
        report['nativeSuccessor'] = dict(n2=left,n3=right,
            qbeEqual=new_report['irDigest']==third_report['irDigest'],
            assemblyEqual=all(new_report['assembly'][k]==third_report['assembly'][k] for k in ['bytes','sha256']),
            objectEqual=all(new_report['object'][k]==third_report['object'][k] for k in ['bytes','sha256']),
            fullELFEqual=left['binary']['sha256']==right['binary']['sha256'],
            loadImageEqual={k:v for k,v in left.items() if k!='binary'} == {k:v for k,v in right.items() if k!='binary'})
        for pin in report['inputs']:
            equal_identity(identity(pin['file']),pin,'Stable metadata/archive')
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        report['wallSeconds'] = time.monotonic()-start
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(report=str(out/'report.json'),complete=True,counts=counts,loadImageEqual=report['nativeSuccessor']['loadImageEqual'])))


if __name__ == '__main__':
    main()
