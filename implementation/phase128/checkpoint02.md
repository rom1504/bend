# Phase128 second checkpoint: preserve the optimization boundary

The combined checked producer reduces the unchanged real compiler name-search
kernel from **1.487884s to 0.533012s**, a **2.79× speedup** (64.18% less time).
Pinned upstream C/Clang takes0.101841s in the same five rotated clean rounds.
This is still5.23× upstream on this kernel. It is **not** a measurement of N1
compilation speed or the historical44-program geometric score.

## What made the difference

Scalar borrowed readers first removed per-character ownership traffic. Verified
calls between those readers improved composition further. Extending the reader
to concrete nested layouts admitted `List<String>` search, but runtime barely
changed: an earlier inliner had replaced the hot call to the public search
wrapper with its underlying tail-SCC worker. The new reader was correct but
was bypassed.

The selected transformation recovers an exact thin-wrapper equation from the
checked source. It restores calls only when formals occur exactly once, fixed
arguments match, the mapping is unambiguous and the wrapper is already available
in definition order. It does not recognize benchmark names. Generated readers,
adapters and copied owning fallbacks are excluded from rewriting. Inspection
confirms the hot digest now calls the borrowed public search while the original
owning fallback still calls the tail-SCC worker. This preserves an optimization
boundary that ordinary inlining had erased.

The separate raw-preparation experiment retains the original candidate list
across initial and late closure. It preserves candidates rejected initially,
and applies the initial SCC transformation only at its original use. Three
same-request paired hosted measurements improve Map's integrated stage from
5.323363s to4.721370s (11.31%). Complete QBE remains identical on tree, RLE and
Map. This excludes frontend/preparation time and is not a cold native result.
The earlier ready-flat-only shortcut was inconclusive and is not selected.

Reachability filtering now constructs the existing exact-name membership index
once. Original definition order, payloads and duplicates survive. Controls
cover Unicode and a real hash collision; no isolated native gain is claimed.

## Checks and current boundary

- The wired native source passes the pinned upstream checker and79 finite
  predicates. Its source SHA is
  `d693cc740c58f9b137e64a043aacd0422c62c688aaf0de62727df7a009cef65f`.
- The combined borrowing code preserves the22-line sharing/alias/Unicode
  ordinary controls. A separate five-line numeric list and renamed generic
  spine fixture passes upstream checking, direct QBE and native execution.
- The first transfer fixture failed the same quantity/kind check upstream and
  self-hosted. It remains preserved; explicit affine-list quantity corrected
  the fixture. This was not a compiler regression.
- Nine varied original benchmark wrappers pass independent emission verification
  and81 timed/output-checked observations. The screen's retained comparator is
  Phase125, not Phase126: it cannot isolate this phase's gains.
- Source grows from55,339 to56,697 physical lines (+1,358,2.45%), including
  controls and diagnostic declarations. Full-image memory/scalability remain
  a qualification obligation; retained candidates can increase live memory.

The first full native acquisition is running under the existing6GiB limit.
Neither a new native speed ratio nor native self-reproduction is claimed yet.
Qualified previous images and installed selection remain unchanged.

## Evidence and research

Exact receipts: `selfhost/build/phase128/combined-timing01/report.json`,
`sharedprep-pairs01.json`, `native-admission01.json`,
`native-finite01/report.json`; emitted programs:
`selfhost/build/phase118/p128-native-small01/report.json`; screen:
`selfhost/build/phase126/p128-screen01/report.json`.

The [fast-compiler survey](../../research/compilers_architecture_and_techniques/phase128-fast-compilers.md)
connects these results to Lean's ownership contracts, Zig's resolved identities
and scoped immutable IR, and Go's amortized work. Our immediate lesson is to
retain and compose useful facts before proposing another backend or a large
cache. The first [evidence archive](evidence/checkpoint01.tar.gz) preserves the
earlier scalar/call experiments; the final archive will add this checkpoint.
