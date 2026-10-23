"""Compose immutable Bend declaration overlays onto qualified Phase130; no lowering."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
SELECTION = ROOT / 'implementation/phase130/candidate.json'
PAT = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
DIRECT_VERIFIER = ROOT / 'selfhost/tools/performance/phase113/direct-emit/verify.bend'
ENTRY_GATES = {
    'p111_emit_admitted', 'p118e_lowered', 'p118e_verified', 'p111_runtime_admission',
    'p113d_verify', 'p113a_verify', 'p113a_verify_after', 'p113a_namespace',
    'p113a_names', 'p113a_params', 'p113a_scalar_names', 'p113a_scalar_list_names',
    'p113a_body_names', 'p113a_function_names',
    'main', 'p111_native_args', 'p111_native_request', 'p111_compile_source',
    'p111_compile_prepared', 'p111_emit_plan',
}


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def blocks(text, combine=False):
    hits, answer = list(PAT.finditer(text)), {}
    for i, hit in enumerate(hits):
        value = text[hit.start():hits[i + 1].start() if i + 1 < len(hits) else len(text)]
        answer[hit[1]] = (answer.get(hit[1], '') if combine else '') + value
    return answer


def norm(text):
    return '\n'.join(line.rstrip() for line in text.splitlines()
                     if line.strip() and not line.lstrip().startswith('#'))


def compose(text, modules, overrides, module_overrides):
    before, added, replaced = blocks(text), {}, set()
    for module in modules:
        current = blocks(module, combine=True)
        if not current:
            raise ValueError('Each module must contain Bend declarations')
        overlap = set(added) & set(current)
        if not overlap <= module_overrides:
            raise ValueError('Undeclared module override: ' + repr(sorted(overlap - module_overrides)))
        replaced |= overlap
        added.update(current)
    if replaced != module_overrides:
        raise ValueError('Exact module-overrides inventory mismatch')
    if set(before) & set(added) != overrides:
        raise ValueError('Exact parent overrides required: ' + repr(sorted(set(before) & set(added))))
    protected = ENTRY_GATES | set(blocks(DIRECT_VERIFIER.read_text())) | {name for name in before if name.startswith('p111v_')}
    changed = [name for name in protected & set(added) & set(before) if norm(added[name]) != norm(before[name])]
    if changed:
        raise ValueError('Original verification gate must remain unchanged: ' + repr(sorted(changed)))
    hits = list(PAT.finditer(text))
    parts = [text[:hits[0].start()]]
    for i, hit in enumerate(hits):
        old = text[hit.start():hits[i + 1].start() if i + 1 < len(hits) else len(text)]
        parts.append(added[hit[1]].rstrip() + '\n\n'
                     if hit[1] in added and not old.lstrip().startswith('law ') else old)
    parts.extend('\n' + body for name, body in added.items() if name not in before)
    result = ''.join(parts)
    after = blocks(result)
    if set(after) != set(before) | set(added):
        raise ValueError('Declaration inventory changed unexpectedly')
    for name, body in before.items():
        expected = blocks(added[name])[name] if name in added else body
        if norm(after[name]) != norm(expected):
            raise ValueError('Unexpected declaration composition: ' + name)
    return result, sorted(set(added) - set(before)), sorted(protected & set(before))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--module', type=Path, action='append', required=True)
    parser.add_argument('--overrides', nargs='*', required=True)
    parser.add_argument('--module-overrides', nargs='*', default=[])
    args = parser.parse_args()
    selected = json.loads(SELECTION.read_text())
    if not (selected.get('complete') and selected.get('nativeQualified')):
        raise ValueError('Qualified Phase130 parent required')
    authority = ['source', 'api', 'runtime', 'sourceManifest', 'checkedApi', 'runtimeReport']
    for key in authority:
        if pin(selected[key]['file']) != selected[key]:
            raise ValueError('Changed selected parent: ' + key)
    modules = [path.resolve() for path in args.module]
    if len(set(modules)) != len(modules):
        raise ValueError('Repeated module path')
    module_data = [path.read_text() for path in modules]
    text = Path(selected['source']['file']).read_text()
    composed, added, protected = compose(text, module_data, set(args.overrides), set(args.module_overrides))
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase131'):
        raise ValueError('Fresh Phase131 output required')
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(composed)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    for i, path in enumerate(modules):
        (out / ('module' + str(i) + '.bend')).write_bytes(path.read_bytes())
    report = dict(complete=True, checked=False, targetsRun=False, source=pin(out / 'compiler.bend'),
        parent=selected['source'], overrides=args.overrides, moduleOverrides=args.module_overrides,
        added=added, protectedDeclarations=protected,
        verifierAuthority=pin(DIRECT_VERIFIER),
        inputs=[pin(__file__), pin(SELECTION), *[pin(path) for path in modules],
                *[selected[key] for key in authority]],
        physicalLines=len(composed.splitlines()), parentLines=len(text.splitlines()),
        scope='Exact declaration overlay only. Original N111/direct/array verification and request-bound entry remain unchanged. Private emitter/lowering overrides are allowed explicitly. No checking, semantic transformation, target execution or new native qualification in this tool.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['source']))


if __name__ == '__main__':
    main()
