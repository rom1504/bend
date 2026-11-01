# Diagnostic only. All seven token fields and exact list shape are compared.
# Timing modes consume every token/text field; the external process clock also
# charges file input, output, runtime startup and any final reclamation.
type P150PObserved is Data:
  P150PObserved{count: U32, hash: U32}

type P150PControls is Data:
  P150PControls{pairs: U32, +error: String}

@unsafe
def p150p_token_same(a: FToken, b: FToken) -> Bool:
  match a b:
    case FToken{at,al,ac,ak,ab,ae,ap} FToken{bt,bl,bc,bk,bb,be,bp}:
      String.eq(at,bt) && U32.is_eq(al,bl) && U32.is_eq(ac,bc) && U32.is_eq(ak,bk) &&
        U32.is_eq(ab,bb) && U32.is_eq(ae,be) && U32.is_eq(ap,bp)

@unsafe
def p150p_same(a: List<&2,FToken>, b: List<&2,FToken>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}:
      f_choose(Bool,p150p_token_same(x,y),u => p150p_same(xs,ys),u => False{})
    case _ _: False{}

def p150p_word(value: U32, hash: U32) -> U32:
  U32.mul(U32.xor(hash,value),16777619)

@unsafe
def p150p_text(text: String, hash: U32) -> U32:
  match text:
    case SNil{}: p150p_word(1100000,hash)
    case SCon{head,rest}: p150p_text(rest,p150p_word(Char.to_u32(head),hash))

@unsafe
def p150p_token_hash(token: FToken, hash: U32) -> U32:
  match token:
    case FToken{text,line,column,kind,begin,end,previous}:
      p150p_word(previous,p150p_word(end,p150p_word(begin,p150p_word(kind,
        p150p_word(column,p150p_word(line,p150p_text(text,p150p_word(21,hash))))))))

@unsafe
def p150p_observe(tokens: List<&2,FToken>, count: U32, hash: U32) -> P150PObserved:
  match tokens:
    case Nil{}: P150PObserved{count,p150p_word(20,hash)}
    case Con{token,rest}: p150p_observe(rest,U32.add(count,1),p150p_token_hash(token,hash))

# These controls also challenge the observer itself: seven field mutants and
# two list-shape mutants must fail, while an unchanged complete token must pass.
@unsafe
def p150p_oracle_controls() -> Bool:
  +a : FToken = FToken{"x",1,2,3,4,5,6}
  p150p_token_same(a,a) &&
    Bool.not(p150p_token_same(a,FToken{"y",1,2,3,4,5,6})) &&
    Bool.not(p150p_token_same(a,FToken{"x",7,2,3,4,5,6})) &&
    Bool.not(p150p_token_same(a,FToken{"x",1,7,3,4,5,6})) &&
    Bool.not(p150p_token_same(a,FToken{"x",1,2,7,4,5,6})) &&
    Bool.not(p150p_token_same(a,FToken{"x",1,2,3,7,5,6})) &&
    Bool.not(p150p_token_same(a,FToken{"x",1,2,3,4,7,6})) &&
    Bool.not(p150p_token_same(a,FToken{"x",1,2,3,4,5,7})) &&
    Bool.not(p150p_same([a],[])) && Bool.not(p150p_same([],[a]))

@unsafe
def p150p_case(+text: String, +line: U32, +column: U32, +depth: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> Bool:
  p150p_same(f_lex_cursor(text,line,column,depth,acc,offset,previous),
    p150l_cursor(text,line,column,depth,acc,offset,previous))

@unsafe
def p150p_case_variants(+text: String) -> Bool:
  p150p_case(text,1,0,0,[],0,0) &&
    p150p_case(text,1,0,0,[],1,1) &&
    p150p_case(text,7,6,1,[FToken{"17n",7,3,1,100,103,91}],4294967294,103) &&
    p150p_case(text,7,6,0,[FToken{">op",6,0,0,9,10,6},FToken{"n",5,0,1,7,8,4}],4294967295,999) &&
    p150p_case(text,4294967295,4294967295,4294967295,[],2,7)

# Every input runs at legacy zero origin, ordinary origin, two near-wrap origins
# with nonempty reversed accumulators, and wrapped physical/depth coordinates.
@unsafe
def p150p_inputs() -> List<&2,String>:
  ["", "\0", "x\0y", "a", "a.b", ".", "..", ".a",
   "e-1", "name+2", "1e+2", "1E-2", "e+", "e+x", "e+2x",
   "-> => <- ++ <> == != <= >= && || << >>", ".&. .|. .^. <&>",
   "- = < ! & | > .& .| .^ <&", ".&x .<&>",
   "1n++foo", "1n++2n", "1n ++foo", "n+abc", "n +abc", "+_x +1 +λ",
   "a>>b a >> b a>b a > b", "> > > >", "     >      >>", "a\n >\n      >>",
   "\n", "\r\n", "\r", "\t\u{B}\u{C}", "([{}\n])\n", ")\n(\n", "}\n",
   "# comment", "a# comment\nb", "(# 😀\n x)\n", "# 😀\n>",
   "\"\"", "''", "'\\''", "\"\\\\\"", "\"a\\n\"", "\"a\nb\"x",
   "\"" ++ "\\" ++ "\n" ++ "\"x", "\"", "'", "\"abc\\", "x \"broken",
   "λ 猫 😀", "\"猫😀\"x", "'😀'", "\"\\u{1F600}\"", "\"\\u{XYZ}\"", "\"\\q\"",
   "\"abcd\"z", "abcd z", "++x", ">>x", "\n\n\n", "#ab\nx"]

@unsafe
def p150p_controls_loop(cases: List<&2,String>, +index: U32) -> P150PControls:
  match cases:
    case Nil{}: P150PControls{U32.mul(index,5),""}
    case Con{text,rest}:
      f_choose(P150PControls,p150p_case_variants(text),
        u => p150p_controls_loop(rest,U32.add(index,1)),
        u => P150PControls{U32.mul(index,5),"token mismatch in finite input " ++ U32.show(index)})

@unsafe
def p150p_controls() -> P150PControls:
  f_choose(P150PControls,p150p_oracle_controls(),
    u => p150p_controls_loop(p150p_inputs(),0),u => P150PControls{0,"exact comparator mutant control failed"})

@unsafe
def p150p_controls_done(result: P150PControls) -> IO(U32):
  match result:
    case P150PControls{pairs,+error}:
      f_choose(IO(U32),String.is_empty(error),
        u => p150p_controls_report(pairs),u => IO.die(U32,1,error))

@unsafe
def p150p_controls_report(pairs: U32) -> IO(U32):
  do IO<U32>:
    Unit <- IO.print("phase150 controls exact_pairs " ++ U32.show(pairs))
    Unit <- IO.print("phase150 controls oracle_checks 10")
    IO.pure(U32,0)

@unsafe
def p150p_lex(candidate: Bool, text: String) -> List<&2,FToken>:
  match candidate:
    case True{}: p150l_cursor(text,1,0,0,[],1,1)
    case False{}: f_lex_cursor(text,1,0,0,[],1,1)

# File reading and initial String creation finish before the first local clock.
@unsafe
def p150p_file(label: String, path: String, candidate: Bool) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(path)
    started : Nat <- IO.now()
    p150p_lexed(label,started,p150p_lex(candidate,text))

@unsafe
def p150p_lexed(label: String, started: Nat, tokens: List<&2,FToken>) -> IO(U32):
  do IO<U32>:
    lexed : Nat <- IO.now()
    p150p_observed(label,started,lexed,p150p_observe(tokens,0,2166136261))

@unsafe
def p150p_observed(label: String, +started: Nat, +lexed: Nat, result: P150PObserved) -> IO(U32):
  match result:
    case P150PObserved{count,hash}:
      do IO<U32>:
        +finished : Nat <- IO.now()
        Unit <- IO.print("phase150 mode " ++ label)
        Unit <- IO.print("phase150 lex_ms " ++ Nat.show(Nat.sub(lexed,started)))
        Unit <- IO.print("phase150 observe_ms " ++ Nat.show(Nat.sub(finished,lexed)))
        Unit <- IO.print("phase150 region_ms " ++ Nat.show(Nat.sub(finished,started)))
        Unit <- IO.print("phase150 tokens " ++ U32.show(count))
        Unit <- IO.print("phase150 hash " ++ U32.show(hash))
        IO.pure(U32,0)

@unsafe
def p150p_compare_file(path: String) -> IO(U32):
  do IO<U32>:
    +text : String <- p86_read_file(path)
    started : Nat <- IO.now()
    p150p_compare_ready(started,f_lex_cursor(text,1,0,0,[],1,1),p150l_cursor(text,1,0,0,[],1,1))

@unsafe
def p150p_compare_ready(started: Nat, +left: List<&2,FToken>, +right: List<&2,FToken>) -> IO(U32):
  do IO<U32>:
    lexed : Nat <- IO.now()
    p150p_compared(started,lexed,left,right,p150p_same(left,right))

@unsafe
def p150p_compared(started: Nat, lexed: Nat, left: List<&2,FToken>, right: List<&2,FToken>, same: Bool) -> IO(U32):
  match same:
    case False{}: IO.die(U32,1,"complete file token lists differ")
    case True{}:
      p150p_compare_summary(started,lexed,p150p_observe(left,0,2166136261),p150p_observe(right,0,2166136261))

@unsafe
def p150p_compare_summary(+started: Nat, +lexed: Nat, a: P150PObserved, b: P150PObserved) -> IO(U32):
  match a b:
    case P150PObserved{+count,+hash} P150PObserved{other,otherHash}:
      f_choose(IO(U32),U32.is_eq(count,other) && U32.is_eq(hash,otherHash),
        u => p150p_compare_report(started,lexed,count,hash),u => IO.die(U32,1,"equal token lists have unequal observations"))

@unsafe
def p150p_compare_report(+started: Nat, +lexed: Nat, count: U32, hash: U32) -> IO(U32):
  do IO<U32>:
    +finished : Nat <- IO.now()
    Unit <- IO.print("phase150 compare exact_equal true")
    Unit <- IO.print("phase150 both_lex_ms " ++ Nat.show(Nat.sub(lexed,started)))
    Unit <- IO.print("phase150 compare_observe_ms " ++ Nat.show(Nat.sub(finished,lexed)))
    Unit <- IO.print("phase150 region_ms " ++ Nat.show(Nat.sub(finished,started)))
    Unit <- IO.print("phase150 tokens " ++ U32.show(count))
    Unit <- IO.print("phase150 hash " ++ U32.show(hash))
    IO.pure(U32,0)

@unsafe
def p150p_dispatch(mode: String, path: String) -> IO(U32):
  match mode:
    case "reference": p150p_file("reference",path,False{})
    case "candidate": p150p_file("candidate",path,True{})
    case "compare": p150p_compare_file(path)
    case "controls": p150p_controls_done(p150p_controls())
    case _: IO.die(U32,2,"expected reference, candidate, compare or controls")

@unsafe
def p150p_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{mode,Con{path,Nil{}}}}: p150p_dispatch(mode,path)
    case _: IO.die(U32,2,"expected IGNORED MODE PATH")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p150p_args(args)
