# Phase41 lexer feasibility and proof contract

Prospective static investigation, 2026-10-03. Baseline `8582de7`, installed
Phase40 checked06; upstream pin `0187512` remains unchanged. Owner: lexer agent.
No build or timing is authorized to this owner; root serializes measurements.

Hypothesis: the manual complete lex/step gain can be emitted by the compiler
without widening public argument admission or changing full native String,
Char, Mode, Cls and Sigma values. The cheapest disproof is an exact inventory
of unavailable source/host proof gates, followed by a String hook counterexample
if a proposed change attempts to reuse the current scalar guard unchanged.
No production source is edited during feasibility.

The proposed minimum contract is a closed scalar root, such as line(U32) or
bench(U32,U32), with a full checked source graph. String values are immutable
native JS strings produced only by pristine compiler literals/SNil/SCon;
Char is the exact built-in Chr ABI, with its existing checkedChar bound and
Unicode behavior. String splitting retains ordinary fields/project sequencing,
including repeated codePointAt calls, astral pairs and lone surrogates. No byte
or ASCII-only representation is permitted.

Sigma admission must be the exact native built-in four-parameter Sigma,
specialized to a nondependent two-field tuple, whose complete fields are
independently admitted. Preserve the native two-element array, constructor
identity, aliases and all tagged Mode/Cls intermediates. Do not classify all
parameterized/native containers as pure. Public tuples or Modes cannot enter
a direct worker from type claims alone.

The source proof must also admit only exact closed String/Char literals and
literal nullary helpers, and explicitly prove the native Bool.and signature.
Snapshots cover all reachable emitted/native wrappers and their ordinary ABI;
changes, getter descriptors and reentry fall back before demand. The String
global binding, constructor identity/static fromCodePoint, String.prototype,
codePointAt and slice require descriptor ownership in addition to existing
numeric/Object/Array guards. A String-producing residual cannot invoke a host
callback while a private region proof is open.

Lex structural admission must allow only built-in SCon tail descent. Char and
Sigma deconstruction are nonrecursive auxiliaries; their fields must never
receive String-descendant provenance. Steps complete before advancing input,
flush occurs after SNil, and the tuple/mode/accumulator demand and error order
remain generic outside owned entry. Reentry/throw cleanup closes any private
proof in finally. No fusion or new runtime/IR is proposed.

Selected controls before measuring: complete Mode/Cls/Sigma traces, all twelve
transitions, U32 overflow, all Unicode classes, mutable wrappers/getters,
String globals/statics/prototype hooks, escaped aliased values, deferred mode
and accumulator errors, invalid Char constructors and deep String descent.
Actual compiler emission and ordinary export entry are mandatory evidence;
manual privateBench timing cannot establish this contract.
