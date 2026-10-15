# Executable constraints for production helpers

This suite exercises exact declarations extracted from the maintained compiler,
compiled by the current genuine JS B2. It defines 226 finite cases in 16 families.
The catalog describes their contracts and domains. These are executable
optimization constraints, not universal proofs or whole-compiler correctness.

The immutable production-full02 snapshot passes all
[226 JS cases](../../../build/phase96/production-full02-js/report.json) through
genuine JS B2 and all
[32 selected native cases](../../../build/phase96/production-full02-native/report.json)
with exact complete stdout. B2 produced that native C, which root built with the
pinned Clang at C11/O3. The native execution is a finite behavior check, not a
program-speed measurement. The accepted snapshot, methods and input pins remain
unchanged; subsequent runner hardening applies to fresh snapshots only.

The independent Python reference generates full expected results without calling
or importing production code. Lookup selects complete first-match records; final
events use last positions; sets use a mathematical partition; substitution uses
capture-free recursive replacement and beta rebuilding. An absent substitution
ID does not imply an unchanged application. A true stability certificate implies
substitution identity; false certificates make no converse claim.

All runtime strings contain valid Unicode scalars, and all algebraic input
values are complete and finite. Constructor-display controls deliberately pass
ASCII spellings of invalid or noncanonical encodings. For example,
constructor-encoding-011 passes the string "$ctor.55296_" and expects that exact
string back: 55296 denotes a surrogate, but the input contains its decimal digits,
not a surrogate Char. The production decoder must reject that numeric candidate
before constructing a character. Out-of-range codes and leading-zero spellings
are similarly deliberate fallback controls.

Substitution has unique binder IDs and two-child Apps/one-body Lambdas. Metadata
tests vary all representable fields, including duplicate removal names and
optional quantity syntax; they do not assert every such record is a well-typed
source program. Missing JS fields, cycles, malformed App arities, invalid scalar
constructors and arbitrary unsafe closures are outside this suite.

Preparation is data-only and requires a fresh destination:

    python3 -B selfhost/proofs/phase96/production/prepare.py \
      --out selfhost/build/phase96/production-all01

Use --families children-update,span-update for the initial 36-case screen, or
--cases with exact comma-separated case IDs. Each snapshot contains original
source files, exact extracted declarations with byte offsets/hashes, all methods,
generated library/native sources, inputs and full expected results. Only the Base
import and test observers/wrappers are added. Baseline helper text and unsafe
annotations stay exact. Test observers are explicitly unsafe because their
mutually recursive serialization is outside the proof claim. Old snapshots remain
self-contained when this suite changes. The preparer checks the Phase91
continuity plan's actual Phase90 B2 and host identities; it cannot bootstrap or
fall back to another compiler.

Root runs the frozen worker through the common serial resource guard:

    node --max-old-space-size=1024 --stack-size=4096 \
      SNAPSHOT/methods/run.mjs SNAPSHOT/manifest.json FRESH_RUN_DIRECTORY js

The worker compiles with actual B2, imports the resulting library, invokes every
named wrapper, and compares its entire returned value. Each row retains actual
and expected JSON plus a mismatch or exception. Failed rows do not prevent later
cases from yielding counterexamples. Compiler failures and law failures are
separate. Any worker exception, including a failed final input-identity check,
sets both complete and passed to false and produces a nonzero exit. The common
runner additionally requires inputsUnchanged and no worker error.

The same command with emit-native emits laws.c using B2. Root can build/run it
under the established Clang/CPU guard and compare stdout with native.expected.txt.
The native main has two selected cases per full family, including changed
children, literal spans, duplicate/colliding lookup, beta reduction with an absent
target, high-bit keys, duplicate environment rows, 256/257-event boundaries,
Unicode encoding and empty join pieces. Single-case mutation snapshots have one
native case. This is a small native behavior screen, separate from the full JS
finite corpus.

Results use JSON arrays with every String expanded to its complete Unicode-scalar
array, independently of compiler pretty-printing or string escaping. Layouts:

- KTerm: [0, tag, name, id, quant, kids, removed, begin, end].
- KLambda: [1, name, id, quant, kids, removed, begin, end, quantityPresent].
- KLiteral: [2, kind, number, text, begin, end].
- KDef: [0, name, kind, arity, templates, type, value, constructors, native, unsafe].
- Set: [0], [1,key], or [2,mask,left,right].
- Binding: [id,word,kind], with W32=0, W64=1, Box=2.
- Partition: [orderedLiveBindings, completeDropText].

Observers match constructors directly rather than relying on tested projections.
No checksum or field count replaces full values. Repeated children, removal
names, definition events, environment rows and text pieces are retained. Shared
originals are observed after updates and lookups.

The ten mutation recipes deliberately break metadata, substitution, membership,
shadowing, hash collisions, environment selection/drop order, text or encoding.
Prepare each into a fresh directory with --mutant ID. By default that selects its
single distinguishing case; --families or --cases can widen the control. The
expected values and original snapshots stay unchanged. Only one exact span in
one extracted definition changes, and the manifest records both module hashes.
Production is never edited. A recipe counts as detected only when its target
executes and the named full-value result fails. An unrun recipe, preparation
success or compiler failure is not a mutation kill.
