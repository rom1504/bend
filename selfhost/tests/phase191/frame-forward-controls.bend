# Independent exact-text assertions plus executable typed functions. Every
# control must end '=1'; p191ff_emit supplies one shared typed output for both
# object and assembly consumers. No source IR or allocator test helper needed.
def p191ff_store(source: U32) -> X188Seq:
  x188_i2("movq",x188_reg(source,64),X187Mem{5,4294967288})

def p191ff_load(destination: U32) -> X188Seq:
  x188_i2("movq",X187Mem{5,4294967288},x188_reg(destination,64))

@unsafe
def p191ff_case(name: String, input: X188Seq, expected: X188Seq) -> String:
  name ++ nt_choose(String,String.eq(x188_render(x191_frame_forward_when(True{},input)),x188_render(expected)),
    u => "=1",u => "=0")

@unsafe
def p191ff_unchanged(name: String, +input: X188Seq) -> String:
  p191ff_case(name,input,input)

@unsafe
def p191ff_barrier(name: String, barrier: X188Seq) -> String:
  p191ff_unchanged(name,x188_many([p191ff_store(7),barrier,p191ff_load(0)]))

@unsafe
def p191ff_controls() -> List<&2,String>:
  +pair: X188Seq = x188_cat(p191ff_store(7),p191ff_load(0))
  [p191ff_case("identity",x188_cat(p191ff_store(7),p191ff_load(7)),p191ff_store(7)),
   p191ff_case("different-register",pair,x188_cat(p191ff_store(7),x188_i2("movq",x188_reg(7,64),x188_reg(0,64)))),
   p191ff_case("extended-register",x188_cat(p191ff_store(10),p191ff_load(11)),
     x188_cat(p191ff_store(10),x188_i2("movq",x188_reg(10,64),x188_reg(11,64)))),
   "disabled" ++ nt_choose(String,String.eq(x188_render(x191_frame_forward_when(False{},pair)),x188_render(pair)),u => "=1",u => "=0"),
   p191ff_barrier("label-barrier",x188_label("label")),
   p191ff_barrier("empty-item-barrier",X188One{PEmpty{}}),
   p191ff_barrier("align-barrier",X188One{PAlign{8}}),
   p191ff_barrier("call-barrier",x188_i1("call",X187Target{"callee"})),
   p191ff_barrier("clobber-barrier",x188_i2("xorq",x188_reg(7,64),x188_reg(7,64))),
   p191ff_barrier("alias-store-barrier",x188_i2("movq",x188_reg(6,64),X187Mem{1,0})),
   p191ff_barrier("byte-overlap-barrier",x188_i2("movb",x188_reg(6,8),X187Mem{5,4294967289})),
   p191ff_unchanged("narrow-load",x188_cat(p191ff_store(7),x188_i2("movl",X187Mem{5,4294967288},x188_reg(7,32)))),
   p191ff_unchanged("narrow-store",x188_cat(x188_i2("movl",x188_reg(7,32),X187Mem{5,4294967288}),p191ff_load(0))),
   p191ff_unchanged("different-slot",x188_cat(p191ff_store(7),x188_i2("movq",X187Mem{5,4294967280},x188_reg(0,64)))),
   p191ff_unchanged("source-rbp",x188_cat(p191ff_store(5),p191ff_load(0))),
   p191ff_unchanged("source-rsp",x188_cat(p191ff_store(4),p191ff_load(0))),
   p191ff_unchanged("destination-rbp",x188_cat(p191ff_store(7),p191ff_load(5))),
   p191ff_unchanged("destination-rsp",x188_cat(p191ff_store(7),p191ff_load(4))),
   p191ff_unchanged("positive-offset",x188_many([x188_i2("movq",x188_reg(7,64),X187Mem{5,16}),x188_i2("movq",X187Mem{5,16},x188_reg(0,64))])),
   p191ff_unchanged("rsp-base",x188_many([x188_i2("movq",x188_reg(7,64),X187Mem{4,0}),x188_i2("movq",X187Mem{4,0},x188_reg(0,64))])),
   p191ff_case("association",X188Join{X188Join{p191ff_store(7),X188Empty{}},X188Join{X188Empty{},p191ff_load(0)}},
     x188_cat(p191ff_store(7),x188_i2("movq",x188_reg(7,64),x188_reg(0,64))))]

@unsafe
def p191ff_function(+name: String, body: X188Seq) -> X188Seq:
  x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),
    x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{16,0},x188_reg(4,64)),body,
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),X188One{PSize{name}}])

@unsafe
def p191ff_emit() -> X181Output:
  +code: X188Seq = x188_many([X188One{PSection{1}},
    p191ff_function("p191ff_identity",x188_many([p191ff_store(7),p191ff_load(7),x188_i2("movq",x188_reg(7,64),x188_reg(0,64))])),
    p191ff_function("p191ff_transfer",x188_cat(p191ff_store(7),p191ff_load(0))),
    p191ff_function("p191ff_narrow",x188_many([p191ff_store(7),x188_i2("movl",X187Mem{5,4294967288},x188_reg(7,32)),x188_i2("movq",x188_reg(7,64),x188_reg(0,64))])),
    p191ff_function("p191ff_clobber",x188_many([p191ff_store(7),x188_i2("xorq",x188_reg(7,64),x188_reg(7,64)),p191ff_load(0)])),
    p191ff_function("p191ff_alias",x188_many([x188_i2("leaq",X187Mem{5,4294967288},x188_reg(1,64)),p191ff_store(7),
      x188_i2("movq",x188_reg(6,64),X187Mem{1,0}),p191ff_load(0)])),
    p191ff_function("p191ff_overlap",x188_many([p191ff_store(7),x188_i2("movb",x188_reg(6,8),X187Mem{5,4294967289}),p191ff_load(0)])),
    p191ff_function("p191ff_flags",x188_many([x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),p191ff_store(7),p191ff_load(0),
      x188_i1("setb",x188_reg(0,8)),x188_i2("movzbl",x188_reg(0,8),x188_reg(0,32))])),
    p191ff_function("p191ff_label",x188_many([p191ff_store(7),x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
      x188_i1("je",X187Target{".Lp191ff_join"}),p191ff_store(6),x188_label(".Lp191ff_join"),p191ff_load(0)])),
    p191ff_function("p191ff_call",x188_many([p191ff_store(7),x188_i1("call",X187Target{"p191ff_clobber"}),p191ff_load(0)])),
    X188One{PSection{4}}])
  X181Output{[x191_frame_forward_when(True{},code)],""}
