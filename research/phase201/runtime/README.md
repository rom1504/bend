# Shared-release entry specialization (offline candidate)

`variant.py` stages a runtime-only experiment. It does not change compiler source,
IR, object generation, ABI or ownership contracts. No C compilation, linking,
target execution or timing was performed for this preparation.

The original runtime object's actual `term_drop` at offset 0x29f0 saves six
callee-saved registers before testing its first term. A non-last shared owner
needs only the reference-count decrement; it cannot free either its wrapper or
children. The candidate routes this common case around the iterative destructor.
The saved-register traffic is observed; its dynamic frequency in the current
compiler is unknown. Historical compiler physical samples put `term_drop` near
9–12% and `span_fade` near 5–7% (Phase193/compiler-profile.md); those entire shares
are neither removable nor a current speedup prediction.

The exact earlier span-only experiment exists in
`research/phase198/reference-counts/`: six application geometric ratios were
1.0035 for release, 1.0026 for inline specialization, and 0.9969 for PGO versus
live runtime. Those results were effectively flat. That experiment did not time
the self compiler. Its ready `release/runtime.o` and `specialize/runtime.o` are
pinned in `preparation.json`, so testing that earlier policy requires no rebuild.
The new `all` mode adds the shortcut to every external `term_drop` entry, including
`term_sink` and runtime request cleanup; internal recursive destructor traversal
is unchanged. `span` and `control` provide causal ablations.

## Semantic boundary

Only `P144_SINGLE_MUTATOR_RFC=1` admits the shortcut. Its existing preprocessing,
entry and provider restrictions remain unchanged. On a nontrivial RFC owner,
read the current low32 word using memcpy. If low24 count > 1, subtract one with
unsigned arithmetic and memcpy it back. No borrow reaches the upper eight bits;
the adjacent high32 word remains untouched. Original `term_drop` performs that
same decrement, selects t=0, and returns after its first err_spun check (step=1,
which cannot poll). Thus the shortcut omits no observable error or freeing step.

Count1, malformed count0, static/trivial terms and every other runtime mode use
the unchanged destructor. Count0 must not be treated as shared: original wrapping
behavior is preserved in the fallback. `span_fade` retains all child increments,
overflow errors and source order; the parent count is reread only afterward.
Output aliasing or an already-posted error does not authorize using an earlier
count snapshot. Cyclic or invalid terms receive no new assumptions beyond the
original runtime. Single mutator is essential; arbitrary concurrent embedding
would invalidate the load/check/store operation and remains excluded.

Offline generation checked six forms, exact original/control equality, and
byte-identical slow destructor bodies. This is source validation, not runtime
correctness qualification. Last-owner-heavy programs may regress because the
new entry adds a predicate before the old destructor; that is a falsifier.

## Ready recipe (root owns execution)

Run from repository root, using a fresh output directory:

```sh
python3 research/phase201/runtime/variant.py --parent original --mode all \
  --output selfhost/build/phase201/drop-all01/runtime.c
/usr/bin/x86_64-linux-gnu-gcc-10 -O2 -std=gnu11 -ffp-contract=off \
  -DP144_SINGLE_MUTATOR_RFC=1 -I selfhost/src/runtime/qbe \
  -c selfhost/build/phase201/drop-all01/runtime.c \
  -o selfhost/build/phase201/drop-all01/runtime.o
```

For clean attribution, start with `original`, matching the installed compiler's
runtime. Repeat with `--mode span` only if the all-entry result warrants it;
`--parent live` composes the independently qualified constructor split.
The root's `research/phase201/cold/replay.py` already accepts the runtime object
as a role and relinks into memfd. Use original, candidate, candidate, original
roles; preserve exact compiler revision, request source, Base/carrier and flags.
Compare emitted object SHA256 and size on every request before accepting timing.
A retained Phase198 or Phase199 compiler object allows this without self-build;
the newest Phase200 streaming object was not retained. Label the producer
revision rather than implying a current-compiler measurement.

Before timing, reuse the Phase198 runtime-broad independent ABI and runtime
fixtures. Explicit focused observations should cover parent count0/1/2/max,
shared children, child overflow, full pointer-word preservation, static values,
last-owner recursive reclamation and out/source overlap. Check actual machine
code: shared path must avoid `p201_term_drop_slow`; no locked operations outside
the already permitted RFC boundary may disappear. A full compiler exact-output
request is only justified if the bounded request improves materially. No
selection, installation or gain is claimed by this preparation.

Allocator environment variables are a lower-priority hypothesis: Bend's hot
heap uses custom per-class free lists (CAP_WORDS=32768, host QUANTUM=4096), not
malloc per term. BENDRTS exposes threads/GPU only. Changing those constants would
require a distinct memory/locality experiment and has no measured support here.
