# A second owned payload/call/resume shape with two independent recursive calls.
import Base

type Archive124 is Data:
  Page124{words: List<&2, U32>}
  Branch124{words: List<&2, U32>, left: Archive124, right: Archive124}

def archive.stamp(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: acc
    case h <> t: archive.stamp(t, U32.add(U32.mul(h, 7), 11) <> acc)

def archive.join(xs: List<&2, U32>, ys: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: ys
    case h <> t: h <> archive.join(t, ys)

def archive.collect(tree: Archive124) -> List<&2, U32>:
  match tree:
    case Page124{words}: archive.stamp(words, Nil{})
    case Branch124{words, left, right}:
      head = archive.stamp(words, Nil{})
      front = archive.collect(left)
      back = archive.collect(right)
      archive.join(head, archive.join(front, back))

def archive.grow(n: Nat, +seed: U32, acc: Archive124) -> Archive124:
  match n:
    case 0n: acc
    case 1n+p:
      archive.grow(p, U32.add(seed, 1), Branch124{[seed], acc, Page124{[U32.add(seed, 1)]}})

def archive.words(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case h <> t: U32.show(h) ++ ";" ++ archive.words(t)

def archive.show(tree: Archive124) -> String:
  match tree:
    case Page124{words}: "P[" ++ archive.words(words) ++ "]"
    case Branch124{words, left, right}:
      "B[" ++ archive.words(words) ++ "](" ++ archive.show(left) ++ ")(" ++ archive.show(right) ++ ")"

def archive.check(+tree: Archive124) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(archive.words(archive.collect(tree)))
    IO.print(archive.show(tree))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- archive.check(Page124{[]})
    Unit <- archive.check(Page124{[4294967295, 0, 1]})
    Unit <- archive.check(Branch124{[3, 4294967295], Page124{[0, 2]}, Branch124{[], Page124{[7]}, Page124{[]}}})
    archive.check(archive.grow(2048n, 0, Page124{[4294967295]}))
