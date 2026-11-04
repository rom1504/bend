# Static audit of the first bendc-built complete request failure

The retained C contains a concrete wrong field projection on the path to the
reported error. This gives a much narrower falsifier than changing allocation
or effect policy: re-emit once with **`BEND_UNBOX=0`**, preserving all other
source, optimizer, runtime, effect-adapter and Clang choices. Do not time this
image until the ordinary complete-output gate passes.

Evidence identities:

- C: `selfhost/build/phase160/request-c01/program.c`, 6,641,678 bytes,
  SHA256 `3ebcaf04eea2c3fc4c7a33d9deec2b90751878941dcf94feac73b4074f1eb649`.
- Executable: same directory `program`, SHA256
  `7bcf47ca6497572a80bf9e268ddddb7b11062cb98876b78bc2616f756407e154`.
- Failure: `selfhost/build/phase160/map01/report.json` and `c/stderr`;
  exit 1, empty stdout, no qualified QBE product. The 160-byte diagnostic has
  SHA256 `01335c93eb4325589190c6485c011382965cb55eebcc38f222ac2168f8ce8a2a`.
  Its prefix is `array native lowering: ` followed by invalid-looking text.
- The C emission was independently source-admitted but bendc-checking-disabled;
  its root receipt is `capped-request01/report.json`. The private capped-runtime
  seed reproduced its own C exactly, which does not establish correctness on
  every other source.

## The exact wrong-field chain

The common Bend source declares these ordinary records
(`request-prepare01/compiler.bend:26180`, `:35799`):

```text
P113DProgram { original: P112StaticProgram, functions: List<P113DFunction> }
P113DLowered { program: P113DProgram, error: String }
P128RawLowering { lowered: P113DLowering, raw: List<P113DCandidate> }
```

`p128raw_session_finish` passes its `lowered` value to
`p114s_open_lowered`. That function preserves the **outer error string** in
`P114SLowered`; it checks whether that string is empty before choosing the
opened/unchecked boundary. Source: `:35872`, `:29721`.

The original source call is:

```bend
def p128raw_session_finish(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p146c_finish(request,certificate,raw,
        p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(lowered))))
```

`p114s_open_lowered` matches `P113DLowered{+program,+error}` and constructs
`P114SLowered{...,error}`. No source operation substitutes the program's function
list for that error. The independent spanless-parser equivalence gate also
retains both record fields and this call; the diagnostic is reached after a
backend representation error, not evidence that our source checker/lowering
algorithm rejected the input correctly.

At C `:99640`, the generated caller receives `P128RawLowering` from
`U_p156o__p128raw__lower__request_x37u`. It projects that result's `lowered`
record into the session worker's arguments `a7=program`, `a8=error`, `a9=raw`.
The worker then does the following at `:99658–99664`:

```c
V s38758 = a7;                     /* program */
V s38759 = a8;                     /* error */
V v38761 = C2(0, s38758, s38759);  /* P113DLowered */
V v38762 = v38761;
V v38763 = FLD(v38762, 0);        /* P113DProgram */
V uo38764[2];
U_p114s__open__lowered_x37u_x37u(
  FLD(v38763, 0),                 /* original */
  FLD(v38763, 1),                 /* functions */
  FLD(v38763, 1),                 /* WRONG: functions again, not error */
  uo38764);
```

The third argument must carry `s38759`, equivalently `FLD(v38762,1)` under
this reconstruction. The generated callee at `:133585` explicitly treats its
third parameter `a2` as a String: it checks its Nil/Con shape and returns it
unchanged in `o[1]`, the error slot. Thus the emitted code passes a
`List<P113DFunction>` where the source supplies `String`.

The value flows through `p114s_inline_lowered`/`p114s_ranges_lowered`,
`p146c_finish`, and `p146c_closed` to `p128raw_lowered`. The last function adds
the observed prefix at C `:99757–99776`, using `F_String_dappend` on that
misprojected value. List Cons and String SCon both use tag 1 here, so a list of
function records can pass the outer shape check while its elements are consumed
as character words. This is consistent with the exact garbled diagnostic.
It does not require assuming a file-effect registration or GC corruption.

The argument mismatch is statically established. The exact internal bendc
transformation that first introduced it is not established by this audit;
the observed wrong projection might be one of several defects in this image.

## Why the one-flag ablation is justified

Current bendc documents `BEND_UNBOX=0` at `bendc.bend:11155` and decodes it at
`:15361`. `Gen.program` (`:26462`) conditionally runs scalar-sum rewriting,
nested-record rewriting, **two** `Unb.program` rounds and `Unb.sret`; all share
this flag. The generated `%u%u` workers above are the concrete result of that
unboxed calling path. `Unb.cargs`/`Unb.call.fin` (`:12108`) open constructor
arguments into worker parameters; `Unb.known` (`:11964`) rewrites reconstructed
records and matches. This makes the flag a direct test of the failing boundary,
although it is not a single-pass localization.

Removing `w`/`h` from `BEND_OPT` is less directly supported. The involved records
have two pointer-shaped fields, not one U32 payload; the headerless eligibility
requires a sum with other constructors, unlike these one-constructor records.
The relevant C uses ordinary `C2`/`FLD`, with the wrong **source object** selected
for the third argument. The runtime's `FLD(v,i)` is the ordinary field access
`((V*)v)[i+1]` (`refill-prepare01/bendrt.h:116`).

The private runtime differs from the pinned header in one GC candidate-search
loop condition, bounded at 64 nonshared words. That change and the exact effect
adapter remain separate qualification limits, but neither can repair this
statically wrong C argument. Keep them fixed for the ablation.

Root's bounded next step: re-emit the same normalized source with
`BEND_UNBOX=0`, inspect the corresponding session/open call before machine work,
then build under the existing cap and retry the unchanged complete Map oracle.
With that flag, these `%u`/`%u%u` argument workers and `Unb.sret` return wrappers
should disappear. An uninlined `p114s_open_lowered` takes the one boxed
`P113DLowered` value; its `error` must be field 1 of that outer record. Ordinary
inlining/DPS may still alter the exact C spelling, so verify the field flow
rather than requiring one textual function name. No generated-C repair is
proposed.
If admitted, require all 1,028,598 expected QBE bytes, SHA256
`eba759e043db9d1dcb5883e51c2120d99e103cac70e334fa327da1458d7f7fda`, plus the
independent refusal/output controls before a full-source request. If it still
fails, retain this counterexample and stop the full cohort; the complete parser
fallback is more economical than a broad compatibility project. An unboxed-off
timing would describe that explicit execution policy, not default bendc speed.

No compiler, build, benchmark, failure probe, or production edit was performed
for this audit.
