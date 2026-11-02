# Private renderer experiments. No production declaration is replaced.
# Each repetition constructs and consumes a complete fresh result.

@unsafe
def p155r_byte(+value: U32, tail: String) -> String:
  "b " ++ U32.show(value) ++ ", " ++ tail

@unsafe
def p155r_utf8_char(+code: U32, +tail: String) -> String:
  nt_choose(String,U32.is_lt(code,128),u => p155r_byte(code,tail),u =>
    nt_choose(String,U32.is_lt(code,2048),u =>
      p155r_byte(U32.add(192,U32.shrn(code,6n)),p155r_byte(U32.add(128,U32.and(code,63)),tail)),u =>
      nt_choose(String,U32.is_lt(code,65536),u =>
        p155r_byte(U32.add(224,U32.shrn(code,12n)),p155r_byte(U32.add(128,U32.and(U32.shrn(code,6n),63)),
          p155r_byte(U32.add(128,U32.and(code,63)),tail))),u =>
        p155r_byte(U32.add(240,U32.shrn(code,18n)),p155r_byte(U32.add(128,U32.and(U32.shrn(code,12n),63)),
          p155r_byte(U32.add(128,U32.and(U32.shrn(code,6n),63)),p155r_byte(U32.add(128,U32.and(code,63)),tail)))))))

@unsafe
def p155r_utf8(text: String) -> String:
  match text:
    case SNil{}: "b 0"
    case SCon{head,rest}: p155r_utf8_char(Char.to_u32(head),p155r_utf8(rest))

@unsafe
def p155r_table_old(+name: String, text: String) -> String:
  p111q_data(P111QData{name,1,False{},p111q_utf8(text,[])})

@unsafe
def p155r_table_new(name: String, text: String) -> String:
  "data $" ++ name ++ " = align 1 { " ++ p155r_utf8(text) ++ " }\n"

@unsafe
def p155r_tables(names: List<&2,String>, +mode: Bool, +index: U32) -> String:
  match names:
    case Nil{}: ""
    case Con{+name,rest}:
      +symbol = "p111_cid_names_" ++ U32.show(index)
      nt_choose(String,mode,u => p155r_table_new(symbol,name),u => p155r_table_old(symbol,name)) ++
        p155r_tables(rest,mode,U32.inc(index))

@unsafe
def p155r_fused_loop(left: U32, +mode: Bool) -> String:
  match left:
    case 0: ""
    case _:
      p155r_tables(p155r_compiler_names(),mode,0) ++ p155r_tables(p155r_map_names(),mode,0) ++
        p155r_fused_loop(U32.sub(left,1),mode)

@unsafe
def p155r_fused_old(n: U32) -> String:
  p155r_fused_loop(n,False{})

@unsafe
def p155r_fused_new(n: U32) -> String:
  p155r_fused_loop(n,True{})

# Cache lifetime is exactly one actual owner. Building, searching, reading and
# destroying this cache are included; no formatted result survives a repetition.
type P155RName is Data:
  P155RName{+source: String, +rendered: String}

@unsafe
def p155r_lookup(names: List<&2,P155RName>, +name: String) -> String:
  match names:
    case Nil{}: ""
    case Con{P155RName{source,+rendered},+rest}:
      nt_choose(String,String.eq(source,name),u => rendered,u => p155r_lookup(rest,name))

@unsafe
def p155r_cache(names: List<&2,String>, +cache: List<&2,P155RName>) -> List<&2,P155RName>:
  match names:
    case Nil{}: cache
    case Con{+name,+rest}:
      nt_choose(List<&2,P155RName>,String.is_empty(p155r_lookup(cache,name)),
        u => p155r_cache(rest,Con{P155RName{name,p111q_local(name)},cache}),
        u => p155r_cache(rest,cache))

@unsafe
def p155r_locals_old(names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{name,rest}: p111q_local(name) ++ "\n" ++ p155r_locals_old(rest)

@unsafe
def p155r_locals_new(names: List<&2,String>, +cache: List<&2,P155RName>) -> String:
  match names:
    case Nil{}: ""
    case Con{name,rest}: p155r_lookup(cache,name) ++ "\n" ++ p155r_locals_new(rest,cache)

@unsafe
def p155r_local_units(units: List<&2,List<&2,String>>, +mode: Bool) -> String:
  match units:
    case Nil{}: ""
    case Con{+names,rest}:
      nt_choose(String,mode,u => p155r_locals_new(names,p155r_cache(names,[])),u => p155r_locals_old(names)) ++
        p155r_local_units(rest,mode)

@unsafe
def p155r_cached_loop(left: U32, +mode: Bool) -> String:
  match left:
    case 0: ""
    case _:
      p155r_local_units(p155r_local_inputs(),mode) ++ p155r_cached_loop(U32.sub(left,1),mode)

@unsafe
def p155r_cached_old(n: U32) -> String:
  p155r_cached_loop(n,False{})

@unsafe
def p155r_cached_new(n: U32) -> String:
  p155r_cached_loop(n,True{})

# Independent literal byte/spelling oracles, in addition to old/new equality.
@unsafe
def p155r_literal_controls() -> Bool:
  String.eq(p155r_utf8(""),"b 0") &&
  String.eq(p155r_utf8("A"),"b 65, b 0") &&
  String.eq(p155r_utf8("π商𐀀"),"b 207, b 128, b 229, b 149, b 134, b 240, b 144, b 128, b 128, b 0") &&
  String.eq(p155r_utf8(SCon{Char.from_u32(0),"\n"}),"b 0, b 10, b 0") &&
  String.eq(p155r_locals_new(["state","x","state","","商"],p155r_cache(["state","x","state","","商"],[])),
    "%state\n%v_x\n%state\n%v_\n%v_商\n")

# Exact literal fixtures appended from experiments/phase155/render/fixtures.json.

def p155r_compiler_names() -> List<&2,String>:
  ["Unit","False","True","LT","EQ","GT","Inl","Inr","Tuple","Zero","Succ","None","Some","Fail","Done","Ready","Wait","Nil","Con","WNil","WCon","U32","F32","Chr","SNil","SCon","ALeaf","ANode","Pix","Qua","Key","Mouse","Move","Look","Scroll","Close","MTip","MLeaf","MNode","File","Socket","Listener","Window","Audio","Chan","Emit","Halt","App","IO.print","IO.write","IO.print_err","IO.get_env","IO.args","Process.run","IO.random_u32","IO.spawn","IO.sleep","IO.now","IO.thread_count","Chan.new","Chan.send","Chan.recv","Chan.try_send","Chan.try_recv","Chan.close","File.open","File.read","File.read_bytes","File.read_at","File.size","File.write","File.write_bytes","File.close","TCP.listen","TCP.accept","TCP.try_accept","TCP.connect","TCP.send","TCP.try_send","TCP.recv","TCP.try_recv","TCP.send_bytes","TCP.try_send_bytes","TCP.recv_bytes","TCP.try_recv_bytes","UDP.bind","UDP.send_to","UDP.try_send_to","UDP.send_bytes_to","UDP.try_send_bytes_to","UDP.recv_from","UDP.try_recv_from","UDP.recv_bytes_from","UDP.try_recv_bytes_from","Socket.close","Listener.close","Window.open","Window.frame","Window.set_title","Window.grab","Window.close","Audio.open","Audio.write","Audio.close","U32.to_f32","F32.to_u32","F32.add","F32.sub","F32.mul","F32.div","F32.mod","F32.pow","F32.atan2","F32.neg","F32.abs","F32.sqrt","F32.exp","F32.log","F32.log2","F32.log10","F32.sin","F32.cos","F32.tan","F32.asin","F32.acos","F32.atan","F32.sinh","F32.cosh","F32.tanh","F32.floor","F32.ceil","F32.trunc","F32.is_eq","F32.is_ne","F32.is_lt","F32.is_le","F32.is_gt","F32.is_ge","F32.show","F32.bits","F32.read","Array.atomic.add","Array.atomic.min","Array.atomic.max","Array.atomic.and","Array.atomic.or","Array.atomic.xor","Array.atomic.exch","Array.atomic.cas","Array.atomic.fadd","$ctor.75_84_101_114_109_","$ctor.75_76_97_109_98_100_97_","$ctor.75_76_105_116_101_114_97_108_","$ctor.75_68_101_102_","$ctor.75_73_110_100_101_120_76_101_97_102_","$ctor.75_73_110_100_101_120_78_111_100_101_","$ctor.75_67_104_101_99_107_105_110_103_","$ctor.75_70_114_101_115_104_75_110_111_119_110_","$ctor.75_70_114_101_115_104_68_101_102_101_114_114_101_100_","$ctor.75_87_111_114_108_100_","$ctor.75_83_112_101_99_77_101_109_111_","$ctor.78_95_67_111_110_115_116_114_117_99_116_111_114_","$ctor.78_49_49_49_85_51_50_","$ctor.78_49_49_49_85_54_52_","$ctor.78_49_49_49_80_116_114_","$ctor.78_49_49_49_76_111_99_97_108_","$ctor.78_49_49_49_67_111_110_115_116_","$ctor.78_49_49_49_83_121_109_98_111_108_","$ctor.78_49_49_49_70_117_110_99_73_100_","$ctor.78_49_49_49_67_116_111_114_73_100_","$ctor.78_49_49_49_65_114_103_","$ctor.78_49_49_49_83_101_116_","$ctor.78_49_49_49_66_105_110_","$ctor.78_49_49_49_67_97_108_108_","$ctor.78_49_49_49_73_102_","$ctor.78_49_49_49_82_101_116_117_114_110_","$ctor.78_49_49_49_76_111_97_100_","$ctor.78_49_49_49_83_116_111_114_101_","$ctor.78_49_49_49_79_102_102_115_101_116_","$ctor.78_49_49_49_65_108_108_111_99_97_","$ctor.78_49_49_49_83_101_103_109_101_110_116_","$ctor.78_49_49_49_73_100_115_","$ctor.80_49_49_49_80_114_111_103_114_97_109_","$ctor.80_49_49_49_86_83_99_97_110_","$ctor.80_49_49_49_86_70_108_111_119_"]

def p155r_map_names() -> List<&2,String>:
  ["Unit","False","True","LT","EQ","GT","Inl","Inr","Tuple","Zero","Succ","None","Some","Fail","Done","Ready","Wait","Nil","Con","WNil","WCon","U32","F32","Chr","SNil","SCon","ALeaf","ANode","Pix","Qua","Key","Mouse","Move","Look","Scroll","Close","MTip","MLeaf","MNode","File","Socket","Listener","Window","Audio","Chan","Emit","Halt","App","IO.print","IO.write","IO.print_err","IO.get_env","IO.args","Process.run","IO.random_u32","IO.spawn","IO.sleep","IO.now","IO.thread_count","Chan.new","Chan.send","Chan.recv","Chan.try_send","Chan.try_recv","Chan.close","File.open","File.read","File.read_bytes","File.read_at","File.size","File.write","File.write_bytes","File.close","TCP.listen","TCP.accept","TCP.try_accept","TCP.connect","TCP.send","TCP.try_send","TCP.recv","TCP.try_recv","TCP.send_bytes","TCP.try_send_bytes","TCP.recv_bytes","TCP.try_recv_bytes","UDP.bind","UDP.send_to","UDP.try_send_to","UDP.send_bytes_to","UDP.try_send_bytes_to","UDP.recv_from","UDP.try_recv_from","UDP.recv_bytes_from","UDP.try_recv_bytes_from","Socket.close","Listener.close","Window.open","Window.frame","Window.set_title","Window.grab","Window.close","Audio.open","Audio.write","Audio.close","U32.to_f32","F32.to_u32","F32.add","F32.sub","F32.mul","F32.div","F32.mod","F32.pow","F32.atan2","F32.neg","F32.abs","F32.sqrt","F32.exp","F32.log","F32.log2","F32.log10","F32.sin","F32.cos","F32.tan","F32.asin","F32.acos","F32.atan","F32.sinh","F32.cosh","F32.tanh","F32.floor","F32.ceil","F32.trunc","F32.is_eq","F32.is_ne","F32.is_lt","F32.is_le","F32.is_gt","F32.is_ge","F32.show","F32.bits","F32.read","Array.atomic.add","Array.atomic.min","Array.atomic.max","Array.atomic.and","Array.atomic.or","Array.atomic.xor","Array.atomic.exch","Array.atomic.cas","Array.atomic.fadd"]

def p155r_local_inputs() -> List<&2,List<&2,String>>:
  [["state","state","v_4294942315","v_4294942314","p112_s_a","p112_s_b","value","scratch","value","state","scratch","reply"],["state","scratch","v_4294945447","state","scratch","scratch","value","state","scratch","reply"],["state","state","scratch","v_4294928633","scratch","v_4294928632","state","scratch","scratch","value","state","scratch","reply"]]
