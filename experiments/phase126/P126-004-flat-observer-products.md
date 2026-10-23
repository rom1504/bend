# P126-004: compose observers with flat product consumers

Status: selected in source32; broad/native qualification is recorded separately
in the Phase126 report. No benchmark-name selection.

The checked observer planner already knew how to inspect Map structure, but its
owning adapter returned a boxed Tuple. The product-call closure could not use that
interface. A second adapter now returns the certified residual variable fields
directly. Existing readers, ownership certificates and boxed fallback remain.
The actual integrated entry reruns the established bounded dependency closure
and independently verifies the resulting catalogue.

A separate source-authenticated Nat.divmod shape supplies two full-width outputs
without constructing a temporary Tuple. The additive runtime helper implements
the existing `(a/b,a%b)` contract, including `(0,a)` for divisor zero. Its exact
import proves a writable16-byte local output. Shared C shape inference and the
original generic verifier remain unchanged.

Source27 passed finite checks but emitted identical code on all five real cases.
Its shape hook looked for NOp while the bound source was still an authenticated
App. This negative activation result prevented a meaningless timing run. Source32
uses the existing native-call authority and saturation test before sequencing.
Actual Map.bit code now calls the product observer path; its intermediate divmod
Tuple allocation/take disappear. The public owning result still materializes.

The matched source32 screen gives record256567/684ms, map-churn128653/712ms and
evening1292/1382ms versus Phase125. RLE1130/1145ms and lexer504/521ms are smaller
changes. These are five-case observations, not a corpus score or an isolated
divmod attribution: source32 also includes the SCC change and numeric work.

Source33 additionally applies the existing bounded inliner only to newly admitted
functions. It changes no lexer/RLE QBE and has only a small additional five-case
timing difference. It is excluded from the final composition for simplicity.

Evidence: `phase126/observer32-{screen,summary}.json` (screen is a directory),
`phase126/observer32-finite/report.json`, the product-primitive evidence26/27/32/33
inventories, and `implementation/phase126/product-observer-report.md`. Ordinary
boundary controls preserve the independent36-line oracle through fixture repairs;
source-language duplicability requires an explicit Data Sigma for shared products.
