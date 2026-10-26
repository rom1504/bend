# Native-library source bodies are not runtime intrinsic replacements.
# Only this append certificate is extended; j_fusion_def remains unchanged.
@unsafe
def p144ap_source_definition(+d: KDef) -> Bool:
  String.eq(dk(d),"Def") && U32.is_eq(da(d),2) && U32.is_eq(dx(d),0) &&
    Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d))

@unsafe
def p125p_admitted(+book: List<&2,KDef>, +d: KDef) -> Bool:
  nt_choose(Bool,p144ap_source_definition(d) && p98_tag_eq(j_strip(dv(d)),"Mat"),u =>
    nt_choose(Bool,p121f_bounded(dv(d)),v =>
      p125p_equations(d,nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1)))) &&
      p125p_types(book,d,nm(j_strip(dv(d))),nm(j_strip(kid(j_strip(dv(d)),1)))),v => False{}),u => False{})

# Restrict the first prototype to the existing forwarding factory. This makes
# the reserved scratch/result namespace disjoint without trusting source names.

