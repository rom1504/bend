# Pure syntax-screen controls; inputs are never lowered or executed as programs.
@unsafe
def p120wpf_shift(amount: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{"shift",N111U64{},"shr",N111Local{"x"},amount}}

@unsafe
def p120wpf_row(name: String, body: List<&2,P113DStmt>, expected: U32) -> String:
  p113wt_row(name,U32.is_eq(p120w_prefilter_body(body,0),expected))

@unsafe
def p120wpf_controls(unit: Unit) -> List<&2,String>:
  +sign = p120wpf_shift(N111Const{31,0})
  +logical = p120wpf_shift(N111Const{8,0})
  +consumer : P113DStmt = P113DScalar{N111Bin{"out",N111U64{},"or",N111Local{"shift"},N111Local{"fill"}}}
  [p120wpf_row("prefilter-all-literals",[sign,logical,consumer],7),
   p120wpf_row("prefilter-no-sign",[logical,consumer],6),
   p120wpf_row("prefilter-no-logical",[sign,consumer],5),
   p120wpf_row("prefilter-no-or",[sign,logical],3),
   p120wpf_row("prefilter-zero-count",[p120wpf_shift(N111Const{0,0}),consumer],4),
   p120wpf_row("prefilter-count32",[p120wpf_shift(N111Const{32,0}),consumer],4),
   p120wpf_row("prefilter-high-count",[p120wpf_shift(N111Const{31,1}),consumer],4),
   p120wpf_row("prefilter-local-count-accepts-both",[p120wpf_shift(N111Local{"count"}),consumer],7),
   p120wpf_row("prefilter-symbol-not-constant",[p120wpf_shift(N111FuncId{"unknown"}),consumer],4),
   p120wpf_row("prefilter-direct-branches",[P113DIf{N111Local{"condition"},[sign],[logical]},consumer],7),
   p120wpf_row("prefilter-scalar-branches",[P113DScalar{N111If{N111Local{"condition"},
     [N111Bin{"shift",N111U64{},"shr",N111Local{"x"},N111Const{31,0}}],
     [N111Bin{"shift",N111U64{},"shr",N111Local{"x"},N111Const{8,0}}]}},consumer],7),
   p113wt_row("prefilter-logical-first",U32.is_eq(p120wpf_count(N111Const{1,0}),2)),
   p113wt_row("prefilter-logical-last",U32.is_eq(p120wpf_count(N111Const{30,0}),2))]
