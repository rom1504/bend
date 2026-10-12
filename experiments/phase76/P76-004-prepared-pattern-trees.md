# P76-004: retain scalar patterns in the native tree

Candidate07 prepares admitted scalar rows during existing static-tree rebuilding,
before repeated occurrence/liveness/lowering traversals. A private NWPattern
contains only reduced rows; ordinary source terms cannot inject it through static
preparation. Generic scalar/float source ABI is unchanged. Maximum-use analysis
combines alternatives with max; minimum-use analysis remains conservative zero.
Unsupported shapes retain the original matcher. Observer analysis deliberately
uses original erased source and remains unchanged.

The three initial C programs execute correctly and are byte-identical to
candidate05. Numeric acquisition time falls about 11%; other acquisition clocks
are much closer. These clocks are diagnostic, not balanced speed evidence.
Genuine B2, targeted pattern/raw controls and broad runtime gates are pending.
Do not promote merely on a smaller internal representation.
