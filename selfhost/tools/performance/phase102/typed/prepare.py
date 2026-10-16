#!/usr/bin/env python3
"""Fuse calls to existing admitted flat workers inside scheduler segments.

General generated-C mechanism prototype. No source/application names are selected.
The original device path and every unrecognized shape remain unchanged. This is
not yet the Bend emitter implementation and does not grant new worker admission.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

CASE = re.compile(r'  WL_CASE\((FID_[A-Za-z0-9_]+)\)\n  \{\n(.*?)\n  \}\}', re.S)
FRAME = re.compile(r'if \(seq\) \{\nWL_ROOM\((\d+)\);\n'
                   r'((?:STK\(\d+\) = [A-Za-z0-9_]+;\n)+)'
                   r'WL_PUSHN\(\1\);\n\} else \{\n'
                   r'u64 (task_\d+) = task_node\(e, (FID_\w+), WL_CONT, WL_IDX, 1\);\n'
                   r'((?:e.mem\[task_\d+ \+ \d+\] = [A-Za-z0-9_]+;\n)*)'
                   r'WL_CONT = term_tsk\(\4, \3\);\nWL_IDX = (\d+);\n\}\n')
JUMP = re.compile(r'WL_JMP\((FID_\w+)\);')
ARGUMENT = re.compile(r'(?:Term [A-Za-z0-9_]+ = [^;\n]+;|'
                      r'if \(!seq && err_seen\(e.mem\)\) \{ return 0; \}|'
                      r'[A-Za-z0-9_]+ = term_keep\(e, [A-Za-z0-9_]+\);|'
                      r'r\d+ = [A-Za-z0-9_]+;)')


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def decode(name):
    def replace(match):
        try:
            return ''.join(chr(int(n)) for n in match[0].strip('_').split('_'))
        except (ValueError, OverflowError):
            return match[0]
    return re.sub(r'(?:\d+_){3,}', replace, name)


def split(segment):
    pieces = segment.split('    WL_OPEN\n')
    return pieces if len(pieces) == 2 else None


def wrappers(segments):
    result = {}
    for name, segment in segments.items():
        parts = split(segment)
        if not parts:
            continue
        header, body = parts
        # Exact one-result ordinary NF wrapper. Product/observer routes remain
        # untouched until their differing argument/result ownership is handled.
        match = re.fullmatch(r'#if !DEVICE\n\{\nTerm nq_result\[1\];\n'
            r'if \(!(?P<call>NF_FID_\w+\(e, seq, nq_result(?:, [A-Za-z0-9_]+)*\))\) '
            r'\{ return 0; \}\nr0 = nq_result\[0\];\nWL_RETN\(1\);\n'
            r'\}\n#else\n.*#endif\n', body, re.S)
        if not match or 'STK(' in header or 'WL_' in header:
            continue
        # Header bindings must exclusively read incoming argument registers.
        clean = re.sub(r'#if !DEVICE && NATIVE_TYPED_SCALARS\nu32\n#else\nTerm\n#endif\n',
                       'Term ', header)
        clean = re.sub(r'\s*Term\s+\w+ = r\d+;', '', clean)
        if clean.strip():
            continue
        result[name] = header + '{\nTerm nq_result[1];\nif (!' + match['call'] + \
            ') { return 0; }\nr0 = nq_result[0];\nrn = 1;\n}\n'
    return result


def captures(frame):
    slots = re.findall(r'STK\((\d+)\) = (\w+);', frame[2])
    count = int(frame[1]) - 1
    if len(slots) != count + 1 or [int(i) for i, _ in slots] != list(range(count + 1)):
        return None
    if slots[-1][1] != frame[4] or int(frame[6]) != count:
        return None
    values = [v for _, v in slots[:-1]]
    expected = ''.join(f'e.mem[{frame[3]} + {i}] = {v};\n' for i, v in enumerate(values))
    if frame[5] != expected:
        return None
    return values


def continuation(segment, count, prefix):
    parts = split(segment)
    if not parts:
        return None
    header, body = parts
    pop = re.match(r'\s*WL_POPN\((\d+)\);\n', header)
    if not pop or int(pop[1]) != count:
        return None
    header = header[pop.end():]
    indexes = re.findall(r'STK\((\d+)\)', header)
    if list(map(int, indexes)) != list(range(count)):
        return None
    # Do not silently remove other stack/control operations from the prologue.
    if 'WL_' in header:
        return None
    header = re.sub(r'STK\((\d+)\)', lambda m: prefix + m[1], header)
    return header, body


def transform(source, maximum_depth=16):
    matches = list(CASE.finditer(source))
    segments = {m[1]: m[2] for m in matches}
    assert matches and len(segments) == len(matches), 'Unique scheduler segments required'
    direct = wrappers(segments)
    stats = dict(admittedWrappers=len(direct), fusedEdges=0, savedSlots=0,
                 transformedSegments=0, maxDepth=maximum_depth, edges=[])
    serial = 0

    def expand(body, seen, depth):
        nonlocal serial
        if depth >= maximum_depth:
            return body
        pieces, position = [], 0
        for frame in FRAME.finditer(body):
            if frame.start() < position:
                continue
            jump = JUMP.search(body, frame.end())
            if not jump or jump[1] not in direct or frame[4] in seen:
                continue
            arguments = body[frame.end():jump.start()]
            if not all(ARGUMENT.fullmatch(line) for line in arguments.splitlines() if line.strip()):
                continue
            values = captures(frame)
            if values is None or frame[4] not in segments:
                continue
            serial += 1
            prefix = f'p102_saved_{serial}_'
            resumed = continuation(segments[frame[4]], len(values), prefix)
            if resumed is None:
                continue
            header, rest = resumed
            rest = expand(rest, seen | {frame[4]}, depth + 1)
            saved = ''.join(f'Term {prefix}{i} = {value};\n' for i, value in enumerate(values))
            old = body[frame.start():jump.end()]
            new = ('#if !DEVICE\n{\n' + saved + arguments + '{\n' + direct[jump[1]] + '}\n' +
                   '{\n' + header + rest + '}\n}\n#else\n' + old + '\n#endif')
            pieces += [body[position:frame.start()], new]
            position = jump.end()
            stats['fusedEdges'] += 1
            stats['savedSlots'] += len(values)
            stats['edges'].append(dict(callee=decode(jump[1]), continuation=decode(frame[4]),
                                       slots=len(values), depth=depth))
        return ''.join(pieces) + body[position:]

    output, position = [], 0
    for match in matches:
        parts = split(match[2])
        if not parts:
            continue
        header, body = parts
        new = expand(body, {match[1]}, 0)
        if new == body:
            continue
        output += [source[position:match.start()],
                   '  WL_CASE(' + match[1] + ')\n  {\n' + header + '    WL_OPEN\n' + new + '\n  }}']
        position = match.end()
        stats['transformedSegments'] += 1
    output.append(source[position:])
    result = ''.join(output)
    stats.update(originalBytes=len(source.encode()), candidateBytes=len(result.encode()))
    return result, stats


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--depth', type=int, default=16)
    args = parser.parse_args()
    assert 1 <= args.depth <= 32 and not args.output.exists()
    result, stats = transform(args.input.read_text(), args.depth)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(result)
    receipt = args.output.with_suffix('.json')
    assert not receipt.exists()
    receipt.write_text(json.dumps(dict(method=pin(__file__), original=pin(args.input),
                                      candidate=pin(args.output), rewrites=stats), indent=2) + '\n')
    print(json.dumps({k:v for k,v in stats.items() if k != 'edges'}))


if __name__ == '__main__':
    main()
