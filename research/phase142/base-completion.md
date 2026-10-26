# Retain the fixed Base completion, if its repeated work matters

Source audit on unchanged Phase141 integrated-source02
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
No target execution or compiler modification by this investigator.

`p140pl_seed` (source line58874) evaluates this on every request:

```text
f_prefix_complete_ready_seed(
  seed.source, "", f_prefix_graph_empty(),
  f_source_path(seed.source), f_source_text(seed.source),
  seed.book, seed.ready)
```

Every input is derived from the same immutable `P86Seed`. Current source,
path/header/imports, parser checkpoint, edit hint, and checker checkpoint are
not inputs. The function and its callees are pure and perform no filesystem
lookup. This is an appropriate producer-owned prepared product; it needs no
content-addressed cache, repeated exact-key comparison or hash policy.

The repeated work is concrete:

- `f_complete_seed`→`f_seed_matches`→`f_seed_text_equal`→`p88_string_eq` compares
  Base text with the text projected from that same source (lines15295,14939,15004).
- `fs_inject` (14979) counts Base definitions for its loaded marker.
- `f_prefix_seed_graph` (15451) counts them again for the prefix certificate.
- `f_prefix_ready_seed_completed` (15432) admits the existing name/constructor
  indexes and wraps the fixed graph. It does not rebuild those indexes.

With the empty carrier, `norm_defs_join([],seed.book)` returns the existing book;
there is no full Base-body reconstruction here. The repeated text equality may
matter in native execution, but no size-based estimate should replace timing.
The prepared graph shares Base products already kept by the seed; its additional
retained metadata is small, although actual native reference-count/lifetime cost
still needs measurement.

A minimal eventual interface pairs the original seed and its exact completion
inside one private session constructor. Only that constructor computes the
completion. It is never a user-supplied reuse flag or a completion accepted under
an independently supplied seed. A different producer/Base preparation constructs
a different pair. `p140pl_seeded` can consume the retained value unchanged.

Preserve error priority: the original request checks its header and import
admission before `p140pl_seeded` observes a Base completion error. If preparation
is performed earlier, retain its result (including error), rather than failing
before those checks. Current-source aliases, name validation, contextual
completion and freshening must still execute normally. Successful and rejected
parser/checker requests must not mutate the fixed product.

The prepared Base graph cannot certify `f_graph_finish_indexed` or
`f_prefix_graph_trace` for a new request. Their dependencies include current
parsed definitions, source paths/import aliases, suffix validation, and freshening.
They also join the old prefix with the current fragment (`norm_defs_join`), which
copies the prefix list spine. Retaining Base completion alone does not eliminate
that separate work. Replacing those joined views would be a larger change.

## Decisive probe, already prepared

[`base-completion.mjs`](../../selfhost/tools/performance/phase142/base-completion.mjs)
requires only existing checked roots:

```text
f_prefix_complete_ready_seed f_prefix_graph_empty f_source_path f_source_text
f_source_located p86_width f_source_header p140pl_load p140pl_seeded
p88_cache_prepare f_source_end
```

Run with the coordinator's checked witness API and a fresh Phase142 output:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase142/base-completion.mjs \
  CHECKED_WITNESS_API_REPORT.json \
  selfhost/build/phase142/base-completion01
```

It measures the isolated Base expression five times. On frozen Lexer/Map A→B
edits it then compares five alternating original-loader/retained-completion
observations, with original parser checkpoints and complete load/cache/flag
structural equality. Source location, width and header are recomputed inside the
retained timing. Full checked source/API/Base/fixture identities are pinned.

The current witness API does not export `p86_import_error`; the probe explicitly
records that the retained path excludes import-validation cost. Its scope is
already independently accepted frozen Base-only fixtures. It does not claim
invalid-input error equivalence or a full pipeline speedup. The isolated cost
and approximate ceiling suffice to reject an unpromising idea without another
API build. Native gains remain unmeasured even if hosted replay is promising.
