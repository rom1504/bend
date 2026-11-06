# Suppressing a decrement must preserve the runtime call's exact return value.
# These are finite compiler IR values, not executed failure/runtime probes.

@unsafe
def p171d_sink_controls() -> List<&2,String>:
  [p171dc_row("fresh-sink-destination-zero-used-later",p171di_exact(p171dc_run([
     P113DScalar{N111Call{"zero",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"root"})]}},
     P113DResult{[N111Local{"zero"}]}],[]),[
     P113DScalar{N111Set{"zero",N111U64{},N111Const{0,0}}},
     P113DResult{[N111Const{1,0},N111Local{"zero"}]}],2,1,0,False{})),
   p171dc_row("reused-sink-destination-overwrites-prior-one",p171di_exact(p171dc_run([
     P113DScalar{N111Set{"value",N111U64{},N111Const{1,0}}},
     P113DScalar{N111Call{"value",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"root"})]}},
     P113DResult{[N111Local{"value"}]}],[]),[
     P113DScalar{N111Set{"value",N111U64{},N111Const{1,0}}},
     P113DScalar{N111Set{"value",N111U64{},N111Const{0,0}}},
     P113DResult{[N111Const{1,0},N111Local{"value"}]}],3,1,0,False{}))]
