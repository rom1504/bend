# Source registry and reproducibility

Research date: **2026-10-01**. Sources are compiler authors' papers, official
documentation and implementation repositories. Historical releases are selected
for stable inspection, not claimed to be latest or mutually contemporary.
No external compiler was installed, built or benchmarked.

## Versioned implementation entry points

| Area | Inspected version / revision | Start with |
| --- | --- | --- |
| Bend TS | `018751270e800bc222a93dad7f257083ee53a5f7` | [comp.ts](https://github.com/bendlang/bend/blob/018751270e800bc222a93dad7f257083ee53a5f7/bend2/comp.ts) |
| Bend selfhost | `9391ebe91ceeb73f69e4d02f1cdb67aa32a0c6a7`, installed Phase37 checked03 | [JS source](../../selfhost/src/back/js/), [baseline](baseline.md) |
| MLton | 20241230, `b15e2d289c3d701131733665a74e2dd8438410b6` | [closure conversion](https://github.com/MLton/mlton/blob/b15e2d289c3d701131733665a74e2dd8438410b6/mlton/closure-convert/closure-convert.fun) |
| GHC | 9.12.2, `383be28ffdddf65b57b7b111bfc89808b4229ebc` | [worker/wrapper](https://github.com/ghc/ghc/blob/383be28ffdddf65b57b7b111bfc89808b4229ebc/compiler/GHC/Core/Opt/WorkWrap.hs) |
| OxCaml / Flambda2 | `15584842f43dde95bd5ef9deb8956a447084c45e` | [value facts](https://github.com/oxcaml/oxcaml/blob/15584842f43dde95bd5ef9deb8956a447084c45e/middle_end/flambda2/docs/types.md) |
| Lean | v4.30.0, `d024af099ca4bf2c86f649261ebf59565dc8c622` | [study and source map](research/lean.md) |
| Koka | v3.1.2, `3c4e721dd48d48b409a3740b42fc459bf6d7828e` | [reuse](https://github.com/koka-lang/koka/blob/3c4e721dd48d48b409a3740b42fc459bf6d7828e/src/Backend/C/ParcReuse.hs) |
| Chez Scheme | v10.2.0, `fdf6b3f5d069bf53082bb827f46714f2de8f11f5` | [passes](https://github.com/cisco/ChezScheme/blob/fdf6b3f5d069bf53082bb827f46714f2de8f11f5/s/cpnanopass.ss) |
| Node / V8 | Node v24.18.0, installed V8 header 13.6.233.17 | [bundled source study](research/js-engines.md) |
| WebKit / JSC | `2917d6c16d9c986306a567222dda3ef72e2a1ddb` | [watchpoint study](research/js-engines.md) |
| Zig | 0.15.1 | [ZIR](https://github.com/ziglang/zig/blob/0.15.1/lib/std/zig/Zir.zig), [AIR](https://github.com/ziglang/zig/blob/0.15.1/src/Air.zig) |
| Cranelift | Extraction at `dd2dd8d9f0a0a06c34e364716d58acf67236ba6a` | [extraction](https://github.com/bytecodealliance/wasmtime/blob/dd2dd8d9f0a0a06c34e364716d58acf67236ba6a/cranelift/codegen/src/egraph/elaborate.rs) |
| Haskell vector | 0.13.2.0, `d9d0d46623fdecce7652f59caa4a28849292a0e7` | [actual stream core](https://github.com/haskell/vector/blob/d9d0d46623fdecce7652f59caa4a28849292a0e7/vector-stream/src/Data/Stream/Monadic.hs) |
| Strymonas OCaml | `3e33fcbc01f91cec58edb3c5f7db1bde3683255c` | [staged generator](https://github.com/strymonas/strymonas-ocaml/blob/3e33fcbc01f91cec58edb3c5f7db1bde3683255c/lib/stream_raw_fn.ml) |

Cranelift rule/ISLE/cache sources, Rust developer docs, Souper and Alive2 links
include development branches explicitly identified in their chapters. They are
inspected references, not frozen artifacts of one complete compiler version.
Before implementing a borrowed rule, pin its exact source and semantic model.

## Papers and official accounts

| Topic | Primary source | Use in this collection |
| --- | --- | --- |
| Control flow | [Contification Using Dominators](https://www.cs.cornell.edu/people/fluet/research/contification/ICFP01/icfp01.pdf) | Return/continuation conditions for local jumps |
| Shape specialization | [Call-pattern Specialisation](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/07/spec-constr.pdf) | Constructor knowledge and reboxing risk |
| Local joins | [Compiling without Continuations](https://simon.peytonjones.org/assets/pdfs/compiling-without-continuations.pdf) | Direct-style join-point discipline |
| Lean ownership | [Counting Immutable Beans](https://arxiv.org/abs/1908.05647) | RC, borrowing and reuse assumptions |
| Koka ownership | [Perceus](https://www.microsoft.com/en-us/research/publication/perceus-garbage-free-reference-counting-with-reuse/) | Precise references and storage reuse |
| Retention | [Frame Limited Reuse](https://www.microsoft.com/en-us/research/publication/reference-counting-with-frame-limited-reuse/) | Lifetime cost of reuse |
| Staged fusion | [Stream Fusion, to Completeness](https://arxiv.org/abs/1612.06668) | Generate away protocols and intermediate state |
| Pass design | [Keep's dissertation](https://andykeep.com/pubs/dissertation.pdf) | Explicit intermediate-language contracts |
| Self-hosting | [Zig 0.10 notes](https://ziglang.org/download/0.10.0/release-notes.html), [0.15.1 notes](https://ziglang.org/download/0.15.1/release-notes.html) | Compilation, memory and generated speed as separate axes |
| Bounded rewriting | [Cranelift maintainer's account](https://cfallin.org/blog/2026/04/09/aegraph/) | Engineering tradeoffs and negative results |
| Rule discovery | [Souper v2 paper](https://arxiv.org/abs/1711.04422v2) | Offline synthesis within a precise subset |
| Validation | [Alive2 paper](https://users.cs.utah.edu/~regehr/alive2-pldi21.pdf), [CompCert specification](https://compcert.org/man/manual001.html) | Model scope, unknown outcomes and observations |

Each study provides more detailed links beside its claims. Papers motivate
mechanisms and constraints; none supplies a measured speedup for our compiler.
Research does not imply copying source, changing licenses, adopting a new runtime
or adding a production dependency.

## Local evidence and source identities

- [Local source identities](../../implementation/phase38/local-source-identities.json)
  bind inspected Bend files and four saved generated modules.
- [Selected external file identities](../../implementation/phase38/external-source-identities.json)
  bind downloaded Koka/Chez source files by commit, URL, bytes and SHA256.
  They are an identity record, not a complete offline source archive.
- [Machine-readable source links](../../implementation/phase38/source-links.json)
  index references across the collection. Inclusion means cited, not that every
  URL was fetched successfully; source-access limitations are explicit in chapters.
- [Phase37 capsule](../../implementation/phase37/evidence/README.md) preserves the
  raw timing/profile/module evidence used by all estimates.

The pinned Bend GitHub link could not be fetched by the browser; its local bytes
were inspected and hashed. Some initially tried historical links redirected or
failed; useful replacements are named in the corresponding study. The corpus
does not claim complete mirroring or a network-wide link-availability audit.

## Mining rules

Use the [idea ranking](ideas.md) as the decision index. A candidate needs a local
bottleneck, a transferable source mechanism, a semantic boundary, a small
falsifiable probe, and an explicit stopping condition. Record scope/denominator,
confidence and overlap before quoting any gain. Do not turn the number of papers
or agreeing compiler designs into a probability that our experiment will win.
