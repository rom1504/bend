# P75-012: one constructor lookup index per native request

B2 numeric sampling attributes16.4ms self time to nc_find_ctor, with additional
lookup/Absent allocation and repeated successful child walks. nc_find_ctor scans
both BookCache trees and event lists for every native field-count query.

Build a private exact-name index once, preserving the legacy depth-first first
constructor winner, including nested raw cache children and duplicate names.
Store it beside erased/static facts; subsequent static preparation reuses it.
Public raw emission clears caller facts before preparation; the legacy scan stays
as the unprepared fallback. Test exact whole C and differential raw graph lookup,
then the three-family compilation fast loop. Do not change source lookup or use
constructor identity alone as a substitute for type checks.
