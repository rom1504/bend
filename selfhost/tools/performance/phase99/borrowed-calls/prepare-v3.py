#!/usr/bin/env python3
"""Prepare exact first-stage borrowed-call derivative; no compiler execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
BASE_SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    assert pin(BASE)['sha256'] == BASE_SHA
    original = BASE.read_text(); candidate = original; changes = []

    def edit(old, new):
        nonlocal candidate
        assert old != new and candidate.count(old) == 1, old[:160]
        offset = candidate.index(old)
        changes.append(dict(old=old, new=new, offset=offset))
        candidate = candidate[:offset] + new + candidate[offset + len(old):]

    def definition(name, kind='def'):
        found = list(re.finditer(r'^' + kind + ' ' + re.escape(name) + r'(?:\(|:)', candidate, re.M))
        assert len(found) == 1, name
        start = found[0].start(); end = candidate.index('\n\n', start)
        return candidate[start:end]

    edit('NO_Context{+book: List<&2, KDef>, +owner: String, +schema: NO_Schema}',
         'NO_Context{+book: List<&2, KDef>, +owner: String, +schema: NO_Schema, +callees: List<&2, NO_Callee>}')
    for name in ['noa_book', 'noa_owner', 'noa_schema']:
        old = definition(name); edit(old, old.replace('NO_Context{+b, +o, +s}', 'NO_Context{+b, +o, +s, +calls}'))
    edit('NO_Route{+workers: List<&2, NF_Worker>, +ready: List<&2, String>, +entries: List<&2, KDef>}',
         'NO_Route{+workers: List<&2, NF_Worker>, +ready: List<&2, String>, +entries: List<&2, KDef>, +callees: List<&2, NO_Callee>, +pending: List<&2, String>}')
    for name in ['no_route_workers', 'no_route_ready', 'no_route_entries']:
        old = definition(name); edit(old, old.replace('NO_Route{workers, ready, entries}', 'NO_Route{workers, ready, entries, callees, pending}'))

    family = ['no_emit', 'no_emit_let', 'no_emit_match_layout', 'no_emit_match_found']
    for name in family:
        old = definition(name); new = old
        for called in family:
            new = new.replace(called + '(', called + '_calls(callees, ')
        new = new.replace('def ' + name + '_calls(callees, +', 'def ' + name + '_calls(+callees: List<&2, NO_Callee>, +')
        if name == 'no_emit':
            head, body = new.split('\n', 1)
            new = head + '\n  nt_choose(NC_Code, p98_tag_eq(t, "NO_Call"), u => nob_emit_call(callees, t, env, params, layouts, n), u =>\n' + body + ')'
        edit(old, new)
    old = definition('no_emit', 'law')
    edit(old, old.replace('law no_emit:', 'law no_emit_calls:\n  for +callees: List<&2, NO_Callee>'))
    old = definition('no_worker')
    edit(old, old.replace('def no_worker(', 'def no_worker_calls(+callees: List<&2, NO_Callee>, ').replace('no_emit(body,', 'no_emit_calls(callees, body,'))
    old = definition('noa_analyze')
    edit(old, old.split('\n')[0] + '\n  noa_analyze_calls(book, name, schema, permission, Nil{})')
    old = definition('no_plan_schema_ready')
    edit(old, old.split('\n')[0] + '\n  no_plan_schema_calls(book, name, schema, Nil{})')

    old = definition('noa_reference')
    new = old.replace('  +d = lookup(noa_book(ctx), name)', '  +d = lookup(noa_book(ctx), name)\n  +callee = nob_find(name, noa_callees(ctx))\n  +words = nob_call_args(ctx, callee, args)')
    anchor = '  nt_choose(NO_Analysis, p88_string_eq(dk(d), "Def")'
    new = new.replace(anchor, '  nt_choose(NO_Analysis, p98_tag_eq(words, "NO_Args"), u => noa_borrow_call(ctx, name, callee, words, facts, n, fuel, k), u =>\n' + anchor) + ')'
    edit(old, new)

    old = definition('no_route_pair')
    new = old.replace('+types: List<&2, KTerm>)', '+types: List<&2, KTerm>, +schema: NO_Schema)')
    new = new.replace('no_route_entries(old)}},', 'no_route_entries(old)}, nt_choose(List<&2, NO_Callee>, scalar, v => Con{NO_Callee{owner, schema}, no_route_callees(old)}, v => no_route_callees(old)), no_route_pending(old)},')
    edit(old, new)
    old = definition('no_route_plan')
    new = old.replace('[no_worker(owner,', '[no_worker_calls(no_route_callees(old), owner,')
    new = new.replace('no_schema_roots(schema), 0)), v => old), u => old)', 'no_schema_roots(schema), 0), schema), v => old), u => nob_defer(old, owner, noa_error(analysis)))')
    edit(old, new)
    old = definition('no_route_schema')
    edit(old, old.replace('no_plan_schema_ready(book, name, schema)', 'no_plan_schema_calls(book, name, schema, no_route_callees(old))'))
    old = definition('no_route_one')
    edit(old, old.replace('p88_string_eq(dk(entry), "NOEligibleEntry"),', 'p88_string_eq(dk(entry), "NOEligibleEntry") && Bool.not(p88_string_eq(no_schema_error(nob_find(name, no_route_callees(old))), "")),'))
    old = definition('no_route')
    new = old.replace('NO_Route{workers, ready, Nil{}}', 'NO_Route{workers, ready, Nil{}, Nil{}, Nil{}}')
    new = new.replace('u => no_route_names(book, names, book_cached(no_entry_defs(segments), 0), old),', 'u => nob_retry(book, book_cached(no_entry_defs(segments), 0), no_route_names(book, names, book_cached(no_entry_defs(segments), 0), old)),')
    edit(old, new)
    helpers = (HERE / 'helpers-v3.bend').read_text()
    offset = len(candidate)
    changes.append(dict(old='', new='\n' + helpers, offset=offset))
    candidate += '\n' + helpers

    reverse = candidate
    for change in reversed(changes):
        at = change['offset']; assert reverse[at:at + len(change['new'])] == change['new']
        reverse = reverse[:at] + change['old'] + reverse[at + len(change['new']):]
    assert reverse == original
    assert 'v => noa_below(kid(origin, 0), want), v => False{}' in candidate
    out.mkdir(parents=True); (out / 'compiler.bend').write_text(candidate)
    recipe = dict(kind='phase99-certified-borrowed-calls-source', complete=True, targetsRun=False,
                  method=pin(__file__), helpers=pin(HERE / 'helpers-v3.bend'), source=pin(BASE),
                  candidate=pin(out / 'compiler.bend'), changes=changes, inverseExact=True,
                  physicalLineDelta=len(candidate.splitlines()) - len(original.splitlines()),
                  byteDelta=len(candidate.encode()) - len(original.encode()),
                  scope='Calls between already admitted scalar observers with existing plain schemas; no KTerm layout, virtual literal, runtime or canonical change. Pending helper-cycle/depth plans receive one retry; no full second analysis pass.')
    (out / 'changes.json').write_text(json.dumps(recipe, indent=2) + '\n')
    print(json.dumps({k: recipe[k] for k in ['candidate', 'physicalLineDelta', 'byteDelta']}))


if __name__ == '__main__':
    main()
