#!/usr/bin/env python3
"""Source-only assertions over actual emitted C; does not execute a compiler."""
import argparse
import hashlib
import json
import re
from pathlib import Path


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def private_name(owner, adapter=False):
    raw = ('$observer.adapter.' if adapter else '$observer.') + owner
    return 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in raw)


def function_span(source, name):
    # Match definitions only; declarations end with semicolon, never a brace.
    pattern = r'\b' + re.escape(name) + r'\(Env e, bool seq, Term\* nf_out[^;{}]*\)\s*\{'
    found = list(re.finditer(pattern, source))
    assert len(found) == 1, (name, 'expected one definition', len(found))
    begin = found[0].end() - 1
    depth = 0
    tokens = r'/\*[\s\S]*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\x27(?:\\.|[^\x27\\])*\x27|[{}]'
    for token in re.finditer(tokens, source[begin:]):
        if token.group() == '{':
            depth += 1
        elif token.group() == '}':
            depth -= 1
            if depth == 0:
                return begin, begin + token.end()
    raise AssertionError('unclosed function ' + name)


def audit(source, owner, expect, permission):
    macro = re.findall(r'^#define NATIVE_READONLY_OBSERVERS ([01])$', source, re.M)
    assert macro == [str(permission)], ('explicit permission macro', macro)
    names = [private_name(owner), private_name(owner, True)]
    result = dict(owner=owner, expected=expect, permission=permission, privateNames=names)
    if expect == 'absent':
        assert all(name not in source for name in names), 'refused owner has observer artifacts'
        result['absent'] = True
        return result
    assert permission == 1
    obs_span, adapter_span = (function_span(source, name) for name in names)
    obs = source[slice(*obs_span)]
    adapter = source[slice(*adapter_span)]
    assert '#if NATIVE_READONLY_OBSERVERS\n' in obs
    assert '#if NATIVE_READONLY_OBSERVERS\n' in adapter
    assert 'err_spun(e.mem, &nf_poll)' in obs
    assert 'if (!seq && err_seen(e.mem)) { return 0; }' in obs
    assert 'nf_out[0] =' in obs and 'return 1;' in obs
    forbidden = ['term_keep(', 'term_sink(', 'term_take(', 'spare_free(', 'term_alloc(',
                 'term_word(', 'heap_alloc(', 'pool_alloc(', 'malloc(', 'term_ctr(']
    assert not [word for word in forbidden if word in obs], 'borrowed body mutates ownership or allocates'
    assert 'Term no_root_' in adapter
    call = re.search(r'if \(!' + re.escape(names[0]) + r'\(e, seq, no_observed[^\n]*\)\) \{ return 0; \}', adapter)
    assert call, 'owned adapter must call actual borrowed worker'
    check = 'if (!seq && err_seen(e.mem)) { return 0; }'
    assert check in adapter[:call.start()] and adapter[call.end():].lstrip().startswith(check)
    assert adapter.find('Term no_scalar_result') > call.end()
    hook = '#if !DEVICE && NATIVE_READONLY_OBSERVERS\n{\nTerm no_public_result[1];\nif (!' + names[1]
    assert source.count(hook) == 1, 'exactly one active scheduler hook required'
    result.update(active=True, observerSpan=obs_span, adapterSpan=adapter_span,
        readOnlyForbiddenTokens=forbidden, borrowedReads=obs.count('term_peek('),
        scalarStatements=obs.count(' = nat_') + obs.count(' = u32_'),
        selfTailTransitions=obs.count('goto nf_again;'), adapterRootSlots=adapter.count('Term no_root_'))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('c', type=Path)
    parser.add_argument('owner')
    parser.add_argument('--expect', choices=['active', 'absent'], required=True)
    parser.add_argument('--permission', type=int, choices=[0, 1], required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    before = pin(args.c)
    value = audit(args.c.read_text(), args.owner, args.expect, args.permission)
    assert pin(args.c) == before
    result = dict(kind='phase70-observer-emission-audit-v1', source=before,
                  producer=pin(__file__), check=value, pass_=True,
                  scope='Actual C source shape only; runtime path coverage and semantics remain separate.')
    with args.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
