# Exact retained scalar segment inputs; no original branch/control-flow projection.

@unsafe
def p147q_fixture_segment0() -> N111Segment:
  N111Segment{"$direct.$native.U32.sub",2,1,0,0,Con{N111Alloca{"scratch",2048,8},Con{N111Call{"v_4294942315",N111U64{},"p111_rt_reg_get",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},Con{N111Call{"v_4294942314",N111U64{},"p111_rt_reg_get",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}},Con{N111Bin{"p112_s_a",N111U64{},"and",N111Local{"v_4294942315"},N111Const{4294967295,0}},Con{N111Bin{"p112_s_b",N111U64{},"and",N111Local{"v_4294942314"},N111Const{4294967295,0}},Con{N111Bin{"value",N111U64{},"sub",N111Local{"p112_s_a"},N111Local{"p112_s_b"}},Con{N111Bin{"value",N111U64{},"and",N111Local{"value"},N111Const{4294967295,0}},Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"value"}},Con{N111Call{"reply",N111U64{},"p111_rt_return",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111Ptr{},N111Local{"scratch"}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}},Con{N111Return{N111Local{"reply"}},Nil{}}}}}}}}}}}}

@unsafe
def p147q_fixture_ids0() -> N111Ids:
  N111Ids{missing(),missing()}

@unsafe
def p147q_fixture_segment1() -> N111Segment:
  N111Segment{"$p111.k.21850",1,1,0,0,Con{N111Alloca{"scratch",2048,8},Con{N111Call{"v_4294945447",N111U64{},"p111_rt_reg_get",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"v_4294945447"}},Con{N111Call{"value",N111U64{},"p111_rt_closure",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111FuncId{"$p111.k.21851"}},Con{N111Arg{N111Ptr{},N111Local{"scratch"}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}},Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"value"}},Con{N111Call{"reply",N111U64{},"p111_rt_return",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111Ptr{},N111Local{"scratch"}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}},Con{N111Return{N111Local{"reply"}},Nil{}}}}}}}}}

@unsafe
def p147q_fixture_ids1() -> N111Ids:
  N111Ids{p111q_insert(missing(),"$p111.k.21851",111),missing()}

@unsafe
def p147q_fixture_segment2() -> N111Segment:
  N111Segment{"$direct.$native.U32.mod",2,1,0,0,Con{N111Alloca{"scratch",2048,8},Con{N111Call{"v_4294928633",N111U64{},"p111_rt_reg_get",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},Con{N111Call{"v_4294928632",N111U64{},"p111_rt_reg_get",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}},Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"v_4294928633"}},Con{N111Store{N111U64{},N111Local{"scratch"},8,N111Local{"v_4294928632"}},Con{N111Call{"value",N111U64{},"p111_rt_op",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111U32{},N111Const{19,0}},Con{N111Arg{N111Ptr{},N111Local{"scratch"}},Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}},Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"value"}},Con{N111Call{"reply",N111U64{},"p111_rt_return",Con{N111Arg{N111Ptr{},N111Local{"state"}},Con{N111Arg{N111Ptr{},N111Local{"scratch"}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}},Con{N111Return{N111Local{"reply"}},Nil{}}}}}}}}}}}

@unsafe
def p147q_fixture_ids2() -> N111Ids:
  N111Ids{missing(),missing()}
