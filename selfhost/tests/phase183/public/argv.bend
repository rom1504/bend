import Base

def args_text(xs: List<String>) -> String:
  match xs:
    case Nil{}: ""
    case x <> rest: x ++ "|" ++ args_text(rest)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    IO.print(args_text(List.tail(&1, String, args)))

#|
