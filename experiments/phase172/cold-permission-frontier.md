# Why the complete compiler has no cold constructors

Bounded read-only follow-up, 2026-11-06. No target ran. The new Phase172 offline
census reports 703 hot constructors out of 703 and descriptor capability 5.
This reproduces a known architectural limitation, not proof that every
constructor is dynamically shared.

## Established cause

The earlier [Phase169 audit](../phase169/constructor-cold-audit.md) binds the
same result on the qualified Phase152 compiler: 695/695 hot, capability 5. Its
retained effect table includes `File.write`, `File.close`, `File.read`,
`File.size`, `File.open`, `IO.print`, `IO.now` and `IO.args`.

The maintained source still follows the same chain:

1. `p113a_certificate` in `back/qbe/verified-plan.bend:10` obtains `scalar`
   from `ns_definitions(book,names)`.
2. `ns_definitions` in `back/native/scalar-array.bend:51` accepts foreign
   providers only for `IO.args`, `IO.print` and `IO.now`. Reachable File
   effects independently suffice to refuse the whole request. Other term
   restrictions may also refuse it.
3. `p169c_selected` in `back/qbe/early-emission.bend:295` invokes the cold
   plan only when that scalar certificate is true.
4. `p118c_plan` in `back/qbe/ownership.bend:350` independently checks the
   same permission before sharing analysis. Invalid permission supplies `*`
   and no cold list. `p118c_tables` adds capability bit 8 only when an actual
   cold constructor byte exists.

Capability 5 consequently means ordinary static/runtime support plus live
register transport; it does not include cold publication or scalar arrays.
The installed compiler is not losing previously established cold facts during
late QBE serialization. The facts are never established for this request.

## Why a larger cold opportunity remains uncertain

The permission couples two different transformations: packed scalar arrays and
constructor publication. File I/O blocking a global constructor analysis is a
conservative engineering boundary, not a language theorem that File requires
every compiler-internal value to be sealed. A separate, narrow publication
certificate could be useful.

However, simply replacing the scalar permission with the broader observer
permission is not justified. The latter proves retained-root reads, not
arbitrary destructive consumers of unsealed children. The sharing analysis also
has independent precision limits:

- `p131u_hot` in `core/ordered-index.bend:113` makes an unannotated duplicated
  variable globally unknown (`*`). Annotated duplication traverses its type.
- `nh_head` in `back/native/sharing.bend:20` permits only the supported typed
  ADT shapes; unknown/escaped shapes or exhausted traversal fuel become `*`.
- `nh_ctors` and `nh_fields` propagate sharing transitively through live
  constructor fields. Common compiler KDef/KTerm/List/String structures are
  heavily reused, so admitting the analysis does not imply they become cold.

Neither the number of cold candidates after a separately authorized File
summary nor their dynamic allocation share has been measured. Treating all 703
as newly cold would be unsound, and assuming a large gain would be speculative.

## The narrow next diagnostic, if needed

Before implementing a new permission, diagnose the existing sharing analysis
on the exact immutable checked request **without applying its output**. Record
the first cause of `*`, concrete constructor hot set, candidate cold set, scan
time, and whether those candidates occur in profiled hot construction sites.
This is diagnostic evidence only; bypassing permission cannot authorize output.
If one unknown duplicated type poisons the entire analysis, first test whether
a local conservative summary can contain that uncertainty. Do not simply remove
the unknown marker.

If useful candidates survive, the smallest justified implementation is a
separate cold-publication permission for the exact pinned effect providers,
leaving scalar arrays disabled. Audit each provider's consumed, retained,
duplicated and newly constructed values, and conservatively mark boundary
types hot. For the existing File functions, runtime source shows handles remain
scalar, `file_open_run`/`file_write_run` consume String data through `io_cstr`,
and asynchronous work owns host buffers; `file_read_pack` builds fresh String
and Result/Tuple output. These observations suggest a tractable summary but do
not themselves prove the complete ownership interface or all error paths.

The existing authenticated File provider catalogue can supply identity, while
the source-derived sharing analysis supplies internal reachability. Retain
ordinary fallback for unknown foreign providers, unsupported terms or unknown
sharing. Reuse the Phase118 transitive sharing/cold controls and complete File
success/error controls. No new generic effect-summary framework is required
to falsify this one case.

For Phase172, the sealed-field constructor template is cheaper and does not
depend on proving this new permission: it dynamically admits only fields for
which the existing `rfc_seal` is exactly identity. Cold-policy research should
not delay that small execution experiment or be advertised as a demonstrated
route to the 100-second target.
