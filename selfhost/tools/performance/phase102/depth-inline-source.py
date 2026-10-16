#!/usr/bin/env python3
"""Compose a bounded-depth forced-inline hint policy; preserve native admission."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); parent = R.read(a.parent)
assert parent['complete']
for item in [parent['source'], parent['candidate']]: R.verify(item)
source = Path(parent['candidate']['file']).read_text()
changes = list(parent['changes'])

def replace(old, new, count=1):
    global source
    assert source.count(old) == count, (old, source.count(old), count)
    start = 0
    for _ in range(count):
        at = source.index(old, start)
        changes.append(dict(offset=at, old=old, new=new))
        source = source[:at] + new + source[at + len(old):]
        start = at + len(new)

replace('''# The explicit inline hint has a local source-size cutoff. Admission already
# excludes C recursion cycles; this is not a transitive code-growth bound.

# Module: src/back/native/flat.bend:224
@unsafe
def nf_inline(+code: NC_Code) -> String:
  nt_choose(String, nct_within(nc_text(code), 8192), u => "NF_INLINE", u => "INLINE")''', '''# Three immutable dependency passes force only small leaves and two caller
# levels. Admission and generated bodies are unchanged; C budgets deeper calls.
@unsafe
def nfi_deps(deps: List<&2, String>, +previous: List<&2, String>) -> Bool:
  match deps:
    case Nil{}: True{}
    case Con{name, rest}: nb_contains(previous, name) && nfi_deps(rest, previous)

@unsafe
def nfi_pass(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +previous: List<&2, String>) -> List<&2, String>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, params, code, deps, shape}, +rest}:
      nt_choose(List<&2, String>, nb_contains(ready, name) && nct_within(nc_text(code), 8192) && nfi_deps(deps, previous),
        u => Con{name, nfi_pass(rest, ready, previous)}, u => nfi_pass(rest, ready, previous))

@unsafe
def nf_inline(name: String, inline: List<&2, String>) -> String:
  nt_choose(String, nb_contains(inline, name), u => "NF_INLINE", u => "INLINE")''')
replace('def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>)',
        'def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>)')
replace('def ntr_plain_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>)',
        'def ntr_plain_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>)')
replace('def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>)',
        'def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>)')
replace('def ntr_worker_body(+name: String, +params: List<&2, N_Param>, +code: NC_Code)',
        'def ntr_worker_body(+name: String, +params: List<&2, N_Param>, +code: NC_Code, +inline: List<&2, String>)')
replace('nf_inline(code)', 'nf_inline(name, inline)', 4)
replace('nf_prototypes(rest, ready)', 'nf_prototypes(rest, ready, inline)')
replace('nf_bodies(rest, ready)', 'nf_bodies(rest, ready, inline)', 2)
replace('ntr_plain_bodies(workers, ready)', 'ntr_plain_bodies(workers, ready, inline)')
replace('ntr_worker_body(name, params, code)', 'ntr_worker_body(name, params, code, inline)')
replace('  +route = no_route(book, ordinary, observer_names, workers, ready, observers)\n',
        '  +route = no_route(book, ordinary, observer_names, workers, ready, observers)\n'
        '  +inline = nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), Nil{})))\n')
replace('nf_prototypes(no_route_workers(route), no_route_ready(route))',
        'nf_prototypes(no_route_workers(route), no_route_ready(route), inline)')
replace('nf_bodies(no_route_workers(route), no_route_ready(route))',
        'nf_bodies(no_route_workers(route), no_route_ready(route), inline)')
reverse = source
for c in reversed(changes):
    i = c['offset']; assert reverse[i:i + len(c['new'])] == c['new']
    reverse = reverse[:i] + c['old'] + reverse[i + len(c['new']):]
assert reverse == Path(parent['source']['file']).read_text()
out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
dest = out / 'compiler.bend'; dest.write_text(source)
R.save(out / 'changes.json', dict(complete=True, targetsRun=False, releaseQualified=False,
    method=R.pin(__file__), parentRecipe=R.pin(a.parent), parentCandidate=parent['candidate'],
    source=parent['source'], candidate=R.pin(dest), changes=changes, inverseExact=True,
    physicalLineDelta=len(source.splitlines()) - len(reverse.splitlines()),
    scope='Forced-inline hint only: existing 8192-byte own-code cutoff plus three '
          'immutable passes over admitted NF_Worker dependency metadata. Missing '
          'dependencies fail closed; late observer edges are included. The one '
          'computed set is shared by prototypes, ordinary bodies, TRMC wrappers '
          'and TRMC inner loops. No admission, call, ownership or body changes.'))
print(R.json.dumps(R.pin(dest)))
