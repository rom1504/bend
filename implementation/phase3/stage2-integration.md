# Stage2 selected integration gate

The actual self-emitted Stage2 API passed six selected integration routes on
CPU 0 with the frozen final host and canonical pinned Base:

| Route | Result |
| --- | --- |
| Base program check | Accepted and checked |
| Interpreter | `42` |
| Generated JavaScript execution | `42` |
| Generated C, Clang 16 compilation and native execution | `42` |
| Invalid type | Exact checked-B1 diagnostic, rejected in `check` |
| Erased dependent argument/native context | Exact checked-B1 C bytes; native execution `Yes{}` |

API SHA-256 is `360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de`;
runtime SHA-256 is `26f5eee2f54b194b64f768df6ff505c67bf7a5df2159aa06caf53ecba54e910b`.
The frozen host is `2b692463e833d36a96edba2adf3ceb53b7f1432dbcb42803ddebb779d7df1749`.
These results exercise provisional Stage2 directly; they do not assert that the
independently running Stage3 fixed-point proof has completed.

The small runner follows the existing `tools/smoke.mjs` routes and retains native
C and executable hashes. Native compilation uses the unchanged frozen host's
`buildNative` with actual Clang 16. The invalid diagnostic is exactly
`Error:\n- expected : Bit\n- observed : Type\nLocation: main` in both B1 and Stage2.
All consumed compiler, source, host-helper and native-runtime hashes were
rechecked after the tests.

The extra dependent fixture initially omitted Base because it came from a
component-only test. The ordinary host correctly rejected that form with
`Error: a build needs import Base`. The original failed assertion is retained;
a separate fixture with `import Base` passed the final control. No compiler code
was changed. [Archived evidence](evidence/stage2-integration.json) includes both
attempts, exact runner sources, fixture inputs, diagnostics, tool hashes, resource
settings and supervision details. Raw C and executables remain under
`selfhost/build/phase3/stage2-integration*`.
