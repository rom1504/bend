# Independent audit: scoped scalar permission

Audited baseline: exact Phase98 selected source
`2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
Root's minimal successor `scalars-source02` is
`7520f6ef07ed3b955bc2d6dea1d6fde5b3fa45fdb18f950b124fd5cb8aac1492`.
The separate SCon refinement `scalars-source03` is
`38c4031361efb1cde82c724ae095d97f76a8dabf3350f024e2176a0afad7adc4`.
This reviewer ran no compiler, generated program or build. The root-run receipts
below now establish focused execution and law results; historical preparation
manifests retain their original unexecuted status. Phase98 artifacts remain
unchanged.

**Neither scalar variant passed the append benefit gate; neither merits a full
compiler build on this evidence.** Each passed 21 complete small-program runs
over ten emission groups. The longer screen measured source02 at
2.2655→2.3267 seconds (1.026991×), and source03 at 2.3023→2.3655 seconds
(1.027434×), with complete outputs in four balanced-order rounds per role.
These are synthetic append/reconstruction whole-process measurements on one CPU,
not compiler-speed results. See the raw [source02 screen](../../selfhost/build/phase99/scalars-micro02/report.json)
and [source03 screen](../../selfhost/build/phase99/scalars-micro03/report.json).

The minimal design is appropriate for a first experiment: the two checked
entries pass `packed || observers` as a separate **typed-local/private-parameter**
permission. The compatibility header wrapper passes its old `packed` value.
Source02 keeps field-width macros, scalar/unshared arrays, cold constructors,
planned-host selection and checked-product admission on their existing
permissions. Source03 additionally enables **only** the trusted Base SCon head
field-width macro under the same scalar permission. It leaves the general
`nh_field_macros` gate on `packed` and does not enable SCon field 1.

Scope erratum: source03's immutable `changes.json` and qualification/emission
receipts inherit a sentence saying fields are unchanged. That sentence is stale:
source03 intentionally changes the SCon field-zero width macro. The exact patch
and generated C establish its actual scope. Arrays, cold constructors and
product-admission rules remain unchanged. Preserve the original receipts and
methods; this correction grants no promotion or broader qualification.

`packed || observers` matters. The old classifier accepts a trusted known foreign
name without the new classifier's filled-`Foreign` requirement. Therefore
`packed => observers` is not an identity on arbitrary supplied KDef lists.
Preserving old permission with OR avoids depending on that additional premise;
both computed inputs remain guarded by `effects_safe`. A new permission must
never independently authenticate a provider by its name.

## Exact consequences and source locations

Locations below refer to the frozen Phase98 source, not shifted candidate lines.

| Site | Consequence when typed scalars becomes 1 |
| --- | --- |
| `nl_c_type`, line 31161 | Existing `N_W32` local and scheduler-entry/capture bindings become `u32` under `!DEVICE`. `N_W64` and `N_Box` remain `Term`. |
| `nf_param_type`, line 33283; `nf_finish_ready`, line 33496 | `NF_SCALAR` private parameters become `u32`; opaque private parameters remain `Term`. Prototype and body generation use the same parameter list. |
| `ns_checked_runtime`, line 35086 | Emits `NATIVE_TYPED_SCALARS`; currently also controls field macros through `packed`. The new helper separates only this one emitted flag. |
| `nc_compile_checked`, line 35074; `nr_compile_prepared`, line 36322 | Both ordinary and prepared checked routes must carry the new permission. Raw entry is not newly entitled to it. |
| `nk_typed_bindings`, line 31190; `nd_extend_arity`, line 33149 | Checked worker kinds are attached to direct-entry bindings; those facts can now affect their C locals. |
| `nf_scalar_kind`, line 33293; `nf_kind_tele`/`nf_worker_kinds`, lines 33304/33319 | Facts come from trusted Base U32/F32/Char/Bool with no unresolved arguments or removed binders. Arity mismatch or exhausted telescope budget remains opaque. |
| `nc_erase_mat`, line 31955; `nh_field_mask`, line 35374 | Existing specialized per-use field masks feed `nc_field_env`/`nk_field_binding` (32592/31197), then captures. This works independently of global field macros. |
| `nh_field_macros`, line 35355; `nh_field_type`, line 35330; `nh_cast_words`, line 35335 | Source02 adds no field flags. Source03 adds only `NATIVE_FIELD32_CID_SCON_0`; that existing field-type/cast template can now use `u32`. The general user-field generator stays on `packed`, and no product-admission rule changes. |

There are three literal `NATIVE_TYPED_SCALARS` occurrences in the source: the
local type template, private parameter macro, and header. The separate
`NATIVE_FIELD32_*` templates must not accidentally be swept into this change.
Heap words, scheduler registers, result arrays and public effect argument arrays
remain full `Term`/`u64`; narrowing occurs at existing typed bindings. Both C
templates retain their `!DEVICE` guard. This does not validate physical GPU
execution, nor permit another target to adopt the checked CPU convention.

## Required trust and ABI premises

1. **Checked, specialized, annotated input.** `nf_scalar_kind` uses the original
   checked telescope; `nc_erase_mat` instantiates the constructor telescope before
   computing field facts. Unknown/dependent types, higher-order or malformed
   telescope tails, missing bodies, arity mismatches and budget failures must
   retain their existing conservative behavior. Do not turn arbitrary Nat into
   `N_W32`. Erased fields must not advance the live-field index. The current field
   mask declines constructors above its eight-field bound.
2. **Authenticated Base and runtime ABI.** The existing constructor emitter at
   line 32490 makes Bool 0/1, Char the complete U32 word, and U32/F32 32-bit words.
   F32 narrowing preserves bits; it is not a C floating-point conversion.
   `native_bool` also accepts a generic tagged True representation, whose high
   bits cannot survive arbitrary `u32` truncation. Newly admitted checked paths
   must use the trusted immediate representation. Unknown/raw paths remain full
   Terms. Structural U32/F32 `Word` reconstruction still allocates through
   `native_word`; changing local width does not authorize borrowed Word views.
3. **Authenticated effects.** Reusing the nine-provider classifier is a bounded
   admission decision, not a new proof of effect implementation correctness.
   Host authentication still pins actual Base, runtime and provider bytes, and
   `effects_safe=false` must disable any new permission. The exact provider names
   remain IO.args/print/print_err/now and File.open/read/size/write/close. Shared
   provider source files do not admit File.read_bytes/read_at/write_bytes or
   arbitrary user-spelled foreign names.
4. **Foreign scalar results agree with Base.** IO.now returns **Nat**, not U32,
   so must remain full-width. IO.args yields strings; printing returns Unit.
   File handles remain opaque full Terms. File.read's maximum and File.size's
   successful result are U32; error codes are U32 and messages are Strings.
   The pinned `file_size.c` rejects sizes beyond `UINT32_MAX` with EOVERFLOW.
   File.read bounds its requested byte count and constructs fresh strings. These
   facts support the proposed scope; they do not license unrelated providers.
5. **Ownership and demand are unchanged.** Do not remove field seals, root
   releases, lazy-branch boundaries, error checks or provider operations as part
   of this permission experiment. Those require different arguments. In
   particular, a correct scalar value theorem cannot prove native evaluation
   order or the runtime's reference-counting protocol.

## Focused execution and actual trust observations

The [source02 qualification](../../selfhost/build/phase99/scalars-small02/report.json)
and [source03 qualification](../../selfhost/build/phase99/scalars-small03/report.json)
both completed with 21 exact complete program outputs and unchanged pinned
inputs. Each includes ten actual emission groups, four additional authority/raw
cases, and 21 compiled-program executions. These counts describe distinct
stages, not 21 independent semantic fixtures.

The emission receipts check both checked entry points, false-permission output
identity, raw permission off, isolated changed-provider rejection, and unknown
provider rejection. The old packed-positive `schema-refusals` case retains
`TYPED_SCALARS=SCALAR_ARRAYS=1` in both roles. Newly scoped IO cases retain
`SCALAR_ARRAYS=UNSHARED_ARRAYS=COLD_USER_CTORS=0`, with only typed scalars raised
(and source03's separate SCon head macro). Forged raw observer-context markers
are inert, and raw residual `NO_Return`/`NO_Loop` nodes retain their existing
rejections. The [source03 emission receipt](../../selfhost/build/phase99/scalars-small03/emission/report.json)
records the actual authority checks, including provider path resolution, active
Base hash and exact provider byte equality.

The standard installed JS driver's permission remains **false** for the
print_err fixtures. These experiments deliberately pass the independently
authenticated permission through the checked APIs built from each exact source;
they do not show a deployed CLI or native compiler image enabling the candidate.
The executed effect fixtures exercise printing. The nine-provider ABI audit
above additionally covers args/files statically; do not report nine native
provider integrations or all qualification groups as tested. Device execution,
generic tagged raw Bool values, and every malformed supplied KDef variant are
not established by these receipts.

## Reusable focused controls

[`fixtures01.json`](../../selfhost/tools/performance/phase99/scalar-controls/fixtures01.json)
pins seven small source derivatives and their exact expected program streams.
They retain historical computations and add `IO.print_err("scalar-control")`,
forcing the old packed certificate off while exercising the newly scoped path.

| Fixture | Main failure it can expose |
| --- | --- |
| `io-char-array` | Byte truncation; Unicode character lost across generic-array get/swap and calls. |
| `io-f32-array` | Treating F32 bits as a numeric integer conversion or breaking generic-array transport. |
| `io-u32-array` | Signed/width error at `0xffffffff`; overflow modulo U32. |
| `io-natural-range` | Illegitimate narrowing of a Nat near the native 48-bit limit. |
| `io-erased-field` | Shifted live-field mask or loss of a captured Nat above 32 bits. |
| `io-generic-array-string` | Accidentally enabling scalar arrays or narrowing a String/alias. |
| `io-dependent-family` | Incorrect assumptions about dependent or specialized field types. |

Every IO fixture expects `TYPED_SCALARS=1` for this candidate and
`SCALAR_ARRAYS=UNSHARED_ARRAYS=COLD_USER_CTORS=0`; baseline expects all four zero.
Program stderr is `scalar-control\n`, separate from compiler diagnostics.
Check exact output and code shape together. Small passing output alone could
come from an unchanged fallback. Reuse the existing complete 1,444-pair String
corpus if the emitted equality path changes, and preserve all failed attempts.

The execution status above supersedes the original preparation status for the
seven fixtures. Missing/untrusted/unfilled KDef variants, device preprocessing
and generic tagged Bool/raw-value controls remain separate obligations before
broader promotion. Changed provider copies must remain isolated; never modify a
pinned provider for a negative. Existing Phase98 provider controls and
source-connected permission laws can be reused after rebinding their evidence.

## Production-connected law preparation

[`kind-laws03/manifest.json`](../../selfhost/tools/performance/phase99/scalar-controls/kind-laws03/manifest.json)
extracts the actual `N_WordKind`, `NC_Binding`, `nk_typed_bindings`, `nl_c_type`
and `nf_param_type` declarations from root's exact `38c40313…` source03 candidate.
Bodies are authenticated as unchanged from Phase98. The only safety adaptation
is omission of leading `@unsafe` annotations; safe admission must still run.
The [preparer](../../selfhost/tools/performance/phase99/scalar-controls/prepare-kind-laws.py)
accepts an explicit source and fresh output directory and runs no targets.

The laws constrain complete ordered binding IDs/names, transmission
of the supplied head kind, and full-Term opaque private parameters. Three
negative helpers respectively corrupt slots, ignore the new kind, and narrow
opaque parameters. Admit each negative without laws before applying the unchanged
law template. Root's [positive receipt](../../selfhost/build/phase99/scalar-laws01/report.json)
records source acceptance, safe elaboration and independent kernel acceptance
with no opaque definitions, plus rejection of the kernel's unequal-label control.
There are five distinct named equalities: four public transport/opaque-parameter
contracts and the `slots_cons` support lemma. They add no theorem about scalar
permission or SCon representation.

The [negative receipt](../../selfhost/build/phase99/scalar-law-negatives01/report.json)
records standalone source admission for all three modified helpers followed by
rejection under the identical laws: `bad-slots` fails
`kind_transport_preserves_slots`; `bad-kind` fails
`kind_transport_preserves_head_kind`; `bad-opaque` fails
`opaque_private_word_stays_term`. These are source-check rejections, not three
additional independent-kernel runs. Earlier `kind-laws01`/`kind-laws02`
preparations remain separate, unexecuted artifacts.

These are useful small transport contracts, not a proof that a supplied scalar
kind is true of its runtime value. The remaining production obligation connects
the checked telescope and per-use mask to the native representation and then to
the narrowing operation. An abstract model or the unchanged Phase98 comparator
law alone cannot discharge that bridge. Provider membership laws constrain the
classifier's decisions, not the ABI of C provider implementations.

## Decision before a full image

The exact `scalars-source02` edits preserve the old compatibility wrapper,
use `packed || observers` at both checked entries, and leave field macros on
`packed`. No additional permission coupling was found in this narrow split.
The focused admission, flags, complete values and intended width mechanism were
tested, but the measured append/continuation screen failed for both candidates.
Keep both as rejected performance experiments. Do not attribute the whole
Phase98 append bucket, or its B1/B2 difference, to scalar narrowing in advance.

## Separate refinement: trusted Base SCon character field

Gating all `nh_field_macros` on scalars would not fix the identified SCon read:
that helper deliberately excludes trusted Base datatypes (`Bool.not(db(d))`).
It would instead widen user field declarations/product casts and broaden the
experiment unnecessarily. A narrower candidate can add only
`NATIVE_FIELD32_CID_SCON_0=1` under checked scalar permission. Existing
`nh_field_test` already includes `!DEVICE`; do not set field 1 or remove that
guard. Raw mode must not acquire the macro.

The [exact ABI audit](../../selfhost/tools/performance/phase99/scalar-controls/scon-abi-audit01.json)
pins the selected source, Base, runtime and provider files and records the
following correspondence:

- Base `Char` is `Chr{value: U32}`. The native `Chr` constructor emits its U32
  argument directly, its field reader is identity, and static `Chr(NWord)` folds
  to that word. Valid arbitrary characters therefore retain all 32 bits, including
  values outside the Unicode scalar range; do not narrow to a byte or assume
  Unicode validation of source-created characters.
- The sole literal `term_ctr(CID_SCON, ...)` construction site in the pinned
  runtime is `io_str`. Its UTF-8 decoder stores the raw bounded codepoint or
  U+FFFD at field zero and seals the tail separately. Runtime-generated error
  and F32-display strings also use this function. The provider files have no
  direct SCon constructor site; args and File.read use `io_str`.
- General generated SCon construction stores the existing character word.
  `rfc_seal` returns that valid 32-bit value unchanged because it has no constructor
  or reference tag. Field zero is not an ownership root. Field one remains an
  arbitrary full pointer/reference and must not be narrowed.
- No admitted checked path producing a generic tagged `Chr` representation was
  found. A user-spelled foreign function or forged raw heap value could violate
  the representation premise, so the exact authentication and checked/raw
  boundary remain necessary. This source/ABI argument is not a theorem about
  arbitrary KDef input or the complete native compiler.

[`scon-full-width01.bend`](../../selfhost/tools/performance/phase99/scalar-controls/scon-full-width01.bend)
adds a focused complete-value witness. It constructs heads `0xffffffff` and
`0x80000000`, appends to the string, then observes both heads from both result
and surviving source alias through `Char.to_u32`. Expected stdout is four full
unsigned decimal values; it never UTF-8-renders the arbitrary characters. The
existing real Unicode/array/provider fixtures remain necessary alongside it.
Root's [full-width receipt](../../selfhost/build/phase99/full-width01/report.json)
now records three passing program executions: baseline and source03 retain all
four exact values and aliases, and the raw forged-context case remains exact.
It also records field-zero-only selection and unchanged raw/denied outputs.
This refinement changes existing field declarations/casts, not String storage,
array representation or ownership operations. Its separate append screen above
failed the benefit gate; complete-value correctness did not justify promotion.
