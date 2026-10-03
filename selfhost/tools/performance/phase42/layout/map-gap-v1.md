# Map gap: structural discriminator

The measured native-comparison screen saved only0.54%/3.05% at32/128, retaining
approximately81–87 times pinned TypeScript time. It does not establish that
source String.cmp itself is cheap: its per-comparison guards may consume part of
the removed work. It does falsify further name-specific native comparison as a
large-gain first action.

The historical Phase37 Map128 application profiles contain503 baseline samples
and501 TypeScript samples. Aggregating identical source frames (rather than each
profiler tree-node separately), baseline self samples are apply17.9%,
invokeExact17.5%, force10.3%, callOwned5.4%, matcher1's closure12.5%, matcher's
closure11.5%, and GC8.7%. TypeScript samples put Map.bit.go at35.7%, seek.go10.8%,
ins.go8.0%, String.cmp6.8%. These are historical profiles, not current timing or
exact dynamic counts.

1. **Map.bit prefix component** is the smallest high-promise experiment. The
   actual saved module has29 saturated simple-variable Map.bit edges: put.go6,
   put1, ins.splice1, ins.go6, ins1, seek.go6, seek1, pop.go6, pop1. Map.bit.go
   recurs once per consumed key-prefix character, and rebuilds the original key
   through go.chr/go.rec. TypeScript does the same algorithm with direct calls;
   candidate repeatedly allocates partial functions/matchers/bounces. A position
   q*33+r consumes min(key.length,q+1) heads: retain two codePointAt+one slice
   per head and one fromCodePoint per reconstructed head. Replace only control
   and intermediate matcher/build dispatch. Preserve native Tuple output,
   original Nat.divmod and Map.bit.chr scalar calls, and all public G descriptors.
2. **Map.seek.go/ins.go/put.go/pop.go paired-child matching** accounts for the
   next large structural surface. seek.go and ins.go each have six recursive
   syntactic alternatives plus one caller; their MTip/MLeaf/MNode Cartesian
   patterns generate deeply nested matcher continuations. A direct owned worker
   should keep Map.bit as a residual barrier and preserve every MNode/Tuple
   reconstruction and alias. This needs a scalar-owned Map/String ground graph
   boundary and exact return continuations; it is wider than the bit experiment.
3. **Numeric Map.msb.u/Map.diff.chr** can isolate the existing bounded scalar SCC.
   msb.u.if has one self-cycle edge back to msb.u plus Nat.add; diff.chr enters
   msb.u with32n. Map.msb.u counts shifts until zero, preserving BigInt countdown
   and Nat.add semantics. This is easy to guard, but its profile share is not
   large enough to rank ahead of the bit/pattern components. Do not substitute
   clz32 or alter its algorithm as the first discriminator.

`map-bit-prepare-v1.py` produces a bounded saved-JS structural ablation from the
already measured map-native-ablation01/baseline.mjs. It rewrites29 callsites,
keeps original fields/constructor operations and full returned key/bit, and
opens no region proof. Exact host/descriptor guards run before validation. Only
ASCII strings up to64 units and canonical nonnegative UInt32-bounded Nat
positions enter; Unicode/long/noncanonical inputs or any changed String/G hooks
call the exact original Map.bit. The ASCII restriction excludes invalid Char
errors and permits an observer-free validation scan with guarded charCodeAt;
it is a diagnostic scope, not production String permission.

Root commands (fresh outputs):

```sh
python3 selfhost/tools/performance/phase42/layout/map-bit-prepare-v1.py \
  selfhost/build/phase42/map-native-ablation01/baseline.mjs NEW_ABLATION
NODE selfhost/tools/performance/phase42/layout/map-bit-controls-v1.mjs \
  NEW_ABLATION NEW_CONTROLS
```

Controls require72 full key/bit observations, five independent complete ordered
Map contents, and45 binding/getter/throw/bounded-reentry/host-hook boundaries.
Every hostile control requires zero fast entries and identical complete traces.
Use existing Map32/128 bench arguments/checksums for paired timing after controls
pass. This is unexecuted saved-JS research, not checked compiler admission.


Root executed the bit discriminator successfully: all complete-value and hostile
boundary controls passed. Fresh `selfhost/build/phase42/map-bit-screen01` timing
rejects the integration: Map32 original14.630506ms, candidate21.028193ms,
TypeScript0.180699ms; Map128 original75.226ms, candidate97.9323ms,
TypeScript0.97796ms. Candidate is approximately44%/30% slower. A plausible reason
is repeated per-edge host, dependency and String-descriptor guard cost outweighing
removed prefix dispatch. This screen does not isolate that cost or prove the
causal attribution. No Map compiler or production change is proposed.
