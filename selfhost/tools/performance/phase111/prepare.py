#!/usr/bin/env python3
"""Freeze the selected Bend compiler plus direct-QBE modules; run no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
SELECTED = ROOT / 'selfhost/build/phase102/projection-cost-source01/compiler.bend'
SELECTED_SHA = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--module', type=Path, action='append', help='Explicit module list in source order')
    parser.add_argument('--without-entry', action='store_true')
    parser.add_argument('--slice', action='store_true', help='Exact declaration dependency slice for fast module checks, not full native acquisition')
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase111'):
        raise ValueError('Use a fresh directory under selfhost/build/phase111')
    selected = pin(SELECTED)
    if selected['sha256'] != SELECTED_SHA:
        raise ValueError('Selected mature source changed; review integration boundary')
    source = SELECTED.read_text()
    old = '@unsafe\ndef main() -> IO(U32):\n  do IO<U32>:\n    args : List<&1,String> <- IO.args()\n    p86_cli(args)'
    if source.count(old) != 1:
        raise ValueError('Expected exact selected main')
    renamed = old.replace('def main()', 'def p111_previous_main()')
    retained = source.replace(old, renamed, 1)
    assert retained.replace(renamed, old, 1) == source
    modules = args.module or [HERE / line.strip() for line in (HERE / 'modules.txt').read_text().splitlines()
                              if line.strip() and not line.startswith('#')]
    modules = list(dict.fromkeys(path.resolve() for path in modules))
    if not args.without_entry:
        modules.append(HERE / 'entry.bend')
    texts = [path.read_text() for path in modules]
    existing = set(re.findall(r'^(?:def|type) ([A-Za-z0-9_.]+)\b', retained, re.M))
    added = []
    for path, text in zip(modules, texts):
        for name in re.findall(r'^(?:def|type) ([A-Za-z0-9_.]+)\b', text, re.M):
            if name in existing or name in added:
                raise ValueError('Duplicate declaration ' + name + ' in ' + str(path))
            added.append(name)
    addition = '\n\n'.join('# Phase111 module: ' + str(path.relative_to(ROOT)) + '\n' + text
                             for path, text in zip(modules, texts))
    chosen = None
    if args.slice:
        # Source preparation only: include whole unchanged declarations, never
        # synthesize semantic bodies. The real language checker still validates
        # all resulting references and implicit dependencies. This is a quick
        # module-check image, not a claim to preserve full-program compilation.
        starts = list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', retained, re.M))
        declarations = {}
        aliases = {}
        order = []
        for i, match in enumerate(starts):
            name = match.group(1)
            block = retained[match.start():starts[i+1].start() if i+1 < len(starts) else len(retained)].split('\n# Module:', 1)[0].rstrip()
            if name not in declarations:
                order.append(name)
            declarations[name] = declarations.get(name, '') + '\n\n' + block
            aliases[name] = name
            if block.startswith('type '):
                for ctor in re.findall(r'^  ([A-Za-z0-9_.]+)\{', block, re.M):
                    aliases[ctor] = name
        chosen = set()
        todo = re.findall(r'[A-Za-z_][A-Za-z0-9_.]*', addition)
        while todo:
            word = todo.pop()
            name = aliases.get(word)
            if name is None or name in chosen or name in added:
                continue
            chosen.add(name)
            todo.extend(re.findall(r'[A-Za-z_][A-Za-z0-9_.]*', declarations[name]))
        retained = 'import Base\n\n' + '\n\n'.join(declarations[name] for name in order if name in chosen)
    final = retained + '\n\n' + addition + '\n'
    if not args.without_entry and len(re.findall(r'^def main\(', final, re.M)) != 1:
        raise ValueError('Expected exactly one main')
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(final)
    (out / 'modules.bend').write_text(addition + '\n')
    inputs = [pin(__file__), selected, *map(pin, modules), *([] if args.module else [pin(HERE / 'modules.txt')])]
    report = dict(kind='phase111-direct-qbe-source', version=1, prepared=True,
                  checked=False, targetsRun=False, sourceInverseExact=True,
                  source=pin(out / 'compiler.bend'), additions=pin(out / 'modules.bend'),
                  selectedSource=selected, modules=list(map(pin, modules)), inputs=inputs,
                  addedDeclarations=added,
                  dependencySlice=sorted(chosen) if chosen is not None else None,
                  edits=['rename selected main to p111_previous_main', 'append exact Phase111 modules'],
                  scope='Source transport only. Full source checking, semantic qualification and native self-hosting are separate gates.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(prepared=True, checked=False, source=report['source'],
                         declarations=len(added), manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
