# Independent policy ablation: candidate384 ->512 only. All result, parameter,
# DAG/return and stack gates remain identical; growth/site limits are unchanged.
@unsafe
def p113i_eligible(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      U32.is_ge(result,1) && U32.is_le(result,8) && U32.is_le(nt_count(NC_Binding,params),32) &&
        U32.is_le(p113i_size(body),512) && U32.is_le(p113i_stack(body),8192) &&
        p113i_params(params) && p113j_returns(body,result)
