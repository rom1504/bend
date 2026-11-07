import Base
type P173EffectRow is Data:
  P173EffectRow{+child: String, +backup: String}
  P173EffectVacant{+tag: U32}

def p173io_get(row: P173EffectRow) -> String:
  match row:
    case P173EffectRow{child,backup}: child
    case P173EffectVacant{tag}: ""

def p173io_set(row: P173EffectRow, value: String) -> P173EffectRow:
  match row:
    case P173EffectRow{child,backup}: P173EffectRow{value,backup}
    case P173EffectVacant{tag}: P173EffectVacant{tag}

def p173io_value(text: String) -> String:
  text ++ "!"

def p173io_change(+row: P173EffectRow) -> P173EffectRow:
  p173io_set(row,p173io_value(p173io_get(row)))

def p173io_show(row: P173EffectRow) -> String:
  match row:
    case P173EffectRow{child,backup}: "row:" ++ child ++ ":" ++ backup
    case P173EffectVacant{tag}: "vacant:" ++ U32.show(tag)

def p173io_worker(+text: String) -> IO(String):
  do IO<String>:
    Unit <- IO.print("F:" ++ text)
    IO.pure(String,p173io_value(text))

def p173io_effect(+row: P173EffectRow) -> IO(P173EffectRow):
  do IO<P173EffectRow>:
    value : String <- p173io_worker(p173io_get(row))
    IO.pure(P173EffectRow,p173io_set(row,value))

def main() -> IO(Unit):
  +child : String = "seed"
  +root : P173EffectRow = P173EffectRow{child,child}
  do IO<Unit>:
    Unit <- IO.print("begin")
    Unit <- IO.print(p173io_show(p173io_change(root)))
    Unit <- IO.print(p173io_show(root))
    Unit <- IO.print("child:" ++ child)
    Unit <- IO.print(p173io_show(p173io_change(P173EffectVacant{7})))
    changed : P173EffectRow <- p173io_effect(root)
    Unit <- IO.print(p173io_show(changed))
    vacant : P173EffectRow <- p173io_effect(P173EffectVacant{7})
    Unit <- IO.print(p173io_show(vacant))
    IO.print("end")
