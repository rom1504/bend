# Experimental exact typed-machine loop-header threading. No IR, homes,
# arguments, stores, or runtime calls change. Preserve scratch AND flags:
# the replacement repeats TEST, and R10 already holds the stored constant.
type X193LTHeader is Data:
  X193LTHeader{+entry: String, +home: X187Operand, +zero: String, +nonzero: String}

def x193lt_enabled() -> Bool: True{}

def x193lt_home(home: X187Operand) -> Bool:
  match home:
    case X187Reg{+index,64,False{}}:
      U32.is_lt(index,16) && Bool.not(U32.is_eq(index,4)) && Bool.not(U32.is_eq(index,5)) &&
        Bool.not(U32.is_eq(index,10)) && Bool.not(U32.is_eq(index,11))
    case X187Mem{5,offset}: x191_ff_private(offset)
    case _: False{}

def x193lt_same(a: X187Operand, b: X187Operand) -> Bool:
  match a b:
    case X187Mem{ab,ad} X187Mem{bb,bd}: U32.is_eq(ab,bb) && U32.is_eq(ad,bd)
    case _ _: x188_operand_same(a,b)

# Count explicit items and joins together. A large or malformed sequence keeps
# its original tree, rather than partially threading or growing the host stack.
@unsafe
def x193lt_flat(todo: List<&2,X188Seq>, out: List<&2,X187Parsed>, fuel: U32) -> Maybe<&2,List<&2,X187Parsed>>:
  match todo fuel:
    case Nil{} _: Some{nt_reverse(X187Parsed,out,[])}
    case _ 0: None{}
    case Con{X188Empty{},rest} _: x193lt_flat(rest,out,U32.sub(fuel,1))
    case Con{X188Join{left,right},rest} _: x193lt_flat(Con{left,Con{right,rest}},out,U32.sub(fuel,1))
    case Con{X188One{item},rest} _: x193lt_flat(rest,Con{item,out},U32.sub(fuel,1))

@unsafe
def x193lt_label_count(body: List<&2,X187Parsed>, +name: String, count: U32) -> U32:
  match body:
    case Nil{}: count
    case Con{PLabel{label},rest}:
      x193lt_label_count(rest,name,nt_choose(U32,String.eq(label,name),u => U32.inc(count),u => count))
    case Con{head,rest}: x193lt_label_count(rest,name,count)

@unsafe
def x193lt_header(body: List<&2,X187Parsed>, +entry: String) -> Maybe<&2,X193LTHeader>:
  match body:
    case Con{PLabel{label},Con{PInst{X187Instruction{+move,[+home,X187Reg{10,64,False{}}]}},
      Con{PInst{X187Instruction{+test,[X187Reg{10,32,False{}},X187Reg{10,32,False{}}]}},
      Con{PInst{X187Instruction{+jump,[X187Target{+zero}]}},rest}}}}:
      nt_choose(Maybe<&2,X193LTHeader>,String.eq(label,entry),u =>
        nt_choose(Maybe<&2,X193LTHeader>,String.eq(move,"movq") && String.eq(test,"testl") &&
          String.eq(jump,"jz") && x193lt_home(home),
          v => Some{X193LTHeader{entry,home,zero,entry ++ "_p193_nonzero"}},v => None{}),
        u => x193lt_header(Con{PInst{X187Instruction{move,[home,x188_reg(10,64)]}},
          Con{PInst{X187Instruction{test,[x188_reg(10,32),x188_reg(10,32)]}},
          Con{PInst{X187Instruction{jump,[X187Target{zero}]}},rest}}},entry))
    case Con{head,rest}: x193lt_header(rest,entry)
    case Nil{}: None{}

@unsafe
def x193lt_valid(+body: List<&2,X187Parsed>, plan: X193LTHeader) -> Bool:
  match plan:
    case X193LTHeader{entry,home,zero,nonzero}:
      U32.is_eq(x193lt_label_count(body,entry,0),1) &&
      U32.is_eq(x193lt_label_count(body,zero,0),1) &&
      U32.is_eq(x193lt_label_count(body,nonzero,0),0) && Bool.not(String.eq(entry,zero))

@unsafe
def x193lt_rewrite(body: List<&2,X187Parsed>, +plan: X193LTHeader, out: List<&2,X188Seq>) -> X188Seq:
  match body plan:
    case Nil{} _: x188_finish(out)
    case Con{PLabel{+label},Con{+a,Con{+b,Con{+c,+rest}}}} X193LTHeader{entry,home,zero,nonzero}:
      nt_choose(X188Seq,String.eq(label,entry),u =>
        x193lt_rewrite(rest,plan,Con{x188_many([x188_label(label),X188One{a},X188One{b},X188One{c},x188_label(nonzero)]),out}),
        u => x193lt_rewrite(Con{a,Con{b,Con{c,rest}}},plan,Con{x188_label(label),out}))
    case Con{PInst{X187Instruction{+move,[X187Imm{+lo,+hi},X187Reg{10,64,False{}}]}},
      Con{PInst{X187Instruction{+store,[X187Reg{10,64,False{}},+destination]}},
      Con{PInst{X187Instruction{+jump,[X187Target{+target}]}},+rest}}} X193LTHeader{entry,home,zero,nonzero}:
      nt_choose(X188Seq,String.eq(move,"movq") && String.eq(store,"movq") && String.eq(jump,"jmp") &&
        String.eq(target,entry) && x193lt_same(destination,home),u =>
        x193lt_rewrite(rest,plan,Con{x188_many([
          x188_i2(move,X187Imm{lo,hi},x188_reg(10,64)),x188_i2(store,x188_reg(10,64),destination),
          x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
          x188_i1("jmp",X187Target{nt_choose(String,U32.is_eq(lo,0),v => zero,v => nonzero)})]),out}),
        u => x193lt_rewrite(Con{PInst{X187Instruction{store,[x188_reg(10,64),destination]}},
          Con{PInst{X187Instruction{jump,[X187Target{target}]}},rest}},plan,
          Con{x188_i2(move,X187Imm{lo,hi},x188_reg(10,64)),out}))
    case Con{head,rest} _: x193lt_rewrite(rest,plan,Con{X188One{head},out})

@unsafe
def x193lt_planned(+original: X188Seq, +body: List<&2,X187Parsed>, plan: Maybe<&2,X193LTHeader>) -> X188Seq:
  match plan:
    case Some{+header}: nt_choose(X188Seq,x193lt_valid(body,header),u => x193lt_rewrite(body,header,[]),u => original)
    case None{}: original

@unsafe
def x193lt_flattened(+original: X188Seq, symbol: String, flat: Maybe<&2,List<&2,X187Parsed>>) -> X188Seq:
  match flat:
    case Some{+body}: x193lt_planned(original,body,x193lt_header(body,".L" ++ symbol ++ "_loop"))
    case None{}: original

@unsafe
def x193lt_thread_when(enabled: Bool, symbol: String, +code: X188Seq) -> X188Seq:
  nt_choose(X188Seq,enabled,u => x193lt_flattened(code,symbol,x193lt_flat([code],[],16384)),u => code)

@unsafe
def x193lt_thread(symbol: String, code: X188Seq) -> X188Seq:
  x193lt_thread_when(x193lt_enabled(),symbol,code)
