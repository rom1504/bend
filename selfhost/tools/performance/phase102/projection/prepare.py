#!/usr/bin/env python3
"""Offline bounded owning-observer product/projection experiment on generated C."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
FUNCTION = re.compile(r'^(?:NF_INLINE|INLINE) Term (NF_FID_\w+)\([^;{}]*\) \{', re.M)
BRACES = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//[^\n]*|[{}]', re.S)
IDENT = re.compile(r'\b(?:NF_FID_\w+|v_\d+|nd_\d+|nf_join_\d+|nq_result_\d+)\b')
TOKENS = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_]\w*|\d+|[^\s]')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def normal(text):
    names, counts = {}, {}
    def rename(match):
        word = match[0]
        category = next(prefix for prefix in ('NF_FID_', 'nf_join_', 'nq_result_', 'v_', 'nd_') if word.startswith(prefix))
        if word not in names:
            index = counts.get(category, 0); counts[category] = index + 1
            names[word] = category + str(index)
        return names[word]
    text = IDENT.sub(rename, text).replace('NF_INLINE', 'INLINE')
    return ' '.join(TOKENS.findall(text)), {value:key for key, value in names.items()}


def functions(source):
    result = {}
    for match in FUNCTION.finditer(source):
        depth = 1
        for token in BRACES.finditer(source, match.end()):
            if token[0] == '{': depth += 1
            elif token[0] == '}': depth -= 1
            if depth == 0: break
        else: raise AssertionError('Unterminated function')
        assert match[1] not in result
        text = source[match.start():token.end()]
        shape, names = normal(text)
        result[match[1]] = dict(start=match.start(), end=token.end(), text=text, shape=shape, names=names)
    return result


def product_adapter(text, name):
    blocks = list(re.finditer(r'u64 (nd_\d+) = heap_alloc\(e, cls_fit\(2\)\);\n'
        r'#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_TUPLE\n'
        r'e.mem\[\1 \+ 0\] = (v_\d+);\ne.mem\[\1 \+ 1\] = (v_\d+);\n'
        r'#else\n.*?#endif\n(v_\d+|nf_out\[0\]) = term_ctr\(CID_TUPLE, \1\);', text, re.S))
    assert len(blocks) == 2 and blocks[1][4] == 'nf_out[0]'
    inner, outer = blocks
    assert inner[4] == outer[2]
    replacements = [f'nf_out[0] = {inner[2]};\nnf_out[1] = {inner[3]};\n{inner[4]} = 0;',
                    f'nf_out[2] = {outer[3]};']
    for block, replacement in reversed(list(zip(blocks, replacements))):
        text = text[:block.start()] + replacement + text[block.end():]
    old_name = FUNCTION.match(text)[1]
    return text.replace('Term ' + old_name + '(', 'Term ' + name + '(', 1)


PROJECT = '''NF_INLINE Term P102_PROJECT_OWNED_TUPLE(Env e, bool seq, Term* nf_out, Term first, Term second, Term result) {
u32 nf_poll = 0;
if (err_spun(e.mem, &nf_poll)) { return 0; }
term_sink(e, first);
term_sink(e, second);
nf_out[0] = result;
return 1;
}
'''


def transform(source):
    assert 'P102_PROJECT_' not in source and 'P102_PRODUCT_' not in source
    patterns = json.loads((HERE / 'patterns.json').read_text())
    fs = functions(source); edits = []; selected = []; products = {}
    for name, fn in fs.items():
        if fn['shape'] != patterns['composition']: continue
        names = fn['names']; owner = names['NF_FID_1']; projector = names['NF_FID_2']; path = []
        if projector not in fs or fs[projector]['shape'] != patterns['projection']: continue
        for _ in range(5):
            if owner not in fs or owner in path: break
            path.append(owner)
            if fs[owner]['shape'] == patterns['adapter']: break
            if fs[owner]['shape'] != patterns['alias']: break
            owner = fs[owner]['names']['NF_FID_1']
        if owner not in fs or fs[owner]['shape'] != patterns['adapter']: continue
        adapter = fs[owner]
        private = 'P102_PRODUCT_' + hashlib.sha256(owner.encode()).hexdigest()[:16]
        products[private] = product_adapter(adapter['text'], private)
        text = fn['text']; first = names['nq_result_0']; second = names['nq_result_1']; value = names['v_2']
        needle = f'if (!{names["NF_FID_1"]}(e, seq, {first},'
        assert text.count(needle) == 1
        text = text.replace(needle, f'if (!{private}(e, seq, p102_product,', 1)
        needle = f'{value} = {first}[0];'; assert text.count(needle) == 1
        text = text.replace(needle, f'{value} = 0;', 1)
        needle = f'if (!{projector}(e, seq, {second}, {value}))'
        assert text.count(needle) == 1
        text = text.replace(needle, f'if (!P102_PROJECT_OWNED_TUPLE(e, seq, {second}, p102_product[0], p102_product[1], p102_product[2]))', 1)
        brace = text.index('{') + 1
        text = text[:brace] + '\nTerm p102_product[3];' + text[brace:]
        edits.append(dict(offset=fn['start'], old=fn['text'], new=text))
        selected.append(dict(caller=name, aliasPath=path, adapter=owner, projection=projector,
                             borrowedWorker=adapter['names']['NF_FID_1'], privateWorker=private))
    if not selected:
        return source, dict(kind='phase102-observer-product-projection', selected=[], unchanged=True)
    # The recognized projection uses full Terms. Do not inherit external field narrowing.
    for match in re.finditer(r'^#define NATIVE_FIELD32_CID_TUPLE_[01]\s+([^\n]+)', source, re.M):
        assert match[1].strip() == '0', 'Tuple field narrowing requires a separate proof'
    end_marker = '#undef NF_INLINE\n#undef NF_SCALAR\n#endif'
    assert source.count(end_marker) == 1
    bodies = '\n'.join(products.values()) + '\n' + PROJECT
    declarations = '\n'.join(body[:body.index('{')].strip() + ';' for body in [*products.values(), PROJECT]) + '\n'
    first_proto = re.search(r'^(?:NF_INLINE|INLINE) Term NF_FID_\w+\(', source, re.M)
    assert first_proto and first_proto.start() < source.index(end_marker)
    edits += [dict(offset=first_proto.start(), old='', new=declarations),
              dict(offset=source.index(end_marker), old='', new=bodies)]
    candidate = source
    for edit in sorted(edits, key=lambda e:e['offset'], reverse=True):
        at = edit['offset']; assert candidate[at:at+len(edit['old'])] == edit['old']
        candidate = candidate[:at] + edit['new'] + candidate[at+len(edit['old']):]
    # Inverse with shifted positions establishes exact nonselected-source preservation.
    shift = 0; adjusted = []
    for edit in sorted(edits, key=lambda e:e['offset']):
        adjusted.append(dict(offset=edit['offset']+shift, old=edit['old'], new=edit['new']))
        shift += len(edit['new']) - len(edit['old'])
    inverse = candidate
    for edit in reversed(adjusted):
        at = edit['offset']; assert inverse[at:at+len(edit['new'])] == edit['new']
        inverse = inverse[:at] + edit['old'] + inverse[at+len(edit['new']):]
    assert inverse == source
    return candidate, dict(kind='phase102-observer-product-projection', selected=selected,
        owningProductWords=3, removedTupleAllocationSites=2*len(products), inverseExact=True,
        patterns=pin(HERE/'patterns.json'), scope='Exact structural generated-C experiment; no String/function-name selection, public ABI change or Bend emitter integration.')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--catalog', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); old = json.loads(a.catalog.read_text()); assert old['complete']
    out = a.out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=True, targetsRun=False, method=pin(__file__), patterns=pin(HERE/'patterns.json'),
                  parent=pin(a.catalog), programs=[])
    for row in old['programs']:
        assert pin(row['candidateC']['file']) == row['candidateC']
        source = Path(row['candidateC']['file']).read_text(); result, details = transform(source)
        dest = out/(row['id']+'.c'); dest.write_text(result)
        report['programs'].append(dict(id=row['id'], baselineC=row['baselineC'], originalC=row['candidateC'],
                                       candidateC=pin(dest), intervention=details))
    (out/'catalog.json').write_text(json.dumps(report, indent=2)+'\n')
    (out/'prepare.py').write_text('''from pathlib import Path
import hashlib,json
def transform(source):
    catalog=json.loads(Path(__file__).with_name('catalog.json').read_text())
    digest=hashlib.sha256(source.encode()).hexdigest()
    rows=[v for v in catalog['programs'] if v['baselineC']['sha256']==digest]
    assert len(rows)==1
    row=rows[0]; data=Path(__file__).with_name(row['id']+'.c').read_bytes()
    assert hashlib.sha256(data).hexdigest()==row['candidateC']['sha256']
    return data.decode(),dict(original=row['originalC'],method=catalog['method'],intervention=row['intervention'])
''')
    print(json.dumps({row['id']:len(row['intervention']['selected']) for row in report['programs']}))


if __name__ == '__main__': main()
