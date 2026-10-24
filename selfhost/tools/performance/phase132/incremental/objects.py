"""Experimental closed-image QBE object reuse; no incremental frontend claim."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
LEXER = ROOT / 'selfhost/tools/performance/phase132/symbols/compact.py'
spec = importlib.util.spec_from_file_location('qbe_tokens', LEXER)
L = importlib.util.module_from_spec(spec); spec.loader.exec_module(L)
POLICY = 'phase132-closed-image-contiguous-qbe-units-v1'
FLAGS = dict(qbe=['-t', 'amd64_sysv'], assembler=['-mbranches-within-32B-boundaries'],
             linker=['-no-pie', '-Wl,--build-id=none'], libraries=['-pthread', '-lm'])


def require(ok, message):
    if not ok: raise ValueError(message)


def pin(path): return L.pin(path)


def verify(row):
    require(pin(row['file']) == row, 'Changed input: ' + row['file'])
    return Path(row['file'])


def hashed(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def save(path, value): path.write_text(json.dumps(value, indent=2) + '\n')


def read(path): return json.loads(Path(path).read_text())


def fresh(path):
    path = path.resolve()
    require(path.is_relative_to(ROOT/'selfhost/build/phase132') and not path.exists(), 'Fresh Phase132 path required')
    path.mkdir(parents=True)
    return path


def records(path):
    """Recognize the emitted top-level grammar; retain complete original spans."""
    rows, gaps, active, depth, start, line_no = [], [], None, 0, 0, 0
    with path.open('rb') as stream:
        while line := stream.readline():
            line_no += 1; end = start + len(line)
            tokens = list(L.tokens(line))
            globals_ = [v for k, _, _, v in tokens if k == 'global']
            masked = bytearray(line)
            for k, a, b, _ in tokens:
                if k in ['string', 'comment']: masked[a:b] = b' '*(b-a)
            header = L.HEADER.match(line)
            type_header = re.match(rb'^\s*type\s+(:[A-Za-z_][A-Za-z0-9_.]*)\s*=', line)
            if active is None:
                if not header and not type_header:
                    require(not bytes(masked).strip(), 'Unsupported top-level bytes at line ' + str(line_no))
                    gaps.append((start, end)); start = end; continue
                kind = header[2].decode() if header else 'type'
                require(kind == 'type' or globals_, 'Definition lacks symbol')
                name = globals_[0].decode() if header else type_header[1].decode()
                active = dict(kind=kind, name=name, exported=bool(header and header[1]),
                              start=start, line=line_no, header=line, refs=set())
                require(b'{' in masked, 'Multiline declaration header not supported')
            else:
                require(not header and not type_header, 'Nested top-level declaration')
            active['refs'].update(v.decode() for v in globals_)
            depth += masked.count(b'{') - masked.count(b'}')
            require(depth >= 0, 'Unbalanced braces')
            if depth == 0:
                active['end'] = end; rows.append(active); active = None
            start = end
    require(active is None and start == path.stat().st_size, 'Unterminated declaration')
    names = [r['name'] for r in rows]
    require(len(names) == len(set(names)), 'Duplicate global/type declaration')
    spans = sorted([(r['start'], r['end']) for r in rows] + gaps)
    require(spans and spans[0][0] == 0 and spans[-1][1] == start
            and all(a[1] == b[0] for a, b in zip(spans, spans[1:])), 'Input span coverage differs')
    return rows, gaps


def prepare(args):
    begun = time.monotonic(); source = args.source.resolve(); source_pin = pin(source)
    require(1 <= args.functions <= 4096, 'Unsupported unit size')
    scan_start = time.monotonic(); rows, gaps = records(source); scan_seconds = time.monotonic()-scan_start
    out = fresh(args.out); units = {}; functions = 0
    types = [r for r in rows if r['kind'] == 'type']
    for row in rows:
        if row['kind'] == 'type': continue
        row['unit'] = f'functions-{functions//args.functions:04d}' if row['kind'] == 'function' else 'data'
        if row['kind'] == 'function': functions += 1
        units.setdefault(row['unit'], []).append(row)
    definitions = {r['name']: r for r in rows if r['kind'] != 'type'}
    promoted = set()
    for row in definitions.values():
        for symbol in row['refs']:
            target = definitions.get(symbol)
            if target and target['unit'] != row['unit'] and not target['exported']: promoted.add(symbol)
    qbe = ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe'
    context = dict(policy=POLICY, method=pin(__file__), lexer=pin(LEXER), runtime=pin(args.runtime),
                   qbe=pin(qbe), assembler=pin(shutil.which('as')), linker=pin(shutil.which('gcc')), flags=FLAGS)
    plan = dict(kind=POLICY, complete=False, source=source_pin, context=context,
                functionsPerUnit=args.functions, functions=functions, data=sum(r['kind']=='data' for r in rows),
                types=len(types), promotedSymbols=sorted(promoted), units=[],
                abiPolicy='Only cross-unit private definitions gain export. All original exports, names, signatures, '
                          'data initializers and instruction bytes remain. Closed statically linked no-PIE image only; '
                          'not an ABI-compatible library replacement. QBE/assembler local labels are object-local.',
                scope='Full emitted QBE remains required. Whole token scan, hashing, materialization, lookup, link and qualification are charged separately.')
    with source.open('rb') as original:
        def body(row):
            original.seek(row['start']); return original.read(row['end']-row['start'])
        type_bytes = b''.join(body(r)+b'\n' for r in types)
        for unit_id in sorted(units, key=lambda n: (n == 'data', n)):
            members = units[unit_id]; path = out/(unit_id+'.ssa')
            with path.open('xb') as target:
                target.write(type_bytes)
                for row in members:
                    raw = body(row)
                    target.write((b'export ' if row['name'] in promoted else b'') + raw + b'\n')
            referenced = set().union(*(r['refs'] for r in members))
            bindings = []
            for name in sorted(referenced):
                declaration = definitions.get(name)
                if declaration and declaration['unit'] != unit_id:
                    # Definition/body addresses and numeric IDs are already literal bytes in current IR.
                    # Cross-unit ABI identity covers symbol kind/header; the current whole program is the authority.
                    header = declaration['header'].split(b'{', 1)[0]
                    bindings.append(dict(symbol=name, kind=declaration['kind'], headerSha256=hashlib.sha256(header).hexdigest(),
                                         exported=declaration['exported'] or name in promoted))
                elif not declaration: bindings.append(dict(symbol=name, external=True))
            ir = pin(path); binding_hash = hashed(bindings)
            key = hashed(dict(context=context, irSha256=ir['sha256'], bindingSha256=binding_hash))
            plan['units'].append(dict(id=unit_id, ir=ir, key=key, bindings=bindings, bindingSha256=binding_hash,
                                      definitions=len(members), promoted=sum(r['name'] in promoted for r in members)))
    require(pin(source) == source_pin, 'Source changed while partitioning')
    plan.update(complete=True, scanSeconds=scan_seconds, prepareSeconds=time.monotonic()-begun,
                affinity=sorted(os.sched_getaffinity(0)), sourceSpansCoverEveryByte=True,
                ignoredGaps='Only lexically empty/comment-only top-level gaps; declaration bytes preserved apart from export prefix.')
    save(out/'plan.json', plan)
    print(json.dumps(dict(complete=True, plan=pin(out/'plan.json'), units=len(plan['units']), promoted=len(promoted), prepareSeconds=plan['prepareSeconds'])))


def build(args):
    begun = time.monotonic(); plan_path = args.plan.resolve(); plan = read(plan_path)
    require(plan['complete'] and plan['kind'] == POLICY and plan['context']['flags'] == FLAGS, 'Wrong plan')
    context = plan['context']; require(context['method'] == pin(__file__) and context['lexer'] == pin(LEXER), 'Method changed')
    out = fresh(args.out); cache = args.cache.resolve()
    require(cache.is_relative_to(ROOT/'selfhost/build/phase132'), 'Cache outside Phase132')
    if args.cold: require(not cache.exists(), 'Cold build requires a nonexistent cache')
    cache.mkdir(parents=True, exist_ok=True)
    for key in ['runtime', 'qbe', 'assembler', 'linker']: verify(context[key])
    verify(plan['source'])
    report = dict(kind=POLICY+'-build', complete=False, plan=pin(plan_path), context=context, cache=str(cache),
                  cold=args.cold, units=[], jobs=[], affinity=sorted(os.sched_getaffinity(0)),
                  frontendAcquisitionIncluded=False, preparation=plan['prepareSeconds'], scope=plan['scope'])
    def checkpoint(): save(out/'report.json', report)
    def run(label, command, directory):
        start = time.monotonic(); row = dict(label=label, command=list(map(str, command))); report['jobs'].append(row); checkpoint()
        with (directory/(label+'.stdout')).open('xb') as stdout, (directory/(label+'.stderr')).open('xb') as stderr:
            result = subprocess.run(row['command'], cwd=ROOT, stdout=stdout, stderr=stderr, timeout=args.seconds)
        row.update(seconds=time.monotonic()-start, exitCode=result.returncode,
                   stdout=pin(directory/(label+'.stdout')), stderr=pin(directory/(label+'.stderr'))); checkpoint()
        require(result.returncode == 0, 'Build child failed: ' + label)
    checkpoint()
    try:
        objects = []; lookup_started = time.monotonic(); lookup_seconds = 0
        for unit in plan['units']:
            lookup_started = time.monotonic(); verify(unit['ir'])
            require(unit['bindingSha256'] == hashed(unit['bindings']) and unit['key'] == hashed(dict(context=context,
                    irSha256=unit['ir']['sha256'], bindingSha256=unit['bindingSha256'])), 'Cache key differs')
            entry = cache/unit['key']; reused = entry.exists()
            if reused:
                receipt = read(entry/'receipt.json')
                require(receipt['complete'] and receipt['key'] == unit['key'] and receipt['context'] == context
                        and receipt['irSha256'] == unit['ir']['sha256'] and receipt['bindingSha256'] == unit['bindingSha256'], 'Cache admission differs')
                obj = verify(receipt['object'])
            lookup_seconds += time.monotonic()-lookup_started
            if not reused:
                entry.mkdir()
                run(unit['id']+'-qbe', [context['qbe']['file'], *FLAGS['qbe'], '-o', entry/'unit.s', unit['ir']['file']], entry)
                run(unit['id']+'-assemble', [context['assembler']['file'], *FLAGS['assembler'], '-o', entry/'unit.o', entry/'unit.s'], entry)
                obj = entry/'unit.o'
                save(entry/'receipt.json', dict(complete=True, key=unit['key'], context=context,
                     irSha256=unit['ir']['sha256'], bindingSha256=unit['bindingSha256'], originPlan=report['plan'], object=pin(obj)))
            objects.append(obj)
            report['units'].append(dict(id=unit['id'], key=unit['key'], reused=reused, object=pin(obj), receipt=pin(entry/'receipt.json'))); checkpoint()
        run('link', [context['linker']['file'], *FLAGS['linker'], *objects, context['runtime']['file'], *FLAGS['libraries'], '-o', out/'program'], out)
        report.update(binary=pin(out/'program'), reusedUnits=sum(r['reused'] for r in report['units']),
                      builtUnits=sum(not r['reused'] for r in report['units']), lookupSeconds=lookup_seconds,
                      childBuildSeconds=sum(r['seconds'] for r in report['jobs']), buildSeconds=time.monotonic()-begun,
                      coldAcquisition='Complete QBE generation and initial cold cache are separate prior costs, never hidden in incremental timing.')
        verify(report['plan']); verify(plan['source'])
        for row in report['units']: verify(row['object']); verify(row['receipt'])
        report.update(complete=True); checkpoint(); print(json.dumps({k:report[k] for k in ['complete','reusedUnits','builtUnits','buildSeconds','binary']}))
    except BaseException as error:
        report['error'] = repr(error); checkpoint(); raise


def allocated(path):
    data = path.read_bytes(); require(data[:6] == b'\x7fELF\x02\x01', 'Expected ELF64 little endian')
    shoff = struct.unpack_from('<Q', data, 40)[0]; size, count, names_index = struct.unpack_from('<HHH', data, 58)
    require(size == 64 and count > 0, 'Unsupported section table')
    sections = [struct.unpack_from('<IIQQQQIIQQ', data, shoff+i*size) for i in range(count)]
    strings = sections[names_index]; names = data[strings[4]:strings[4]+strings[5]]; result=[]
    for row in sections:
        if not row[2] & 2: continue
        end = names.index(0, row[0]); name = names[row[0]:end].decode()
        payload = b'' if row[1] == 8 else data[row[4]:row[4]+row[5]]
        require(row[1] == 8 or len(payload) == row[5], 'Truncated section')
        result.append(dict(name=name, type=row[1], flags=row[2], address=row[3], bytes=row[5], alignment=row[8], sha256=hashlib.sha256(payload).hexdigest()))
    return result


def compare(args):
    begun=time.monotonic(); left=read(args.cached); right=read(args.fresh)
    require(left['complete'] and right['complete'] and left['plan'] == right['plan'] and left['context'] == right['context'], 'Different current build inputs')
    require(not left['cold'] and right['cold'] and right['reusedUnits'] == 0 and left['cache'] != right['cache'], 'Independent fresh cache required')
    a, b = allocated(verify(left['binary'])), allocated(verify(right['binary']))
    require(a == b, 'Allocated machine sections differ')
    out=fresh(args.out)
    result=dict(complete=True, targetsRun=False, cached=pin(args.cached), fresh=pin(args.fresh),
                allocatedSectionsExact=True, sections=a, seconds=time.monotonic()-begun,
                scope='Current cached versus independent full partitioned build only. Ordinary runtime outputs and monolithic/compiler conformance require separate gates.')
    save(out/'report.json',result);print(json.dumps(dict(complete=True,report=pin(out/'report.json'))))


def main():
    p=argparse.ArgumentParser(description=__doc__);subs=p.add_subparsers(dest='mode',required=True)
    a=subs.add_parser('prepare');a.add_argument('--source',type=Path,required=True);a.add_argument('--runtime',type=Path,required=True);a.add_argument('--out',type=Path,required=True);a.add_argument('--functions',type=int,default=1000)
    b=subs.add_parser('build');b.add_argument('--plan',type=Path,required=True);b.add_argument('--cache',type=Path,required=True);b.add_argument('--out',type=Path,required=True);b.add_argument('--cold',action='store_true');b.add_argument('--seconds',type=int,default=90)
    c=subs.add_parser('compare');c.add_argument('--cached',type=Path,required=True);c.add_argument('--fresh',type=Path,required=True);c.add_argument('--out',type=Path,required=True)
    args=p.parse_args(); {'prepare':prepare,'build':build,'compare':compare}[args.mode](args)


if __name__ == '__main__': main()
