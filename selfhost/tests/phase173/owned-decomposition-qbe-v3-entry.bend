# Sole v3 replacement. This is the selected checked QBE route, not a common
# preparation hook: p169np_plan already established p111_runtime_admission.
# Keep p112s_prepare unchanged and call it exactly once.
@unsafe
def p168_catalogued(mode: U32, source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>) -> P167Lowered:
  p168_prepared(mode,source,names,constructors,
    p173op_prepared(book,names,p112s_prepare(book,names,constructors)))
