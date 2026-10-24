# Preserving borrowed queries through optimization

Phase137 addresses a composition problem in the compiler written in Bend. A
complete scalar query can observe a retained record without transferring every
field's ownership. Earlier inlining could erase that query boundary before the
borrowed-reader pass ran, leaving the owning extraction in the caller.

The candidate does three things:

- Admits verified shallow record layouts of up to 16 fields, covering the
  nine-field compiler definition record. Packed/unsupported layouts retain
  their existing refusals and owning fallbacks.
- Expresses complete name/kind predicates in three actual compiler queries,
  preserving first-match, BookCache, Unicode and missing-result semantics.
- Conservatively defers early inlining of calls containing a literal 9–16-field
  consuming read. The existing borrow pass can then install its guarded reader.

The last rule is profitability policy, not permission to borrow. Runtime root
checks, alias/escape restrictions, scratch capacity, ownership fallbacks and
independent final verification remain. No C/JavaScript optimizer, new runtime,
backend replacement or duplicate preparation pass was added. Source checking,
finite controls, old mathematical proof bridges and native reproduction establish
different properties; none is a complete compiler-correctness theorem.

This is also not automatic fusion of every projection and consumer. The measured
compiler source explicitly composes its complete predicates. Unchanged programs
with owned projections may still keep unhelpful call boundaries. The report
preserves that limitation and the rejected source-only experiments.

## Qualified research version

The full source is `selfhost/build/phase137/integrated-source03/compiler.bend`,
SHA256 `2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38`.
The final native image is `selfhost/build/phase111/p137-n3/program`.
It retains the Phase128 runtime and authenticated compact prepared-Base carrier.
This is a qualified research checkpoint; the installed CLI is unchanged.

See [qualification and measurements](../../implementation/phase137/README.md),
[exact native acquisition commands](../../implementation/phase137/native-plan.md)
and [reproduction tools](../../selfhost/tools/performance/phase137/README.md).
Use fresh output directories and the existing process-tree guard when running
full compiler work. The previous qualified Phase134 source/image remains a
recovery and comparison point.

## Measurement boundaries

The extracted query and unrelated record tests establish useful capability and
transfer. Whole compiler requests decide whether it pays overall. Full cold
source-to-executable time additionally includes QBE, assembly and linking.
Generated-program code identity is checked separately on all 45 historical
benchmark wrappers; exact identity permits reuse of their existing machine
products, rather than claiming a new runtime timing result.

The latest numbers and their sample counts are in the linked report. In
particular, a large kernel improvement is not evidence of the same percentage
improvement in ordinary compilation, and a faster generated compiler is not
proof of recursive research acceleration.
