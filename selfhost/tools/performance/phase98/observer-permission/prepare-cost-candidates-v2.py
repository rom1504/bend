#!/usr/bin/env python3
"""Freeze independent observer-planning cost candidates. Data only; no targets."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase98/permission-tag-source02/compiler.bend'
BASE_SHA = '59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714'
BASE_RECIPE = BASE.with_name('changes.json')


def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return {'file': str(path), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}


def definition(text, name):
    token = '@unsafe\ndef ' + name + '('
    assert text.count(token) == 1, name
    start = text.index(token)
    end = text.find('\n\n', start)
    assert end > start
    return text[start:end + 1]


SCHEMA_NAMES = ['no_schema', 'nol_params', 'nol_param_head', 'nol_param_type', 'nol_result', 'nol_finish']
ROUTE_NAMES = ['no_route_schema', 'no_route_one', 'no_route_names']


def cached_definition(text, name, names):
    """Copy exact helper, changing only cached-helper calls and one added argument."""
    value = definition(text, name)
    # All these signatures are one physical line. Match its final -> delimiter,
    # rather than trying to parse the generic types as call expressions.
    signature = next(line for line in value.splitlines() if line.startswith('def '))
    old_signature = signature
    signature = signature.replace('def ' + name + '(', 'def ' + name + '_cached(')
    assert ') -> ' in signature
    signature = signature.replace(') -> ', ', +scalarSpecs: List<&2, NO_Spec>) -> ', 1)
    value = value.replace(old_signature, signature, 1)
    # These exact definitions have only ordinary double-quoted strings. Scan
    # call parentheses with string awareness; nested call offsets are applied
    # backwards so every original span remains exact.
    body_at = value.index('\n', value.index('def ')) + 1
    replacements = []
    for other in names:
        for match in re.finditer(r'\b' + re.escape(other) + r'\(', value[body_at:]):
            start = body_at + match.start()
            pos = body_at + match.end()
            depth = 1
            quoted = False
            escaped = False
            while depth:
                char = value[pos]
                if quoted:
                    if escaped:
                        escaped = False
                    elif char == '\\':
                        escaped = True
                    elif char == '"':
                        quoted = False
                elif char == '"':
                    quoted = True
                elif char == '(':
                    depth += 1
                elif char == ')':
                    depth -= 1
                pos += 1
            replacements += [(start, start + len(other), other + '_cached'), (pos - 1, pos - 1, ', scalarSpecs')]
    for start, end, new in sorted(replacements, reverse=True):
        value = value[:start] + new + value[end:]
    if name == 'nol_finish':
        assert value.count('nol_scalar_specs(book, book)') == 1
        value = value.replace('nol_scalar_specs(book, book)', 'scalarSpecs')
    return value


def cached_route(text):
    names = SCHEMA_NAMES + ROUTE_NAMES
    additions = '\n'.join(cached_definition(text, name, names) for name in names)
    before = definition(text, 'no_route')
    old_call = 'no_route_names(book, names, book_cached(no_entry_defs(segments), 0), old)'
    assert before.count(old_call) == 1
    after = before.replace(old_call, 'no_route_names_cached(book, names, book_cached(no_entry_defs(segments), 0), old, nol_scalar_specs(book, book))')
    # Compute shared scalar descriptors only inside the permission=True branch.
    # Original public queries and all six original schema helpers stay exact.
    return {'function': 'no_route', 'old': before, 'new': additions + '\n' + after}


def lazy_redirect(text):
    before = definition(text, 'no_scalar_redirect')
    after = '''@unsafe
def no_scalar_redirect(workers: List<&2, NF_Worker>, +owner: String, +roots: List<&2, U32>) -> List<&2, NF_Worker>:
  match workers:
    case Nil{}: Nil{}
    case Con{+worker, rest}:
      match worker:
        case NF_Worker{+name, +params, +code, +deps, +shape}:
          Con{nt_choose(NF_Worker, p88_string_eq(name, owner), u =>
            NF_Worker{name, params, nc_prepend("if (" ++ no_shared_roots(params, roots, 0) ++ ") { return " ++ nf_name(no_adapter_name(owner)) ++ "(e, seq, nf_out" ++ nf_arg_c(nf_segment_args(params)) ++ "); }\\n", code), Con{no_adapter_name(owner), deps}, shape},
            u => worker), no_scalar_redirect(rest, owner, roots)}
'''
    return {'function': 'no_scalar_redirect', 'old': before, 'new': after}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase98') and not out.exists()
    base_pin = pin(BASE)
    assert base_pin['sha256'] == BASE_SHA
    source = BASE.read_text()
    parent = json.loads(BASE_RECIPE.read_text())
    original = Path(parent['source']['file'])
    assert pin(original) == parent['source']
    replay = original.read_text()
    for change in parent['changes']:
        at = change['offset']
        assert replay[at:at + len(change['old'])] == change['old']
        if change['old']: assert replay.count(change['old']) == 1
        replay = replay[:at] + change['new'] + replay[at + len(change['old']):]
    assert replay == source
    candidates = {
        'scalar-specs': [cached_route(source)],
        'redirect': [lazy_redirect(source)],
        'both': [cached_route(source), lazy_redirect(source)],
    }
    out.mkdir(parents=True)
    rows = []
    for kind, extra in candidates.items():
        target = out / kind
        target.mkdir()
        candidate = source
        own_changes = []
        for change in extra:
            assert candidate.count(change['old']) == 1
            change = dict(change, offset=candidate.index(change['old']))
            own_changes.append(change)
            candidate = candidate.replace(change['old'], change['new'])
        path = target / 'compiler.bend'
        path.write_text(candidate)
        all_changes = parent['changes'] + own_changes
        replay = original.read_text()
        for change in all_changes:
            at = change['offset']
            assert replay[at:at + len(change['old'])] == change['old']
            if change['old']: assert replay.count(change['old']) == 1
            replay = replay[:at] + change['new'] + replay[at + len(change['old']):]
        assert replay == candidate
        inverse = candidate
        for change in reversed(all_changes):
            at = change['offset']
            assert inverse[at:at + len(change['new'])] == change['new']
            inverse = inverse[:at] + change['old'] + inverse[at + len(change['new']):]
        assert inverse == original.read_text()
        preserved = SCHEMA_NAMES + ROUTE_NAMES if kind != 'redirect' else []
        assert all(definition(source, name) == definition(candidate, name) for name in preserved)
        receipt = dict(kind='phase98-observer-planning-cost-' + kind, complete=True,
                       targetsRun=False, method=pin(Path(__file__)), source=parent['source'],
                       parentSource=base_pin, parentRecipe=pin(BASE_RECIPE), candidate=pin(path),
                       changes=all_changes, localChanges=own_changes,
                       physicalLineDelta=len(candidate.splitlines())-len(source.splitlines()),
                       originalHelpersPreserved=preserved,
                       forwardReplayExact=True, inverseRecoversSource=True,
                       scope='Planning work only; unqualified source derivative. Exact full C/diagnostic identity is required against the parent, then timing. No permission/schema/result/runtime semantic change intended.')
        (target / 'changes.json').write_text(json.dumps(receipt, indent=2) + '\n')
        rows.append({'variant': kind, 'candidate': receipt['candidate'],
                     'recipe': pin(target / 'changes.json'), 'physicalLineDelta': receipt['physicalLineDelta']})
    manifest = dict(kind='phase98-observer-cost-candidates', complete=True, targetsRun=False,
                    method=pin(Path(__file__)), parent=base_pin, candidates=rows)
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
