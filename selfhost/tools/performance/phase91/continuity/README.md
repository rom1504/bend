# Current-release JS23 and C12 continuity

This closes the identity gap between the current compiler07 release and the
artifacts used for the last actual generated-program timings. It is separate
from compiler-host performance and does not execute or time generated programs.

- JavaScript: 23 exact modules representing all 45 Phase66 observer points.
- C: the twelve actual Phase78 batch fixtures, rather than the separate 45
  catalog wrappers used by Phase90's broader preprocessing check.
- Roles: the current checked/equality-derived B1 and genuine self-emitted B2.

Preparation reads and authenticates files only:

```sh
python3 -B selfhost/tools/performance/phase91/continuity/prepare.py \
  selfhost/build/phase91/continuity01
```

Use a fresh output directory. The resulting `commands.json` contains two serial
guarded commands, B1 then B2. Root alone executes these commands under the shared
target lock. Each has a 180-second deadline, 2-GiB process-tree RSS limit, 4-GiB
available-memory floor, CPU3 affinity, 1-GiB Node heap and 4-MiB stack. No project
copy, compiler rebuild or object build is required. The existing frozen project
is reused, with only its API-specific prepared cache allowed to be produced by
the ordinary driver. The recorded installed-release files remain unchanged.

The worker accepts `PLAN ROLE FRESH_OUT [both|js|c]`; `both` is the default. A
subset remains explicitly labeled and cannot count as completion of the whole
gate. The frozen plan's commands select `both`. Each output row is written
immediately to `report.json`; complete successful qualification requires 35
matching rows per role, 70 total.

## Comparison boundary

JavaScript is compared byte-for-byte with Phase66's qualified raw modules.
Base, legacy runtime and direct runtime identities are also required to match
the earlier successful Phase82 continuity join.

C uses the original historical `-std=c11 -O3` flags, the exact Clang executable
and include directory, followed by `-x c -E -P -fminimize-whitespace -H -`.
Both source versions enter through fresh read-only regular-file descriptors at
offset zero and the same `<stdin>` filename. Output and stderr also use regular
file descriptors, avoiding the earlier sandbox pipe failure. Environment,
working directory and prebound system headers match. Child failures and unknown
headers fail the comparison; they are not ignored.

There is no custom whitespace stripper, C lexer, string replacement, discarded
function or ignored foreign block in the actual comparison. Every preprocessor
output byte must match. Preparation separately proves that both known runtime
edits can be applied exactly once to each old C oracle. All old/current FID
tables must stay below the 4096-entry accessor boundary. Final indentation and
the inactive optimized runtime changes are the expected differences, not an
allowance to accept other changes. The historical 163 observed headers plus
`sys/stat.h` and nine literal include dependencies are pinned before targets.

This proves scoped optimized CPU preprocessing continuity. It does not assert
fresh execution timings, identical ELF binaries, GPU behavior or universal
conformance. Use the original dated runtime ratios with that qualification;
do not substitute the six-source compiler-request score.

## Disk and evidence

The old raw JS modules total 1.03 MB and the twelve C oracles total 4.56 MB.
Current outputs for both roles should therefore occupy about 11 MB. Matching
temporary preprocessor files are fully compared, hashed and removed; their
identities and header observations remain in the report. A mismatching pair is
retained. Each preprocessor output is checked against a 16-MiB bound after the
child returns, and the outer guard also limits resources. Preparation requires
64 MiB free. No historical files are deleted.

Offline preflight `continuity01` passed with 813 bound inputs, 173 headers,
23 JS sources and 12 C sources. Its plan SHA is
`b1af8a22d2143eeedc00ea91790d765da2d72a9326c803f46286917fe9bea18d`.
This preflight did not import a compiler or run Clang. Actual outcomes belong
to the later guarded worker reports.
