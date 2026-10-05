# Phase48: direct typed native leaves

Initial candidate, not yet built or measured. Data-only inspection of exact
array06 Unicode output finds a complete11-function private worker, but residual
String.append still uses `callOwned(get(G,"String.append"),[a,b])`. The pinned
TypeScript emitter produces direct concatenation. Broader worker admission is
already present here; the remaining dispatch/argument vector is concrete work.

The new `ir/native-values.bend` handles only canonical `JWNative String.append`
with two operands. Existing JPure `j_map_native_string` establishes exact native
identity, arity, quantities and canonical String input/result types. Worker
lowering evaluates operands in source order. Existing root host/string/source
guards and original fallback are unchanged. The emitted `left + right` evaluates
each already typed value once; no String coercion hook applies to primitive
strings. It adds no assumption that arbitrary user functions with this name are
native. Other JWNative values retain the previous emitter byte-for-byte.

This is an application of typed effects/representation facts, not an expansion
of the native whitelist. The private guard must reject changed G binding/code,
bound/env/arity and observable host protocol mutation exactly as before. Known
partial prefix, error and reentry observations remain on the original public
path. Named markers/counter derivatives are diagnostic, never timing evidence.

First checks: a renamed recursive string producer with empty, ASCII, surrogate
and non-BMP content; an independent source with multiple consumers; mutation of
native code and global binding; getter and relevant prototype/call hooks. Check
exact complete output and error/event order, plus actual private entry/refusal.
Measure Unicode16/64 and a structurally independent records/library case before
crediting broader gains. Compiler source and output growth are explicit costs.

String allocation itself remains. V8 may already remove much of the dispatch;
reject a no-gain candidate rather than inferring speed from fewer AST nodes.
The wider private-value/aggregate workstream remains independently attributable.
