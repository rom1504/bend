# Full compiler C emission succeeds after removing body indentation

The indexed-closure candidate reaches final C body formatting, where genuine
JS B2 spends85.82% of its last55–60s diagnostic window in GC. Clean full-source
attempts hit V8's explicit heap limits at64.944s with1GiB and67.679s with1.5GiB.
Peak process-tree RSS is1,250,803,712 and1,767,714,816 bytes respectively. These
are contained child-process heap failures, with over24GiB of host memory still
available; neither is a host OOM or a reason to increase memory indefinitely.

`ne_segment` used `nt_indent(body)`, which traversed every character, constructed
a reversed string with inserted indentation, then reversed it again. Generated
JS retained the resulting character-level string ropes with all other segments.
The one-line candidate emits `body` directly. It retains newlines and removes a
cosmetic whole-output traversal. The standalone text helper remains unchanged.

Foreign C and multiline table macros use separate runtime payloads; they do not
pass through `ne_segment`. Generated body literals contain escaped source text,
and their conditional directives remain legal at column1. Arbitrary raw
`N_Segment` input is a separate boundary: a backslash-newline inside a C string
can have its value changed by inserted indentation. This change does not claim
universal equivalence for arbitrary raw C bodies or GPU self-embedding.

Checked compiler06 passes36 frontend cases, with exact diagnostics, in35.935s.
Its actual checked JS-hosted B1 then emits the complete frozen native compiler
source `d04ad79c…` successfully (`js-self11`). The14-edit source assembly replays
and reverses exactly to the original source. The actual request takes109.399s;
whole guarded invocation116.955s, peak RSS1,213,001,728 bytes with the original
1GiB Node heap. All four foreign-effect-sensitive representation policies stay0.

The emitted C has1,159,731 lines and38,614,586 bytes, SHA256
`81ca2837d2f274a23aeab7addf40cbef0e62a96a5ff7026c62a5112b1be0361e`.
The producer is the checked, equality-derived JS-hosted Bend B1. This is not
native execution, a native-B1→B2 chain, a mathematical proof, or a fixed point.
No independent older full-source C exists for a token comparison. Different
producer stages/source derivatives also prevent treating the earlier timeouts
as a paired speed ratio for this one-line change.

The first machine-code build uses Clang-O1 under6GiB RSS/16GiB available-memory
guards because this C is2.17× the upstream-built image's source size; the latter
already peaked at4.30GB under-O2. This choice is for bounded initial correctness
qualification, not an optimized-speed result. Native requests and reproduction
remain pending at this checkpoint.

That first `-O1` build stops at the6GiB process-tree guard after94.884s;
this is a guarded rejection, not host OOM. A separate `-O0` attempt uses only
3.16GB peak RSS but fails after93.388s in Clang's register allocator, reporting
`ran out of registers` in preserve-none/must-tail functions. Neither attempt
produces an admitted native compiler. The next discriminator changes the register
allocator at `-O0`, before attempting another expensive optimizing build.

The first four-case preprocessing attempt also fails: Clang receives the small
baseline through a Node input pipe and times out with no output after30s.
The failure does not establish a semantic mismatch or prove a Node defect.
A separate v3 method passes the same pinned file through a read-only stdin file
descriptor, keeping the command, `<stdin>` filename, timeout and equality gates.
Both methods and the failed attempt are retained.

The four retained Small/Map/Unicode/file-I/O C references have independent B2
digests. A separate checked-B1 emission compares complete preprocessing output
with identical Clang stdin filename, includes, macros and default CPU mode using
`-E -P -fminimize-whitespace`. It preserves intentional raw-byte differences;
old exact-C gates are not silently relabeled. Native-image gates must compare
against the new token-qualified C and preserve both proof chains.

Raw attempts and methods live under `selfhost/{build,tools/performance}/phase90`.
The successful full-source method is `bootstrap/emit-self-v7.mjs`; the new
generated source and its replay proof are in `observation/noindent01`.

The genuine, fresh-source-checked, fixed-point-qualified compiler06 JS B2 also
emits the same full native compiler source successfully (`js-self12`). Its
request takes48.662s, whole guarded invocation61.959s and peak RSS1,276,276,736
bytes. The entire38,614,586-byte C output is byte-identical to B1's output
(`cross-host-c-equality.json`). Both use the original1GiB heap cap and keep the
four foreign-effect-sensitive representation policies at0. This strengthens
cross-stage C correctness; it does not establish native execution parity or
native self-reproduction.
