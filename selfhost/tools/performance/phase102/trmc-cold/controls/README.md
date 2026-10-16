# TRMC destination constructor policy controls

`mixed-construction.bend` builds a recursive sum with a one-field terminal,
two-field short node and four-field wide node. Its direct recursive calls are
in the last field. Alternation changes both the pending slot offset and the
constructor policy; zero/one/many-node paths cover first-root publication and
the final terminal store. Strings are shared between fields and remain live
after consuming the chain. Every field and constructor appears in full output.

```sh
python3 -B selfhost/tools/performance/phase102/trmc-cold/controls/prepare.py \
  --out selfhost/build/phase102/trmc-cold-controls-FRESH
```

Preparation freezes this source, a separate duplicated-root source, and complete
independent Python output bytes. It runs no targets. Root owns admission, guarded
serial emission/build/run and 1/2/4-worker repetitions. Require the builder's
emitted worker to use TRMC before calling a passing output a TRMC control.

Current `nh_ctors` heats every constructor of a shared datatype and recursively
its fields; `nh_observer_types` also removes HOT flags for the whole datatype.
Thus this sum does not naturally obtain mixed HOT policies per constructor.
Do not claim a natural mixed-policy fixture without inspecting its actual C.

For the **unique-chain source only**, a diagnostic same-C policy matrix can set
`NATIVE_COLD_CTORS=1`, `NATIVE_COLD_USER_CTORS=0`, and individually set the three
`NATIVE_HOT_<actual CID>` flags. Use the actual emitted constructor IDs, preserving
all other macros. Insert overrides after any observer `#undef` directives and
before the first constructor worker; verify the preprocessed decisions. Exercise
all-hot, all-cold, short-only-hot, wide-only-hot, and end-only-hot. These yield
both hot-to-cold and cold-to-hot pending edges and both terminal policies.
If also testing `NATIVE_COLD_USER_CTORS=1`, record that it overrides the normal
hot fallback for user constructors; the expected slot policy must match the
ordinary constructor emitter's entire conditional, not the HOT flag alone.

Mixed policy variants are diagnostic runtime/ABI tests, not ordinary compiler
outputs or promotion evidence. The unique constructor chain makes both policies
valid: adding sealing is conservative, while its cold parents are consumed once.
The String fields already carry their required sharing ownership. Do **not**
apply arbitrary cold policies to the duplicated-root source: sharing a cold
recursive chain may expose unsealed children and invalidate the test itself.
That source uses natural/all-hot only and protects actual shared-parent behavior.

Output alone cannot detect every unnecessary seal or missing seal while a parent
remains unique. Add a structural generated-C check or diagnostic assertion that
each pending store follows the **previous destination parent's policy**; the
current child constructor's policy is a different value. Apply that check to
both recursive-node and terminal-result stores. Root's separate memory/error
controls remain necessary; this fixture is not an ownership proof.
