# Indexed report roots

The private adapter replaces only `dr_own_names` inside the session's successful
report path. Compose report-v01 before frontend-v02, replacing frontend-v01.
The frontend inverse edit (`p140dr_report_data`→`driver_report_data`) restores
v01 byte-for-byte. Add report-controls-v01 and export p140dr_controls (15 rows).
No original production declaration is overridden.

`p140dr_names` emits the first non-native occurrence of each name in source
order, exactly as dr_own_names. Native entries neither emit nor insert a seen
name, so a later ordinary entry with the same name remains visible. The index
uses existing collision-safe exact-name Patricia functions; hashes never prove
name equality. The seen marker distinguishes an actual empty name from absence.
The two Absent marker fields are literal immutable constructors, allowing the
existing static pool to retain them rather than allocate tiny factories.

The private report adapter calls original book_final_fast, book_cached with
bound0, dr_cached_names and dr_verdict unchanged. It does not cache or infer
safe/unsafe dependency results. Thus all unsafe, foreign and transitive report
logic remains executed. This removes quadratic linear seen-list membership
from root selection; it does not remove has_name inside dr_walk.

Finite comparisons use original dr_own_names plus explicit expected ordered
lists: duplicate/native-shadow order, initial seen lists, actual FNV collision,
empty names and Unicode. Five controls compare complete old/new DR_Report.
These controls and full real session outputs still require coordinator source
checking/execution. No speed result is claimed. Phase138's active has_name
samples include other callers and cannot be interpreted as this change's gain.
