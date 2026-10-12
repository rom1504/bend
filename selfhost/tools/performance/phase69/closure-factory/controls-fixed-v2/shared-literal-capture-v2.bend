import Base

def pipe(f: String -> String, g: String -> String, x: String) -> String:
  g(f(x))

type Stored69 is Type:
  Stored69{f: String -> String}

def run_stored(s: Stored69) -> String:
  match s:
    case Stored69{f}:
      f("q")

def main() -> IO(Unit):
  +prefix = {"p" : String}
  f = {pipe(x => String.append(prefix, x), x => String.append(x, "!")) : String -> String}
  IO.print(String.append(run_stored(Stored69{f}), prefix))

#|pq!p
