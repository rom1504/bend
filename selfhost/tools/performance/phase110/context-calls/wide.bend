# Synthetic machine-ABI witness, not an actual checked-source algorithm.
# Every public call crosses the six-register boundary; threaded private calls
# carry eleven machine arguments. The original owning checker remains active.
@unsafe
def nx110ctx_wide_source() -> Nx110RtLibrary:
  Nx110RtLibrary{
    [nx110rt_call_control_worker("wide_leaf",8,0,
      [NxoSink{"p0"},NxoSink{"p1"},NxoSink{"p2"},NxoSink{"p3"},
       NxoSink{"p4"},NxoSink{"p5"},NxoSink{"p6"},NxoReturn{"p7"}]),
     nx110rt_call_control_worker("wide",8,1,
      [NxoCall{"v0","wide_leaf",["p0","p1","p2","p3","p4","p5","p6","p7"]},NxoReturn{"v0"}])],
    ["wide"]}

@unsafe
def nx110ctx_wide_qbe(+mode: String) -> String:
  nx_choose(String,String.eq(mode,"baseline"),u => nx110rt_qbe(nx110ctx_wide_source()),u =>
    nx110ctx_qbe(nx110ctx_prepare(nx110ctx_wide_source(),mode)))

@unsafe
def nx110ctx_wide_c(+mode: String) -> String:
  nx_choose(String,String.eq(mode,"baseline"),u => nx110rt_c(nx110ctx_wide_source()),u =>
    nx110ctx_c(nx110ctx_prepare(nx110ctx_wide_source(),mode)))

@unsafe
def nx110ctx_wide_report() -> String:
  nxlib_control_result("wide-baseline-owned-eight-args",nx110rt_verify(nx110ctx_wide_source())) ++
  nxlib_control_result("wide-threaded-eleven-machine-args",nx110ctx_verify(nx110ctx_prepare(nx110ctx_wide_source(),"threaded"))) ++
  nxlib_control_result("wide-context-nine-machine-args",nx110ctx_verify(nx110ctx_prepare(nx110ctx_wide_source(),"context")))
