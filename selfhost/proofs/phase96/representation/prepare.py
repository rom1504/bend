#!/usr/bin/env python3
"""Extract exact term representation bodies, removing only unsafe annotations."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT/'selfhost/src/core/term.bend'
NAMES = ['KTerm', 'tg', 'nm', 'ix', 'qt', 'ks', 'rm', 'kb', 'ke',
         'k_with_children', 'k_with_span', 'core_literal', 'kl_number', 'kl_text',
         'k_quantity_present', 'k_rebuild']


def identity(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('--out', type=Path, required=True)
    out = p.parse_args().out.resolve(); assert out.is_relative_to(ROOT) and not out.exists()
    out.mkdir(parents=True)
    text = SOURCE.read_text()
    declarations = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b', text))
    selected = []; pieces = []
    for name in NAMES:
        found = [(i,m) for i,m in enumerate(declarations) if m.group(1)==name]
        assert len(found)==1, (name,found)
        i,m = found[0]; end = declarations[i+1].start() if i+1<len(declarations) else len(text)
        original = text[m.start():end]
        extracted = original.removeprefix('@unsafe\n')
        assert '@unsafe' not in extracted
        selected.append(dict(name=name, startLine=text[:m.start()].count('\n')+1,
                             original=original, extracted=extracted,
                             removedUnsafe=original!=extracted))
        pieces.append(extracted)
    (out/'production.bend').write_text('import Base\n\n'+''.join(pieces))
    (out/'laws.bend').write_bytes(Path(__file__).with_name('laws.bend').read_bytes())
    manifest = dict(source=identity(SOURCE), method=identity(Path(__file__)),
                    proof=identity(Path(__file__).with_name('laws.bend')), definitions=selected,
                    outputs=[identity(out/'production.bend'), identity(out/'laws.bend')],
                    transformation='Remove only the leading @unsafe annotation from selected declarations; bodies and KTerm type remain exact. Production untouched.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(out=str(out), definitions=len(selected))))


if __name__=='__main__': main()
