#!/usr/bin/env python3
"""Metadata-only recovery of a guarded native45 emission stopped after 44 rows.

Accept exactly the frozen catalog's 44 completed rows plus a separately completed
last row, using the same emitter/API/base binding. Never executes compiler code.
"""
import argparse
import copy
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT / 'selfhost/tools/bench'), str(ROOT / 'selfhost/tools/build')]
import bench as B
import common as C

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
EMITTER = Path(__file__).with_name('emit-programs.mjs')
LIMIT = 16 * 1024 * 1024


def document(path):
    identity = C.pin(path)
    C.require(identity['bytes'] <= LIMIT, 'Oversized metadata receipt')
    return B.read(path), identity


def pins(value):
    """Collect every declared file identity, including nested product receipts."""
    if isinstance(value, dict):
        if {'file', 'bytes', 'sha256'} <= value.keys():
            yield {key: value[key] for key in ('file', 'bytes', 'sha256')}
        else:
            for child in value.values():
                yield from pins(child)
    elif isinstance(value, list):
        for child in value:
            yield from pins(child)


def verify_all(entries):
    entries = B.unique_inputs(entries)
    for entry in entries:
        C.require(C.pin(entry['file']) == entry, 'Changed or noncanonical identity: ' + entry['file'])
    return entries


def read_emission(path, catalog, partial):
    report, receipt = document(path)
    C.require(report.get('kind') == 'phase185-checked-native-emission'
              and report.get('target') in ('qbe', 'x86') and not report.get('error')
              and not report.get('changedInputs'), 'Invalid or errored emission report')
    C.require(report.get('complete') is (not partial), 'Unexpected emission completion state')
    rows, inputs = report.get('rows', []), report.get('inputs', [])
    names = [case['id'] for case in catalog]
    expected = names if partial else names[-1:]
    C.require([row['id'] for row in rows] == expected, 'Expected ordered first 44 plus incomplete last, or last-only supplement')
    C.require(len(inputs) == 9 + len(rows), 'Unexpected emitter input layout')
    checked = verify_all([receipt, *pins(report)])
    prefix = inputs[:9]
    emitter, engine, authority_pin, source, api, binding_pin, base, carrier, catalog_pin = prefix
    C.require(emitter == C.pin(EMITTER) and catalog_pin == C.pin(CATALOG), 'Emitter or frozen catalog differs')
    authority, _ = document(authority_pin['file'])
    binding, _ = document(binding_pin['file'])
    C.require(authority.get('kind') == 'bend-checked-hosted-api'
              and authority.get('complete') is True and authority.get('checked') is True
              and not authority.get('error') and not authority.get('changedInputs')
              and authority.get('api') == api and authority.get('source') == source,
              'Checked API authority differs')
    C.require(binding.get('kind') == 'phase175-prepared-base'
              and binding.get('base') == base and binding.get('carrier') == carrier
              and binding.get('engine') == engine and isinstance(binding.get('stamp'), str)
              and binding['stamp'], 'Prepared base binding differs')
    checked = verify_all([*checked, *pins(authority), *pins(binding)])
    suffix = '.ssa' if report['target'] == 'qbe' else '.s'
    known = {case['id']: case for case in catalog}
    for index, row in enumerate(rows):
        C.require(row.get('source') == known[row['id']]['source'] == inputs[9 + index],
                  'Row source differs from frozen catalog')
        if partial and index == 44:
            C.require(row.get('complete') is False, 'Partial last row must be incomplete')
            continue
        C.require(row.get('complete') is True and row.get('verified') is True
                  and not row.get('error'), 'Incomplete, unverified or errored row cannot be reused')
        product = row.get('product', {})
        C.require(0 < product.get('bytes', 0) <= 128 * 1024 * 1024
                  and Path(product.get('file', '')).suffix == suffix
                  and Path(product['file']).parent == Path(receipt['file']).parent / row['id'],
                  'Invalid emitted product identity or location')
    return dict(report=report, receipt=receipt, prefix=prefix, checked=checked)


def guard(path, emitted, partial):
    receipt, identity = document(path)
    report, prefix = emitted['report'], emitted['prefix']
    root = str(Path(emitted['receipt']['file']).parent)
    C.require(receipt.get('kind') == 'build-retention-disk-guard-v1'
              and receipt.get('artifactRoots') == [root]
              and receipt.get('method', {}).get('cpu') == '3'
              and 0 < receipt.get('rssLimitBytes', 0) <= 2 * 1024**3
              and receipt.get('diskReserveBytes', 0) >= 5 * 1024**3,
              'Guard ownership or resource limits differ')
    if partial:
        C.require(receipt.get('complete') is False and receipt.get('stoppedFor') == 'deadline'
                  and receipt.get('returncode') == -9 and receipt.get('wallSeconds', 0) >= 180,
                  'Partial report requires its failed 180-second deadline guard')
    else:
        C.require(receipt.get('complete') is True and receipt.get('returncode') == 0
                  and not receipt.get('stoppedFor'), 'Supplement guard did not complete')
    method = receipt['method']
    method_pins = [dict(file=value['path'], bytes=value['bytes'], sha256=value['sha256'])
                   for value in [method['guard'], method['support'], *method['commandFiles']]]
    checked = verify_all([identity, *method_pins])
    C.require(all(pin in checked for pin in (prefix[0], prefix[1], prefix[2], prefix[5])),
              'Guard command identities differ from emission')
    command = receipt['command']
    matches = [i for i, token in enumerate(command)
               if str((ROOT / token).resolve()) == prefix[0]['file']]
    C.require(len(matches) == 1 and matches[0] > 0, 'Guard must invoke the pinned emitter once')
    start = matches[0]
    C.require(str((ROOT / command[start - 1]).resolve()) == prefix[1]['file'], 'Guard engine differs')
    args = command[start + 1:]
    C.require(len(args) == 10 and len(set(args[::2])) == 5, 'Unexpected guarded emitter arguments')
    options = dict(zip(args[::2], args[1::2]))
    C.require(set(options) == {'--api', '--binding', '--target', '--cases', '--out'}, 'Unexpected emitter options')
    C.require(str((ROOT / options['--api']).resolve()) == prefix[2]['file']
              and str((ROOT / options['--binding']).resolve()) == prefix[5]['file']
              and str((ROOT / options['--out']).resolve()) == root
              and options['--target'] == report['target']
              and options['--cases'] == ('all' if partial else report['rows'][0]['id']),
              'Guard command does not authenticate this emission scope')
    return dict(receipt=identity, stoppedFor=receipt.get('stoppedFor'),
                complete=receipt['complete'], wallSeconds=receipt['wallSeconds'], checked=checked)


def merge(a):
    catalog = B.catalog(CATALOG)['cases']
    C.require(len(catalog) == 45, 'Exactly frozen native45 required')
    partial = read_emission(a.partial, catalog, True)
    supplement = read_emission(a.supplement, catalog, False)
    C.require(partial['prefix'] == supplement['prefix']
              and partial['report']['target'] == supplement['report']['target'],
              'Emitter, engine, checked API, binding or catalog identity differs')
    partial_guard = guard(a.partial_guard, partial, True)
    supplement_guard = guard(a.supplement_guard, supplement, False)
    inputs = verify_all([C.pin(__file__), C.pin(B.__file__), C.pin(C.__file__),
        *partial['checked'], *supplement['checked'], *partial_guard['checked'], *supplement_guard['checked']])
    rows = []
    for source, selected in ((partial, partial['report']['rows'][:44]),
                             (supplement, supplement['report']['rows'])):
        for value in selected:
            row = copy.deepcopy(value)
            row['parentEmission'] = source['receipt']
            rows.append(row)
    C.require([row['id'] for row in rows] == [case['id'] for case in catalog], 'Coverage must be exactly frozen native45')
    report = dict(kind='phase185-checked-native-emission', version=1, complete=True,
        target=partial['report']['target'], inputs=inputs, rows=rows, targetsRun=False,
        scope='Metadata union of 45 individually completed, verified emissions with identical checked API/base/catalog identities. The first parent campaign failed its 180-second guard deadline; its incomplete last row is discarded. No compiler code, native build or program execution occurs here; no single successful emission campaign is claimed.',
        merge=dict(kind='phase185-44-plus-1-deadline-recovery',
            partial=partial['receipt'], supplement=supplement['receipt'],
            partialGuard={k: v for k, v in partial_guard.items() if k != 'checked'},
            supplementGuard={k: v for k, v in supplement_guard.items() if k != 'checked'},
            discardedRows=[dict(id=catalog[-1]['id'], reason='Incomplete deadline-stopped row; never reused')],
            reusedCompletedRows=44, separatelyCompletedRows=1, fullCatalog=True))
    out = C.fresh_output(a.out, ROOT)
    C.write_json(out / 'report.json', report)
    return dict(complete=True, targetsRun=False, report=str(out / 'report.json'), rows=len(rows))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--partial', type=Path, required=True)
    p.add_argument('--partial-guard', type=Path, required=True)
    p.add_argument('--supplement', type=Path, required=True)
    p.add_argument('--supplement-guard', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    print(json.dumps(merge(p.parse_args())))


if __name__ == '__main__':
    main()
