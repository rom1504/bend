#!/usr/bin/env python3
"""Source-only isolated ownership-index overlay on the frozen Phase134 session."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
COMPOSER = ROOT / 'selfhost/tools/performance/phase131/prepare.py'
spec = importlib.util.spec_from_file_location('phase135_compose', COMPOSER)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase135')
    parent_manifest = ROOT / 'selfhost/build/phase134/session-source04/manifest.json'
    checked = ROOT / 'selfhost/build/phase111/p134-session-api02/report.json'
    parent = json.loads(parent_manifest.read_text())
    authority = json.loads(checked.read_text())
    assert parent['source']['sha256'] == '1cadf44f486825a6f161ff01b15b582eca13522585deff8415d6c8c2aea7be45'
    assert C.pin(parent['source']['file']) == parent['source']
    assert authority['complete'] and authority['checked'] and authority['status'] == 0
    assert parent['source'] in authority['inputs']
    here = Path(__file__).parent
    modules = [here / name for name in (
        'ownership-v01.bend', 'ownership-request-v01.bend',
        'ownership-override-v01.bend', 'controls-v01.bend')]
    before = Path(parent['source']['file']).read_text()
    old = C.blocks(before)
    text, added, protected = C.compose(before, [p.read_text() for p in modules], {'nc_ctor_owned'}, set())
    new = C.blocks(text)
    changed = sorted(name for name in old if C.norm(old[name]) != C.norm(new[name]))
    assert changed == ['nc_ctor_owned']
    assert all(C.norm(old[name]) == C.norm(new[name]) for name in parent['unchangedProofDeclarations'])
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(text)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    for number, module in enumerate(modules):
        (out / f'module{number}.bend').write_bytes(module.read_bytes())
    result = dict(
        complete=True, checked=False, targetsRun=False,
        source=C.pin(out / 'compiler.bend'), parent=parent['source'],
        sourceManifest=C.pin(parent_manifest), checkedParent=C.pin(checked),
        inputs=[C.pin(__file__), C.pin(COMPOSER), C.pin(parent_manifest), C.pin(checked),
                parent['source'], *[C.pin(p) for p in modules]],
        overrides=changed, added=added, protectedDeclarations=protected,
        unchangedProofDeclarations=parent['unchangedProofDeclarations'],
        scope='Unselected late-only ownership index. Existing frontend, request source, compile admission, ordinary entry and all verifier/proof declarations unchanged. The one query override falls back without a valid private sidecar. Only p135co_emit explicitly prepares the sidecar. No native build or target execution.')
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result['source']))


if __name__ == '__main__':
    main()
