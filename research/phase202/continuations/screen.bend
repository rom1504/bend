@unsafe
def x202s_rows(+held: String, +incoming: String, +alias: String, +reverse: Bool) -> List<&2,N111Stmt>:
  [N111Alloca{"scratch",2048,8},N111Call{"ignored",N111U64{},"p111_rt_stack_pop",[p111_state(),p111_u32(1)]},
   N111Call{held,N111U64{},"p111_rt_stack_get",[p111_state(),p111_u32(0)]},
   N111Load{incoming,N111U64{},N111Local{"state"},40},N111Set{alias,N111U64{},N111Local{held}},
   N111Call{"reply",N111U64{},"p111_rt_apply",[p111_state(),p111_word(N111Local{nt_choose(String,reverse,u => alias,u => incoming)}),
     p111_word(N111Local{nt_choose(String,reverse,u => incoming,u => alias)})]},N111Return{N111Local{"reply"}}]

@unsafe
def x202s_work(+i: U32, build: X187Build) -> X187ObjectResult:
  match i:
    case 128: x187_build_finish(build)
    case _:
      +rows = x202s_rows("v_" ++ U32.show(U32.mul(i,3)),"v_" ++ U32.show(U32.inc(U32.mul(i,3))),
        "v_" ++ U32.show(U32.add(U32.mul(i,3),2)),U32.is_eq(i,127))
      x202s_work(U32.inc(i),x187_output(x181_segment(N111Segment{p111_name(U32.add(i,1000)),2,1,1,0,rows},N111Ids{missing(),missing()}),build))

@unsafe
def main() -> IO(U32):
  x187_print_result(x202s_work(0,x187_build_empty()))
