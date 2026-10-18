# Frozen Phase108 coverage controls

These are source-prepared controls, frozen before candidate execution. The
compiler algorithms remain Bend. `nt-reverse.bend` contains the exact unchanged
`nt_reverse` declaration; `lexer-scan.bend` contains exact lexer declarations;
the held-out String fixture calls unchanged pinned Base `String.reverse.go`.
`manifest.json` records source/declaration/fixture hashes and manually derived
expected outputs. Preparation does not claim that the sources check or run.

Run the inexpensive source authentication from the repository root:

```sh
python3 selfhost/tools/performance/phase108/coverage/verify.py
```

This only hashes files, checks source excerpts and compares the `#|` lines to the
independent manifest. It does not execute the compiler or target programs.

Manifest version 2 corrects the array fixture's computed tuple destructuring
after a source parse failure; its expected output is unchanged. The exact version-1
source and manifest are preserved in [`rejected-source01`](rejected-source01/README.md).
The lexer fixture contains no analogous computed tuple binding and is unchanged.

| Fixture | Purpose | Expected stdout |
| --- | --- | --- |
| `nt-reverse` | Erased polymorphism; List match/build; opaque String children; retained tail/head aliases | `z`, `\|bc\|a\|tail`, `c\|b\|head/b\|c/head`, `cd\|ab`, each followed by LF |
| `string-reverse-heldout` | Same mechanism through Base String/Char; scalar Unicode and combining mark order; retained alias | `tail`, `é🙂a!`, combining acute then `e`, `cba!/abc`, each followed by LF |
| `higher-order-capture` | Captured String through a higher-order parameter and invocation | `captured=42\n` |
| `non-tail-list` | Build after recursive result; addition after recursive result | `list=14\n` |
| `arrays-io` | Allocate/clone String arrays; retain retrieved String across mutation; print | `arrays=seed/changed/seed\n` |
| `lexer-scan` | Exact real scanner, product results, closures, signs/exponents, Unicode refusal, quote failure | Seven complete lines recorded in the manifest |
| `negative-type` | String cannot inhabit U32 | Source admission rejects, no C/object/executable product |
| `negative-affine` | Function parameter consumed twice | Source admission rejects, no C/object/executable product |
| `negative-foreign` | Missing foreign provider | Source admission rejects, no C/object/executable product |

Negative diagnostics are not frozen byte-for-byte. Their phase, nonzero exit and
absence of emitted products are the assertions. Runtime digest/ABI/layout negative
controls in the manifest are **specifications**, to bind to the actual adapter
once it exists; they are not runnable source fixtures or counted passes.

Root serializes all source checks, emission, builds and target execution on CPU3
under the existing process-tree guard. Each attempt has a fresh output directory.
Record method/tool/runtime/source identities, complete commands, exit status,
stdout/stderr and artifact hashes. The existing compiler baseline emission syntax
is:

```sh
selfhost/bend selfhost/tools/performance/phase108/coverage/fixtures/nt-reverse.bend -o ATTEMPT/nt-reverse.c
```

That command uses the existing selected runtime. For the cproc candidate, root
must use the selected Bend compiler's supported runtime input with the portable
runtime template before emission. Do not rewrite compiler-generated function
bodies, treat ordinary baseline output as evidence of runtime substitution, or
silently replace the independent expectations with incumbent output. The exact
candidate command belongs in the attempt receipt once the runtime/emitter bridge
is fixed; no nonexistent CLI runtime option is assumed here.

Run the three-element aliased List first, then freeze its candidate and run the
held-out String fixture without adaptation. Continue with closure, non-tail list,
arrays/IO and lexer controls. Compare both portable-runtime Clang/GCC (where
admitted) and cproc/QBE outputs to the manifest; use existing-runtime Clang as a
separate semantic reference. Any change prompted by a held-out failure starts a
new candidate and forfeits the original held-out qualification.

Inspect emitted C/IR/assembly to establish which closure, allocation, refcount and
trampoline paths actually survived optimization. Source-level coverage alone does
not prove those physical paths ran. These small fixtures also do not prove bounded
deep stacks or all alias disposal orders: add parameterized deep/lifetime runs and
allocator accounting before full-image qualification. They exercise valid array
clone sharing rather than illegal affine array-handle duplication.

The complete coverage/source-boundary audit is
[`implementation/phase108/coverage-audit.md`](../../../../../implementation/phase108/coverage-audit.md).
