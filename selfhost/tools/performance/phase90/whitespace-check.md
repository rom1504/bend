# Four-case CPU C whitespace qualification

Use `whitespace-check-v2.mjs` after a checked equality-profile B1 acquisition.
The offline preflight against `compiler06/attempt.json` passed and recorded 505
input identities in `build/phase90/whitespace-preflight02/report.json`. That
preflight does not import or execute the generated compiler and does not run
Clang. It is not a target qualification.

The actual runner loads the selected checked B1, prepares its own API-specific
Base state, then emits Small, closed Map, Unicode and file IO sequentially in
one process. It retains each raw C file/hash. Each reference is an existing
independent B2 result: where the historical original was archived, the runner
uses the retained native-gates01 copy only after checking its entire byte count
and SHA against the original B2 receipt. References are never regenerated.

For each pair it sends the complete baseline/current C through stdin to the
same Clang executable, working directory and command:

```text
clang -isystem LEAN_INCLUDE -x c -E -P -fminimize-whitespace -H -
```

Both inputs have the same `<stdin>` filename and default host CPU macros. `-H`
records included headers in stderr; header identities are held unchanged after
the first observation. Full minimized stdout bytes must match, not just a token
count or syntactic summary. Child status, signal, stdout/stderr pins, headers
and stdin identity are recorded per pair. Child preprocessing has a 30-second
timeout. Run the entire Node/Clang process tree under the Phase86 external guard;
there are no nested guards or benchmark-clock claims.

From the repository root, root may execute the frozen command plan
`whitespace-commands.json` using `run-commands.py`, or its one command directly.
The target directories `build/phase90/whitespace01` and `whitespace01-guard` must
not already exist. Completion requires all four full preprocessed comparisons,
unchanged frozen inputs, and the outer guard's successful process receipt.
`checkOnly`/`executionPerformed:false` reports are never admissible target proof.

The proof kind is `phase90-checked-b1-cpu-preprocessed-c-equality`. Each row has
`name`, `source`, `oracleReceipt`, `baseline`, `current`, `rawEqual`,
`preprocess.{baseline,current}`, and `exactPreprocessed`. Producer, nine effects,
native runtime/template and frozen method are explicitly pinned. A later native
image gate can require this completed proof, authenticate its outer guard and
then demand exact full C equality to each **new** `current` file in all live and
cached requests. This does not weaken any historical exact-C gate.

The scope is these four source-level programs under default CPU preprocessing.
It does not admit arbitrary raw N_Segment bodies (backslash-newline text can
change meaning), device preprocessing, compiled execution or performance.
After this screen, root can run selected executable controls and extend the
same retained-oracle method to the broad 45 set. The B1 definition change
`nt_indent(body)` to `body` intentionally changes raw C formatting; all raw
hash differences remain visible.

`whitespace-check.mjs` and preflight01 are retained unrun draft-method evidence;
v2 adds explicit effect/runtime bindings and identical preprocessing commands.

## Actual v2 failure and v3 transport revision

Root ran `whitespace01`: the first 93,941-byte Small baseline preprocessing
reached the 30-second timeout with empty stdout and stderr. The run failed and
is preserved; no token equality or candidate failure was inferred. Its
`spawnSync(input: Buffer, stdio: ['pipe', ...])` combination is a valid Node API,
so the observed timeout alone does not prove the underlying cause.

Fresh `whitespace-check-v3.mjs` removes that parent-to-child pipe. It opens the
already pinned C file read-only at offset zero and passes the FD as child stdin,
with regular-file stdout/stderr captures. Clang still receives `-`; baseline
and current still share `<stdin>`, argv, cwd, timeout and full byte-equality
requirements. The report records the transport and pins both v2 and its failed
report. No timeout was increased and no gate was relaxed.

Use `whitespace-commands-v3.json` for the fresh `whitespace02` and
`whitespace02-guard` run. Offline preflight03 passed against the actual inputs;
this is not evidence that the new transport has executed successfully. The
native-oracle admission helper must bind the v3 method SHA
`b916bef1c3daf337b4bc7d133407b5f02104209789abf8ea1393c56299c59f50`.
