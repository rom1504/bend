#!/usr/bin/env python3
"""Read-only streaming QBE census; no compiler or generated program execution."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
import pathlib
import re
import resource
import struct
import time
import zlib

FUNCTION = re.compile(rb'^(export )?function\b.*?\$([^ (]+)')
DATA = re.compile(rb'^(export )?data\s+\$([^ =]+)')
TOKENS = re.compile(rb'"(?:[^"\\]|\\.)*"|#[^\n]*|[$%@][A-Za-z0-9_.$]+|\s+|[^"$%@#\s]+|.', re.DOTALL)
ASSIGN = re.compile(rb'^%[^ ]+\s*=\w+\s+(\w+)')
CALL = re.compile(rb'\bcall\s+([$%][A-Za-z0-9_.$]+)')
DEF = re.compile(r'^(?:@unsafe\s+)?(?:def|type|enum|record)\s+([^\s(:]+)')


def pin(path):
    path = pathlib.Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        for data in iter(lambda: f.read(1 << 20), b''):
            h.update(data)
    return {'file': str(path), 'bytes': path.stat().st_size, 'sha256': h.hexdigest()}


def decode(name):
    m = re.fullmatch(r'[A-Za-z0-9_]+_FID_((?:[0-9]+_)+)', name)
    if not m:
        return name
    return ''.join(chr(int(x)) for x in m[1].split('_') if x)


def source_index(path):
    result = {}
    with pathlib.Path(path).open() as f:
        for line, text in enumerate(f, 1):
            m = DEF.match(text)
            if m:
                result[m[1]] = {'file': str(pathlib.Path(path).resolve()), 'line': line}
    return result


def category(record):
    name, decoded = record['symbol'], record['decoded']
    if name == 'main':
        return 'process_entry'
    if name.startswith('p111_'):
        calls = record['callsByTarget']
        # A syntactic adapter classification, not a reachability/semantic claim.
        if len(calls) == 1 and sum(calls.values()) == 1 and next(iter(calls)).startswith(('$p112w_', '$p113d_', '$p114r_')) and record['blocks'] == 1:
            return 'public_single_private_call_adapter'
        return 'public_continuation_segment' if decoded.startswith('$p111.k.') else 'public_named_segment'
    if name.startswith('p112w_'):
        return 'private_p112_worker'
    if name.startswith('p113d_'):
        if decoded.startswith('$p128borrow.owned.'):
            return 'private_owned_reader_fallback'
        if decoded.startswith('$p118borrow.read.'):
            return 'private_borrowed_reader'
        if decoded.startswith('$direct.'):
            return 'private_direct_worker_or_adapter'
        return 'private_other_p113_worker'
    if name.startswith('p114r_'):
        return 'private_recursive_region'
    return 'other_function'


def elf_sections(path):
    with open(path, 'rb') as f:
        head = f.read(64)
        assert head[:6] == b'\x7fELF\x02\x01', 'expected ELF64 little endian'
        fields = struct.unpack('<16sHHIQQQIHHHHHH', head)
        offset, width, count, names = fields[6], fields[11], fields[12], fields[13]
        assert width == 64 and count and names < count
        f.seek(offset)
        headers = [struct.unpack('<IIQQQQIIQQ', f.read(width)) for _ in range(count)]
        string_header = headers[names]
        f.seek(string_header[4])
        strings = f.read(string_header[5])
    rows = []
    for h in headers:
        name = strings[h[0]:].split(b'\0', 1)[0].decode()
        rows.append({'name': name, 'type': h[1], 'flags': h[2], 'bytes': h[5],
                     'allocated': bool(h[2] & 2), 'fileBacked': h[1] != 8})
    return {'sections': rows, 'allocatedFileBytes': sum(x['bytes'] for x in rows if x['allocated'] and x['fileBacked']),
            'allocatedZeroFillBytes': sum(x['bytes'] for x in rows if x['allocated'] and not x['fileBacked']),
            'sectionFileBytes': sum(x['bytes'] for x in rows if x['fileBacked'])}


def compression(path):
    results = []
    import zstandard
    for name, obj in [('gzip-9', zlib.compressobj(9, zlib.DEFLATED, 31)),
                      ('zstd-3', zstandard.ZstdCompressor(level=3).compressobj()),
                      ('zstd-19', zstandard.ZstdCompressor(level=19).compressobj())]:
        start = time.monotonic()
        count = 0
        h = hashlib.sha256()
        with open(path, 'rb') as f:
            for data in iter(lambda: f.read(1 << 20), b''):
                packed = obj.compress(data)
                count += len(packed)
                h.update(packed)
        packed = obj.flush()
        count += len(packed)
        h.update(packed)
        results.append({'codec': name, 'bytes': count, 'sha256': h.hexdigest(),
                        'seconds': time.monotonic() - start, 'retainedFile': False})
    return results


def run(args):
    start = time.monotonic()
    resource.setrlimit(resource.RLIMIT_AS, (2 << 30, 2 << 30))
    owner_doc = json.loads(pathlib.Path(args.owners).read_text())
    ownership = {r['symbol']: (r['lowered_owner'], r['owner_basis']) for r in owner_doc['functions']}
    owner_pin = owner_doc['identities']['qbe']
    owner_coverage = owner_doc['coverage']
    del owner_doc
    sources = source_index(args.base)
    sources.update(source_index(args.source))
    funcs = []
    data_rows = []
    global_occurrences = Counter()
    global_definitions = {}
    bytes_by_kind = Counter()
    token_occurrences = Counter()
    bytes_by_section = Counter()
    instructions = Counter()
    calls = Counter()
    exact_groups = defaultdict(list)
    normalized_groups = defaultdict(list)
    malformed = []
    qhash = hashlib.sha256()
    total_bytes = total_lines = 0
    record = None
    data_record = None
    local_names = label_names = None
    exact = normalized = None
    for line in pathlib.Path(args.qbe).open('rb'):
        total_lines += 1
        total_bytes += len(line)
        qhash.update(line)
        fmatch = FUNCTION.match(line)
        dmatch = DATA.match(line)
        if fmatch:
            assert record is None and data_record is None
            name = fmatch[2].decode()
            assert name not in global_definitions
            global_definitions[name] = ('function', bool(fmatch[1]))
            decoded = decode(name)
            lowered_owner, basis = ownership.get(name, (None, 'unknown'))
            source_name = lowered_owner
            source_basis = 'existing_lexical_segment_owner'
            if not source_name:
                for prefix in ['$p128borrow.owned.', '$p118borrow.read.', '$direct.', '$p118.trmc.$direct.']:
                    if decoded.startswith(prefix):
                        source_name = decoded[len(prefix):]
                        source_basis = 'encoded_adapter_origin_only'
                        break
            if source_name and source_name.startswith('$native.'):
                source_name = source_name[8:]
            record = {'symbol': name, 'decoded': decoded, 'line': total_lines,
                      'offset': total_bytes - len(line), 'bytes': 0, 'blocks': 0,
                      'instructions': 0, 'callsByTarget': Counter(), 'exported': bool(fmatch[1]),
                      'sourceName': source_name, 'sourceOrigin': sources.get(source_name),
                      'sourceOriginBasis': source_basis if source_name in sources else 'unknown',
                      'lexicalOwnerBasis': basis}
            local_names, label_names = {}, {}
            exact, normalized = hashlib.sha256(), hashlib.sha256()
        elif dmatch:
            assert record is None and data_record is None
            name = dmatch[2].decode()
            assert name not in global_definitions
            global_definitions[name] = ('data', bool(dmatch[1]))
            data_record = {'symbol': name, 'line': total_lines, 'bytes': 0, 'exported': bool(dmatch[1]),
                           'fieldsByWidth': Counter(), 'initializerBytes': 0, 'globalRelocations': 0}

        section = 'functions' if record else ('data' if data_record else 'interstitial')
        bytes_by_section[section] += len(line)
        clean = []
        for token in TOKENS.finditer(line):
            t = token[0]
            if t.startswith(b'"'):
                kind = 'quoted_strings'
            elif t.startswith(b'#'):
                kind = 'comments'
            elif t.isspace():
                kind = 'whitespace'
            elif t[:1] in (b'$', b'%', b'@'):
                kind = {b'$': 'global_symbols', b'%': 'local_symbols', b'@': 'block_labels'}[t[:1]]
                token_occurrences[kind] += 1
                if kind == 'global_symbols':
                    global_occurrences[t[1:].decode()] += 1
                    if data_record and (not dmatch or token.start() != dmatch.start(2) - 1):
                        data_record['globalRelocations'] += 1
            else:
                kind = 'other_syntax'
            bytes_by_kind[kind] += len(t)
            if kind != 'comments':
                clean.append(t)
            if record and kind not in ('comments', 'whitespace'):
                if t == b'$' + record['symbol'].encode():
                    t = b'$SELF'
                elif kind in ('local_symbols', 'block_labels'):
                    names = local_names if kind == 'local_symbols' else label_names
                    if t not in names:
                        names[t] = t[:1] + str(len(names)).encode()
                    t = names[t]
                normalized.update(t + b'\0')
        semantic = b''.join(clean).strip()
        if record:
            record['bytes'] += len(line)
            exact.update(FUNCTION.sub(lambda m: m[0].replace(b'$' + record['symbol'].encode(), b'$SELF'), line, count=1) if fmatch else line)
            if semantic.startswith(b'@'):
                record['blocks'] += 1
            elif semantic and not fmatch and semantic != b'}':
                match = ASSIGN.match(semantic)
                op = match[1] if match else semantic.split(None, 1)[0]
                if not re.fullmatch(rb'[a-z][a-z0-9]*', op):
                    malformed.append({'line': total_lines, 'prefix': semantic[:100].decode()})
                opname = op.decode()
                record['instructions'] += 1
                instructions[opname] += 1
                if op == b'call':
                    target_match = CALL.search(semantic)
                    assert target_match, semantic
                    target = target_match[1].decode()
                    calls[target if target.startswith('$') else '%indirect'] += 1
                    record['callsByTarget'][target if target.startswith('$') else '%indirect'] += 1
            if semantic == b'}':
                record['category'] = category(record)
                record['exactBodySha256'] = exact.hexdigest()
                record['alphaBodySha256'] = normalized.hexdigest()
                exact_groups[exact.hexdigest()].append(len(funcs))
                normalized_groups[normalized.hexdigest()].append(len(funcs))
                funcs.append(record)
                record = None
        if data_record:
            data_record['bytes'] += len(line)
            # This compiler emits typed numeric/relocation cells, one value each.
            initializer = semantic.split(b'{', 1)[-1] if dmatch else semantic
            for item in initializer.split(b','):
                m = re.match(rb'\s*([bhlwsdz])\s+([^}]+)', item)
                if m:
                    width = {b'b': 1, b'h': 2, b'w': 4, b's': 4, b'l': 8, b'd': 8}.get(m[1])
                    data_record['fieldsByWidth'][m[1].decode()] += 1
                    if width:
                        data_record['initializerBytes'] += width
                    elif m[1] == b'z':
                        data_record['initializerBytes'] += int(m[2].strip())
            if b'}' in semantic:
                data_rows.append(data_record)
                data_record = None
    assert record is None and data_record is None
    assert sum(bytes_by_kind.values()) == total_bytes
    assert sum(bytes_by_section.values()) == total_bytes
    assert total_bytes == owner_pin['bytes'] and qhash.hexdigest() == owner_pin['sha256']
    assert len(funcs) == owner_coverage['functions']
    assert not malformed, malformed[:10]
    categories = defaultdict(Counter)
    for f in funcs:
        c = categories[f['category']]
        c.update({'functions': 1, 'bytes': f['bytes'], 'blocks': f['blocks'],
                  'instructions': f['instructions'], 'calls': sum(f['callsByTarget'].values())})
    symbols = defaultdict(Counter)
    for name, occurrences in global_occurrences.items():
        definition = global_definitions.get(name)
        group = ('exported_' if definition[1] else 'private_') + definition[0] if definition else 'unresolved_external'
        symbols[group].update({'distinct': 1, 'occurrences': occurrences, 'bytes': occurrences * (len(name) + 1)})

    def short(f):
        return {k: f[k] for k in ['symbol', 'decoded', 'line', 'bytes', 'blocks', 'instructions', 'category', 'sourceName', 'sourceOrigin', 'sourceOriginBasis']}

    def duplicates(groups):
        repeated = [indexes for indexes in groups.values() if len(indexes) > 1]
        repeated.sort(key=lambda indexes: sum(funcs[i]['bytes'] for i in indexes[1:]), reverse=True)
        return {'groups': len(repeated), 'functionsInRepeatedGroups': sum(map(len, repeated)),
                'candidateRedundantRawBytes': sum(sum(funcs[i]['bytes'] for i in indexes[1:]) for indexes in repeated),
                'topGroups': [{'count': len(indexes), 'rawBytes': sum(funcs[i]['bytes'] for i in indexes),
                               'examples': [short(funcs[i]) for i in indexes[:4]]} for indexes in repeated[:15]]}

    origin_totals = defaultdict(Counter)
    for f in funcs:
        key = f['sourceName'] if f['sourceOrigin'] else '(unknown source origin)'
        origin_totals[key].update({'bytes': f['bytes'], 'functions': 1, 'instructions': f['instructions']})
    result = {'kind': 'phase132-streaming-qbe-census-v1', 'complete': True,
              'inputs': {'qbe': dict(owner_pin), 'source': pin(args.source), 'base': pin(args.base),
                         'binary': pin(args.binary), 'owners': pin(args.owners), 'method': pin(__file__)},
              'rawBytes': total_bytes, 'physicalLines': total_lines,
              'functions': len(funcs), 'blocks': sum(f['blocks'] for f in funcs),
              'instructions': sum(instructions.values()), 'calls': sum(calls.values()),
              'dataDeclarations': len(data_rows), 'sectionBytes': dict(bytes_by_section),
              'lexicalBytes': dict(bytes_by_kind), 'symbolOccurrences': dict(token_occurrences),
              'globalSymbolRoles': dict(symbols), 'disjointFunctionCategories': dict(categories),
              'opcodes': dict(instructions.most_common()), 'callTargets': dict(calls.most_common(50)),
              'allDirectCallSites': sum(v for k, v in calls.items() if k != '%indirect'),
              'indirectCallSites': calls['%indirect'], 'data': data_rows,
              'topFunctions': [short(f) for f in sorted(funcs, key=lambda x: x['bytes'], reverse=True)[:40]],
              'topSourceOwners': [{'name': n, **c, 'sourceOrigin': sources.get(n)} for n, c in sorted(origin_totals.items(), key=lambda x: x[1]['bytes'], reverse=True)[:40]],
              'sourceOriginCoverage': {'functions': sum(f['sourceOrigin'] is not None for f in funcs),
                                       'bytes': sum(f['bytes'] for f in funcs if f['sourceOrigin']),
                                       'unknownFunctions': sum(f['sourceOrigin'] is None for f in funcs)},
              'ownerMapCoverage': owner_coverage,
              'exactDefinitionNameErasedDuplicates': duplicates(exact_groups),
              'alphaNormalizedDuplicates': duplicates(normalized_groups),
              'largestGlobalSymbolsByOccurrenceBytes': [{'symbol': n, 'occurrences': c, 'bytes': c * (len(n) + 1),
                                                        'definition': global_definitions.get(n)} for n, c in sorted(global_occurrences.items(), key=lambda x: x[1] * (len(x[0]) + 1), reverse=True)[:30]],
              'elf': elf_sections(args.binary),
              'bounds': {'oneBytePerInstructionPlusData': sum(instructions.values()) + sum(d['initializerBytes'] for d in data_rows),
                         'fourByteMinimumInstructionLineOnly': 4 * sum(instructions.values()),
                         'scope': 'Illustrative inventory-preserving representation budgets, not an information-theoretic limit or a claim that instructions/functions cannot be eliminated.'},
              'limitations': ['No reachability or semantic equivalence analysis. Similar bodies are candidates only; addresses, linkage, fallbacks and dispatch identities may prohibit merging.',
                              'Source owners are authenticated names/lexical groups, not precise inlined instruction provenance or dynamic call ancestry.',
                              'Calls are static instruction counts. Occurrence bytes include definitions and relocations; they are not dynamic frequencies.',
                              'Data initializer byte count assumes observed scalar numeric/relocation syntax; ELF sections independently measure linked allocation.',
                              'Storage compression is not QBE input size, native instruction count, or runtime improvement.'],
              'streamingSecondsBeforeCompression': time.monotonic() - start}
    result['storageCompression'] = compression(args.qbe)
    result['resource'] = {'seconds': time.monotonic() - start, 'peakRssKiB': resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
                          'cpuAffinity': sorted(__import__('os').sched_getaffinity(0)), 'addressSpaceCapBytes': 2 << 30}
    out = pathlib.Path(args.out)
    assert not out.exists(), 'refuse overwrite'
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ['rawBytes', 'functions', 'blocks', 'instructions', 'calls', 'sectionBytes', 'lexicalBytes', 'globalSymbolRoles', 'resource']}, indent=2))


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--qbe', required=True)
    p.add_argument('--source', required=True)
    p.add_argument('--base', required=True)
    p.add_argument('--binary', required=True)
    p.add_argument('--owners', required=True)
    p.add_argument('--out', required=True)
    run(p.parse_args())
