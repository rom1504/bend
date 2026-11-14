@unsafe
def x181_program_private(+function: P113DFunction, context: P134Context, +available: KDef) -> X181Output:
  match function context:
    case P113DFunction{name,params,result,public,body} P134Context{+ids,index,direct,ready,view,+lookups,+heap,+mode}:
      +enabled = x195t_enabled() && U32.is_eq(mode,2)
      x181_program_join(X181Output{[],x181_program_stmts(body,available)},
        x181_program_join(nt_choose(X181Output,enabled,
          u => x195t_data(function,lookups,available),u => X181Output{[],""}),
          x181_program_join(x185_array_function(x195t_when(enabled,function,lookups),ids,heap,mode),
            x181_forward(function,ready))))
