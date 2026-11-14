#!/usr/bin/env python3
"""Offline exact seven-root declaration audit; no compiler semantics in Python.

Reuses the original Phase147 conservative dependency extractor and Phase175
transport rule (remove CLI main, add absent Phase190 API wrappers). Compares
all declaration bytes, retaining comments/annotations, except outer newlines.
"""
import hashlib
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
ROOTS = ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'x181_prepared',
         'x188_many', 'x188_render', 'x188_assemble']
EXTRACTOR = ROOT / 'experiments/phase147/tools/prepare.py'
spec = importlib.util.spec_from_file_location('p193_core_extract', EXTRACTOR)
E = importlib.util.module_from_spec(spec); spec.loader.exec_module(E)


def digest(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def audit(evidence, preparation, hosted, native):
    require = E.require
    methods = [Path(__file__), EXTRACTOR, Path(E.assembly.__file__),
               ROOT / 'selfhost/tests/phase175/frontend-prepare.py',
               ROOT / 'selfhost/tests/phase190/prepare-api.py']
    for method in methods:
        evidence.verify(E.pin(method))
    require(preparation['source'] == hosted and preparation['complete'] is True,
            'Authenticated prepared hosted source required')
    require(preparation['sourceConstantOverrides'] == [] and
            preparation['helperLawPositions'] == [] and not preparation['nativeMain'],
            'Unexpected source overrides, helper laws, or native-main transport')
    require(preparation['exports'] == ROOTS + ['x193fb_controls'],
            'Exactly seven compiler roots plus budget control export required')
    exports = evidence.read(preparation['exportManifest'])
    require(exports['exports'] == preparation['exports'], 'Export metadata differs')
    inputs = {item['file']: item for item in preparation['inputs']}

    def recorded(relative):
        path = ROOT / relative
        require(str(path) in inputs, 'Missing original preparation input: ' + str(path))
        return evidence.verify(inputs[str(path)]).read_bytes()

    bridge = recorded('selfhost/tests/phase190/api-bridge.bend')
    hook = recorded('selfhost/tests/phase193/public-fusion-budget-hook.bend')
    module = recorded('selfhost/tests/phase193/public-fusion-budget-experimental.bend')
    snapshot = evidence.verify(preparation['snapshot']).read_bytes()
    hosted_data = evidence.verify(hosted).read_bytes()
    native_data = evidence.verify(native).read_bytes()
    require(digest(snapshot) == preparation['snapshotIdentity'], 'Snapshot identity differs')
    require(native['sha256'] == 'fd95adc1bdc210bc3827c9dd3536b8e7289fb60c4e983f0e008714665239428a',
            'Expected frozen maintained budget source02 required')

    def blocks(data):
        return E.assembly.blocks(data)[1]

    def with_bridge(data):
        original = blocks(data)
        present = {(r['kind'], r['name']) for r in original}
        additions = [r for r in blocks(bridge) if (r['kind'], r['name']) not in present]
        return original + additions, additions

    rows, added = with_bridge(snapshot)
    require([r['name'] for r in added] == preparation['bridgedExportDeclarations'],
            'Bridge additions differ from preparation')
    bridged = snapshot + b'\n' + b'\n'.join(r['data'] for r in added)
    require(digest(bridged) == preparation['parent'], 'Bridged parent differs')
    rows = [r for r in blocks(bridged) if r['name'] != 'main']
    replacement = blocks(hook)
    require(len(replacement) == 1 and replacement[0]['name'] == 'x193f_plan',
            'Exactly one budget hook required')
    original_hook = [r for r in rows if r['kind'] == 'def' and r['name'] == 'x193f_plan']
    require(len(original_hook) == 1, 'Unique original hook required')
    require(preparation['replacements'] == [dict(name='x193f_plan',
        originalSha256=digest(original_hook[0]['data'])['sha256'],
        replacementSha256=digest(replacement[0]['data'])['sha256'])],
        'Recorded replacement hashes differ')
    replacements = {(r['kind'], r['name']): r for r in replacement}
    rows = [replacements.get((r['kind'], r['name']), r) for r in rows] + blocks(module)
    reconstructed, _ = E.extract([('reconstructed', b'\n'.join(r['data'] for r in rows))],
                                 preparation['exports'])
    require(reconstructed == hosted_data, 'Exact hosted preparation reconstruction failed')

    # CLI main is always removed by the original API preparation. The lexical
    # extractor otherwise conservatively treats local words named main as a
    # reference to the CLI entry and drags in unrelated IO wrappers.
    native_rows, native_bridge = with_bridge(native_data)
    native_api = b'\n'.join(r['data'] for r in native_rows if r['name'] != 'main')
    left, _ = E.extract([('hosted', hosted_data)], ROOTS)
    right, _ = E.extract([('native-api-view', native_api)], ROOTS)

    def keyed(data):
        result = {}
        for row in blocks(data):
            key = (row['kind'], row['name'])
            require(key not in result, 'Duplicate declaration: ' + repr(key))
            result[key] = row['data'].strip(b'\r\n')
        return result

    a, b = keyed(left), keyed(right)
    require(a.keys() == b.keys(), 'Seven-root closure inventories differ')
    require(all(a[key] == b[key] for key in a), 'Reachable declaration bytes differ')
    ignored = set(keyed(hosted_data)) - set(a)
    require(ignored == {('def', 'x193fb_controls'), ('def', 'x193fb_row')},
            'Unexpected hosted declarations outside compiler closure')
    bridge_keys = {(r['kind'], r['name']) for r in native_bridge}
    require(bridge_keys <= set(a), 'Bridge declaration outside expected closure')
    # Stronger supplemental check: every declaration shared by the complete
    # original sources is identical, including declarations beyond seven roots.
    all_a, all_b = keyed(hosted_data), keyed(native_data)
    shared = set(all_a) & set(all_b)
    require(all(all_a[key] == all_b[key] for key in shared),
            'A shared full-source declaration differs')
    inventory = [dict(kind=k[0], name=k[1], **digest(a[k])) for k in sorted(a)]
    return dict(kind='phase193-budget-reachable-core-equivalence', version=1,
        complete=True, compilerRun=False, targetsRun=False, roots=ROOTS,
        hosted=hosted, native=native, snapshot=preparation['snapshot'],
        reconstructedHostedBytesIdentical=True,
        declarationsIdentical=len(a), sharedFullSourceDeclarationsIdentical=len(shared),
        sharedCompilerDeclarationsIdentical=len(a)-len(bridge_keys),
        excludedUnusedControls=sorted([name for _, name in ignored]),
        nativeApiBridge=[r['name'] for r in native_bridge],
        nativeMainExcludedByOriginalTransport=True,
        normalization='Only CR/LF bytes at declaration boundaries; all comments, annotations, bodies and internal whitespace preserved.',
        declarations=inventory,
        scope='Exact conservative seven-API-root declaration identity after original API transport. CLI IO wrapper equivalence and universal backend correctness are not claimed; independent product comparison remains required.')
