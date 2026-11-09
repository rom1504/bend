#!/usr/bin/env python3
"""Read-only checked-B1/native-N2 emitted identities; never execute a compiler."""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly
from common import pin, require, verify

VERIFIED = {}


def checked(item):
    key = (item['file'], item['bytes'], item['sha256'])
    if key not in VERIFIED:
        verify(item)
        VERIFIED[key] = item
    return item


def identity(item):
    return {k: item[k] for k in ('bytes', 'sha256')}


def read(path):
    item = checked(pin(path))
    return json.loads(Path(path).read_text()), item


def declaration_relation(api_source, release_source, target):
    roots = ['p88_cache_prepare', 'p86_plan', 'p169np_plan',
             'p134e_next' if target == 'qbe' else 'x181_prepared']
    _, api_rows = assembly.blocks(Path(api_source['file']).read_bytes())
    _, release_rows = assembly.blocks(Path(release_source['file']).read_bytes())
    selected = assembly.declaration_closure(
        [(('', r['kind'], r['name']), r['data'], {}) for r in api_rows], roots)
    groups = {}
    for key, data, _ in selected:
        groups.setdefault(key[2], []).append({'data': data})
    release = assembly.grouped(release_rows)
    same, different, missing = [], [], []
    for name in sorted(groups):
        (missing if name not in release else same if
         assembly.normalized(groups[name]) == assembly.normalized(release[name]) else different).append(name)
    return dict(apiSource=api_source, releaseSource=release_source, roots=roots,
        compared=len(same) + len(different), identical=len(same), different=different,
        absentFromRelease=missing,
        comparison='Existing source.normalized: ignore blank/comment lines and trailing whitespace only.',
        scope='Conservative lexical API request closure, compared by named declaration. '
              'Fixture-only roots are excluded. Missing transport wrappers and unused extra '
              'release declarations are reported, not treated as a semantic-equivalence proof.')


def reference(path, target, release_file):
    report, report_pin = read(path)
    require(report.get('complete') and report.get('target') == target, 'Incomplete/wrong B1 emission')
    for item in report['inputs']:
        checked(item)
    authorities = []
    for item in report['inputs']:
        if item['file'].endswith('/report.json'):
            candidate = json.loads(Path(item['file']).read_text())
            if candidate.get('kind') == 'bend-checked-hosted-api':
                authorities.append((candidate, item))
    require(len(authorities) == 1, 'Exactly one checked API authority required')
    authority, authority_pin = authorities[0]
    require(authority.get('complete') and authority.get('checked') and authority.get('status') == 0,
            'Unchecked API authority')
    checked(authority['source']); checked(authority['api'])
    release_pin = checked(pin(release_file))
    bindings = [item for item in report['inputs'] if item['file'].endswith('/base-binding.json')]
    require(len(bindings) == 1, 'Exactly one Base binding required')
    binding = json.loads(Path(bindings[0]['file']).read_text())
    for row in report['rows']:
        require(row.get('complete') and row.get('verified'), 'Incomplete/unverified B1 row')
        checked(row['source']); checked(row['product'])
    return report, dict(report=report_pin, apiAuthority=authority_pin,
        sourceRelation=declaration_relation(authority['source'], release_pin, target)), binding


def native_evidence(product, target, source_pin, release_pin, binding):
    receipts = []
    for item in product.get('inputs', []):
        if item['file'].endswith('/report.json'):
            checked(item)
            data = json.loads(Path(item['file']).read_text())
            if data.get('kind') in ('bend-build-request', 'bend-native-build'):
                receipts.append((data, item))
    native = [(d, p) for d, p in receipts if d.get('host') == 'native' and
              d.get('stage') == 'N2' and d.get('target') == target]
    require(native, 'Missing actual native N2 request receipt')
    request_report, request_pin = native[0]
    require(request_report.get('complete') and not request_report.get('changedInputs'), 'Failed native request')
    request = request_report['request']
    require(request['imageMetadata'].get('complete') and
            request['imageMetadata'].get('host') == 'native' and
            request['imageMetadata'].get('stage') == 'N2' and
            identity(request['imageMetadata']['image']) == identity(request['image']),
            'Native image binding mismatch')
    require(identity(checked(request['source'])) == identity(source_pin), 'Native/B1 workload differs')
    require(identity(checked(request['base'])) == identity(binding['base']) and
            identity(checked(request['carrier'])) == identity(binding['carrier']) and
            request['stamp'] == binding['stamp'], 'Native/B1 prepared Base differs')
    require(identity(checked(request['imageMetadata']['sourceIdentity'])) == identity(release_pin),
            'Native image belongs to a different compiler source')
    checked(request['image'])
    emitted = request_report.get('product') or request_report.get(
        'irDigest' if target == 'qbe' else 'assemblyDigest')
    require(emitted is not None, 'Native request has no emitted identity')
    candidates = []
    if product.get('generatedSource'):
        candidates.append(product['generatedSource'])
    for receipt, _ in receipts:
        for key in ('product', 'retainedIR' if target == 'qbe' else 'retainedAssembly',
                    'sourceIR' if target == 'qbe' else 'sourceAssembly'):
            value = receipt.get(key)
            if isinstance(value, dict) and 'sha256' in value:
                candidates.append(value)
    for candidate in candidates:
        require(identity(candidate) == identity(emitted), 'Manifest/receipt emitted identity mismatch')
        if Path(candidate['file']).is_file():
            return checked(candidate), request_pin, 'retained-bytes'
    for receipt, receipt_pin in receipts:
        digest = receipt.get('irDigest' if target == 'qbe' else 'assemblyDigest')
        if digest and receipt.get('complete') and not receipt.get('changedInputs'):
            require(identity(digest) == identity(emitted), 'Machine/request digest mismatch')
            return identity(digest), receipt_pin, 'authenticated-stream-digest'
    raise ValueError('No retained emitted bytes or authenticated complete-stream digest')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    base = ROOT / 'selfhost/build/phase186'
    p.add_argument('--qbe', type=Path, default=base/'stack-only-qbe-emit01/report.json')
    p.add_argument('--x86', type=Path, default=base/'xmm-live-x86-emit01/report.json')
    p.add_argument('--release-qbe', type=Path, default=base/'release-source01/compiler.bend')
    p.add_argument('--release-x86', type=Path, default=base/'release-source01/compiler.x86.bend')
    p.add_argument('--native', type=Path, default=base/'release-native45-acquire01/report.json')
    p.add_argument('--role-prefix', default='phase186')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists(), 'Fresh report path required')
    report = dict(kind='phase186-native-b1-product-identity', complete=False, passed=None,
        targetsRun=False, inputs=[pin(__file__), pin(assembly.__file__)], references={}, rows=[],
        scope='Emitted bytes only; no normalization, target execution, semantic qualification, '
              'ELF identity, or installed-selector claim. Declaration comparison is separate metadata.')
    try:
        acquired = manifest = None
        if a.native.is_file():
            acquired, acquisition_pin = read(a.native)
            report['inputs'].append(acquisition_pin)
            if acquired.get('complete') and acquired.get('programManifest'):
                checked(acquired['programManifest'])
                manifest = json.loads(Path(acquired['programManifest']['file']).read_text())
                report['inputs'].append(acquired['programManifest'])
        for target in ('qbe', 'x86'):
            ref, detail, binding = reference(getattr(a, target), target, getattr(a, 'release_' + target))
            report['references'][target] = detail
            cases = {r['id']: r for r in manifest['cases']} if manifest else {}
            for item in ref['rows']:
                row = dict(id=item['id'], target=target, source=item['source'], checkedB1=item['product'],
                           status='pending-native', identityEqual=None, byteExact=None)
                report['rows'].append(row)
                case = cases.get(item['id'], {})
                product = case.get('products', {}).get(a.role_prefix + '-' + target + '-n2')
                if product is None:
                    continue
                require(identity(case['source']) == identity(item['source']), 'Native manifest workload differs')
                evidence, receipt, method = native_evidence(product, target, item['source'],
                    detail['sourceRelation']['releaseSource'], binding)
                equal = identity(evidence) == identity(item['product'])
                exact = None
                if method == 'retained-bytes':
                    exact = Path(evidence['file']).read_bytes() == Path(item['product']['file']).read_bytes()
                    require(exact == equal, 'Digest/byte comparison disagreement')
                row.update(nativeN2=evidence, nativeReceipt=receipt, comparisonMethod=method,
                           identityEqual=equal, byteExact=exact, status='matched' if equal else 'mismatch')
        report['pending'] = sum(r['status'] == 'pending-native' for r in report['rows'])
        report['complete'] = report['pending'] == 0
        report['passed'] = all(r['identityEqual'] for r in report['rows']) if report['complete'] else None
        report['nativeAcquisitionComplete'] = bool(acquired and acquired.get('complete'))
    except Exception as error:
        report['error'] = str(error)
        report['passed'] = False
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: report.get(k) for k in ('complete', 'passed', 'pending', 'error')}))
    return 1 if report.get('error') or report.get('passed') is False else 0


if __name__ == '__main__':
    raise SystemExit(main())
