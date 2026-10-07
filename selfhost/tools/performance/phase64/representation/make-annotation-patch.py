#!/usr/bin/env python3
"""Make an isolated compact-annotation source patch. Never edit production."""
import argparse
import difflib
import hashlib
import json
import re
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--root', type=Path, default=Path('.'))
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root, out = a.root.resolve(), a.output.resolve()
assert not out.exists()
out.mkdir(parents=True)
changes, preservation = [], []

def sha(value):
    return hashlib.sha256(value.encode()).hexdigest()

def patch_function(source, name, body):
    pattern = re.compile(r'^def ' + re.escape(name) + r'\b', re.M)
    found = list(pattern.finditer(source))
    assert len(found) == 1, name
    begin = found[0].start()
    following = re.search(r'\n(?=@unsafe\n|law |type )', source[begin:])
    end = begin + following.start() if following else len(source)
    old = source[begin:end]
    assert old.count('case KTerm{') == 1, name
    marker = '\n    case KLambda{'
    assert old.count(marker) == 1, name
    new = old.replace(marker, '\n    case KAnnotation{term, typ}:\n      ' + body + marker, 1)
    preservation.append({'function': name, 'body': body})
    return source[:begin] + new + source[end:]

term_rel = 'selfhost/src/core/term.bend'
paths = [term_rel, 'selfhost/src/check/annotate.bend', 'selfhost/src/check/prefix-state.bend',
         'selfhost/src/load/prefix.bend', 'selfhost/src/front/elaborate.bend',
         'selfhost/src/front/parser.bend']
originals = {rel: (root / rel).read_text() for rel in paths}
source = originals[term_rel]
needle = '  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}\n'
assert source.count(needle) == 1
source = source.replace(needle, needle + '  KAnnotation{+term: KTerm, +typ: KTerm}\n')
compact_arms = {
 'tg': '"Ann"', 'nm': '""', 'ix': '0', 'qt': '0',
 'ks': 'Con{term, Con{typ, Nil{}}}', 'rm': 'Nil{}',
 'subst_node': 'KAnnotation{subst(term, id0, v), subst(typ, id0, v)}',
 'core_subst_stable': 'core_subst_stable(term) && core_subst_stable(typ)',
 'kb': '0', 'ke': '0',
 'k_with_children': 'KTerm{"Ann", "", 0, 0, newKids, Nil{}, 0, 0}',
 'k_with_span': 'KTerm{"Ann", "", 0, 0, Con{term, Con{typ, Nil{}}}, Nil{}, newBegin, newEnd}',
 'core_literal': 'False{}', 'kl_number': '0', 'kl_text': '""',
 'k_quantity_present': 'False{}',
 'k_rebuild': 'KTerm{"Ann", name, id, quant, kids, removed, begin, end}',
 'k_snf_children': 'KTerm{"Ann", "", 0, 0, kids, Nil{}, 0, 0}',
 'k_lambda_presence': 't',
}
for name, body in compact_arms.items():
    source = patch_function(source, name, body)
old_kid = '  terms_at(ks(t), n)'
assert source.count(old_kid) == 1
source = source.replace(old_kid, '''  match t:
    case KAnnotation{term, typ}:
      kc(KTerm, U32.is_eq(n, 0), u => term,
        u => kc(KTerm, U32.is_eq(n, 1), u => typ, u => atom("Absent")))
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      terms_at(kids, n)
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      terms_at(kids, n)
    case KLiteral{kind, number, text, begin, end}:
      atom("Absent")''')
results = {term_rel: source}
rel = 'selfhost/src/check/annotate.bend'
needle = '  kt("Ann", "", 0, 0, Con{t, Con{ty, Nil{}}})'
assert originals[rel].count(needle) == 1
results[rel] = originals[rel].replace(needle, '  KAnnotation{t, ty}')
for rel, name in [('selfhost/src/check/prefix-state.bend', 'prefix_state_variant'),
                  ('selfhost/src/load/prefix.bend', 'f_fresh_prefix_variant')]:
    results[rel] = patch_function(originals[rel], name, '3')
rel = 'selfhost/src/front/elaborate.bend'
results[rel] = patch_function(originals[rel], 'f_pattern_value', '''KTerm{"Ann", "", 0, 0, f_pattern_values(Con{term, Con{typ, Nil{}}}, begin, end), Nil{},
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => 0),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => 0)}''')
rel = 'selfhost/src/front/parser.bend'
results[rel] = patch_function(originals[rel], 'f_span_created', '''f_choose(KTerm, U32.is_eq(begin, 0), u => t,
        u => KTerm{"Ann", "", 0, 0, f_spans_created(Con{term, Con{typ, Nil{}}}, begin, end), Nil{}, begin, end})''')
assert len(preservation) == 23
patches = []
for rel in paths:
    old, new = originals[rel], results[rel]
    for side, content in [('before', old), ('after', new)]:
        target = out / side / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content)
    patches.extend(difflib.unified_diff(old.splitlines(True), new.splitlines(True),
                                       fromfile='a/' + rel, tofile='b/' + rel))
    changes.append({'file': rel, 'beforeSha256': sha(old), 'afterSha256': sha(new),
                    'beforeLines': len(old.splitlines()), 'afterLines': len(new.splitlines())})
    assert (root / rel).read_text() == old, 'Live source changed while preparing: ' + rel
patch = ''.join(patches)
(out / 'candidate.patch').write_text(patch)
manifest = {'kind': 'phase64-compact-annotation-patch-only', 'dataOnly': True,
            'targetExecuted': False, 'productionEdited': False, 'productionQualified': False,
            'generator': {'file': str(Path(__file__).resolve()), 'sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},
            'constructor': {'name': 'KAnnotation', 'fields': ['term', 'typ'], 'logicalTag': 'Ann'},
            'files': changes, 'preservationArms': preservation, 'patchSha256': sha(patch),
            'netLines': sum(x['afterLines'] - x['beforeLines'] for x in changes),
            'hostBoundary': 'NOT IMPLEMENTED: constructor positional ABI and explicit annotation/term-version/cache admission policy require host-owner coordination. Named-layout-only experimental source ablation; do not promote this patch alone.',
            'allocationModel': 'Ignoring promotion and Nil/header effects, each producer avoids 2 Con and 6 wrapper payload fields; each generic ks materialization allocates 2 Con. Net objects saved: 2*A-2*G. Retained-node census does not measure A/G.'}
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({'patch': str(out / 'candidate.patch'), 'files': len(changes), 'preservationArms': len(preservation), 'netLines': manifest['netLines']}))
