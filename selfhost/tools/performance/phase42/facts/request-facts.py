#!/usr/bin/env python3
"""Generate an isolated request-local exact-plan reuse patch; never edit production."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path

HELPERS = r'''

# Exact planner results belong to one immutable JS emission request. The first
# BookCache child stays the original source index; the second is private facts.
# Logical planners still accept arbitrary definitions and never use name-only
# facts. Cached entry points always obtain the original definition by lookup.
@unsafe
def j_component_cached(+book: List<&2,KDef>, +name: String) -> JPure:
  +fact = j_plan_lookup(book, name, False{})
  kc(JPure, String.eq(dk(fact), "JSPlanFact"),
    u => JPure{dc(fact), da(fact), db(fact)},
    u => j_component_plan(book, lookup(book, name)))

@unsafe
def j_direct_cached(+book: List<&2,KDef>, +name: String) -> JPure:
  +fact = j_plan_lookup(book, name, True{})
  kc(JPure, String.eq(dk(fact), "JSPlanFact"),
    u => JPure{dc(fact), da(fact), db(fact)},
    u => j_direct_plan(book, lookup(book, name)))

@unsafe
def j_plan_lookup(+book: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{cache, rest}:
      kc(KDef, String.eq(dk(cache), "BookCache"),
        u => j_plan_payload(dc(cache), name, direct), u => missing())

@unsafe
def j_plan_payload(+children: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match children:
    case Nil{}: missing()
    case Con{source, rest}:
      +payload = index_first(rest)
      kc(KDef, String.eq(dk(payload), "JSPlanContext") && String.eq(dn(payload), "$js.plans"),
        u => j_plan_index(dc(payload), name, direct), u => missing())

@unsafe
def j_plan_index(+indexes: List<&2,KDef>, +name: String, +direct: Bool) -> KDef:
  match indexes:
    case Nil{}: missing()
    case Con{component, rest}:
      index_find(kc(KDef, direct, u => index_first(rest), u => component), name, index_hash(name, 2166136261), 32)

@unsafe
def j_plan_fact(+name: String, +pure: JPure) -> KDef:
  KDef{name, "JSPlanFact", j_pure_fuel(pure), 0, atom("Absent"), atom("Absent"), j_pure_defs(pure), j_pure_valid(pure), False{}}

# Strip any prior facts before preparing a fresh request. Source lookup and
# maximum binder identity remain exactly those of the incoming BookCache.
@unsafe
def j_plan_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      kc(List<&2,KDef>, String.eq(dk(cache), "BookCache"), u =>
        j_plan_prepare(KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache))], db(cache), du(cache)}, rest, defs), u => book)

@unsafe
def j_plan_prepare(+cache: KDef, +rest: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:
  +source = {Con{cache, rest} : List<&2,KDef>}
  +components = j_plan_components(source, defs, book_cached(Nil{}, 0))
  +directs = j_plan_directs(source, j_plan_needed(source, defs, book_cached(Nil{}, 0)), book_cached(Nil{}, 0))
  Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache),
    [index_first(dc(cache)), KDef{"$js.plans", "JSPlanContext", 0, 0, atom("Absent"), atom("Absent"),
      [index_first(dc(index_first(components))), index_first(dc(index_first(directs)))], False{}, False{}}], db(cache), du(cache)}, rest}

# Only definitions whose ordinary emitter already asks for a component plan.
# Duplicate selected names share the canonical original definition once.
@unsafe
def j_plan_emitted(+d: KDef) -> Bool:
  String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0) &&
    Bool.not(String.eq(tg(dv(d)), "Absent")) && Bool.not(String.eq(tg(dv(d)), "Foreign"))

@unsafe
def j_plan_components(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_components(book, rest, kc(List<&2,KDef>, j_plan_emitted(d) && String.eq(dk(lookup(done, dn(d))), "Absent"),
        u => book_put(done, j_plan_fact(dn(d), j_component_plan(book, lookup(book, dn(d))))), u => done))

# The scan gathers saturated nonprimitive source call targets. Its bound only
# limits reuse: every uncollected target still runs the unchanged logical plan.
@unsafe
def j_plan_needed(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_needed(book, rest, kc(List<&2,KDef>, j_plan_emitted(d),
        u => j_plan_scan(book, [dv(d)], 8192, done), u => done))

@unsafe
def j_plan_scan(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32, +done: List<&2,KDef>) -> List<&2,KDef>:
  match todo:
    case Nil{}: done
    case Con{t, rest}:
      kc(List<&2,KDef>, U32.is_gt(fuel, 0), u =>
        j_plan_scan(book, List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1),
          kc(List<&2,KDef>, String.eq(tg(t), "App"),
            u => j_plan_call(book, j_call_spine(t, Nil{}), done), u => done)), u => done)

@unsafe
def j_plan_call(+book: List<&2,KDef>, +spine: KTerm, +done: List<&2,KDef>) -> List<&2,KDef>:
  +d = lookup(book, nm(spine))
  kc(List<&2,KDef>, String.eq(tg(spine), "Call") && String.eq(dk(d), "Def") &&
    U32.is_eq(terms_len(ks(spine)), da(d)) && Bool.not(j_primitive_call(book, spine)) &&
    String.eq(dk(lookup(done, dn(d))), "Absent"), u => book_put(done, d), u => done)

@unsafe
def j_plan_directs(+book: List<&2,KDef>, +defs: List<&2,KDef>, +done: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: done
    case Con{d, rest}:
      j_plan_directs(book, rest, kc(List<&2,KDef>, String.eq(dk(d), "Def"),
        u => book_put(done, j_plan_fact(dn(d), j_direct_plan(book, lookup(book, dn(d))))), u => done))
'''

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('root', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
root = a.root.resolve()
out = a.out.resolve()
assert not out.exists(), 'Preserve every attempt'
files = ['jpure.bend', 'tree.bend', 'finite.bend', 'emit.bend', 'region.bend']
before = {f: (root / 'selfhost/src/back/js' / f).read_text() for f in files}
after = dict(before)
assert 'def j_component_cached(' not in before['jpure.bend']
after['jpure.bend'] += HELPERS

def replace(file, old, new, count=1):
    assert after[file].count(old) == count, (file, old, after[file].count(old), count)
    after[file] = after[file].replace(old, new)

replace('emit.bend', 'j_program_context(book_context(book), defs)', 'j_program_context(j_plan_context(book_context(book), defs), defs)')
replace('emit.bend', 'j_library_context(book_context(book), defs)', 'j_library_context(j_plan_context(book_context(book), defs), defs)')
replace('emit.bend', 'j_component_plan(book, component)', 'j_component_cached(book, dn(component))')
replace('tree.bend', 'j_component_plan(book, callee)', 'j_component_cached(book, dn(callee))')
replace('tree.bend', 'j_component_plan(book, d)', 'j_component_cached(book, dn(d))', 2)
replace('region.bend', 'j_component_plan(book, lookup(book, dn(d)))', 'j_component_cached(book, dn(d))')
replace('finite.bend', 'j_direct_plan(book, lookup(book, nm(spine)))', 'j_direct_cached(book, nm(spine))', 2)

out.mkdir(parents=True)
patch = ''
identities = []
for file in files:
    target = out / 'src/back/js' / file
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(after[file])
    path = 'selfhost/src/back/js/' + file
    patch += ''.join(difflib.unified_diff(before[file].splitlines(True), after[file].splitlines(True), fromfile='a/' + path, tofile='b/' + path))
    identities.append(dict(file=path, sourceSha256=hashlib.sha256(before[file].encode()).hexdigest(), candidateSha256=hashlib.sha256(after[file].encode()).hexdigest(), physicalLineDelta=len(after[file].splitlines()) - len(before[file].splitlines())))
(out / 'candidate.patch').write_text(patch)
(out / 'identity.json').write_text(json.dumps(dict(kind='phase42-request-local-complete-plans', productionEdited=False, expectedEmission='byte-identical to current calls/context candidate; full ordered JPure and refusals preserved', files=identities), indent=2) + '\n')
print(out / 'candidate.patch')
