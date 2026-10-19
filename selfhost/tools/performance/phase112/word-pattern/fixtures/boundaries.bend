import Base

def word_tag(value: U32) -> U32:
  match value:
    case 0: 10
    case 1: 11
    case 2147483647: 12
    case 2147483648: 13
    case 4294967295: 14
    case _: 99

def char_tag(value: Char) -> U32:
  match value:
    case '\n': 20
    case 'λ': 21
    case '🙂': 22
    case _: 29

def line_tag(text: String) -> U32:
  match text:
    case SCon{'\n', tail}: 30
    case SCon{head, tail}: 31
    case SNil{}: 32

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(word_tag(0)))
    Unit <- IO.print(U32.show(word_tag(1)))
    Unit <- IO.print(U32.show(word_tag(2147483647)))
    Unit <- IO.print(U32.show(word_tag(2147483648)))
    Unit <- IO.print(U32.show(word_tag(4294967295)))
    Unit <- IO.print(U32.show(word_tag(2)))
    Unit <- IO.print(U32.show(word_tag(2147483649)))
    Unit <- IO.print(U32.show(word_tag(4294967294)))
    Unit <- IO.print(U32.show(char_tag('\n')))
    Unit <- IO.print(U32.show(char_tag('λ')))
    Unit <- IO.print(U32.show(char_tag('🙂')))
    Unit <- IO.print(U32.show(char_tag('x')))
    Unit <- IO.print(U32.show(line_tag(String.reverse("x\n"))))
    Unit <- IO.print(U32.show(line_tag(String.reverse("\nx"))))
    IO.print(U32.show(line_tag("")))

#|10
#|11
#|12
#|13
#|14
#|99
#|99
#|99
#|20
#|21
#|22
#|29
#|30
#|31
#|32
