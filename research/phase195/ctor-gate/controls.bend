# Actual x86 late expansion, then existing alpha-renaming maps original scratch
# to an external parameter. The unchanged independent observer can check exact
# fallback pointer identity without aliasing the compiler's implicit scratch.
@unsafe
def p195cg_one(name: String, +count: U32, cid: U32, hot: Bool) -> X181Output:
  +ids : N111Ids = N111Ids{missing(),p111q_constructor_ids([N_Constructor{"oracle",count,hot}],cid,missing())}
  +body = nt_append(N111Stmt,x185_late_scalar(p185ct_ordinary("oracle",count),ids,0),[N111Return{N111Local{"value"}}])
  x181_function(name,["state","ct_local_scratch"],x181_scalar_rows(p112f_rename(body,"ct_")),ids)
@unsafe
def p195cg_twice() -> X181Output:
  +ids : N111Ids = N111Ids{missing(),p111q_constructor_ids([N_Constructor{"oracle",2,False{}}],42,missing())}
  +body = nt_append(N111Stmt,x185_late_scalar(p185ct_ordinary("oracle",2),ids,0),
    nt_append(N111Stmt,x185_late_scalar(p185ct_ordinary("oracle",2),ids,1),[N111Return{N111Local{"value"}}]))
  x181_function("p185ct_twice",["state","ct_local_scratch"],x181_scalar_rows(p112f_rename(body,"ct_")),ids)
@unsafe
def p195cg_emit() -> X181Output:
  x181_program_join(p195cg_one("p185ct_width1",1,65535,False{}),
  x181_program_join(p195cg_one("p185ct_width2",2,65534,False{}),
  x181_program_join(p195cg_one("p185ct_width3",3,65533,False{}),
  x181_program_join(p195cg_one("p185ct_width4",4,65532,False{}),
  x181_program_join(p195cg_one("p185ct_hot",2,41,True{}),p195cg_twice())))))
