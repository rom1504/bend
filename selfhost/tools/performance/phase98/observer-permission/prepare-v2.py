#!/usr/bin/env python3
"""Freeze successor02: affine correction, safe predicate, isolated observer permission; no targets."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
D04 = 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
BASE = ROOT/'selfhost/build/phase92/upstream-checked01/compiler.bend'
MODULES = ROOT/'selfhost/src/back/native'


def pin(path):
    path = path.resolve(); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def definition(text, name):
    token = '@unsafe\ndef '+name+'('
    assert text.count(token) == 1, name
    start = text.index(token); end = text.find('\n\n', start)
    return text[start:] if end < 0 else text[start:end+1]


HELPERS = '''# Checked observer permission is independent of packed arrays and narrowing.
# The host authenticates Base/runtime/provider bytes; names alone grant nothing.
# Keep the old rewrite refusal. The observer's own typed schema/residual checks
# separately exclude Array roots, allocating Word views and foreign calls.
@unsafe
def no_effect_terms(ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{+t, rest}: Bool.not(String.eq(tg(t), "Rwt")) && no_effect_terms(ks(t)) && no_effect_terms(rest)

@unsafe
def no_effect_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d), u => True{}, u => nt_choose(Bool, nc_foreign(d),
        v => no_effect_foreign_allowed(db(d), String.eq(tg(nc_unann(dv(d))), "Foreign"), dn(d)),
        v => String.eq(dk(d), "Def") && no_effect_terms([dv(d)]))), u => no_effect_definitions(book, rest), u => False{})

'''


def transformations(text, safe_helpers):
    edits = []
    def edit(name, transform):
        nonlocal text
        old = definition(text, name); new = transform(old)
        assert new != old and text.count(old) == 1
        edits.append(dict(old=old, new=new, offset=text.index(old), function=name))
        text = text.replace(old, new)

    def checked(old):
        old = old.replace('requests: String, effects_safe: Bool)', 'requests: String, +effects_safe: Bool)')
        old = old.replace('  nc_compile_mode(book, ns_checked_runtime(book, runtime, packed, unshared), requests, packed)', '''  +observers = nt_choose(Bool, effects_safe, u => no_effect_definitions(book, names), u => False{})
  +error = nc_compile_error(book)
  nt_choose(NC_Result, String.eq(error, ""), u =>
    ns_compile_scoped(book, NE_Text{ns_checked_runtime(book, runtime, packed, unshared)}, requests, observers, packed),
    u => NC_Result{"", error})''')
        return safe_helpers+"\n"+HELPERS+old

    def request(old):
        old = old.replace('      +unshared = ', '      +observers = nt_choose(Bool, effects_safe, u => no_effect_definitions(book, names), u => False{})\n      +unshared = ')
        return old.replace('ns_compile_named(book, names, header, requests, packed)', 'ns_compile_named_scoped(book, names, header, requests, observers, packed)')

    def compile_source(old):
        return '''@unsafe
def ns_compile(+book: List<&2, KDef>, +runtime: NE_Runtime, +requests: String, +observers: Bool) -> NC_Result:
  ns_compile_scoped(book, runtime, requests, observers, observers)

'''+old.replace('def ns_compile(', 'def ns_compile_scoped(').replace('+observers: Bool)', '+observers: Bool, +sharing: Bool)').replace('ns_compile_named(source, names, runtime, requests, observers)', 'ns_compile_named_scoped(source, names, runtime, requests, observers, sharing)')

    def compile_named(old):
        return '''@unsafe
def ns_compile_named(+source: List<&2, KDef>, +names: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool) -> NC_Result:
  ns_compile_named_scoped(source, names, runtime, requests, observers, observers)

'''+old.replace('def ns_compile_named(', 'def ns_compile_named_scoped(').replace('+observers: Bool)', '+observers: Bool, +sharing: Bool)').replace('ns_compile_planned(prepared, names, bangs, runtime, requests, observers)', 'ns_compile_planned_scoped(prepared, names, bangs, runtime, requests, observers, sharing)').replace('nh_macros(prepared, names, observers)', 'nh_macros(prepared, names, sharing)').replace('observers && List.is_empty', 'sharing && List.is_empty').replace('ns_compile_fallback(prepared,', 'ns_compile_fallback_scoped(prepared,').replace('requests, observers, nc_compile_defs', 'requests, observers, sharing, nc_compile_defs')

    def compile_planned(old):
        return '''@unsafe
def ns_compile_planned(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool) -> NC_Result:
  ns_compile_planned_scoped(book, names, bangs, runtime, requests, observers, observers)

'''+old.replace('def ns_compile_planned(', 'def ns_compile_planned_scoped(').replace('+observers: Bool)', '+observers: Bool, +sharing: Bool)').replace('nh_macros(selected, names, observers)', 'nh_macros(selected, names, sharing)').replace('nf_plan(book, names, bangs, observers)', 'nf_plan_scoped(book, names, bangs, observers, sharing)')

    def compile_fallback(old):
        return """@unsafe
def ns_compile_fallback(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, compiled: NC_Book) -> NC_Result:
  ns_compile_fallback_scoped(book, names, bangs, runtime, requests, observers, observers, compiled)

"""+old.replace('def ns_compile_fallback(', 'def ns_compile_fallback_scoped(').replace('+observers: Bool, compiled:', '+observers: Bool, +sharing: Bool, compiled:').replace('nf_plan(book, names, bangs, observers)', 'nf_plan_scoped(book, names, bangs, observers, sharing)')

    def worker_plan(old):
        return """@unsafe
def nf_plan(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +observers: Bool) -> NF_Plan:
  nf_plan_scoped(book, names, bangs, observers, observers)

"""+old.replace('def nf_plan(', 'def nf_plan_scoped(').replace('+observers: Bool)', '+observers: Bool, +checked: Bool)').replace('nq_candidates_mode(book, names, bangs, signatures, observers)', 'nq_candidates_mode(book, names, bangs, signatures, checked)')

    for name, transform in [('nc_compile_checked', checked), ('nr_compile_prepared', request),
                            ('ns_compile', compile_source), ('ns_compile_named', compile_named),
                            ('ns_compile_planned', compile_planned), ('ns_compile_fallback', compile_fallback), ('nf_plan', worker_plan)]:
        if '@unsafe\ndef '+name+'(' in text: edit(name, transform)
    return text, edits


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase98') and not out.exists()
    baseline = pin(BASE); assert baseline['sha256'] == D04
    proofs = ROOT/'selfhost/proofs/phase98/permission'
    safe_d04 = proofs/'helper.d04.bend'; safe_canonical = proofs/'helper.canonical.bend'
    source = BASE.read_text(); candidate, edits = transformations(source, safe_d04.read_text())
    assert len(edits) == 7
    replay = source
    for change in edits:
        assert replay.count(change['old']) == 1 and replay.index(change['old']) == change['offset']
        replay = replay.replace(change['old'], change['new'])
    assert replay == candidate
    inverse = candidate
    for change in reversed(edits): inverse = inverse.replace(change['new'], change['old'])
    assert inverse == source
    out.mkdir(parents=True); (out/'compiler.bend').write_text(candidate)
    original_modules = []; patch = ''
    for name in ['scalar-array.bend', 'request.bend', 'static.bend', 'flat.bend']:
        path = MODULES/name; original_modules.append(pin(path))
        old = path.read_text(); new, _ = transformations(old, safe_canonical.read_text())
        destination = out/'modules'/name; destination.parent.mkdir(exist_ok=True); destination.write_text(new)
        relative = str(path.relative_to(ROOT))
        patch += ''.join(difflib.unified_diff(old.splitlines(True), new.splitlines(True), fromfile='a/'+relative, tofile='b/'+relative))
    (out/'canonical.patch').write_text(patch)
    receipt = dict(kind='phase98-scoped-observer-permission-source-derivative', complete=True,
                   targetsRun=False, method=pin(Path(__file__)), source=baseline,
                   predecessorMethod=pin(HERE/"prepare.py"), safePredicateInputs=[pin(safe_d04), pin(safe_canonical)],
                   candidate=pin(out/'compiler.bend'), changes=edits,
                   canonicalInputs=original_modules, canonicalPatch=pin(out/'canonical.patch'),
                   canonicalOutputs=[pin(out/'modules'/Path(p['file']).name) for p in original_modules],
                   physicalLineDelta=len(candidate.splitlines())-len(source.splitlines()),
                   forwardReplayExact=True, inverseRecoversSource=True,
                   scope='Independent checked observer permission with authenticated nine-provider closure; packed arrays, typed scalars, cold-constructor permission, planned-host selection and product checked admission remain on old certificate. No production/runtime/provider/driver edits; unqualified until root-owned controls and generated-route inspection pass.')
    assert pin(BASE) == baseline
    for record in original_modules: assert pin(Path(record['file'])) == record
    (out/'changes.json').write_text(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps({key:receipt[key] for key in ['candidate', 'physicalLineDelta', 'targetsRun']}))


if __name__ == '__main__': main()
