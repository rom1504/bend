import Base

def text_count(xs: List<String>) -> String:
  match xs:
    case Nil{}: "missing program"
    case program <> rest:
      Bool.show(Bool.not(String.is_empty(program))) ++ " " ++ Nat.show(List.length(&1, String, rest))

def byte_count(xs: List<List<&2, U32>>) -> String:
  match xs:
    case Nil{}: "missing program"
    case program <> rest:
      Bool.show(Nat.is_gt(List.length(&2, U32, program), 0n)) ++ " " ++ Nat.show(List.length(&1, List<&2, U32>, rest))

def main() -> IO(Unit):
  do IO<Unit>:
    a : List<String> <- IO.args()
    IO.print(text_count(a))
    b : List<List<&2, U32>> <- IO.args_bytes()
    IO.print(byte_count(b))

#|True 0
#|True 0
