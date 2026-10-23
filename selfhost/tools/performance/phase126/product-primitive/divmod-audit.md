# Phase126 product admission and native quotient/remainder

This is a bounded composition experiment on the existing checked semantic and
structured direct IR. It adds no new generic IR opcode, ownership protocol,
shared C shape rule or workload-name selection. Source/API/native qualification
and runtime results are root-owned; this note records source proof and static
activation evidence.

## What source26 demonstrated

The original reader and owning adapter already exist for the certified Map
observer. Source26 additionally exposes the reader's exact existing fields
through the existing product ABI, and reruns dependency closure from that
verified immutable catalogue. Three actual emitted programs gain private
Map.bit/at routing. Their former scheduler transitions disappear, while the
Nat.divmod Tuple allocation and corresponding take remain. Static evidence is
in evidence26/report.json, not a dynamic allocation count. Root's matched
screen measured improvements in records, map churn and evening, but a lexer
regression; none of those results establishes the value of divmod flattening.

## New primitive contract

The existing runtime opcode70 returns `(0,a)` when the divisor is zero and
otherwise unsigned full-width `(a/b,a%b)`. The additive p126_rt_nat_divmod
helper writes exactly these two words to a verified 16-byte local output and
returns an ignored U64 status. It neither allocates nor observes ownership.
Existing generic primitive calls remain the fallback for opaque/escaping
results. The shared `nq_pair_primitive` predicate remains unchanged: its C
implementation dispatches to array operations, so extending that predicate to
Nat would have been incorrect.

The direct-import extension checks the exact state argument, full-width scalar
arguments, nonstate live output pointer, capacity through byte15 and U64 result.
It retains the old verifier implementation as an exact alias. The generic
N111 verifier is unchanged. This is an explicit new verified-runtime contract,
not a claim that the original verifier independently knew the new helper.

Existing `p113p_bindable`, product substitution, fresh-ID threading, typed
original-source verification, ownership environment and final direct/program
verification remain required. The helper is used only when the requested
result is the exact two-field Tuple shape. Arbitrary grounded Nat inputs,
including values above 2^32 and divisor zero, retain the original semantics.

## Negative activation result and repair

Source27 checked and passed the pure import/shape controls, yet all five emitted
benchmark QBE files were byte-identical to source26. There were zero new-helper
calls. Its shape hook only recognized the already sequenced NOp form. At a
checked let binding, the native call can still be an App; choosing a boxed
binding there commits to the boxed result before p113pl_app later creates NOp.

The source32 shape refinement uses the exact existing `nd_native_call` proof for
that App form: native declaration identity, fully saturated arity, non-bang
reference and existing primitive mapping must all agree on opcode70. Ordinary
lookalike functions, partial applications and overapplications retain the
original query/fallback. It does not substitute argument evaluation or change
argument order. Five additional pure controls cover these boundaries. Actual
emission activation must be checked before any timing claim.

## Independent ordinary controls and retained failures

The fixture covers twelve operand pairs: zero divisors, zero dividends,
divisors 1/2/3/33/maximum, values around 2^32 and maximum valid 48-bit Nat.
It prints each escaping pair twice and also its flat-consumer sum. The 36-line
expected output is independently computed with Python integer arithmetic, with
the language's zero-divisor rule explicit; Python is not part of compilation.
The final ordinary source constructs large values using safe `hi*65536+lo`
expressions, with every intermediate within the valid Nat range.

The first manifest omitted the host harness's expectedStdoutEvidence key;
cases02 repaired only transport. The initial ordinary source then failed its
frontend gate because it destructured a computed term and contained oversized
literal tokens; cases03/fixture03 fixes only those source expressions, keeping
the same independent expected output. None of these failed versions executed a
malformed target. All earlier files remain retained.

## Separate optimization-order ablation

Source33 applies the existing bounded p113i_function (including its range pass)
only to symbols newly admitted by the late closure. Original/borrowed workers
remain byte-identical. The complete immutable eligible callee catalogue uses
existing hygiene and profitability gates. Final candidate verification is
unchanged; a failed candidate returns the original closed catalogue. This is
a separate ablation from source32's product-shape fix, intended to test whether
late admission bypassing established passes explains the lexer regression.
It adds no custom source-name profitability exception.

Source28 failed its SCC module's law-backed declaration syntax; source29
inherited that rejected parent. Source30 repairs those declarations. Source31
was composed before a crossed request to separate the two final ablations and
is retained unused; source32 and source33 provide the causal chain. These are
composition/parser outcomes, not performance findings.

## Fixture grade correction and actual activation

Fixture04 still failed its frontend gate. The exact cause is that Base's Pair
notation uses Sigma<&1,&1,...> of kind Type, so duplicating Nat & Nat is invalid.
Fixture05 consumes that linear result into explicit Data Sigma<&2,&2,Nat,_=>Nat>
before retaining it twice; this matches a previously checked shared-Sigma source.
The independent36-line arithmetic oracle is unchanged.

Root's source32 emission now contains the new helper: four static sites in each
of records/evening/map churn and two in lexer/RLE. Map.bit calls product Map.bit.at,
removing the intermediate quotient/remainder Tuple and matching take from this
path. Evidence32 preserves the actual QBE. The focused screen and its attribution
limits are recorded in implementation/phase126/product-observer-report.md.
