# cproc → QBE host compiler boundary

The prepared toolchain compiles ordinary C through cproc and QBE without Clang.
The small witness passes Linux system headers, 32/64-bit concurrent atomics,
compare/exchange success and failure, CLZ, aggregate argument/return ABI,
constructor invocation before `main`, and 128-byte global alignment. This is a
toolchain witness, not a full Bend compiler or language conformance result.
Root owns the full-image and Bend-program integration gates.

## Exact implementation and acquisition

- cproc upstream: <https://git.sr.ht/~mcf/cproc>, commit
  `d1c53ddf56571573a7025324c8dd5c6d547a4d1f`.
- QBE: the existing Phase107 QBE 1.3 source, copied into Phase108 before patching.
  The Phase107 directory and executable remain unchanged.
- Both tools are built with GCC 10.2.1; cproc and the small atomic shim use
  `-O2`, QBE uses `-O2 -std=c99 -Wall -Wextra -Wpedantic`.
- The two source patches, preinclude headers, shim, bounded smoke, acquisition
  recipe and [exact SHA-256 receipt](../../selfhost/tools/performance/phase108/toolchain/receipt.json)
  are in [toolchain/](../../selfhost/tools/performance/phase108/toolchain/).
- Build artifacts occupy about 6.2 MiB under
  `selfhost/build/phase108/toolchain`; a deterministic gzip archive retains
  the original cproc commit source independently of the applied patch.

The upstream cproc project documents its incomplete atomic/volatile support,
external preprocessor dependency and lack of PIC generation in its
[README](https://github.com/michaelforney/cproc). The executable path therefore
uses the configured GNU preprocessor, cproc, QBE, GNU assembler, and explicit
`gcc -no-pie` linking. GCC compiles only the tool acquisition and small atomic/CLZ
boundary; Bend compiler algorithms remain the generated C input to cproc/QBE.

## Required compatibility work

1. The original host runtime's GNU `__atomic_*` operations all access `u32`.
   Its only C11 `_Atomic` globals are `pool_row: u32`, `pool_tick: u64`, and
   `pool_done: u32`. A narrow `stdatomic.h` adapter removes the atomic qualifier
   and routes every operation to typed external wrappers. `_Generic` chooses
   the 32/64-bit pool wrapper without evaluating the selector expression.
   There is no plain load/store replacement for any atomic access.
2. The shim implements those wrappers using GCC atomic builtins, preserving
   widths, compare/exchange expected-value updates, weak/strong arguments and
   order values. Dynamic order arguments may cause GCC to conservatively
   strengthen ordering; that is a possible performance cost. It supplies CLZ
   through the same nonzero-input contract as the original builtin.
3. cproc itself has no supported constructor emission, despite recognizing the
   attribute's spelling. A small pinned patch carries a pre-declarator GNU
   constructor attribute to a function definition and emits an ELF `.init_array`
   pointer. It admits file-scope, non-inline `void(void)` definitions, matching
   the generated effect providers. Priorities, declaration-only constructors,
   arguments, non-void returns and non-function declarations fail explicitly.
   There is no host scan of effect-provider function bodies or names.
4. glibc's `sys/cdefs.h` erases `__attribute__` when `__GNUC__` is absent. The
   preinclude loads the observed Linux headers under that policy, then undefines
   the erasing macro so provider constructors reach the patched parser. Unknown
   noinline/cold/may_alias attributes are ignored by cproc. Required allocation
   alignment is expressed using standard `_Alignas` by the portable runtime.
5. QBE 1.3 stores data alignment in a signed `char` and rejects 128-byte
   alignment. The isolated two-line patch changes that field to `int` and the
   upper validation bound from `CHAR_MAX` to `INT_MAX`. It retains positivity
   and power-of-two checks. The original 128-byte runtime layout is preserved.
6. cproc cannot implement Clang `musttail`. The separately reviewed portable
   runtime dispatch is mandatory; `compile-c.sh` enables `WL_PORTABLE=1` and the
   preinclude defines `BEND_CPROC=1`. The toolchain patch does not replace any
   Bend lowering or runtime scheduling algorithm.

The `.init_array` emission follows QBE's documented
[section linkage](https://c9x.me/compile/doc/il.html#Linkage). The smoke executable
contains the initializer's address in that section and its aligned object at
an address divisible by 128.

## Evidence and rejected steps

- The initial stock cproc/system-header compile failed at GCC `stdatomic.h`
  because `__ATOMIC_RELAXED` was absent. The narrow header/shim resolves that
  boundary without pretending cproc implements general C11 atomics.
- The first combined smoke exited 9: glibc silently erased constructor and
  alignment attributes. Its source, executable, preprocessed source and QBE
  output are retained as `smoke-attrs-erased*` in the build capsule.
- Undefining the attribute eraser before all system headers were loaded exposed
  an unsupported pthread declaration attribute. Preloading the observed headers
  before restoring attribute syntax resolves that concrete boundary.
- Preserved constructor attributes then failed explicitly in stock cproc.
  The recorded cproc patch resolves that case; it does not enable every GNU
  constructor syntax.
- Standard `_Alignas(128)` subsequently failed in stock QBE's alignment parser.
  The isolated QBE patch resolves it without changing the runtime alignment.
- The final combined smoke prints
  `phase108 cproc headers/atomics/CLZ/constructor/alignment/aggregate PASS`.
  Two pthreads perform 20,000 total increments on each width. Independent checks
  cover old values, CAS failure updating expected, CLZ endpoints, an aggregate
  crossing the 32-bit boundary, constructor side effects, and address alignment.
- Six constructor negative controls reject non-functions, non-void results,
  arguments, prototypes, priorities and inline definitions. Their exact
  diagnostics and exit statuses are included in the receipt.

General foreign C, arbitrary headers, volatile semantics, constructor priorities,
position-independent objects, device execution and broad concurrent runtime
correctness remain outside this toolchain witness. The small threaded atomic
test is not a proof of the complete Bend scheduler or ownership implementation.

## Replay

```sh
selfhost/tools/performance/phase108/toolchain/setup.sh
selfhost/tools/performance/phase108/toolchain/compile-c.sh \
  selfhost/tools/performance/phase108/toolchain/smoke.c \
  selfhost/build/phase108/toolchain/smoke
selfhost/build/phase108/toolchain/smoke
```

The setup recipe verifies the cproc commit and exact recorded patch. Normal
compilation streams intermediate forms between cproc/QBE/assembler and retains
one object plus the executable, avoiding a full-image `.ssa` or `.s` artifact.
