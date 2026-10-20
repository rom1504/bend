# Optional compositional policy: simplify each completed inline candidate before
# the existing bottom-up table decides whether later callers may inline it.
# Existing node/site/growth policy remains 192/16/512; no extra pass re-inlines
# names already introduced by the hygienic renamer.
@unsafe
def p113i_function_done(+original: P113DFunction, +name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, scan: P113IScan) -> P113DFunction:
  match scan:
    case P113IScan{+body,next,budget}:
      nt_choose(P113DFunction,U32.is_le(p113i_stack(body),16384),
        u => p113k_function(P113DFunction{name,params,result,public,body}),u => original)
