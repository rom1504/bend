import Base

type Payload is Type:
  Parcel{n: U32, text: String}

def answer(r: Result<&1, &1, Payload, Unit>) -> String:
  match r:
    case Done{u}: "unexpected send"
    case Fail{Parcel{n, text}}: U32.show(n) ++ ":" ++ text

def sender(+ch: Chan(Payload)) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, Payload, Unit> <- Chan.send(Payload, ch, Parcel{7, "kept"})
    return answer(r)

def close_waiter(+ch: Chan(Payload)) -> IO(Unit):
  do IO<Unit>:
    result : Chan(String) <- IO.fork(String, sender(ch))
    Unit <- IO.sleep(20)
    Unit <- Chan.close(Payload, ch)
    text : String <- IO.join(String, result)
    IO.print(text)

def run(room: U32) -> IO(Unit):
  do IO<Unit>:
    ch : Chan(Payload) <- Chan.new(Payload, room)
    close_waiter(ch)

def main() -> IO(Unit):
  run(0)

#|7:kept
