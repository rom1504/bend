# JavaScript self-hosting stack investigation

The first snapshot08 B3 attempt (`js-b301`) passed fresh own-source checking,
specialization, ownership, reachability and layout, then failed during
`public-library-emission` with `RangeError: Maximum call stack size exceeded`.
It did not produce a B3 image or establish byte equality. Its original failure
receipt and progress log remain in `evidence/`.

The generated call path is `jd_plan_library → jd_exports → jd_host_exports →
j_io_type → j_io_shadow → book_put → index_put_rest → index_remove`.
`jd_host_exports` retains concatenation frames for preceding definitions;
`index_remove` recursively reconstructs the nonmatching book suffix. These
stack costs compose. The critical generated helpers match the installed
Phase174 B2 after local identifier normalization. This is evidence against a
new lowering error, not proof that every call or input is equivalent.

The diagnostic in `selfhost/tests/phase182/js-export-stack.mjs` imports the
actual B2's public exports, without editing the image. It first checks eight
independent complete-value/order removal cases and two path controls, then
varies synthetic book length and skipped-export prefix independently. These
aggregate fixtures are diagnostic inputs, not checked Bend source programs.
Catching an overflow records a limitation; it never qualifies self-hosting.

## Explicit host policy

The pinned Bun is 1.4.3, revision `c6da4a4d3010e5553438c60f6bd76d981976867c`.
Its [WebKit pin](https://github.com/oven-sh/bun/blob/c6da4a4d3010e5553438c60f6bd76d981976867c/scripts/build/deps/webkit.ts#L6)
selects `0c06faadf65bf8e8c8ad3a5a8aca83e1e9ed653f`, whose
[stack defaults](https://github.com/oven-sh/WebKit/blob/0c06faadf65bf8e8c8ad3a5a8aca83e1e9ed653f/Source/JavaScriptCore/runtime/OptionsList.h#L129)
set a 5 MiB JavaScript cap. The OS soft stack limit in this campaign is 8 MiB.
A separate diagnostic requests a bounded 7 MiB cap through
`BUN_JSC_maxPerThreadStackUsage=7340032`, retaining the accepted option dump.
Neither OS limits nor reserved zones are changed.

Bun accepts these settings in
[JSCInitialize](https://github.com/oven-sh/bun/blob/c6da4a4d3010e5553438c60f6bd76d981976867c/src/jsc/bindings/ZigGlobalObject.cpp#L373)
and explicitly labels them an
[unstable debugging interface](https://github.com/oven-sh/bun/blob/c6da4a4d3010e5553438c60f6bd76d981976867c/src/jsc/lib.rs#L515).
This is an explicit policy for this exact pinned host, not a portable Bun API,
compiler optimization, or automatic operational override. Ordinary program
qualification continues at the default host setting. A successful larger-stack
B3 run would qualify self-reproduction only under that recorded resource policy.

## Results

Both 34-observation diagnostic matrices completed with all ten small oracles
passing and no unexpected exceptions. At the default cap, removing IO from a
12,288-row book overflowed even without export-prefix frames. At 7 MiB that
filter returned in order, and the combined path also returned with a 2,048-row
export prefix. Prefixes 4,271 and 4,290 still overflowed on that deliberately
large synthetic book. The cap increases capacity; it does not make recursion
stack-safe. See [default evidence](evidence/js-stack-default02.json),
[7 MiB evidence](evidence/js-stack-7m02.json), and the
[accepted option dump](evidence/js-stack-7m02-options.txt).

The complete [same-source B3 retry](evidence/js-b302.json) passes in
351.802s with fresh source checking and complete B2/B3 byte equality. The
[guard receipt](evidence/js-b302-guard.json) records the exact explicit environment
argument, pinned command inputs, CPU and resource bounds. The source and B2 image
are unchanged. This establishes self-reproduction under that host policy;
it does not establish stack safety for arbitrarily large inputs.

Reproduce under the ordinary outer guard, using the exact source, Base and B2
receipt recorded in that report:

```sh
env BUN_JSC_maxPerThreadStackUsage=7340032 selfhost/.assets/bin/bun \
  selfhost/tools/build/js-bootstrap.mjs \
  --generator selfhost/build/phase182/js-b203/api.mjs \
  --generator-report selfhost/build/phase182/js-b203/report.json \
  --source selfhost/build/phase182/snapshot08/compiler.bend \
  --base selfhost/.bootstrap/upstream-phase182/bend2/base.bend \
  --out selfhost/build/phase182/FRESH_B3 \
  --compare selfhost/build/phase182/js-b203/api.mjs
```


## Follow-up

The narrow source remedy to investigate separately is tail iteration over
export rows, collecting chunks in reverse and finishing in original order.
It would remove export-prefix stack growth while preserving per-row decisions.
Hoisting the immutable IO shadow could also remove repeated full-book filtering,
but changes more than stack capacity. Neither transformation is part of the
current migration or its qualified native source.
