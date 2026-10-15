#!/usr/bin/env python3
"""Compose verified source recipes using unambiguous exact definition replacements."""
import argparse, hashlib, json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]

def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

def verify(record):
    assert pin(record['file']) == record
    return Path(record['file'])

def replay(text, changes):
    for item in changes:
        at, old, new = item['offset'], item['old'], item['new']
        assert text[at:at+len(old)] == old
        text = text[:at]+new+text[at+len(old):]
    return text

def load(path):
    receipt = json.loads(Path(path).read_text()); assert receipt['complete']
    original = verify(receipt.get('original',receipt['source'])).read_text()
    candidate = verify(receipt['candidate']).read_text()
    assert replay(original,receipt['changes']) == candidate
    return receipt, original, candidate

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base-recipe', type=Path, required=True)
    parser.add_argument('--delta-recipe', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    base, original, text = load(args.base_recipe)
    delta, delta_original, _ = load(args.delta_recipe)
    assert delta_original == original
    parent_pin = delta['parentRecipe']; parent, parent_original, _ = load(verify(parent_pin))
    assert parent_original == original
    shared = parent['changes']; assert delta['changes'][:len(shared)] == shared
    assert base['changes'][:len(shared)] == shared, 'Recipes do not share the declared exact prefix'
    changes = list(base['changes']); applied = []
    for item in delta['changes'][len(shared):]:
        old, new = item['old'], item['new']
        if old:
            assert text.count(old) == 1, 'Exact old text is absent or ambiguous; no fuzzy composition'
            offset = text.index(old)
        else:
            assert new not in text, 'Append already present'
            names = re.findall(r'(?m)^(?:def|type|law) (\w+)',new)
            for name in names:
                assert not re.search(r'(?m)^(?:def|type|law) '+re.escape(name)+r'\b',text), 'New helper already defined: '+name
            offset = len(text)
        change = dict(old=old,new=new,offset=offset)
        changes.append(change); applied.append(change); text = replay(text,[change])
    assert replay(original,changes) == text
    reverse = text
    for item in reversed(changes):
        at = item['offset']; assert reverse[at:at+len(item['new'])] == item['new']
        reverse = reverse[:at]+item['old']+reverse[at+len(item['new']):]
    assert reverse == original
    out = args.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase98')
    out.mkdir(parents=True); candidate = out/'compiler.bend'; candidate.write_text(text)
    result = dict(kind='phase98-exact-source-recipe-composition',complete=True,targetsRun=False,
        source=base.get('original',base['source']),candidate=pin(candidate),method=pin(__file__),
        parentRecipe=pin(args.base_recipe),deltaRecipe=pin(args.delta_recipe),sharedParent=parent_pin,
        changes=changes,sharedPrefixChanges=len(shared),newChanges=applied,
        physicalLineDelta=len(text.splitlines())-len(original.splitlines()),
        forwardReplayExact=True,inverseRecoversSource=True,
        scope='Exact source composition only. Shared parent changes appear once; delta replacements are relocated by unique complete old text, appends reject helper collisions. No semantic, timing or native qualification is inferred.')
    (out/'changes.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['candidate','physicalLineDelta','sharedPrefixChanges']}))

if __name__ == '__main__': main()
