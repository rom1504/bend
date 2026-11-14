#!/usr/bin/env python3
"""Reconstruct only the original seven-root API transport, byte for byte; no targets."""
import hashlib
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
METHOD = ROOT/'experiments/phase147/tools/prepare.py'
spec = importlib.util.spec_from_file_location('phase194_exact_api_transport', METHOD)
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)
ROOTS = ['p88_cache_prepare', 'p86_plan', 'p169np_plan', 'x181_prepared',
         'x188_many', 'x188_render', 'x188_assemble']


def digest(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def audit(evidence, preparation, hosted, native):
    require = E.require
    inputs = {item['file']: item for item in preparation['inputs']}
    for method in (METHOD, Path(E.assembly.__file__), ROOT/'selfhost/tests/phase175/frontend-prepare.py',
                   ROOT/'selfhost/tests/phase190/prepare-api.py'):
        require(str(method) in inputs, 'Original source transport input missing: '+str(method))
        evidence.verify(inputs[str(method)])
    evidence.verify(E.pin(__file__))
    require(preparation['complete'] is True and preparation['source'] == hosted
            and preparation['exports'] == ROOTS and not preparation['nativeMain']
            and preparation['sourceConstantOverrides'] == [] and preparation['replacements'] == []
            and preparation['helperLawPositions'] == [],
            'Plain seven-root preparation from selected source required; no experimental overrides')
    exports = evidence.read(preparation['exportManifest'])
    require(exports['exports'] == ROOTS, 'Checked export manifest differs')
    parent = evidence.verify(preparation['snapshot']).read_bytes()
    native_data = evidence.verify(native).read_bytes()
    hosted_data = evidence.verify(hosted).read_bytes()
    require(digest(parent) == preparation['snapshotIdentity'] and parent == native_data,
            'Complete hosted parent/native compiler source differs')
    bridge_path = str(ROOT/'selfhost/tests/phase190/api-bridge.bend')
    require(bridge_path in inputs, 'Recorded original API bridge required')
    bridge = evidence.verify(inputs[bridge_path]).read_bytes()
    rows = E.assembly.blocks(parent)[1]
    keys = [(row['kind'], row['name']) for row in rows]
    require(len(keys) == len(set(keys)), 'Duplicate parent declaration')
    present = set(keys)
    additions = [row for row in E.assembly.blocks(bridge)[1] if (row['kind'], row['name']) not in present]
    require([row['name'] for row in additions] == preparation['bridgedExportDeclarations'],
            'API bridge additions differ')
    bridged = parent + b'\n' + b'\n'.join(row['data'] for row in additions) if additions else parent
    require(digest(bridged) == preparation['parent'], 'Bridged parent identity differs')
    # This is exactly the maintained preparation's CLI-main removal and
    # conservative extraction, not whitespace/comment/type/body normalization.
    chunks = [row['data'] for row in E.assembly.blocks(bridged)[1] if row['name'] != 'main']
    reconstructed, inventory = E.extract([('phase175-combined', b'\n'.join(chunks))], ROOTS, 4_000_000)
    require(reconstructed == hosted_data, 'Hosted effective compiler differs from exact original API transport')
    return dict(kind='phase194-exact-same-parent-api-transport', complete=True, targetsRun=False,
        method=E.pin(__file__), parent=preparation['snapshot'], hosted=hosted, native=native,
        roots=ROOTS, declarations=len(inventory), reconstructedHostedBytesIdentical=True,
        fullParentBytesIdentical=True, normalization='None. Exact reconstructed source bytes, including annotations and bodies.',
        scope='Only original absent API bridge additions, CLI main removal and seven-root conservative extraction. No experimental hook, control export or alternate closure normalization accepted.')
