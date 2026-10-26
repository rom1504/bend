"""Mechanical parser scope-field extension and explicit Bend overlays, no lowering."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def scopes(block):
    start, out, count = 0, '', 0
    while True:
        at = block.find('FParseScope{', start)
        if at < 0:
            return out + block[start:]
        opening = at + len('FParseScope')
        depth, end, quoted, escaped = 1, opening + 1, False, False
        while depth:
            c = block[end]
            if quoted:
                if escaped:
                    escaped = False
                elif c == '\\':
                    escaped = True
                elif c == '"':
                    quoted = False
            elif c == '"':
                quoted = True
            elif c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
            end += 1
        prefix = block[block.rfind('\n', 0, at)+1:at]
        if block.startswith('type FParseScope '):
            extra = ', +priorView: Maybe<&2,KDef>'
        elif prefix.lstrip().startswith('case ') and ':' not in prefix:
            extra = ', +p144p_view' + (str(count) if 'def p140p_scope_same(' in block else '')
            count += 1
        else:
            extra = ', None{}'
        out += block[start:end-1] + extra + '}'
        start = end


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
    selection = ROOT/'implementation/phase143/candidate.json'
    parent = json.loads(selection.read_text())['source']
    assert parent['sha256'] == 'a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'
    assert C.pin(parent['file']) == parent
    before = Path(parent['file']).read_text()
    blocks = C.blocks(before)
    changed = {name: scopes(value) for name,value in blocks.items() if 'FParseScope{' in value}
    # Preserve None fallback for every pre-existing constructor. Only this real
    # parse boundary builds a view; contextual header publication maintains it.
    body = blocks['f_body_header']
    assert body.count('False{}, scope)') == 1
    changed['f_body_header'] = body.replace('False{}, scope)', 'False{}, p144p_ready_scope(scope))')
    b = changed['f_context_declare']
    old = 'f_context_declared(f_context_header(d, ns, aliases), prior, index, ctorIndex, ns, aliases)'
    assert b.count(old) == 1
    changed['f_context_declare'] = b.replace(old,'p144p_declared(f_context_header(d, ns, aliases), prior, index, ctorIndex, ns, aliases, p144p_view)')
    for name, key in [('f_context_family_input','head'),('f_context_mark_input','resolved'),
                      ('f_do_header_resolved','resolved'),('f_do_resolved','resolved')]:
        b = changed[name]
        old = f'f_find(nm({key}), prior)'
        assert b.count(old) == (2 if name == 'f_do_header_resolved' else 1)
        changed[name] = b.replace(old,f'p144p_find(nm({key}), prior, p144p_view)')
    # Cache equality remains stricter than the old semantic scope comparison.
    changed['p140p_scope_same'] = changed['p140p_scope_same'].replace(
        'p140p_defs([ai,ac],[bi,bc])','p140p_defs([ai,ac],[bi,bc]) && p144p_view_same(p144p_view0,p144p_view1)')
    mechanical = ''.join(changed.values())
    modules = [HERE/'prior-v01.bend',HERE/'controls-v02.bend']
    after,added,protected = C.compose(before,[mechanical,*[m.read_text() for m in modules]],set(changed),set())
    final = C.blocks(after)
    for name in ('f_find','f_find_next','f_ctor_index','index_find','index_build','p126bp_complete'):
        assert blocks[name] == final[name], name
    proofs = json.loads((ROOT/'implementation/phase137/candidate.json').read_text())['proofScope']['exactDeclarations']
    for name in proofs:
        assert blocks[name] == final[name], name
    out.mkdir(parents=True)
    (out/'compiler.bend').write_text(after)
    (out/'scope-overlay.bend').write_text(mechanical)
    (out/'prepare.py').write_bytes(Path(__file__).read_bytes())
    for m in modules:
        (out/m.name).write_bytes(m.read_bytes())
    report = dict(kind='phase144-parser-prior-view',complete=True,checked=False,nativeQualified=False,
                  source=C.pin(out/'compiler.bend'),parent=parent,overrides=sorted(changed),added=added,
                  scopeOccurrences=before.count('FParseScope{'),controlCount=27,
                  originalFindUnchanged=True,localLookupAlgorithmUnchanged=True,protectedDeclarations=protected,
                  unchangedProofDeclarations=proofs,physicalLines=len(after.splitlines()),
                  inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(selection),parent,*[C.pin(m) for m in modules]])
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'source':report['source'],'overrides':report['overrides'],'controls':report['controlCount']}))


if __name__ == '__main__':
    main()
