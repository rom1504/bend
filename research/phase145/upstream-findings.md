# What the pinned upstream comparison actually shows

All16 root-owned jobs passed: generated-copy preparation and original/clean/
counted observations for four complete programs plus one parse-only compiler
prefix. Guarded wall totaled **31.781 seconds**, with maximum observed process-tree
RSS393,564,160 bytes. No compiler image or generated native program was built.
The earlier0.351-second preparation refusal remains separately preserved.
The complete [derived summary](../../selfhost/build/phase145/upstream03/summary01.json)
pins the raw reports and validates their unchanged inputs; [method](upstream-method.md)
describes the source and instrumentation contracts.

The useful finding is architectural, not a new parity ratio: upstream produces
runtime terms while checking, then performs substantial repeated analysis and
emission over those products. It is fast despite this later repetition. We need
to compare the cost and representation of complete computations, not count
passes or assume every repeated visit is removable.

## Actual original TypeScript/Bun observations

| Exact input | Load, including Base | Check, including Base | C emission | Compiler-action subtotal | C output bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer |0.192s|0.240s|0.291s|0.723s|100,700|
| Closures256 |0.180s|0.207s|0.103s|0.489s|83,120|
| Map128 |0.190s|0.224s|0.603s|1.018s|280,410|
| Actual compiler Patricia-index slice |0.216s|0.234s|1.972s|2.422s|347,386|
| Actual1024-declaration compiler prefix |0.308s|not run|not run|0.308s|not emitted|

These are **one fresh process per variant**, not repeated medians or confidence
intervals. Subtotals exclude imports, input authentication, output hashing and
observer bookkeeping. For example, original Lexer's whole observer was1.317s,
not0.723s. The index slice is21,869 bytes of real compiler code with existing
independent fixed-result controls; it is not a full-compiler scalability test.
The191,922-byte prefix parses successfully, but is not established dependency-
closed and makes no checking/emission claim.

Clean-transpiled variants and counted variants produce exactly the original
complete C bytes for all four programs. Loaded/checked event-order, name/kind,
constructor and erased-body summaries also agree. These summary checks do not
prove arbitrary internal semantic equivalence; exact emitted products add an
independent practical gate.

Do **not** divide these subtotals into our native request or JS-hosted observer
numbers. Upstream reads and checks Base source; our ordinary compiler decodes a
prepared Base. Upstream emits C while ours emits QBE, with different analyses,
text volumes and machine-build stages. Both engines also have fresh-process/JIT
costs. The separate same-Bend-source QBE-versus-JS experiment addresses execution
backend cost; this table compares a different compiler implementation.

## The work we can now distinguish

| Complete input | Body checks / distinct checked names | Runtime bodies available after checking | WNF entries / internal focus steps during checking | C-emission fact rounds |
| --- | ---: | ---: | ---: | ---: |
| Lexer |374 /374|374|55,008 /74,398|2|
| Closures256 |352 /352|352|53,740 /72,947|2|
| Map128 |352 /352|352|53,897 /73,097|3|
| Compiler index slice |396 /396|396|60,624 /80,025|5|

All figures include Base. On these inputs each observed definition body is
checked once by name, and its checked runtime body appears directly as `Def.e`.
`term_lower` has **zero observed entries during checking** in all four cases.
This agrees with the source: `def_check` returns `term_check(...).tm`, published
as `tld.e`; `fun_of` later raises that product and memoizes the resulting function
facts. It is evidence for keeping a useful checked product instead of rebuilding
one, **not proof that our annotation/layout/erasure gates can be deleted**.
Our representation and final native verification have additional contracts.

Normalization is not a single constant-cost operation. For Lexer,55,008 WNF
entries execute74,398 internal focus dispatches. Checking also enters
`term_higher`62,625 times. During emission it enters22,407 times on3,163 distinct
input object identities. Reuse across different binder environments can be
necessary: identical input-object identity does not establish an identical
conversion result or justify memoization without the environment.

Upstream emission discovers facts in multiple rounds. The index slice's
`[owned,hot,static]` progression is:

```text
[0,0,0] → [65,0,4] → [70,23,4] → [72,23,4] → [74,23,4] → stable
```

Each round re-emits before testing stability. Map similarly takes three rounds;
Lexer and closures take two. Thus an observation of one `compile_book` call
would miss real repeated work. Avoid calling upstream's whole pipeline one-pass.
These rounds are part of its semantics/optimization strategy, not demonstrated
waste that can simply be omitted.

The backend memo evidence also differs by computation:

| Input | Memo hits / total | Memo-cache clears | `emit_body` entries | `file_push` text units |
| --- | ---: | ---: | ---: | ---: |
| Lexer |12,408 /30,806|106|878|44,725|
| Closures256 |1,592 /3,753|37|142|11,592|
| Map128 |48,056 /87,528|233|3,957|437,043|
| Compiler index slice |196,338 /312,900|465|5,830|637,619|

The clear count is calls to `memo_gc`, not a count of all cleared entries.
Its source clears selected temporary term caches while retaining other function/
layout/dependency facts in `FL`. The hit aggregate combines several memo tables;
it does not identify one missing cache or establish a benefit from retaining
all temporaries. Text units are UTF-16 units passed into statement accumulation,
including repeated emission, not allocated bytes or final file size.

## What this changes about the next experiment

The most promising question is whether our checked/annotated producer can hand
one compact, context-qualified product to several native consumers, preserving
local IDs and immutable schema without repeated wide-record/string work. The
upstream source demonstrates such producer-product and memo boundaries are
useful design choices. The observations also show that having more than one
pass is compatible with good compiler throughput; pass count alone is the wrong
objective.

A cheap decisive experiment remains one complete real producer→verifier→consumer
path, charged for conversion, joins, errors and teardown, with the independent
final verifier intact. Join our actual operation counts on these same inputs
before attributing the gap to redundant algorithms. Compare counts only where
semantic boundaries agree. The prior11.06% compact-verifier slice is insufficient
to infer a major whole-compiler gain.

The counters are intentionally diagnostic. They add function wrappers, WeakSet
identity probes, clock calls and a second lookup to observe memo hits. Counted
compiler-action time is1.57–1.73× its clean-transpiled counterpart on complete
programs, and1.46× on the prefix. This is not a neutral profiler and those clocks
are not used as compiler speed results. No new performance optimization, broad
conformance result, upstream parity ratio or default-selection change is claimed.

## Exact full cold-input loader extension

The optional extension also passed. On the exact frozen Phase142 source
`15f5cada…7dac1` (2,946,225 bytes), original upstream **`book_load` takes2.583s**;
the whole original observer takes3.204s and its guard3.269s. The counted artifact
loads in5.023s (whole observer6.004s, guard6.065s). Peak observed child RSS is
370.5MB original and427.4MB counted. The
[pinned two-variant summary](../../selfhost/build/phase145/upstream-full-parse01/summary02.json)
authenticates both successful receipts and the prefix comparison. No checking,
erasure or emission occurred, and all loaded summaries agree.

This is **loading and parsing with import/header processing, name resolution,
declaration construction and parser representation conversions**, not raw syntax
or tokenization alone. `parse_book` is entered exactly twice in both observations:
once for the same pinned75,064-byte Base and once for the requested source. The
counters aggregate those calls; exact Base-only and user-only operation totals
were not separately collected. Source bytes grow15.35× over the earlier prefix,
but total source-plus-Base bytes grow11.32×. Loaded event count grows5.55×, and
original loader time grows8.38×. These differing denominators matter.

| Loader work | Prefix1024 | Full frozen input | Full/prefix |
| --- | ---: | ---: | ---: |
| Loaded events |1,520|8,436|5.55×|
| `parse_def` entries |626|7,300|11.66×|
| `parse_term` entries |20,741|282,045|13.60×|
| `term_lower` entries |25,553|909,338|35.59×|
| `term_higher` entries |52,189|3,680,893|70.53×|
| Distinct objects passed to `term_higher` |42,330|1,688,169|39.88×|

The full program is structurally different, not just a longer list of the same
small declarations. Higher/lower conversion work grows much faster than
parser-entry counts. `term_higher` revisits input identities in54.14% of full
entries versus18.89% for the prefix; its binder environment still matters, so
these are not automatically duplicate results. The prefix was extracted from
final03 source, while the full input is frozen Phase142; this is not a controlled
size-only series or an asymptotic complexity proof. No linear scaling claim is
made.

The retained Phase144 selected native parser proxy, using its older atomic
reference-count runtime, reported31.175s on this same
frozen full input, making the2.583s upstream loader a valuable **scope-audit and
representation discriminator**. It does not establish a12× drop-in parser fix:
our additional lexical/context construction, completion/freshening and validation
contracts differ, and the producer,
runtime and observation boundaries require their own accounting. Nevertheless,
this is stronger motivation to examine the complete frontend boundary than to
infer performance from source length or tiny fixtures. The separate architecture
contract audit determines what work must remain. Improving one roughly31-second
component alone cannot explain a50-second complete build.

The original and counted extension add9.334 guarded seconds. They reuse the same
instrumentation and leave all earlier measurements intact. Counts nearly double
this full loader's observed time, reinforcing the separation of diagnostic work
counts from clean compiler timings.

Observer wording correction: the generic worker's frozen `scope` sentence says
"Base loaded and checked every request". That wording is inaccurate for both
parse-only cases. Their actual `mode`, control flow, timing keys and zero
`erasedBodies` show Base was **loaded and parsed, never checked**. Original
receipts remain unchanged; the extension summary's explicit no-checking scope
is authoritative. The historical parser contrast is not attributable solely to
String representation, and it does not isolate the atomic/serial runtime change.
