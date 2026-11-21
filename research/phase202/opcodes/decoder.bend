@unsafe
def x187_e_spec(+op: String) -> X187Op:
  match op:
    case SNil{}: X187OpNone{}
    case SCon{head,+tail}:
      x202o_dispatch(Char.to_u32(head),tail)

@unsafe
def x202o_dispatch(initial: U32, +tail: String) -> X187Op:
  match initial:
    case 109:
      nt_choose(X187Op,String.eq(tail,"ovq"),u => X187Op{2,64,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ovl"),u => X187Op{2,32,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ovd"),u => X187Op{10,0,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ovabsq"),u => X187Op{15,64,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ovzbl"),u => X187Op{6,32,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ovaps"),u => X187Op{7,128,40,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ovb"),u => X187Op{2,8,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ulss"),u => X187Op{7,128,89,0,243},u =>
      X187OpNone{}))))))))
    case 106:
      nt_choose(X187Op,String.eq(tail,"ne"),u => X187Op{9,0,15,133,0},u =>
      nt_choose(X187Op,String.eq(tail,"mp"),u => X187Op{9,0,233,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"e"),u => X187Op{9,0,15,132,0},u =>
      nt_choose(X187Op,String.eq(tail,"z"),u => X187Op{9,0,15,132,0},u =>
      nt_choose(X187Op,String.eq(tail,"a"),u => X187Op{9,0,15,135,0},u =>
      nt_choose(X187Op,String.eq(tail,"b"),u => X187Op{9,0,15,130,0},u =>
      nt_choose(X187Op,String.eq(tail,"ae"),u => X187Op{9,0,15,131,0},u =>
      nt_choose(X187Op,String.eq(tail,"be"),u => X187Op{9,0,15,134,0},u =>
      nt_choose(X187Op,String.eq(tail,"g"),u => X187Op{9,0,15,143,0},u =>
      nt_choose(X187Op,String.eq(tail,"ge"),u => X187Op{9,0,15,141,0},u =>
      nt_choose(X187Op,String.eq(tail,"l"),u => X187Op{9,0,15,140,0},u =>
      nt_choose(X187Op,String.eq(tail,"le"),u => X187Op{9,0,15,142,0},u =>
      nt_choose(X187Op,String.eq(tail,"np"),u => X187Op{9,0,15,139,0},u =>
      nt_choose(X187Op,String.eq(tail,"nz"),u => X187Op{9,0,15,133,0},u =>
      nt_choose(X187Op,String.eq(tail,"p"),u => X187Op{9,0,15,138,0},u =>
      X187OpNone{})))))))))))))))
    case 99:
      nt_choose(X187Op,String.eq(tail,"mpq"),u => X187Op{1,64,0,7,0},u =>
      nt_choose(X187Op,String.eq(tail,"mpl"),u => X187Op{1,32,0,7,0},u =>
      nt_choose(X187Op,String.eq(tail,"all"),u => X187Op{9,0,232,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"vtsi2ssq"),u => X187Op{11,64,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movael"),u => X187Op{16,32,67,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"omiss"),u => X187Op{7,128,47,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movaeq"),u => X187Op{16,64,67,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"moval"),u => X187Op{16,32,71,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movaq"),u => X187Op{16,64,71,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movbel"),u => X187Op{16,32,70,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movbeq"),u => X187Op{16,64,70,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movbl"),u => X187Op{16,32,66,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movbq"),u => X187Op{16,64,66,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movel"),u => X187Op{16,32,68,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"moveq"),u => X187Op{16,64,68,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movgel"),u => X187Op{16,32,77,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movgeq"),u => X187Op{16,64,77,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movgl"),u => X187Op{16,32,79,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movgq"),u => X187Op{16,64,79,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movlel"),u => X187Op{16,32,78,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movleq"),u => X187Op{16,64,78,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movll"),u => X187Op{16,32,76,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movlq"),u => X187Op{16,64,76,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movnel"),u => X187Op{16,32,69,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"movneq"),u => X187Op{16,64,69,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"mpb"),u => X187Op{1,8,0,7,0},u =>
      X187OpNone{}))))))))))))))))))))))))))
    case 112:
      nt_choose(X187Op,String.eq(tail,"opq"),u => X187Op{8,64,88,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ushq"),u => X187Op{8,64,80,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"xor"),u => X187Op{7,128,239,0,102},u =>
      X187OpNone{})))
    case 97:
      nt_choose(X187Op,String.eq(tail,"ddq"),u => X187Op{1,64,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ndq"),u => X187Op{1,64,0,4,0},u =>
      nt_choose(X187Op,String.eq(tail,"ndb"),u => X187Op{1,8,0,4,0},u =>
      nt_choose(X187Op,String.eq(tail,"ddl"),u => X187Op{1,32,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ddb"),u => X187Op{1,8,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ddss"),u => X187Op{7,128,88,0,243},u =>
      nt_choose(X187Op,String.eq(tail,"ndl"),u => X187Op{1,32,0,4,0},u =>
      X187OpNone{})))))))
    case 115:
      nt_choose(X187Op,String.eq(tail,"hrq"),u => X187Op{3,64,0,5,0},u =>
      nt_choose(X187Op,String.eq(tail,"ubq"),u => X187Op{1,64,0,5,0},u =>
      nt_choose(X187Op,String.eq(tail,"etnp"),u => X187Op{5,8,155,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"eta"),u => X187Op{5,8,151,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etae"),u => X187Op{5,8,147,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etb"),u => X187Op{5,8,146,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etbe"),u => X187Op{5,8,150,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"ete"),u => X187Op{5,8,148,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etne"),u => X187Op{5,8,149,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etp"),u => X187Op{5,8,154,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"arl"),u => X187Op{3,32,0,7,0},u =>
      nt_choose(X187Op,String.eq(tail,"arq"),u => X187Op{3,64,0,7,0},u =>
      nt_choose(X187Op,String.eq(tail,"etg"),u => X187Op{5,8,159,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etge"),u => X187Op{5,8,157,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etl"),u => X187Op{5,8,156,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etle"),u => X187Op{5,8,158,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etnz"),u => X187Op{5,8,149,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"etz"),u => X187Op{5,8,148,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"hll"),u => X187Op{3,32,0,4,0},u =>
      nt_choose(X187Op,String.eq(tail,"hlq"),u => X187Op{3,64,0,4,0},u =>
      nt_choose(X187Op,String.eq(tail,"hrl"),u => X187Op{3,32,0,5,0},u =>
      nt_choose(X187Op,String.eq(tail,"ubb"),u => X187Op{1,8,0,5,0},u =>
      nt_choose(X187Op,String.eq(tail,"ubl"),u => X187Op{1,32,0,5,0},u =>
      nt_choose(X187Op,String.eq(tail,"ubss"),u => X187Op{7,128,92,0,243},u =>
      X187OpNone{}))))))))))))))))))))))))
    case 108:
      nt_choose(X187Op,String.eq(tail,"eaq"),u => X187Op{12,64,0,0,0},u =>
      X187OpNone{})
    case 120:
      nt_choose(X187Op,String.eq(tail,"orl"),u => X187Op{1,32,0,6,0},u =>
      nt_choose(X187Op,String.eq(tail,"orb"),u => X187Op{1,8,0,6,0},u =>
      nt_choose(X187Op,String.eq(tail,"orq"),u => X187Op{1,64,0,6,0},u =>
      X187OpNone{})))
    case 116:
      nt_choose(X187Op,String.eq(tail,"estl"),u => X187Op{13,32,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"estb"),u => X187Op{13,8,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"estq"),u => X187Op{13,64,0,0,0},u =>
      X187OpNone{})))
    case 114:
      nt_choose(X187Op,String.eq(tail,"et"),u => X187Op{14,0,195,0,0},u =>
      X187OpNone{})
    case 117:
      nt_choose(X187Op,String.eq(tail,"comiss"),u => X187Op{7,128,46,0,0},u =>
      X187OpNone{})
    case 111:
      nt_choose(X187Op,String.eq(tail,"rb"),u => X187Op{1,8,0,1,0},u =>
      nt_choose(X187Op,String.eq(tail,"rl"),u => X187Op{1,32,0,1,0},u =>
      nt_choose(X187Op,String.eq(tail,"rq"),u => X187Op{1,64,0,1,0},u =>
      X187OpNone{})))
    case 100:
      nt_choose(X187Op,String.eq(tail,"ivss"),u => X187Op{7,128,94,0,243},u =>
      X187OpNone{})
    case 105:
      nt_choose(X187Op,String.eq(tail,"mull"),u => X187Op{4,32,0,0,0},u =>
      nt_choose(X187Op,String.eq(tail,"mulq"),u => X187Op{4,64,0,0,0},u =>
      X187OpNone{}))
    case _: X187OpNone{}
