#!/usr/bin/env python3
"""Compare retained QBE products by exact source identity; execute no targets.

References may be maintained qualification or benchmark-acquisition reports.
Names never establish a match. Historical method files are not imported.
"""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import changed_inputs, pin, require, same_bytes, verify


def identity(row):
    return {key: row[key] for key in ('bytes', 'sha256')}


def key(row):
    return row['bytes'], row['sha256']


class Evidence:
    def __init__(self):
        self.inputs = {}

    def keep(self, row):
        path = row['file']
        if path in self.inputs:
            require(self.inputs[path] == row, 'Conflicting pin: ' + path)
        else:
            verify(row)
            self.inputs[path] = row
        return row

    def read(self, value):
        row = self.keep(value if isinstance(value, dict) else pin(value))
        return json.loads(Path(row['file']).read_text()), row


def machine_identity(document, evidence):
    require(document.get('kind') == 'bend-native-build' and document.get('complete') is True
            and not document.get('changedInputs'), 'Incomplete or changed machine build')
    tools = {}
    pins = {row['file']: row for row in document['inputs']}
    for label in ('qbe', 'assemble', 'link'):
        jobs = [job for job in document['jobs'] if job['label'] == label]
        require(len(jobs) == 1 and jobs[0].get('complete') is True, 'Missing successful ' + label)
        executable = jobs[0]['command'][0]
        require(executable in pins, 'Unpinned machine executable')
        tools[label] = identity(evidence.keep(pins[executable]))
    return dict(runtime=identity(evidence.keep(document['runtime'])),
                runtimePolicy=document['runtimePolicy'], toolchain=document['toolchain'], tools=tools)


def emission(row, report_pin, machine_pin, evidence):
    document, ep = evidence.read(report_pin)
    require(document.get('kind') == 'bend-build-request' and document.get('complete') is True
            and not document.get('changedInputs') and document.get('host') == 'native'
            and document.get('target') == 'qbe', 'Expected completed native QBE request')
    process = document['process']
    require(process.get('complete') is True and process.get('exitCode') == 0
            and process['stderr']['bytes'] == 0, 'Emission process failed or diagnosed')
    require(key(row['source']) == key(document['source']), 'Source/report mismatch')
    source = evidence.keep(document['source'])
    product = evidence.keep(document['product'])
    require(product['bytes'] > 0, 'Empty QBE')
    machine, mp = evidence.read(machine_pin)
    require(key(machine['sourceIR']) == key(product), 'Machine built another QBE input')
    base = evidence.keep(document['base'])
    prepared = document.get('preparedBase')
    if prepared:
        evidence.keep(prepared)
    evidence.keep(document['image'])
    return dict(id=row['id'], source=source, product=product, emission=ep, build=mp,
                image=document['image'], mode=document['mode'], base=identity(base),
                preparedBase=identity(prepared) if prepared else None,
                stamp=document['request'].get('stamp'), machine=machine_identity(machine, evidence))


def load_report(path, evidence, role='candidate'):
    document, report_pin = evidence.read(path)
    require(document.get('complete') is True and not document.get('changedInputs'),
            'Incomplete/changed parent report: ' + str(path))
    rows = []
    if document['kind'] == 'bend-finite-qualification':
        require(document.get('passed') is True and document.get('host') == 'native'
                and document.get('target') == 'qbe', 'Expected passing native qualification')
        for row in document['rows']:
            if row['id'].startswith('broad/'):
                require(row['status'] == 'pass', 'Nonpassing broad case')
                rows.append(emission(row, row['emission'], row['build'], evidence))
    elif document['kind'] == 'bend-benchmark-acquisition':
        require(all(row.get('complete') is True for row in document['rows']), 'Incomplete acquisition row')
        manifest, _ = evidence.read(document['programManifest'])
        require(set(document['selected']) == {row['id'] for row in manifest['cases']},
                'Acquisition/manifest selection differs')
        for case in manifest['cases']:
            product = case['products'][role]
            def one(suffix):
                values = [row for row in product['inputs'] if row['file'].endswith(suffix)]
                require(len(values) == 1, 'Ambiguous acquisition dependency: ' + suffix)
                return values[0]
            row = emission(case, one('/emission/report.json'), one('/machine/report.json'), evidence)
            require(key(row['product']) == key(product['generatedSource']), 'Manifest QBE differs')
            oracle, _ = evidence.read(one('/oracle-process.json'))
            require(oracle.get('complete') is True and oracle.get('exitCode') == 0
                    and oracle['stderr']['bytes'] == 0, 'Original value/count oracle failed')
            evidence.keep(oracle['stdout']); evidence.keep(oracle['stderr'])
            rows.append(row)
    else:
        raise ValueError('Unsupported evidence kind: ' + document['kind'])
    require(rows, 'No broad products in report')
    return rows, report_pin


def references(paths, evidence, role='candidate', expected=45):
    rows, reports = {}, []
    for path in paths:
        values, report = load_report(path, evidence, role)
        reports.append(report)
        for row in values:
            source = key(row['source'])
            require(source not in rows, 'Duplicate exact reference source identity')
            rows[source] = row
    require(len(rows) == expected, 'Expected %d unique reference sources, found %d' % (expected, len(rows)))
    return rows, reports


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--qualification', type=Path, required=True)
    parser.add_argument('--reference', type=Path, action='append', required=True)
    parser.add_argument('--reference-role', default='candidate')
    parser.add_argument('--expected-count', type=int, default=45)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    require(not args.out.exists(), 'Fresh output required')
    evidence = Evidence(); evidence.keep(pin(__file__))
    result = dict(kind='bend-phase170-exact-products', version=1, complete=False,
                  targetsRun=False, rows=[], scope='Exact source/QBE and machine-policy identity; no new timing measurement.')
    try:
        refs, result['references'] = references(args.reference, evidence, args.reference_role, args.expected_count)
        rows, result['qualification'] = load_report(args.qualification, evidence)
        require(len(rows) == args.expected_count and len({key(row['source']) for row in rows}) == len(rows),
                'Qualification must cover the expected unique sources')
        for row in rows:
            old = refs.get(key(row['source']))
            comparison = dict(id=row['id'], source=row['source'], candidate=row['product'], matched=old is not None)
            if old:
                comparison.update(reference=old['product'], referenceId=old['id'],
                    byteExact=same_bytes(row['product']['file'], old['product']['file']),
                    contextExact=all(row[field] == old[field] for field in ('mode', 'base', 'preparedBase', 'stamp')),
                    machinePolicyExact=row['machine'] == old['machine'],
                    candidateEmission=row['emission'], referenceEmission=old['emission'])
            result['rows'].append(comparison)
        result['matched'] = sum(row['matched'] for row in result['rows'])
        result['exact'] = sum(row.get('byteExact', False) for row in result['rows'])
        result['complete'] = all(row.get('byteExact') and row.get('contextExact')
                                 and row.get('machinePolicyExact') for row in result['rows'])
    except Exception as error:
        result['error'] = repr(error)
    result['inputs'] = list(evidence.inputs.values())
    result['changedInputs'] = changed_inputs(result['inputs'])
    result['complete'] = result['complete'] and not result['changedInputs']
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps({key: result.get(key) for key in ('complete', 'matched', 'exact', 'error')}))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
