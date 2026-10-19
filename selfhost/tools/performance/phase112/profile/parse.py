#!/usr/bin/env python3
"""Validate complete diagnostic records and unchanged observable output offline."""
import argparse
import hashlib
import json
import math
import re
from pathlib import Path
from prepare import COUNTERS, HISTOGRAMS, SOURCE_SHA, ROOT

PREFIX = b'P112_PROFILE '


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def unique_object(pairs):
    out = {}
    for key, value in pairs:
        if key in out:
            raise ValueError('duplicate JSON key: ' + key)
        out[key] = value
    return out


def integer(value, minimum=0, maximum=(1 << 64) - 1):
    if type(value) is not int or not minimum <= value <= maximum:
        raise ValueError('invalid integer: ' + repr(value))
    return value


def decode_symbol(symbol):
    encoded = symbol.removeprefix('p111_FID_')
    if symbol.startswith('p111_FID_') and re.fullmatch(r'(?:\d+_)+', encoded):
        try:
            return ''.join(chr(int(x)) for x in encoded.rstrip('_').split('_'))
        except ValueError:
            pass
    return symbol


def validate_output(stdout, stderr, expected, wall_seconds=None):
    if stderr != expected['stderr'].encode():
        raise ValueError('observable stderr differs from independent expected output')
    if expected.get('kind') == 'phase112-diagnostic-batch-output':
        prefix = expected['stdoutPrefix'].encode()
        if (expected.get('suffixRule') != 'unsigned-decimal-milliseconds-newline' or
                wall_seconds is None or not math.isfinite(wall_seconds) or wall_seconds < 0 or
                not stdout.startswith(prefix)):
            raise ValueError('invalid batch stdout prefix or observation metadata')
        suffix = stdout[len(prefix):]
        if re.fullmatch(rb'[0-9]+\n', suffix) is None or int(suffix[:-1]) > wall_seconds * 1000 + 2:
            raise ValueError('invalid batch elapsed suffix; diagnostic elapsed value is not a benchmark')
        return 'exact frozen result and requested success counts; numeric elapsed suffix only'
    if stdout != expected['stdout'].encode():
        raise ValueError('observable stdout differs from independent frozen expected output')
    return 'exact frozen stdout and stderr'


def parse_records(raw):
    records, remaining = [], []
    for line in raw.splitlines(keepends=True):
        if line.startswith(PREFIX):
            if not line.endswith(b'\n'):
                raise ValueError('truncated diagnostic line')
            records.append(json.loads(line[len(PREFIX):], object_pairs_hook=unique_object))
        else:
            remaining.append(line)
    if len(records) < 2 or records[0].get('type') != 'meta' or records[-1].get('type') != 'end':
        raise ValueError('missing complete diagnostic report')
    meta, end = records[0], records[-1]
    if set(meta) != {'type', 'version', 'sourceSha256', 'heapRc', 'abi', 'segments', 'constructors', 'transportWidth'}:
        raise ValueError('unexpected metadata fields')
    if meta['version'] != 1 or meta['sourceSha256'] != SOURCE_SHA or meta['abi'] != 11101 or type(meta['heapRc']) is not bool:
        raise ValueError('wrong diagnostic source/version/ABI')
    integer(meta['segments'], 1, 65532)
    integer(meta['constructors'], 1, 65536)
    integer(meta['transportWidth'], 2, 256)
    if set(end) != {'type', 'rows', 'invalid'} or integer(end['invalid']) != 0 or integer(end['rows']) != len(records) - 2:
        raise ValueError('incomplete/overflowed/out-of-range diagnostic report')
    counters, hist = {}, {name: {} for name in HISTOGRAMS}
    for record in records[1:-1]:
        name = record.get('name')
        count = integer(record.get('count'))
        if record.get('type') == 'counter':
            if set(record) != {'type', 'name', 'count'} or name not in COUNTERS or name in counters:
                raise ValueError('invalid/duplicate counter: ' + repr(record))
            counters[name] = count
        elif record.get('type') == 'histogram':
            if set(record) not in ({'type', 'name', 'index', 'count'}, {'type', 'name', 'index', 'count', 'symbol'}) or name not in HISTOGRAMS:
                raise ValueError('invalid histogram: ' + repr(record))
            size, kind = HISTOGRAMS[name]
            index = integer(record['index'], 0, size - 1)
            if str(index) in hist[name] or not count:
                raise ValueError('duplicate/zero histogram row')
            if 'symbol' in record and (kind != 'cid' or not isinstance(record['symbol'], str)):
                raise ValueError('invalid constructor symbol')
            if kind == 'fid' and index >= meta['segments'] + 4 and not (name == 'public_calls_fid' and index == 65535):
                raise ValueError('FID outside descriptor')
            if kind == 'cid' and index >= meta['constructors']:
                raise ValueError('CID outside descriptor')
            hist[name][str(index)] = record
        else:
            raise ValueError('unexpected record type')
    if set(counters) != set(COUNTERS):
        raise ValueError('incomplete counter catalogue')
    for name, counter in [('op', 'rt_op'), ('ctor_cid', 'rt_ctor'), ('ctor_arity', 'rt_ctor'),
        ('take_cid', 'rt_take'), ('take_arity', 'rt_take'), ('frame_fid', 'rt_frame'),
        ('frame_captures', 'rt_frame'), ('jump_fid', 'rt_jump'), ('jump_arity', 'rt_jump'),
        ('closure_fid', 'rt_closure'), ('closure_captures', 'rt_closure'), ('apply_fid', 'rt_apply'),
        ('return_width', 'rt_return'), ('special_ctor_kind', 'rt_special_ctor'),
        ('special_test_kind', 'rt_special_test'), ('special_take_kind', 'rt_special_take')]:
        if sum(r['count'] for r in hist[name].values()) != counters[counter]:
            raise ValueError('histogram/counter mismatch: ' + name)
    if sum(r['count'] for r in hist['public_calls_fid'].values()) != sum(counters['rt_' + n] for n in
        ['keep', 'sink', 'tag', 'ctor', 'take', 'closure', 'frame', 'jump', 'return', 'apply',
         'stack_pop', 'stack_get', 'reg_get', 'fail', 'op', 'special_ctor', 'special_test', 'special_take']):
        raise ValueError('public-call total mismatch')
    return meta, counters, hist, b''.join(remaining)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['stdout', 'stderr', 'expected', 'runtime-manifest', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--status', type=int, required=True)
    p.add_argument('--qbe', type=Path)
    p.add_argument('--counter-expect', type=Path)
    p.add_argument('--wall-seconds', type=float, help='Only validates a diagnostic batch elapsed suffix; not a performance sample')
    a = p.parse_args()
    if a.out.exists():
        raise SystemExit('refusing existing output directory')
    inputs = [pin(path) for path in [a.stdout, a.stderr, a.expected, a.runtime_manifest,
                                   Path(__file__), Path(__file__).with_name('prepare.py')]]
    expected = json.loads(a.expected.read_text(), object_pairs_hook=unique_object)
    if a.status != 0 or expected['status'] != 0:
        raise SystemExit('successful diagnostic execution required; nonzero status is not a profile')
    runtime = json.loads(a.runtime_manifest.read_text())
    if runtime.get('kind') != 'phase112-diagnostic-runtime' or runtime['source']['sha256'] != SOURCE_SHA:
        raise SystemExit('wrong runtime manifest')
    for frozen in runtime['output']:
        actual = pin(Path(frozen['file']))
        if actual['sha256'] != frozen['sha256'] or actual['bytes'] != frozen['bytes']:
            raise SystemExit('materialized runtime changed: ' + frozen['file'])
        inputs.append(actual)
    meta, counters, hist, clean = parse_records(a.stderr.read_bytes())
    if runtime['heapRc'] != meta['heapRc']:
        raise SystemExit('runtime instrumentation mode mismatch')
    output_rule = validate_output(a.stdout.read_bytes(), clean, expected, a.wall_seconds)
    fids = {}
    if a.qbe:
        inputs.append(pin(a.qbe))
        ssa = a.qbe.read_text()
        table = re.findall(r'^data \$p111_segments = align 8 \{([^}]+)\}$', ssa, re.M)
        if len(table) != 1:
            raise SystemExit('expected one QBE segment table')
        symbols = re.findall(r'l \$([A-Za-z0-9_.$]+)', table[0])
        if len(symbols) != meta['segments'] or re.sub(r'l \$[A-Za-z0-9_.$]+|[\s,]', '', table[0]):
            raise SystemExit('QBE segment table does not match descriptor')
        fids.update({i: dict(symbol=s, decoded=decode_symbol(s)) for i, s in enumerate(symbols)})
    fids.update({meta['segments'] + i: dict(symbol=s, decoded=s) for i, s in
                 enumerate(['IO_EMIT', 'CLO_APPLY', 'EXIT', 'ENTER'])})
    catalogue = ROOT / 'selfhost/tools/performance/phase111/runtime/catalogue.json'
    inputs.append(pin(catalogue))
    operations = {op['id']: op['name'] for op in json.loads(catalogue.read_text())['operations']}
    for name, buckets in hist.items():
        kind = HISTOGRAMS[name][1]
        for index, row in buckets.items():
            if kind == 'fid' and int(index) in fids:
                row.update(fids[int(index)])
            elif kind == 'op':
                row['symbol'] = operations.get(int(index), 'unknown')
    if a.counter_expect:
        inputs.append(pin(a.counter_expect))
        freeze = a.counter_expect.with_name('control-freeze.json')
        inputs.append(pin(freeze))
        frozen = json.loads(freeze.read_text())
        pinned_counts = False
        for record in frozen['files']:
            actual = pin(ROOT / record['file'])
            if actual['sha256'] != record['sha256'] or actual['bytes'] != record['bytes']:
                raise SystemExit('independent control freeze changed: ' + record['file'])
            pinned_counts |= actual['file'] == str(a.counter_expect.resolve())
            inputs.append(actual)
        if not pinned_counts:
            raise SystemExit('counter expectations are not pinned by control freeze')
        checks = json.loads(a.counter_expect.read_text())
        for name, value in checks.get('counters', {}).items():
            if counters[name] != value:
                raise SystemExit(f'independent counter mismatch: {name}: {counters[name]} != {value}')
        for name, buckets in checks.get('histograms', {}).items():
            actual = {index: row['count'] for index, row in hist[name].items()}
            if actual != buckets:
                raise SystemExit(f'independent histogram mismatch: {name}: {actual} != {buckets}')
    ranking = {name: sorted(rows.values(), key=lambda row: (-row['count'], row['index']))
               for name, rows in hist.items()}
    report = dict(kind='phase112-runtime-count-profile', version=1, complete=True,
                  diagnosticOnly=True, inputs=inputs, meta=meta, counters=counters,
                  histograms=ranking, independentCounterControl=bool(a.counter_expect),
                  outputValidation=output_rule,
                  note='Counts are source-level invocations, not disjoint costs or native machine calls. Instrumented execution time is not a benchmark.')
    a.out.mkdir(parents=True)
    (a.out / 'stderr.cleaned').write_bytes(clean)
    (a.out / 'profile.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, profile=str(a.out / 'profile.json'),
                          publicCalls=sum(row['count'] for row in ranking['public_calls_fid']),
                          dispatches=sum(row['count'] for row in ranking['dispatch_fid']))))


if __name__ == '__main__':
    main()
