# Independent review of private worker lexical scope

Decision: **GO for the scoped correction**, subject to the separate full-source and frontend integration gates. The old private image's `F is not defined` is a real compiler regression: hoisting a generated function outside its block loses its captured split-worker table. This review does not reinterpret that failed compile as successful.

The corrected [call transform](../../selfhost/tools/private-compiler/calls.mjs) only hoists a generated `G=fn` declaration whose line begins at zero delimiter depth after the reviewed runtime boundary. Block-contained declarations retain their original closure and cannot become private-call targets. Ordinary and tail callers therefore use the original `call`/`jump` path for those functions. The trampoline and all other worker bodies are unchanged.

The scanner skips quoted strings and comments, counts line changes, validates matching parentheses/brackets/braces and rejects unterminated scopes, comments, strings, template literals or unsupported slash syntax. It is deliberately limited to the actual emitter grammar, not a general JavaScript parser. The runtime-end sentinel must be unique; the production builder separately checks the complete runtime identity. Quoted `F` text in generated-code strings does not imply a captured binding.

A mixed top-level/block-scoped duplicate assignment could otherwise leave a stale eligible worker. Following review, the transform now rejects duplicate generated global names before worker selection, including that mixed-scope case. This is conservative refusal, not replacement of JavaScript's general rebinding semantics. The closed compiler image still assumes its generated `G`, `get`, `call` and runtime bindings are not shadowed or mutated by arbitrary injected JavaScript.

## Independent checks

CPU3, correctness only; no benchmark claim:

```sh
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/private-compiler/transform.test.mjs

taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase4/private-scope-review.mjs \
  selfhost/build/phase4/combined-fixedpoint/stage2.mjs NEW_DIRECTORY
```

All **9 unit tests** passed, including captured `F` and a differently named local, ordinary/tail callers, quoted/comment braces, unknown/unbalanced syntax refusal, mixed-scope duplicates, partial/overapplication and 100,000 tail calls. See [captured test output](evidence/private-scope-review-tests.log).

The independent [actual-worker probe](../../selfhost/tools/performance/phase4/private-scope-review.mjs) passed **14 exact observations** against the public checked H: `j_escape` on plain, control, quote, backslash, combined and Unicode strings; `nb_fork_close` through a generated caller at fuel 0, 1, 2, 32 and 255. The candidate excludes exactly `nb_fork_close` and `j_escape_char_on` from hoisting. The unchanged actual function bodies come from H `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`; only the test caller/export roots differ. [Compact report](evidence/private-scope-review.json.gz) records source, transform and disposable image identities. This small gate exercises the failure mechanism directly; it does not compile a whole source program.

The first independent probe accidentally inserted its test caller into quoted emitter text because its insertion was not line-anchored. The new scanner correctly refused the malformed string. That failed harness attempt is retained in [its log](evidence/private-scope-review-rejected-harness.log); only the test insertion anchor was corrected before the successful second attempt. No production changes were made by this reviewer.
