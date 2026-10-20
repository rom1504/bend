# Versioned diagnostic override: consult actual selected policy, never report
# an obsolete hardcoded 192-node cutoff when a different policy is composed.
@unsafe
def p113j_reason(+function: P113DFunction) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      nt_choose(String,p113i_eligible(function),u => "eligible",u =>
      nt_choose(String,U32.is_lt(result,1) || U32.is_gt(result,8),u => "result-width",u =>
      nt_choose(String,U32.is_gt(nt_count(NC_Binding,params),32),u => "argument-count",u =>
      nt_choose(String,Bool.not(p113i_params(params)),u => "parameter-prefix",u =>
      nt_choose(String,Bool.not(p113j_returns(body,result)),u => "loop-or-partial-return",u => "policy-limit")))))
