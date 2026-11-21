# Only the guarded mode-2 array version can enter the new selector.
# The original fallback worker and dispatch/setup factories are unchanged.
@unsafe
def x185_array_version(+function: P113DFunction, +ids: N111Ids, +heap: U32, +used: U32, sites: KDef) -> X181Output:
  match function:
    case P113DFunction{+name,+params,+result,public,body}:
      x181_program_join(x185_array_emit(p113a_function(function,heap),"p117v_" ++ nt_fid(name),[],ids),
        x199s_array_emit(p113a_function_done(name,params,result,public,p117v_rewrite(body,0,heap,used,sites)),
          p113e_symbol(name),nt_append(N111Stmt,p117h_prelude(params,1,used,heap),
            x185_array_dispatch(name,params,result,used)),ids,used))
