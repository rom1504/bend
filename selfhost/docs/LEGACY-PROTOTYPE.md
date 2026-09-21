# A self-hosted Bend2 → JavaScript compiler

**This is a working, self-hosted compiler prototype, not a complete rewrite of
Bend2's upstream compiler.** The lexer, parser, AST construction, and JavaScript
emitter are written in Bend2. The dependency-free generated compiler can compile
that Bend2 source again. The full dependent-type/proof checker, module loader,
and native/GPU backends have not been ported.

Targets upstream **Bend 2.0.21**, revision
[`6018e28ecc67cf1fffc0c20c64b11023474c2df8`](https://github.com/bendlang/bend/tree/6018e28ecc67cf1fffc0c20c64b11023474c2df8),
committed 2026-09-20. This is the new Bend2 language, not the older Bend/HVM language.

## Run it

Node.js 24 or newer is the only requirement for the included executable. No
TypeScript compiler, upstream Bend compiler, or Bun is involved in normal use.

```sh
node legacy-cli.mjs tests/fixtures/hello.bend --run
node legacy-cli.mjs tests/fixtures/tree.bend --run
# Prints 42.

node legacy-cli.mjs tests/fixtures/tree.bend -o tree.mjs
node tree.mjs

npm run test:legacy
```

The CLI writes an explicit unchecked-compilation notice to stderr. Output
programs are standalone JavaScript modules with an embedded runtime. Compilation
to stdout is also supported:

```sh
node legacy-cli.mjs tests/fixtures/tree.bend > tree.mjs
```

The lower-level generated compiler has this interface:

```sh
node dist/bend2c.mjs INPUT.bend src/runtime.mjs > OUTPUT.mjs
```

Use `legacy-cli.mjs` normally: it validates CLI options, protects the input file from
being overwritten, enforces the current 16 MiB source limit, and only replaces
an output file after successful compilation.

## What was verified

- The pinned upstream checker accepts `src/compiler.bend`.
- Upstream compiles that source into stage 1.
- Stage 1 compiles the same source into stage 2.
- Stage 2 compiles the same source into stage 3.
- Stage 3 compiles the same source into stage 4.
- **Stages 2, 3, and 4 are byte-for-byte identical.**
- **64/64 local tests pass**, including a 100,000-step tail-recursive program,
  lexical closure capture, partial application, nested patterns, parallel-let
  scoping, array wrapping, monadic short-circuiting, Unicode, malformed syntax,
  and 40 deterministic U32 wrapping-arithmetic cases.
- **183/194 selected upstream programs produce their exact expected output.**
  The selection includes files from `tests/run`, `tests/compile`, `tests/base`,
  and `tests/show` that import Base, define main, and do not have an `Error:`
  expectation. No individual failing case was removed from this selection.

The 19 named positive local fixture programs were also checked with upstream.
The 40 generated arithmetic tests use the same annotated expression template.
This is **not** a claim to pass the entire upstream suite: negative type/proof
checking tests and other namespaces were not covered by this survey.

The 11 non-passing survey cases are listed in `CONFORMANCE.md`; 10 are readback
or diagnostic-format differences, and one correctly detects Nat overflow but
does not reproduce the upstream harness's exact error/exit rendering.

Reports contain actual results and bootstrap hashes:

- `dist/bootstrap-report.json`
- `dist/test-report.json`
- `dist/fixture-typecheck-report.json`
- `dist/upstream-survey.json`

The final bootstrap took about 13 seconds in the development environment. This
is a reproduction observation, not a portable performance claim.

## How self-hosting works

The upstream TypeScript compiler produces `stage1.cjs`, run with Bun. Stage 1
produces `stage2.mjs`. Node runs stage 2 to produce stage 3, and stage 3 to
produce stage 4; those three JavaScript files are identical.

`src/compiler.bend` is the compiler implementation (1,528 lines). It uses
persistent token lists and algebraic syntax trees. Parsing functions return an
AST and unconsumed tokens. Emission traverses those trees and writes JavaScript.

`src/runtime.mjs` implements the generated language's execution substrate:
curried calls, a tail-call trampoline, constructor representation, pattern
matching, numeric/collection primitives, and IO. It contains **no Bend source
parser or emitter**, and never invokes the upstream compiler. Pattern matching
is a runtime helper, so this backend favors simplicity over optimization.

Top-level signatures are declared before their definitions because Bend checks
names in order. Mutually recursive compiler helpers use `@unsafe`. Upstream's
acceptance verifies their types and affine use; it does not prove compiler
correctness or termination.

The small JavaScript files under `tools/` handle bootstrapping and testing.
`legacy-cli.mjs` only handles arguments, files, and subprocess execution. They do not
perform the source-to-JavaScript compilation.

## Supported computational features

- Named definitions and curried higher-order functions, closures, partial calls,
  lexical bindings, and direct or mutual recursion.
- Algebraic constructors, nested and multi-scrutinee patterns, default cases,
  destructuring, natural-number predecessor patterns, lists and tuples.
- Lambdas and constructor-matching lambdas.
- Parallel-let syntax with simultaneous binding; execution is sequential.
- U32 arithmetic/bit operations, F32 operations, bounded runtime Nat arithmetic,
  strings, characters, arrays, maps, sets, and a substantial Base subset.
- Array fill/index/update sugar and wrapping indexes.
- IO and do notation, including Maybe and Result short-circuiting.
- Type annotations, ordinary polymorphic argument passing, laws used as forward
  declarations, and basic execution of template-style higher-order code.

Passing tests establish coverage of particular programs, not full equivalence
for every combination of these features.

## Important omissions and differences

1. **No dependent type checker, affine-use checker, termination checker, proof
   verification, or guarantee that laws hold.** Laws and annotations are parsed
   or skipped for executable compilation. `{==}` can be represented as an erased
   value; accepting it is not proof validation. `--check-only` is explicitly
   rejected by the CLI. Use the upstream checker for verification.
2. **JavaScript only.** No C emitter, native reference-counted runtime, CPU
   parallel scheduler, Metal, or CUDA. GPU `!` and parallel-call syntax execute
   sequentially, as they also do in upstream's JavaScript target.
3. **Single-file input plus built-in Base support.** Non-Base module imports are
   rejected instead of silently ignored. No package hub, publication, or foreign
   source imports.
4. **Incomplete type-directed erasure and specialization.** Type syntax is often
   erased to placeholders, while many explicit arguments are retained. This is
   not equivalent to upstream for all programs that compute with types or rely
   on erased arguments not being evaluated. Templates are not specialized.
5. No guarantee of parser/checker diagnostic parity. Some source forms outside
   the tested computational subset remain unsupported.
6. Incomplete pretty-printing of function values, characters versus U32 values,
   type values, and nested tuples/arrays. IO programs using Base formatting are
   much better covered than interpreter-style term readback.
7. Only a subset of Base effects is implemented. In particular there is no
   networking, graphics, audio, or complete channel/concurrency support.
8. The lower-level compiler performs one read of at most 16 MiB per input file;
   the wrapper rejects larger source files. Deep non-tail recursion and large
   inputs can still run into host stack, memory, or time limits.
9. No upstream optimization passes or performance-parity claim. Large immutable
   token lists, dynamically scoped lookup objects, and generic call machinery
   make this a reference implementation rather than a production replacement.

## Reproduce the bootstrap

Install Node 24+, Git, and Bun (tested with Bun 1.3.11):

```sh
npm run bootstrap:legacy
npm run test:legacy
npm run survey
npm run check-fixtures
```

`bootstrap` fetches the exact pinned upstream revision into `.bootstrap/upstream`
if necessary. It never edits upstream's `bend.ts` or `comp.ts`. To use existing
local tools and a checkout:

```sh
BEND_UPSTREAM=/absolute/path/to/bend BUN=/absolute/path/to/bun npm run bootstrap:legacy
BEND_UPSTREAM=/absolute/path/to/bend npm run survey
npm run check-fixtures
```

The checkout must be at the recorded revision. `bootstrap` refuses a different
HEAD. The first step uses upstream's APIs from Node; stage 1 uses Bun because
upstream's generated file effects depend on `bun:ffi`. Every later generation
runs using Node alone.

## Work needed for a complete rewrite

The next major task is porting `bend2/bend.ts`'s trusted core: terms, substitution,
normalization, bidirectional dependent checking, quantity accounting, and
termination/proof rules. That checker should reject upstream negative tests
before adding backend optimizations. Module resolution, erasure, and template
specialization must then be integrated with checked terms. Finally, port the
native emitter and runtime from `bend2/comp.ts`, validate CPU behavior, and test
Metal/CUDA on appropriate hardware. Those parts have not been completed here.

## Sources

- [Pinned language implementation and trusted checker](https://github.com/bendlang/bend/blob/6018e28ecc67cf1fffc0c20c64b11023474c2df8/bend2/bend.ts)
- [Pinned compiler and runtimes](https://github.com/bendlang/bend/blob/6018e28ecc67cf1fffc0c20c64b11023474c2df8/bend2/comp.ts)
- [Pinned language guide](https://github.com/bendlang/bend/blob/6018e28ecc67cf1fffc0c20c64b11023474c2df8/guide/GUIDE.md)
- [Pinned Base library](https://github.com/bendlang/bend/blob/6018e28ecc67cf1fffc0c20c64b11023474c2df8/bend2/base.bend)

See `LICENSE`, `UPSTREAM-LICENSE`, and `NOTICE` for licensing and attribution.
