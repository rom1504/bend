# P73-011: carry existing word kinds across continuations

Checked argument widths were used for entry C declarations but discarded from
ownership bindings; a continuation reload made even proven U32/Bool values
opaque. Add the existing N_WordKind to NC_Binding and preserve it through
filtering, aliases and continuation parameters. Seed from the same checked
function telescope and compiler-owned32-bit NWord literals; unknown results
remain64-bit. Gate narrowing on checked CPU permission even when raw lowering
computes metadata. No new value representation, call convention or analysis
framework. Test all ownership/error/raw fixtures and measure independent families;
reject if the metadata cost does not produce broad material gains.

Candidate13 also composes the previously ineffective P73-008 field masks with
these capture kinds. The field proof now survives suspension, where it may pay.
Remove the post-hoc segment-telescope rewrite and the duplicate ordinary-worker
kind query: direct bindings now acquire the same fact before lowering, and the
existing N_Param emitter consumes it. This tests both performance and simpler
information flow, rather than keeping two independent ways to recover facts.

Candidate13's screen improves Array.map to459ms (candidate11/08:478) and tree
by roughly5% relative to its same-campaign baseline ratio. AST stays~440ms;
lexer stays~295ms. The unusually slow401ms upstream AST sample is retained and
is not used to claim a new AST gain. Candidate14 consolidates: binding kind
helpers live in layout.bend, and monomorphic macro facts reuse the same field
mask computation rather than maintain a second telescope walker. Final broad
measurements and gates determine promotion.
