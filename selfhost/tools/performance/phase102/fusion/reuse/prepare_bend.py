#!/usr/bin/env python3
"""Prepare explicit match/allocation hooks for private TRMC cell reuse."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--parent', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase102') and not out.exists()
    parent = json.loads(args.parent.read_text()); assert parent['complete'] and parent['inverseExact']
    for item in [parent['source'], parent['candidate']]: assert pin(item['file']) == item
    original = Path(parent['candidate']['file']).read_text(); candidate = original; edits = []
    def replace(old, new):
        nonlocal candidate
        assert candidate.count(old) == 1, (old[:100], candidate.count(old))
        at = candidate.index(old); edits.append(dict(offset=at, old=old, new=new))
        candidate = candidate[:at] + new + candidate[at+len(old):]
    replace('def nc_destructure(+name: String, +word: String, +count: U32, +n: U32) -> String:',
        'def ntr_destructure_mode(+name: String, +word: String, +count: U32, +n: U32, +reuse: Bool) -> String:')
    replace('++ "spare_free(e, cls_fit(" ++ U32.show(count) ++ "), ctr_take(e, " ++ word',
        '++ nt_choose(String, reuse, u => "p102_trmc_keep_cell(e, nf_out, cls_fit(", u => "spare_free(e, cls_fit(") ++ U32.show(count) ++ "), ctr_take(e, " ++ word')
    replace('nc_match_apply_join(nm(mat), word, count, n, hit_body, hit_segs, hit_error, hit_calls,',
        'nc_match_apply_join(nm(mat), word, count, n, ntr_target(target), hit_body, hit_segs, hit_error, hit_calls,')
    replace('def nc_match_apply_join(+name: String, +word: String, +count: U32, +n: U32, hit_body: NC_Text,',
        'def nc_match_apply_join(+name: String, +word: String, +count: U32, +n: U32, +reuse: Bool, hit_body: NC_Text,')
    replace('nc_destructure(name, word, count, n)',
        'ntr_destructure_mode(name, word, count, n, reuse)')
    replace('nc_constructor_value(nm(t), nt_append(String, ntr_take_words(words, ix(t)), ["TERM_HOLE"]), n)',
        'ntr_cached_constructor(nm(t), nt_append(String, ntr_take_words(words, ix(t)), ["TERM_HOLE"]), n)')
    replace('Term ntr_state[2] = { TERM_HOLE, 0 };\\nif (!" ++ inner ++ "(e, seq, ntr_state" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { term_sink(e, ntr_state[0]); return 0; }',
        'Term ntr_state[4] = { TERM_HOLE, 0, 0, 0 };\\nTerm ntr_ok = " ++ inner ++ "(e, seq, ntr_state" ++ nf_arg_c(nf_segment_args(params)) ++ ");\\nif (ntr_state[2]) spare_free(e, (Cls)ntr_state[3], (Loc)ntr_state[2]);\\nif (!ntr_ok) { term_sink(e, ntr_state[0]); return 0; }')
    replace('++ nf_prototypes(no_route_workers(route), no_route_ready(route)) ++ nf_bodies(',
        '++ ntr_cache_helpers() ++ nf_prototypes(no_route_workers(route), no_route_ready(route)) ++ nf_bodies(')
    c = (HERE/'reuse-cells.c').read_text()
    helpers = '''
# Ordinary matches keep their original release policy. Only a tail destination
# with the private TRMC marker can retain a uniquely transferred input cell.
@unsafe
def nc_destructure(+name: String, +word: String, +count: U32, +n: U32) -> String:
  ntr_destructure_mode(name, word, count, n, False{})

# NTRCons admission already proves an ordinary boxed constructor with 2..8
# fields. Preserve ne_ctor_node's normal field stores, packing and seal policy;
# only this final reconstruction allocation may use the private same-class cell.
@unsafe
def ntr_cached_constructor(+name: String, +words: List<&2, String>, +n: U32) -> N_Emitted:
  ne_wrap_ctor(name, ne_ctor_node(name, "p102_trmc_take_cell(e, nf_out, cls_fit(" ++ U32.show(nt_count(String, words)) ++ "))", words, n, True{}))

@unsafe
def ntr_cache_helpers() -> String:
  ''' + json.dumps(c) + '\n'
    edits.append(dict(offset=len(candidate), old='', new=helpers)); candidate += helpers
    reverse = candidate
    for edit in reversed(edits):
        at=edit['offset']; assert reverse[at:at+len(edit['new'])] == edit['new']
        reverse=reverse[:at]+edit['old']+reverse[at+len(edit['new']):]
    assert reverse == original
    for edit in reversed(parent['changes']):
        at=edit['offset']; assert reverse[at:at+len(edit['new'])] == edit['new']
        reverse=reverse[:at]+edit['old']+reverse[at+len(edit['new']):]
    assert reverse == Path(parent['source']['file']).read_text()
    out.mkdir(parents=True); (out/'compiler.bend').write_text(candidate)
    report=dict(complete=True,targetsRun=False,releaseQualified=False,kind='phase102-explicit-trmc-cell-reuse-hooks',
        source=parent['source'],parentCandidate=parent['candidate'],parentRecipe=pin(args.parent),
        candidate=pin(out/'compiler.bend'),method=pin(__file__),helper=pin(HERE/'reuse-cells.c'),
        changes=parent['changes']+edits,addedChanges=edits,inverseExact=True,inverseToParentExact=True,
        physicalLineDelta=len(candidate.splitlines())-len(original.splitlines()),byteDelta=len(candidate.encode())-len(original.encode()),
        scope='Explicit compiler hooks, no C macro or emitted-text rewrite. Only NTRMC tail matches cache ctr_take-returned cells and only admitted NTRCons reconstruction allocates from cache. Original scalar/array/packing/field-store policy and scheduler/non-TRMC match paths unchanged. Shared/static cells rejected by HEAP_OFF guard; one private cell released by wrapper before success/failure. C prototype parent additionally tried all constructor allocation sites; this source intentionally narrows allocation reuse to the structural reconstruction node.')
    (out/'changes.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(candidate=report['candidate'],physicalLineDelta=report['physicalLineDelta'],byteDelta=report['byteDelta'])))


if __name__ == '__main__': main()
