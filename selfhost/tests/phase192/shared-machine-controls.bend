# Append after shared-address-controls-v2.bend. Export p192sm_emit.
# Four allocation paths: joint, explicit legacy, stack-only and oversized joint
# refusal. Each consumes the SAME selected dependency rows and original slots.
@unsafe
def p192sm_body(+kind: U32) -> List<&2,P113DStmt>:
  +scaled: P113DStmt = p192sa_scale(nt_choose(N111Type,U32.is_eq(kind,4),u => N111U32{},u => N111U64{}))
  +prefix: List<&2,P113DStmt> = [scaled,p192sa_offset("pointer","base")]
  +tail: List<&2,P113DStmt> = nt_choose(List<&2,P113DStmt>,U32.is_eq(kind,2),u =>
    [P113DScalar{N111Store{N111U32{},p192sa_v("pointer"),0,p192sa_v("accumulator")}},
     p192sa_load(),P113DResult{[p192sa_v("loaded")]}],u =>
    nt_append(P113DStmt,[p192sa_load(),p192sa_add()],
      nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,U32.is_eq(kind,1),
        v => [p192sa_offset("second","target")],v =>
          nt_choose(List<&2,P113DStmt>,U32.is_eq(kind,3),w => [p192sa_set("index")],w => [])),
        [p192sa_store(nt_choose(String,U32.is_eq(kind,1),v => "second",v => "pointer"),0),
         P113DResult{[p192sa_v("result")]}])))
  nt_append(P113DStmt,prefix,tail)

@unsafe
def p192sm_padding(+count: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(count,0),u => [],u =>
    Con{p192sa_set("padding"),p192sm_padding(U32.sub(count,1))})

@unsafe
def p192sm_frame(+mode: U32, +frame: X181Frame, +params: List<&2,String>,
    +placement: List<&2,P113DStmt>) -> X181Frame:
  nt_choose(X181Frame,U32.is_eq(mode,2),u => frame,u =>
    nt_choose(X181Frame,U32.is_eq(mode,1),v => x190_allocate_legacy(frame,params,[],placement,placement),
      v => x190_allocate_frame(frame,params,[],placement,placement)))

@unsafe
def p192sm_function(+kind: U32, +mode: U32) -> X181Output:
  +symbol = "p192sm_" ++ U32.show(kind) ++ "_" ++ U32.show(mode)
  +params: List<&2,String> = ["state","base","index","accumulator","target"]
  +body = nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,3),
    u => p192sm_padding(260),u => []),p192sm_body(kind))
  +facts = x190_branch_facts(params,[],body)
  +placement = x191_placement(body,facts)
  x191_function_saved(symbol,[],body,facts,N111Ids{missing(),missing()},
    x186_saves_frame(p192sm_frame(mode,x181_frame(symbol,params,body),params,placement)))

@unsafe
def p192sm_modes(+kind: U32, +mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,4),u => X181Output{[],""},u =>
    x181_program_join(p192sm_function(kind,mode),p192sm_modes(kind,U32.inc(mode))))

@unsafe
def p192sm_kinds(+kind: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(kind,5),u => X181Output{[],""},u =>
    x181_program_join(p192sm_modes(kind,0),p192sm_kinds(U32.inc(kind))))

def p192sm_emit() -> X181Output: p192sm_kinds(0)
