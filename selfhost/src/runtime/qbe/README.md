# Direct-QBE native runtime

These files are the maintained direct-QBE runtime, separate from
`runtime/native/`, which serves the emitted C backend. `migration.json` records
the historical byte-identical migration and its qualified object; it is not a
qualification receipt for later source changes.

Phase182 changes the semantic ABI to11102 while preserving the descriptor and
state layouts. Primitive86 is full-width `F32.from_nat`; IDs1–85 retain their
meaning. The new runtime includes argv[0], uses `+RTS`/`-RTS`/`--RTS` and
`BENDRTS`, supports quiet `Exit`, and adds byte argv/path, line-read and positioned
write providers. Its Unicode output and file-loop semantics follow the new Base.
ABI11101 products require their old runtime. Rebuild this source into a fresh
object and qualify that explicit binding before selecting it.

The ordinary object uses GCC with `-O2 -std=gnu11 -ffp-contract=off
-DP144_SINGLE_MUTATOR_RFC=1`. This is the established **one Bend heap mutator**
policy: `--threads 1 --gpu off`, no compute workers and no arbitrary foreign
embedding. Host IO workers are allowed under the existing provider contract.
The `=0` variant remains the atomic control; switching policy is not an implicit
upgrade to qualified multiworker support. Historical `p111`/`p125` names and
diagnostic strings are preserved ABI identities.

Only `runtime.h` and `primitives.h` are quoted local includes. Effect providers
and native OS helpers are already embedded in `runtime.c`; old paths in comments
are provenance, not build-time reads. This relocation intentionally does not
split/rewrite provider code or change runtime semantics.

Use the maintained build asset manifest for the object/toolchain, and
`tools/profiler/runtime.py` for reversible diagnostics. Rebuilding from this
source and validating exact objects/products or ABI controls is a separate
execution gate; a byte-identical source migration alone is not a new runtime
qualification.
