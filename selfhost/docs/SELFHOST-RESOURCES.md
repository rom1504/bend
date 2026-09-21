# Self-hosting resources

Run the self-hosted JavaScript compiler with `node --stack-size=4096`.
This sets V8's JavaScript stack budget to 4 MB. It changes host resource
configuration, not compiler terms, checking rules, generated source, or the
fixed-point comparison.

The compiler's `count_open` and `constructor_exists` traversals currently use
non-tail recursion through arithmetic or Boolean operations. The default
Node 24 stack can overflow even for the approximately 1,859 declarations in
the compiler's canonical book. The exact threshold varies with V8 optimization
and call context; successful warm runs do not establish a safe default budget.

A focused probe exercises the ordinary positional/named compiler ABI, without
changing the emitted module or bypassing the checker implementation:

```sh
BEND_SELFHOST_API=/absolute/path/to/stage2.mjs \
  node --stack-size=4096 tests/selfhost-stack.mjs
```

The test covers 1,859, 3,000, and 5,000 shallow declarations: open-definition
counts, mixed native/filled/open definitions, missing and final-position
constructors, and the compiler-owned-name scan. All 15 cases passed with the
4 MB configuration for stage2 SHA256
`68585dc2852d8364b3ead69ea26b1e6c5a05809eeab7325206d18e06e8124418`.
Running the same command without the stack flag records the default-stack
failures and exits nonzero. Full measured results and module identity are in
[the resource probe report](../tests/conformance/selfhost-stack-resources.json).

This establishes the tested resource configuration, not an unbounded-program
stack guarantee or a performance-parity claim. A tail-recursive source rewrite
was explored separately and was not included in the frozen compiler.

## Heap allowance

The self-generated compiler accepted its own source, then failed during the
annotation phase with both Node's default heap and a 12 GB heap allowance.
The larger attempt failed while growing the host's eager ABI conversion
WeakMap. Symbolized stack evidence and both failed attempts are preserved in
[the historical release report](../dist/selfhost/release/report.json) and
[the ABI failure report](../tests/conformance/selfhost-abi-oom.json).

The host now uses [lazy ABI views](COMPILER-ABI.md), preserving compiler graph
identity between phases. Its separate
[direct seed verification](../dist/selfhost/seed-verification/report.json)
records a successful complete checked self-rebuild in 49 minutes, producing
exactly the seed compiler's bytes. The successful run used
`BEND_SELFHOST_HEAP_MB=12288`, passing
`--max-old-space-size=12288` to Node under a 20 GB container limit. This sets
a heap ceiling rather than preallocating memory; it does not establish a
minimum requirement or skip any compiler phase.

The [relocated distribution smoke](../dist/lazy-selfhost-distribution-smoke.json)
checks the self-generated compiler with the lazy adapter and a fresh Base
cache after extraction to a different directory. Byte-for-byte self-rebuilds
are a separate condition: foreign-function metadata contains canonical paths,
so relocation requires generating a new local seed before comparing outputs.
