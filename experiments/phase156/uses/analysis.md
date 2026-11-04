# Phase156 uses transfer: machine audit

**Follow-up timing correction:** the later `map02` uses two balanced rounds in
the existing image: uses median2.695297s, original2.691808s, ratio1.00130×.
The pilot's11.6% slowdown did not repeat. The static overhead below is real,
but it does not establish a stable request regression. Neither run demonstrates
a useful complete-request gain from sharing. All four follow-up outputs match
the independent oracle exactly. No new candidate image was built.

**The guard adds real work, but there is no observed loss of direct-worker
admission.** Both versions were already scheduled generic functions. Removing
the guard is a justified, small discriminator; it is not an established remedy
for the Map regression. No source replacement, target run or rebuild was made
for this audit.

The coordinator's single pilot observations are checker645 old23.670s versus
uses23.568s (effectively neutral), and Map old2.697s versus uses3.011s
(11.6% longer). All eight mode/workload outputs match the qualified original.
One observation per role does not establish repeatability or attribute that
entire difference to one helper. Publication/both results do not improve the
case for promotion.

## Identity and actual entry paths

Inspected frozen source:
`selfhost/build/phase156/request-prepare01/compiler.bend`, 1,565,433 bytes,
SHA256 `6020f680fd96e59b5a629e3ba898aacfc7f85895e9b2b22f3f1426084f656ce3`.
Original clone begins at line40303; candidate begins at39731. The original uses
its original ancestor lowerer, as required. The native build receipt pins image
`3d6c7ec0acf162bc5872358c9ccdbad42af3d9ada45a4dc59ceb1b3bf36ad7f9`.

Independently rehashed the retained products:

- `native/program.ssa`: 109,340,121 bytes,
  `2d247e0da4223b2dbc4f6d92441ba5c5883fe5ea5af206ba4d25212db2fbdee9`.
- `native/program.s`: 78,812,329 bytes,
  `4b309ee263eacf01333a7258646e3c2f31915a7a3688db7d1120b6a63967df4b`.

Decoded `FID_` symbol spellings and the emitted `$p111_segments` table to identify
runtime jump targets. Neither owner has a `p113d` direct native worker or a named
borrowed worker. Both have a generic `$direct` entry plus currying/continuation
segments. The eight-argument source also exceeds the ordinary observer-plan
four-argument gate. The two actual entries, SSA1323481/1460792 and
assembly1434462/1581978, each have89 SSA lines,66 assembly lines and4,136 bytes
of machine stack. Both call keep, the same `ix` worker, and runtime jump. The
instruction structure is the same after renaming IDs.

## Guard and lifetime evidence

The original continuation `$p111.k.1480436` (SSA1324015, assembly1434909) jumps
unconditionally to segment26297, `$direct.nc_uses`, before continuation
`$p111.k.1480463` jumps to `$direct.p111_keep`. There is no environment or
value-environment test on this route. Thus the original **does evaluate the
use-set eagerly**, even when keep's environment will be empty. A later original
continuation calls `nc_live_env` and rebuilds the set only for nonempty `env`.

The candidate guard is fused into `$p111.k.1705673` (SSA1461326,
assembly1582425): it calls `$direct.List.is_empty`, tests the two Boolean tags,
then either returns `NU_Empty` or jumps to that same `nc_uses` segment. It does
not allocate a new branch closure on the ordinary valid path.

| Local continuation | Old | Guarded candidate |
| --- | ---: | ---: |
| Before use-set production, assembly lines |94|131|
| Machine stack bytes |2,088|4,136|
| Keep callsites in that continuation |1|2|
| Conditional jumps |0|2|

After production, candidate `$p111.k.1705674` (SSA1461485,
assembly1582561) keeps the returned set, retains it in the continuation frame,
and passes it to `p111_keep`; later `$p111.k.1705687` passes it to
`nc_live_uses`. The corresponding old immediate keep consumer has21 assembly
lines; the new one has97, including its additional frame transport and keep.
The set now survives across both consumers instead of being independently
constructed for each. This lifetime cost is separate from the empty-env guard.

The source-owner groups contain28 versus30 generic segments, but not every
segment runs on the direct-entry path. In particular, the extra runtime `apply`
is reached through the malformed-Boolean failure fallback, not ordinary
False/True evaluation. Counting it as a per-binding closure cost would be
incorrect. All these counts are static evidence, not execution frequencies or
an allocation/time attribution. The inspected assembly still leaves the actual
Map call frequency and cost distribution unknown.

## Smallest next discriminator

An unconditional local `+uses = nc_uses(body)` is semantically safe relative to
the original eager route. It retains the original one scan for empty `env`,
replaces two identical scans with one for nonempty `env`, and lets
`nc_live_uses([],uses)` return immediately. It does not preserve the guarded
candidate's extra zero-scan optimization for empty environments. No source
validation, shape/bindability check, substitution, diagnostic order or final
verifier should change. The retained set and associated ownership transport
would still exist, so eliminating the guard need not recover the kernel ratio.

First use the existing11 controls, including five complete local bindings, to
compare original/guarded/unconditional results in every `P113DCode` field. For
a genuine actual-binding performance witness, retain a bounded set of complete
`book,value,body,env,id,target,n,shape` argument tuples from the checked Map
lowering; preserve empty/nonempty environments and small bodies, and observe
all statements/fresh counters/errors/calls after each complete invocation.
Do not reuse the large synthetic use-set-only workload as transfer evidence.

If obtaining those tuples would require a new instrumentation project, the
cheaper immediate check is a reversed ordinary Map pair with the existing
image. Only a repeated regression justifies acquiring an unconditional variant
for the same complete requests and exact QBE oracle. A new full compiler image
or broad runtime qualification is not justified by this source/machine audit.
