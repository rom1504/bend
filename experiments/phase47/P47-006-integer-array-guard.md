# P47-006: specialize array guards to proved integer-only graphs

Date: 2026-10-05. Initial source status: frozen for independent review; no checked
build, compiler-generated timing, or promotion claim yet. Parent: tree05.

The root-owned saved-output diagnostic passed 45 samples. Smaller hook-set
medians were 15.879→14.075 µs at 128 iterations, 62.061→60.348 µs at 4096, and
112.390→110.355 µs at 8192. The modest fixed-cost saving does not erase the short
fold regression. See the pre-edit [design](../../design/phase47/integer-array-guard.md).

After independent contract review, the source adds a private optional integer
mode to arrayViewHostGuard. Both modes still refuse inherited proof, check the
Object prototype parent and exact fill/isSafeInteger descriptors, and preserve
host-before-input-before-dependency ordering. Integer mode uses the existing
smaller region hook set plus a separate exact captured Math.floor descriptor;
U32 division therefore retains its required hook proof.

One shared compiler helper selects true only if canonical root signature,
original root type/body, checked root term(s), and every helper signature/type/
body contain no floating use. Unused or aliased F32 inputs keep full validation.
Full mode retains the original emitted `arrayViewHostGuard()` call spelling.
Runtime source and assembled runtime are mirrored. This is a guard subtype,
not broader array/source admission or a numeric workload threshold.

The patch adds 13 source lines: array-view +9; each runtime copy +2; region and
tree call-site updates add no lines. Runtime syntax, Bend delimiter, and diff
checks pass. Independent v5 controls cover floor/division and unused F32 guard
selection alongside the prior host/public-boundary controls. Qualification and
clean timing are root-owned and pending at this checkpoint.
