# Next cost target and native qualification boundary

Read-only follow-up after the single-verifier source review. No target was run,
no runtime or compiler method was changed, and no new speed result is claimed.

## One remaining mechanism worth a causal test

The strongest source-supported next target is **owning field projection**,
already specified in [owned-projection.md](owned-projection.md): consuming a
shared constructor to return one field should avoid retaining and then sinking
all the unselected fields. The current generated compiler still performs those
round trips in ordinary `tg`, `nm`, `ks`, `dn` and `dk` workers. These are examples
of a general checked take/load/sink/return shape, not names to recognize.

The important capability gap is the escaping result. Existing scalar borrowing
can avoid product reconstruction for an observed Bool/U32, but it cannot simply
return an owning String or KTerm field after discarding its owner. An admitted
consuming projection can retain that escaping child, release the shared parent,
and preserve the full old path for unique parents, unsafe counts/representations
and unsupported cases. The previously proposed preflight and exact error-order
obligations remain necessary. A borrowed raw field read alone is insufficient.

The current physical profile puts 40.41% of samples in the combined product,
ownership and reclamation families; take+sink alone is 14.99%. Those are loose
envelopes, not getter attribution or predicted savings. The retained real checker
has 86 terminal projection shapes in 69 functions. Neither count proves that
enough of the full request is removable. The next useful observation is a
complete checker ceiling with exact output and lifetime controls, followed by
caller attribution or a small real compiler request if favorable. It should
precede a compiler rebuild undertaken solely for this mechanism.

This does not repeat these earlier results:

- Private borrowed equality identity: approximately 0.28% lower time on the
  Phase131 use-query proxy, despite substantial identity-step coverage.
- Shared-take fusion: approximately 2.15% lower time in Phase169's small native
  verifier screen; it still retains every child.
- Early direct ordering alone: Phase164's full private-source acquisition was
  effectively neutral; Phase168 required early verified imports to recover
  generated execution quality.
- Numeric representation conversions and compact App: prior results do not
  justify another isolated conversion around unchanged consumers.

The smaller canonical generated product does not establish another free saving.
The [complete census](canonical-product-review.md) already accounts for
118.23→94.45 MB QBE and 73,926→58,376 functions. Its remaining 37,607 generic
continuations are not proven dead. The canonical product contains the original
canonical main; the experimental N2 contains the new six-string entry and
algorithm. Comparing their self-builds on different source closures would mix
generated-code quality, algorithm changes and input size. No newly inspected
small rewrite supports a defensible additional twenty-second forecast.

## The maintained qualification runner already accepts this entry

[`request.py`](../../selfhost/tools/build/request.py) emits this native command
for a `qbe-source-v1` binding:

```
IMAGE --threads 1 --gpu off -- phase111 ABS_INPUT ABS_BASE cache ABS_CARRIER STAMP
```

After the runtime arguments, the six strings are exactly those accepted by
[`p169n_args`](../../selfhost/tests/phase169/native-entry.bend). The first string
is ignored by that function, so `phase111` is compatible; no shim or protocol
relabeling is needed. Live mode supplies the same six positions with empty
carrier and stamp. Native N2's complete receipt already binds host `native`,
stage `N2-P169-imports`, protocol `qbe-source-v1` and target `qbe`.

[`qualification.py`](../../selfhost/tools/build/qualification.py) independently
authenticates source/oracle pins, runs the actual compiler, constructs QBE with
the pinned runtime/toolchain, executes each product and checks complete stdout,
stderr and exit status. This qualifies ordinary serial QBE requests only; the
new entry does not provide sessions, batches, JS/C emission or the public C CLI.

One source-visible protocol mismatch must remain explicit: the existing
`negative-foreign` catalog expects exactly
`compile: foreign provider unavailable in fixed runtime: p108_missing`.
`p169s_admitted` instead prefixes that runtime-admission failure with
`adapter renderer runtime: `. The maintained strict refusal check should fail
that case even though the foreign effect is correctly rejected. Do not relax
the matcher or count the mismatch as a pass. Restore the selected public error
contract in a separately checked entry change if that compatibility is required.

## Small first cross-program screen

The following payload selects ten independent positive oracles and the two
source-refusal controls. It covers captured closures, non-tail lists, arrays/IO,
numeric loops, tree computation, lexer/text processing, expression traversal,
persistent maps and record aggregation. This is a bounded diagnostic subset,
not full broad qualification. Run it inside one parent-owned resource guard on
CPU3, with a fresh output root and the ordinary serial-runtime policy:

```sh
python3 -B selfhost/tools/build/qualification.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase169/native-n2/program \
  --image-receipt selfhost/build/phase169/native-n2/report.json \
  --host native --stage N2-P169-imports --target qbe --mode cache \
  --suite all \
  --case focused/non-tail-list --case focused/arrays-io \
  --case focused/negative-type --case focused/negative-affine \
  --case broad/mandelbrot --case broad/lexer --case broad/tree-bitonic \
  --case broad/coverage-closures-64 --case broad/coverage-expression-32 \
  --case broad/coverage-map-churn-32 --case broad/coverage-unicode-text-16 \
  --case broad/coverage-record-aggregation-64 \
  --seconds 90 --build-seconds 60 --execute-seconds 20 \
  --out selfhost/build/phase169/qualification-screen01
```

The command names the currently completed experimental N2. For the new
single-verifier image, replace both image paths and `--stage` with that actual
completed receipt's binding; do not inherit qualification or guess its stage.
Add `--plan` to authenticate this request without execution.

After a successful screen, use the same arguments with `--suite broad` and no
`--case` flags for all 45 positive runtime programs. Use a separate fresh output
root. The full focused suite remains necessary for numeric/ABI cases and the
three exact refusals; the foreign diagnostic mismatch currently prevents an
honest focused-19 pass. Before claiming live/cache compatibility, repeat one
positive and the source-refusal pair with `--mode live` and compare complete
products where the policy promises identical emission.

These runs test generated behavior, not its speed. Reuse the existing balanced
checker/verifier execution comparisons for the first performance gate; a new
lowering pipeline can change QBE bytes legitimately, so old byte identity alone
is neither required nor a substitute for the independent runtime oracles.
