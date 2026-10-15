#!/usr/bin/env python3
"""Prepare exact dispatch selectors and ordered-condition laws; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
FROZEN = ROOT / 'selfhost/build/phase98/dispatch-frozen02'
RECEIPT = FROZEN / 'receipt.json'
SELECTORS = FROZEN / 'selectors.d04.bend'
SOURCE = ROOT / 'selfhost/build/phase92/upstream-checked01/compiler.bend'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def comparison_bodies(source):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b', source))
    result = []
    for name in ['p88_string_eq_go', 'p88_string_eq']:
        hits = [(i,m) for i,m in enumerate(matches) if m.group(1) == name]
        assert len(hits) == 1
        i,m = hits[0]; body = source[m.start():matches[i+1].start()]
        assert '@unsafe' not in body
        result.append(body)
    return ''.join(result)


def condition(text):
    # The immutable pre-change receipt supplies these conditions, never the
    # candidate stage bodies. Only the observer and known comparator bridge
    # are adapted; Boolean grouping and first-match order remain literal.
    result = text.replace('String.eq(tg(t), ', 'H.p88_string_eq(tag, ')
    assert 'String.eq' not in result and 'tg(' not in result
    assert re.fullmatch(r'[A-Za-z0-9_. ()"|]+', result), result
    return result


def generate(receipt):
    reference = ['import Base', 'import ./candidate.bend as H', '',
                 '# Independent straight-line first-match specification.',
                 '# Conditions and order come from the original caller receipt.', '']
    laws = ['import Base', 'import ./candidate.bend as H', 'import ./reference.bend as R', '']
    public, support, scopes = [], [], []
    for change in receipt['changes']:
        bridge = change['dispatchBridge']
        selector, enum = bridge['selector'], bridge['enum']
        prefix = selector.removesuffix('_select')
        conditions = [condition(row['condition']) for row in bridge['branches']]
        count = len(conditions)
        choice = prefix+'_choice'
        reference += [f'def {choice}(hit: Bool, yes: H.{enum}, no: H.{enum}) -> H.{enum}:',
                      '  match hit:', '    case True{}: yes', '    case False{}: no', '']
        for i in reversed(range(count)):
            rest = f'H.{enum}Default{{}}' if i+1 == count else f'{prefix}_suffix{i+1}(tag)'
            reference += [f'def {prefix}_suffix{i}(+tag: String) -> H.{enum}:',
                          f'  {choice}({conditions[i]}, H.{enum}{i}{{}}, {rest})', '']
        for i in reversed(range(count)):
            name = prefix+f'_stage{i}_ordered'
            support.append(name)
            rest = f'H.{enum}Default{{}}' if i+1 == count else f'R.{prefix}_suffix{i+1}(tag)'
            laws += [f'# Support: suffix {i} preserves arbitrary pending decision and tag.',
                     f'law {name}:', '  for +hit: Bool', '  for +tag: String',
                     f'  {{H.{prefix}_stage{i}(hit, tag) == R.{choice}(hit, H.{enum}{i}{{}}, {rest}) : H.{enum}}}',
                     '', f'def {name}(hit, tag):', '  match hit:',
                     '    case True{}: {==}']
            proof = '{==}' if i+1 == count else f'{prefix}_stage{i+1}_ordered({conditions[i+1]}, tag)'
            laws += [f'    case False{{}}: {proof}', '']
        name = prefix+'_preserves_ordered_dispatch'
        public.append(name)
        laws += ['# Public: full selected constructor for every arbitrary String tag.',
                 f'law {name}:', '  for +tag: String',
                 f'  {{H.{selector}(tag) == R.{prefix}_suffix0(tag) : H.{enum}}}', '',
                 f'def {name}(tag):', f'  {prefix}_stage0_ordered({conditions[0]}, tag)', '']
        scopes.append(dict(selector=selector, resultType=enum,
                           originalConditions=[row['condition'] for row in bridge['branches']],
                           adaptedConditions=conditions, publicLaw=name,
                           literalGatePreserved=bridge['literalGatePreserved'],
                           originalFallback=bridge['fallback']))
    laws += ['#|ALL PROOFS CHECK', '#|Use --verdict for mathematical validity.', '']
    return '\n'.join(reference), '\n'.join(laws), public, support, scopes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    receipt = json.loads(RECEIPT.read_text())
    assert pin(SOURCE)['sha256'] == receipt['original']['sha256']
    pinned = [row for row in receipt['frozenInputs'] if row['file'] == str(SELECTORS)]
    assert len(pinned) == 1 and pin(SELECTORS) == pinned[0]
    selectors = SELECTORS.read_text()
    assert '@unsafe' not in selectors and 'import ' not in selectors
    reference, laws, public, support, scopes = generate(receipt)
    out.mkdir(parents=True)
    (out/'candidate.bend').write_text('import Base\n\n'+comparison_bodies(SOURCE.read_text())+selectors)
    (out/'reference.bend').write_text(reference)
    (out/'laws.bend').write_text(laws)
    (out/'prepare.py').write_bytes(Path(__file__).read_bytes())
    manifest = dict(kind='phase98-exact-ordered-dispatch-proof-source', targetsRun=False,
                    method=pin(__file__), receipt=pin(RECEIPT), source=pin(SOURCE), selectors=pin(SELECTORS),
                    outputs=[pin(out/name) for name in ['candidate.bend','reference.bend','laws.bend','prepare.py']],
                    publicLaws=public, supportLemmas=support, scopes=scopes,
                    entry=str(out/'laws.bend'),
                    transformation='Exact safe comparator and selector declaration bytes prefixed by import Base. Reference derives from original ordered conditions, not candidate bodies.',
                    boundary='Full enum result only. Comparator semantics checked separately. No equivalence or termination theorem for unsafe branch bodies, literal gates, or full callers; no native lifetime proof.')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(out=str(out), entry=manifest['entry'], publicLaws=len(public), supportLemmas=len(support), targetsRun=False)))


if __name__ == '__main__':
    main()
