import Base

# Ordinary renamed equality traversal; compiler selection must depend on the
# checked NO plan and fallback shape, never this function's name.
def coincide(left: String, right: String, same: Bool) -> Bool:
  match left right same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{head,tail} result: False{}
    case SCon{head,tail} SNil{} result: False{}
    case SCon{lh,lt} SCon{rh,rt} False{}: False{}
    case SCon{lh,lt} SCon{rh,rt} True{}:
      coincide(lt,rt,Char.is_eq(lh,rh))

def fresh_word(n: Nat) -> String:
  match n:
    case Zero{}: ""
    case Succ{rest}: String.append("α",fresh_word(rest))

def show_result(value: Bool) -> IO(Unit):
  IO.print(U32.show(Bool.to_u32(value)))

def shared_distinct(+left: String, +right: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- show_result(coincide(left,right,True{}))
    Unit <- IO.print(left)
    IO.print(right)

def mixed_roots(+left: String, right: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- show_result(coincide(left,right,True{}))
    IO.print(left)

def alias_only(+word: String) -> IO(Unit):
  show_result(coincide(word,word,True{}))

def alias_retained(+word: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- show_result(coincide(word,word,True{}))
    IO.print(word)

# Distinct retained roots share a dynamically allocated suffix. Both the equal
# case and an early mismatch must leave the shared descendant unchanged.
def p128bs_suffix(+suffix: String, +right_prefix: String) -> IO(Unit):
  +left = String.append("x",suffix)
  +right = String.append(right_prefix,suffix)
  do IO<Unit>:
    Unit <- show_result(coincide(left,right,True{}))
    Unit <- IO.print(left)
    Unit <- IO.print(right)
    IO.print(suffix)

# These retained entry names are useful refusal diagnostics. Neither should be
# mistaken for a checked tail-loop scalar observer.
def p128bs_after_recursion(left: String) -> Bool:
  match left:
    case SNil{}: True{}
    case SCon{head,tail}: Bool.not(p128bs_after_recursion(tail))

def p128bs_owned_result(left: String, right: String) -> String:
  left

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- show_result(coincide(fresh_word(3n),fresh_word(3n),True{}))
    Unit <- show_result(coincide(fresh_word(3n),fresh_word(2n),True{}))
    Unit <- show_result(coincide("αβ","αγ",True{}))
    Unit <- show_result(coincide("same","same",True{}))
    Unit <- shared_distinct(fresh_word(2n),fresh_word(2n))
    Unit <- mixed_roots(fresh_word(2n),fresh_word(2n))
    Unit <- alias_only(fresh_word(2n))
    Unit <- alias_retained(fresh_word(2n))
    Unit <- p128bs_suffix(fresh_word(2n),"x")
    Unit <- p128bs_suffix(fresh_word(2n),"y")
    Unit <- show_result(p128bs_after_recursion(fresh_word(2n)))
    IO.print(p128bs_owned_result("owned","discarded"))

#|1
#|0
#|0
#|1
#|1
#|αα
#|αα
#|1
#|αα
#|1
#|1
#|αα
#|1
#|xαα
#|xαα
#|αα
#|0
#|xαα
#|yαα
#|αα
#|1
#|owned
