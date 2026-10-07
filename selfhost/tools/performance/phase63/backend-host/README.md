# One host field plan

`candidate.json` binds an isolated, initially unqualified source patch. Root owns
application and qualification; the original files here remain immutable inputs.
The patch adds 44 lines and one private type, replacing the use of two recursive
constructor-field scans with a single list of already-built converters.

The old `jd_host_marshal_arm` visits each field through `jd_host_marshal_tail`,
constructing its complete converter to detect the iterative self-tail. It then
visits the fields again through `jd_host_marshal_fields`, rebuilding each
non-tail converter. Recursive converter construction repeats native/Nat graph
classification, specialization and string production. The new list retains
`name` and converter String once per live field, then selects the final converter
equal to `self` and renders the other fields. The pinned TS `js_marshal` uses the
same field-list approach (`fs`, selected tail, remaining `copy`).

Each converter receives the same book, normalized domain, direction, ancestor
map, depth and decremented fuel as in both old scans. Erased fields still advance
the telescope without building a converter. The terminal plan retains the exact
old `host field telescope depth` fragment: exhaustion is checked before looking
at the head, even if that head would have ended the telescope. Tail selection
keeps the last equal converter and field text keeps source order. Existing helpers
remain present for first qualification rather than mixing cleanup into the test.

Fresh State05 CPU evidence supports this bounded hypothesis. In the Map sample,
host marshalling occupies 114.36 ms / 1,600.65 ms (7.14%); constructor-arm ancestry
occupies 107.48 ms. Tail and field scans overlap recursively, so their inclusive
69.43 ms and 71.09 ms cannot be added or treated as removable time. Numeric's
entire library plan occupies 14.19 ms in its CPU profile, rather than the separate
40.38 ms stage observation. Its native-type proof costs 10.97 ms and the proposed
field plan does not remove that proof. These single diagnostic samples are not
clean timing estimates or evidence of a selected gain.

The final byte checks must include recursive Nat aggregates and mixed Nat-free
fields, both directions, more than one self-recursive field, and the exact/over
marshaller depth/telescope bounds. Use the existing short clean loop only after
those controls, then representative full output qualification. The expected gain
comes from avoiding repeated semantic/type work as well as output construction.
