#!/usr/bin/env python3
"""Offline integration specification: only returns/writes a candidate flat module.

Root combines this with other lanes. This tool does not edit the live compiler,
execute a compiler, regenerate a runtime template, or admit a native product.
"""
import argparse
import hashlib
import json
from pathlib import Path


def transform_flat(source):
    assert 'nx_append_' not in source, 'Refuse double append integration'
    declaration = '  +ordinary = nf_wrap_segments(ss, book_cached(nf_adapter_defs(workers, ready), 0))\n'
    assert source.count(declaration) == 1
    source = source.replace(declaration, declaration + '  +append = nx_append_allowed(book, observers)\n')
    old = 'nc_with_show(no_wrap_routes(ordinary, no_route_entries(route), no_route_ready(route)), cs, runtime'
    new = 'nc_with_show(nx_append_segments(no_wrap_routes(ordinary, no_route_entries(route), no_route_ready(route)), append), cs, runtime'
    assert source.count(old) == 1
    source = source.replace(old, new)
    old = 'pure, show, nh_observer_macros(book, no_route_entries(route), no_route_ready(route))'
    new = 'pure, show, kc(String, append, u => nx_append_helper(), u => "") ++ nh_observer_macros(book, no_route_entries(route), no_route_ready(route))'
    assert source.count(old) == 1
    return source.replace(old, new)



def patch(source, equal='String.eq'):
    """Composable full-source intervention; exact reversible edit records."""
    assert equal in ('String.eq', 'p88_string_eq')
    start = source.index('@unsafe\ndef nf_finish_ready(')
    end = source.index('\n\n', start)
    old = source[start:end]
    new = transform_flat(old)
    changes = [dict(offset=start, old=old, new=new, function='nf_finish_ready')]
    source = source[:start] + new + source[end:]
    helper = '\n' + Path(__file__).with_name('append.bend').read_text().replace('String.eq(', equal + '(')
    changes.append(dict(offset=len(source), old='', new=helper, function='nx_append_*'))
    source += helper
    return source, changes


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--flat', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    source = args.flat.read_text()
    output = transform_flat(source)
    args.out.mkdir(parents=True, exist_ok=False)
    module = Path(__file__).with_name('append.bend')
    (args.out/'flat.bend').write_text(output)
    (args.out/'append.bend').write_bytes(module.read_bytes())
    sha = lambda b: hashlib.sha256(b).hexdigest()
    receipt = dict(complete=True, offline=True,
        source=dict(file=str(args.flat.resolve()), sha256=sha(source.encode())),
        transformed=dict(file=str((args.out/'flat.bend').resolve()), sha256=sha(output.encode())),
        append=dict(file=str(module.resolve()), sha256=sha(module.read_bytes())),
        instructions='Add append.bend as a native module in the candidate manifest; merge flat change; no runtime.c/template change. Qualification and release selection remain separate.')
    (args.out/'integration.json').write_text(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    main()
