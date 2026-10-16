# Phase99 independent scalar controls

All files here are preparations or offline source evidence. Root owns every
compiler, elaborator, kernel, Clang and generated-program execution.

`fixtures01.json` pins seven IO derivatives with independent historical output
expectations. Compile each through the baseline and the actual candidate API,
check emitted permissions and exact program stdout/stderr, and preserve failures.
The new stderr line belongs to the generated program, not compiler diagnostics.
Use the unchanged serial native qualifier/guards; these files introduce no runner.

`prepare-kind-laws.py --source SOURCE --out FRESH_DIRECTORY_HERE` extracts exact
safe helper candidates and prepares unchanged laws plus three negative helpers.
`kind-laws01` binds Phase98; `kind-laws02` binds root's first monotone Phase99
successor (`7520f6ef…`). These are not accepted proof receipts. First admit each
helper by itself, then check its laws. Positive safe elaboration and independent
kernel checks use the existing Phase98 proof procedure. Re-extract from a later
selected source rather than citing an earlier candidate's source pin.

The source bridge deliberately rejects changed helper bodies until reviewed.
Its contracts preserve binding identity/order and supplied scalar kinds; they
do not prove that the supplied kinds are valid of native runtime values.

See [the audit](../../../../../implementation/phase99/scalar-audit.md) for source
locations, trust/ABI prerequisites, required API negatives and promotion limits.
