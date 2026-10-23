"""Exact closed source-layer replay for the reviewed Phase126 native candidates."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
AUTHORITY = HERE / 'layered-authority07.json'
AUTHORITY_SHA = '081e1c66cb287662fad3d895f0f8b08d3ccc87ab75e413ad5e507b56d40a55a8'
DECL = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(path):
    path = Path(path).resolve(); raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def verify(row):
    assert pin(row['file']) == row, 'Changed frozen input: ' + row['file']
    return Path(row['file'])


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value)
    return value


def blocks(text, combine=False):
    hits = list(DECL.finditer(text)); answer = {}
    for i, hit in enumerate(hits):
        value = text[hit.start():hits[i+1].start() if i+1 < len(hits) else len(text)]
        answer[hit[1]] = (answer.get(hit[1], '') if combine else '') + value
    return answer


def norm(text):
    return '\n'.join(x.rstrip() for x in text.splitlines() if x.strip() and not x.lstrip().startswith('#'))


def authority():
    assert pin(AUTHORITY)['sha256'] == AUTHORITY_SHA, 'Changed exact layer authority'
    return read(AUTHORITY)


def source_contract(source, manifest):
    """No checking/lowering: independently replay only the frozen declaration overlays."""
    policy = authority()
    original = load(ROOT/'selfhost/tools/performance/phase118/native-plan-v2.py', 'p126_old_contract')
    base = read(verify(policy['baseManifest']))
    contract = original.source_contract(Path(base['source']['file']), base)
    snapshots = [pin(__file__), pin(AUTHORITY), policy['baseManifest'], *contract['snapshots']]
    text = verify(base['source']).read_text(); previous = base
    final = pin(source); matched = False; receipts = []
    for layer in policy['layers']:
        frozen = read(verify(layer['manifest'])); inventory = read(verify(layer['authority']))
        verify(layer['producer'])
        if layer['kind'] != 'divmod':
            assert inventory['parent'] == previous['source']
            assert frozen['moduleInventory'] == layer['authority']
            assert frozen['parentManifest'] == inventory['parentManifest']
        assert frozen['complete'] and frozen['parent'] == previous['source'], 'Layer parent mismatch'
        assert frozen['overrides'] == layer['overrides'], 'Layer override mismatch'
        assert inventory['modules'] == layer['modules'], 'Layer module inventory mismatch'
        for row in frozen['inputs']:
            verify(row)
        before = blocks(text); added = {}
        for i, row in enumerate(layer['modules']):
            body = verify(row).read_text(); current = blocks(body, combine=layer['kind'] != 'divmod')
            assert not (set(current) & set(added)), 'Unexpected module replacement'
            assert row in frozen['inputs'], 'Unbound layer module'
            added.update(current)
            if layer['kind'] != 'divmod':
                snapshot = Path(frozen['source']['file']).parent / ('module%d.bend' % i)
                assert snapshot.read_bytes() == Path(row['file']).read_bytes(), 'Changed module snapshot'
                snapshots.append(pin(snapshot))
        assert set(before) & set(added) == set(layer['overrides']), 'Unexpected parent replacement'
        for old, alias in layer['aliases'].items():
            expected = before[old].replace('def '+old+'(', 'def '+alias+'(', 1)
            assert norm(expected) == norm(added[alias]), 'Previous authority not preserved: '+old
        if layer['kind'] == 'tail-scc':
            assert inventory['parent'] == previous['source']
            original_plan = blocks(verify(inventory['originalPlan']).read_text())['p113pl_plan']
            assert norm(before['p113pl_plan']) == norm(original_plan), 'Changed original SCC plan'
        hits = list(DECL.finditer(text)); pieces = [text[:hits[0].start()]]
        for i, hit in enumerate(hits):
            old = text[hit.start():hits[i+1].start() if i+1 < len(hits) else len(text)]
            pieces.append(added[hit[1]].rstrip()+'\n\n' if hit[1] in added and (layer['kind'] == 'divmod' or not old.lstrip().startswith('law ')) else old)
        pieces.extend('\n'+body for name, body in added.items() if name not in before)
        text = ''.join(pieces)
        assert text.encode() == verify(frozen['source']).read_bytes(), 'Layer replay bytes differ'
        assert set(blocks(text)) == set(before) | set(added), 'Layer declaration inventory differs'
        if 'runtimeExtension' in previous:
            assert frozen['runtimeExtension'] == previous['runtimeExtension'], 'Changed inherited runtime authority'
        snapshots.extend([layer['manifest'], layer['authority'], layer['producer'], frozen['source'], *frozen['inputs']])
        receipts.append(dict(kind=layer['kind'], manifest=layer['manifest'], byteExactReplay=True,
                             overrides=layer['overrides'], preservedAliases=layer['aliases']))
        previous = frozen
        if final == frozen['source']:
            assert manifest == frozen, 'Manifest does not match frozen authority'
            matched = True; break
    assert matched, 'Source is not an exact admitted layer endpoint'
    # The original native bridge, final verifier and request-bound entry are not replaced.
    base_defs, final_defs = blocks(Path(base['source']['file']).read_text()), blocks(text)
    for name in ['main', 'p111_native_args', 'p111_native_request', 'p111_compile_source',
                 'p111_compile_prepared', 'p111_emit_plan', 'p111_emit_admitted', 'p118e_lowered', 'p118e_verified']:
        assert norm(base_defs[name]) == norm(final_defs[name]), 'Changed native boundary: '+name
    result = dict(contract)
    result.update(snapshots=original.unique(snapshots), layeredReplay=receipts,
                  exactLayerAuthority=pin(AUTHORITY), fullCompositionReplay=True)
    return result
