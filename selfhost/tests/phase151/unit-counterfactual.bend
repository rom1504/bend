# Frozen-artifact causality probe; not a compiler optimization or general parser.
# The supervisor authenticates input and runtime-supplied pins by exact SHA256.
# This pure transform checks both bodies/counts; split/join retains all newlines.
type P151UBody is Data:
  P151UBad{}
  P151UBody{+rest: List<&2,String>, +out: List<&2,String>, ctors: U32, sinks: U32}
type P151UText is Data:
  P151UError{}
  P151UText{+text: String}

@unsafe
def p151u_line(+line: String, +rest: List<&2,String>, +pin: List<&2,String>, +out: List<&2,String>, +ctors: U32, +sinks: U32) -> P151UBody:
  kc(P151UBody,String.eq(line,"%v_p113i_1_local_value =l call $p111_rt_ctor(l %state, w 0, l %v_p113i_1_local_scratch, w 0)"),
    u => p151u_body(rest,pin,Con{"%v_p113i_1_local_value =l copy 72057594037927936",out},U32.inc(ctors),sinks),u =>
  kc(P151UBody,String.starts_with(line,"%v_p113i_1_local_ignored =l call $p111_rt_sink(l %state, l %v_p113i_1_local_v_"),
    u => p151u_body(rest,pin,Con{"%v_p113i_1_local_ignored =l copy 0",out},ctors,U32.inc(sinks)),
    u => p151u_body(rest,pin,Con{line,out},ctors,sinks)))

# A pin mismatch aborts the complete transformation. Pins were separately audited
# for exact Unit ctor / two alias copies / matching sink adjacency at every site.
@unsafe
def p151u_body(lines: List<&2,String>, pin: List<&2,String>, out: List<&2,String>, ctors: U32, sinks: U32) -> P151UBody:
  match lines pin:
    case rest Nil{}: P151UBody{rest,out,ctors,sinks}
    case Con{+line,rest} Con{expected,more}:
      kc(P151UBody,String.eq(line,expected),u => p151u_line(line,rest,more,out,ctors,sinks),u => P151UBad{})
    case _ _: P151UBad{}

@unsafe
def p151u_after(result: P151UBody, +expected: U32, roles: U32, binary: U32, rolesPin: String, binaryPin: String) -> P151UText:
  match result:
    case P151UBad{}: P151UError{}
    case P151UBody{rest,out,ctors,sinks}:
      kc(P151UText,U32.is_eq(ctors,expected) && U32.is_eq(sinks,expected),
        u => p151u_scan(rest,out,roles,binary,rolesPin,binaryPin),u => P151UError{})

@unsafe
def p151u_scan(lines: List<&2,String>, +out: List<&2,String>, +roles: U32, +binary: U32, +rolesPin: String, +binaryPin: String) -> P151UText:
  match lines:
    case Nil{}:
      kc(P151UText,U32.is_eq(roles,1) && U32.is_eq(binary,1),
        u => P151UText{String.join(List.reverse(&2,String,out),"\n")},u => P151UError{})
    case Con{+line,+rest}:
      kc(P151UText,String.eq(line,p151u_roles_header()),u =>
        kc(P151UText,U32.is_eq(roles,0),
          v => p151u_after(p151u_body(Con{line,rest},String.lines(rolesPin),out,0,0),22,1,binary,rolesPin,binaryPin),v => P151UError{}),u =>
      kc(P151UText,String.eq(line,p151u_binary_header()),u =>
        kc(P151UText,U32.is_eq(binary,0),
          v => p151u_after(p151u_body(Con{line,rest},String.lines(binaryPin),out,0,0),20,roles,1,rolesPin,binaryPin),v => P151UError{}),
        u => p151u_scan(rest,Con{line,out},roles,binary,rolesPin,binaryPin)))

@unsafe
def p151u_transform(text: String, rolesPin: String, binaryPin: String) -> P151UText:
  p151u_scan(String.lines(text),[],0,0,rolesPin,binaryPin)
