#!/usr/bin/env python3
"""Optional, frozen-image continuation diagnostic; never a timing measurement.

Briefly stops an explicitly selected own process with ptrace, reads bounded
memory, then detaches without writing target memory/registers. Only FIDs and
symbols are retained, never captured terms or register/stack dumps. A frame
push/pop can be sampled in transition: accepted chains remain heuristic.
"""
import argparse
import bisect
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import time


# This +8 state displacement is a reviewed property of this exact non-PIE
# full-native03 image, not a C ABI guarantee. Refuse all other image bytes.
IMAGE_SHA256 = '284797e08ea6c754e6f0a8508e3f2d3bc18b18722ba27616229fee7403897872'
CALL_RETURN_IP = 0xfa829d
STATE_AFTER_RETURN = 8
STATE_BYTES = 2088
STOP = (1 << 32) - 1
MAX_SCAN = 64 * 1024
MAX_FRAMES = 64
MAX_READ_BYTES = 1024 * 1024
RUNTIME_NAMES = ('IO_EMIT', 'CLO_APPLY', 'EXIT', 'ENTER')


class Unknown(Exception):
    pass


def require(condition, reason):
    if not condition:
        raise Unknown(reason)


def identity(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def process_start(proc):
    # comm can contain spaces and parentheses; starttime is field 22.
    return (proc / 'stat').read_text().rsplit(')', 1)[1].split()[19]


def decode_symbol(name):
    prefix = 'p111_FID_'
    if not name.startswith(prefix):
        return name
    parts = name[len(prefix):].strip('_').split('_')
    require(all(p.isdecimal() for p in parts), 'invalid-segment-symbol')
    return ''.join(chr(int(p)) for p in parts)


def parse_maps(text):
    rows = []
    for line in text.splitlines():
        fields = line.split(maxsplit=5)
        lo, hi = (int(x, 16) for x in fields[0].split('-'))
        rows.append((lo, hi, fields[1], fields[5] if len(fields) == 6 else ''))
    return rows


def contains(rows, address, size, permission='r', path=None):
    return next((row for row in rows if row[0] <= address and
                 address + size <= row[1] and permission in row[2] and
                 (path is None or row[3] == path)), None)


class Reader:
    def __init__(self, mem, maps):
        self.mem, self.maps = mem, maps
        self.used = 0
        self.deadline = time.monotonic() + 2

    def read(self, address, size):
        require(size >= 0 and self.used + size <= MAX_READ_BYTES, 'read-budget')
        require(time.monotonic() <= self.deadline, 'read-deadline')
        require(contains(self.maps, address, size), 'unmapped-read')
        self.mem.seek(address)
        data = self.mem.read(size)
        require(len(data) == size, 'short-read')
        self.used += size
        return data

    def word(self, address):
        return struct.unpack('<Q', self.read(address, 8))[0]


def descriptor(reader, symbols, executable):
    at = reader.word(symbols['p111_program_active'])
    words = struct.unpack('<24Q', reader.read(at, 192))
    count, constructors, main, pure, width, results = words[2:8]
    require(words[:2] == (11101, 192), 'descriptor-version-or-size')
    require(0 < count <= 65532 and 0 < constructors <= 65536,
            'descriptor-counts')
    require(main < count and pure <= 1 and 2 <= width <= 256 and
            1 <= results <= width and words[11] == 1, 'descriptor-widths-or-mode')
    functions = struct.unpack('<' + 'Q' * count, reader.read(words[12], 8 * count))
    arities = reader.read(words[13], count)
    flags = reader.read(words[14], count)
    incoming = reader.read(words[15], count)
    require(all(a <= width and i <= results and i <= a and not (f & ~3)
                for a, i, f in zip(arities, incoming, flags)), 'descriptor-entries')
    require(arities[main] == incoming[main] == 0, 'descriptor-main')
    require(all(contains(executable, address, 1, 'x') for address in functions),
            'segment-outside-image')
    return count, arities, incoming, functions


def segment_labels(functions, exact):
    labels = []
    owner = None
    for fid, address in enumerate(functions):
        raw = next((s for s in exact.get(address, ()) if s.startswith('p111_FID_')), None)
        require(raw is not None, 'segment-without-exact-symbol')
        name = decode_symbol(raw)
        continuation = re.fullmatch(r'\$p111\.k\.[0-9]+', name) is not None
        if not continuation:
            owner = name
        labels.append(dict(fid=fid, rawSymbol=raw, symbol=name,
                           heuristicOwner=owner, generatedContinuation=continuation))
    return labels


def recover(reader, regs, symbols, executable, exact):
    count, arities, incoming, functions = descriptor(reader, symbols, executable)
    labels = segment_labels(functions, exact)
    heap = reader.word(symbols['CORPUS'])
    stack_base = reader.word(symbols['io_stk'])
    require(heap and contains(reader.maps, heap, 8), 'runtime-heap-unavailable')
    logical_map = contains(reader.maps, stack_base, 8, 'w')
    require(logical_map is not None, 'runtime-stack-unavailable')
    rsp = int(regs[19])
    cpu_stack = contains(reader.maps, rsp, 8, 'w', '[stack]')
    require(cpu_stack is not None and rsp % 8 == 0, 'cpu-stack-unavailable')
    scan = reader.read(rsp, min(MAX_SCAN, cpu_stack[1] - rsp))
    candidates = []
    pending = 0
    for offset in range(0, len(scan) - 7, 8):
        if struct.unpack_from('<Q', scan, offset)[0] != CALL_RETURN_IP:
            continue
        state = rsp + offset + STATE_AFTER_RETURN
        if not contains([cpu_stack], state, STATE_BYTES, 'w'):
            continue
        mem, alc, sp, seq, rn, next_fid, reserved = struct.unpack(
            '<3Q4I', reader.read(state, 40))
        if not (mem == heap and alc == symbols['ALC'] and seq == 1 and
                rn <= 256 and reserved == 0 and sp % 8 == 0 and
                stack_base + 8 <= sp <= logical_map[1]):
            continue
        if next_fid != STOP:
            pending += 1
            continue
        candidates.append(sp)
    require(len(candidates) == 1, 'ambiguous-state' if len(candidates) > 1 else
            'transition-pending' if pending else 'no-validated-dispatch-state')
    sp = candidates[0]
    frames = []
    reason = 'frame-limit'
    for _ in range(MAX_FRAMES):
        if sp < stack_base + 8:
            reason = 'logical-stack-boundary'
            break
        fid = reader.word(sp - 8)
        if count <= fid < count + 4:
            frames.append(dict(fid=fid, symbol='runtime:' + RUNTIME_NAMES[fid - count]))
            reason = 'runtime-boundary'
            break
        # Never preserve an invalid word: it may actually be a captured Term.
        if fid >= count or incoming[fid] == 0 or not labels[fid]['generatedContinuation']:
            reason = 'invalid-or-transient-frame'
            break
        held = arities[fid] - incoming[fid]
        next_sp = sp - 8 * (1 + held)
        if next_sp < stack_base:
            reason = 'frame-outside-logical-stack'
            break
        frames.append(labels[fid])
        sp = next_sp
    return dict(status='candidate' if frames else 'unknown', frames=frames,
                stopReason=reason, segmentCount=count, bytesRead=reader.used)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pid', required=True, type=int)
    parser.add_argument('--image', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--samples', type=int, default=8)
    parser.add_argument('--interval', type=float, default=.2)
    args = parser.parse_args()
    require(1 <= args.samples <= 24 and .05 <= args.interval <= 2, 'sampling-bounds')
    require(args.pid > 1 and args.pid != os.getpid(), 'invalid-pid')
    image = args.image.resolve(strict=True)
    pin = identity(image)
    require(pin['sha256'] == IMAGE_SHA256, 'unsupported-image-layout')
    with image.open('rb') as elf:
        header = elf.read(20)
    require(header[:6] == b'\x7fELF\x02\x01' and
            struct.unpack_from('<HH', header, 16) == (2, 62), 'unsupported-elf')
    proc = Path('/proc') / str(args.pid)
    require(proc.stat().st_uid == os.getuid() and
            (proc / 'exe').resolve(strict=True) == image, 'process-identity')
    start = process_start(proc)
    raw = subprocess.check_output(['nm', '-n', str(image)], text=True, timeout=10)
    exact, symbols = {}, {}
    text_symbols = []
    for line in raw.splitlines():
        fields = line.split()
        if len(fields) != 3 or not re.fullmatch('[0-9a-fA-F]+', fields[0]):
            continue
        address, kind, name = int(fields[0], 16), fields[1], fields[2]
        symbols[name] = address
        if kind in ('t', 'T'):
            exact.setdefault(address, []).append(name)
            text_symbols.append((address, decode_symbol(name)))
    require(all(name in symbols for name in
                ('work_loop', 'p111_program_active', 'CORPUS', 'ALC', 'io_stk')),
            'missing-layout-symbols')
    disassembly = subprocess.check_output(
        ['objdump', '-d', '--disassemble=work_loop', str(image)], text=True, timeout=10)
    calls = []
    for line in disassembly.splitlines():
        match = re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}\s+)+)callq?\s+\*', line)
        if match:
            calls.append(int(match[1], 16) + len(match[2].split()))
    require(calls == [CALL_RETURN_IP], 'unexpected-dispatch-call-layout')
    args.out.mkdir(parents=True, exist_ok=False)
    (args.out / 'method.py').write_bytes(Path(__file__).read_bytes())
    (args.out / 'work_loop.objdump.txt').write_text(disassembly)
    root = Path(__file__).resolve().parents[4]
    sources = [root / name for name in (
        'selfhost/build/phase111/runtime-source04/runtime.h',
        'selfhost/build/phase111/runtime-source04/runtime.c',
        'selfhost/tools/performance/phase111/segment/lower-helpers.bend',
        'selfhost/tools/performance/phase111/segment/lower-book.bend')]
    report = dict(kind='phase111-qualitative-continuation-samples', complete=False,
                  pid=args.pid, processStartTicks=start, image=pin,
                  inputs=[identity(path) for path in sources],
                  nmSha256=hashlib.sha256(raw.encode()).hexdigest(),
                  layout=dict(returnIP=hex(CALL_RETURN_IP), stateAfterReturn=8,
                              stateBytes=STATE_BYTES, cpuScanBytes=MAX_SCAN,
                              maxFrames=MAX_FRAMES, maxReadBytes=MAX_READ_BYTES),
                  samples=[], scope='Read-only, image-specific heuristic stage clues. '
                  'Ptrace pauses perturb wall time. Frame transitions can be transient. '
                  'Owner labels use preceding non-$p111.k.<n> segment-table entry; '
                  'they are inferred definition labels, not verified dynamic callers. '
                  'No terms, captures, or register/stack dumps are retained.')
    libc = ctypes.CDLL(None, use_errno=True)
    libc.ptrace.restype = ctypes.c_long
    libc.ptrace.argtypes = [ctypes.c_uint, ctypes.c_uint, ctypes.c_void_p, ctypes.c_void_p]

    def trace(op, data=None):
        if libc.ptrace(op, args.pid, None, data) == -1:
            raise OSError(ctypes.get_errno(), os.strerror(ctypes.get_errno()))

    addresses = [row[0] for row in text_symbols]
    for number in range(args.samples):
        attached = False
        detach_error = None
        began = time.monotonic()
        sample = dict(at=time.time(), status='unknown', frames=[])
        try:
            require(process_start(proc) == start and
                    (proc / 'exe').resolve(strict=True) == image, 'process-changed')
            trace(16)
            attached = True
            _, status = os.waitpid(args.pid, 0)
            require(os.WIFSTOPPED(status), 'process-not-stopped')
            maps_text = (proc / 'maps').read_text()
            maps_file = args.out / ('maps-%02d.txt' % number)
            maps_file.write_text(maps_text)
            sample['maps'] = identity(maps_file)
            maps = parse_maps(maps_text)
            executable = [row for row in maps if row[2] == 'r-xp' and row[3] == str(image)]
            require(executable, 'missing-exact-image-mapping')
            regs = (ctypes.c_ulonglong * 27)()
            trace(12, ctypes.cast(ctypes.byref(regs), ctypes.c_void_p))
            ip = int(regs[16])
            index = bisect.bisect_right(addresses, ip) - 1
            sample['nativeSymbol'] = (text_symbols[index][1] if index >= 0 and
                contains(executable, ip, 1, 'x') and
                contains(executable, addresses[index], 1, 'x') else '?')
            with (proc / 'mem').open('rb', buffering=0) as mem:
                sample.update(recover(Reader(mem, maps), regs, symbols, executable, exact))
        except (Unknown, OSError, ValueError, struct.error) as error:
            sample['stopReason'] = str(error)
        finally:
            if attached:
                try:
                    trace(17)
                except OSError as error:
                    detach_error = error
                    sample['detachError'] = str(error)
            sample['pauseSeconds'] = time.monotonic() - began
            report['samples'].append(sample)
            (args.out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        if detach_error is not None:
            raise detach_error
        if number + 1 < args.samples:
            time.sleep(args.interval)
    report['complete'] = True
    report['candidateSamples'] = sum(s['status'] == 'candidate' for s in report['samples'])
    (args.out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, samples=len(report['samples']),
                          candidateSamples=report['candidateSamples'],
                          report=str((args.out / 'report.json').resolve()))))


if __name__ == '__main__':
    main()
