import Base

type Record is Data:
  Record{number: U32, text: String, marker: U32}

def fields(record: Record) -> U32 & String:
  match record:
    case Record{number, text, marker}:
      (U32.add(number, marker), String.reverse(text))

def emit(pair: U32 & String) -> IO(Unit):
  (number, text) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(number))
    IO.print(text)

def observe(+record: Record) -> IO(Unit):
  do IO<Unit>:
    Unit <- emit(fields(record))
    emit(fields(record))

def main() -> IO(Unit):
  observe(Record{4294967295, String.reverse("🙂cbaλ"), 3})

#|2
#|🙂cbaλ
#|2
#|🙂cbaλ
