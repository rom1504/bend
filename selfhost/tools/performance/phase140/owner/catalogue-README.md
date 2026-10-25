# Reuse the already computed constructor catalogue

`bridge-v03.bend` replaces bridge-v02. No production declarations are overridden,
no new cache field is introduced, and reverse dependency state remains v02's
exact wiring. Append catalogue-controls-v01.bend and export p140cat_controls
(four finite complete-result comparisons; uses existing registry comparison
helpers/fixtures). This is source-only pending coordinator checking.

The original p140or_lower computes
`nc_add_ctors(nc_default_ctors(),nc_constructors(source,source))` after successful
nc_compile_error_known and passes it into p112s_prepare. Later p111_finish
recomputes the identical pure expression on the same immutable source value.
The new p140or_catalogued retains this actual first result through
p140or_prepared/context/compiled and passes it to p140or_finish. That helper
preserves the original p111_finish main lookup, IO determination, lowering-error
choice, effect scan, printable-show construction and p111_finish_show call.
The only removed work is the second construction of the same catalogue.

The first catalogue is still evaluated at exactly the original point, including
on requests that fail static preparation. Such requests still return the same
error/previous cache and never enter finish. Lowering failures still return the
original P111Result error. No trust is inferred from an old catalogue or another
request; this is same-request common-subexpression reuse.

Gates: source-check; four finite old/new whole-P111Result comparisons; existing
owner raw-product screen comparing fresh/cold/warm full structured lowering and
complete QBE for actual Lexer/Map edits; final composed native timing if selected.
The exact native gain is unmeasured. Phase138 cold active-owner attribution has
531/10785 nc_ctor_owned samples (~4.92%); that is neither this duplicate call's
inclusive cost nor a warm-stage estimate. The saved work is one catalogue
construction, not all ownership queries.
