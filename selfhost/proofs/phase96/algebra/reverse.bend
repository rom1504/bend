import Base
import ./list.bend as L

# The accumulator and list order are those of the actual Base implementation.
law reverse_accumulator:
  for -A: Data
  for +xs: List<&2, A>
  for +acc: List<&2, A>
  {List.append(&2, A, List.reverse.go(&2, A, xs, Nil{}), acc) == List.reverse.go(&2, A, xs, acc) : List<&2, A>}

def reverse_accumulator(A, xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %reverse_accumulator(A, rest, head <> acc) : {List.append(&2, A, List.reverse.go(&2, A, rest, [head]), acc) == _ : List<&2, A>}
      %reverse_accumulator(A, rest, [head]) : {List.append(&2, A, _, acc) == List.append(&2, A, List.reverse.go(&2, A, rest, Nil{}), head <> acc) : List<&2, A>}
      %L.append_associative(A, List.reverse.go(&2, A, rest, Nil{}), [head], acc) : {List.append(&2, A, List.append(&2, A, List.reverse.go(&2, A, rest, Nil{}), [head]), acc) == _ : List<&2, A>}
      {==}

# Supporting induction lemma, not a separately counted public law.
law reverse_append_acc:
  for -A: Data
  for +xs: List<&2, A>
  for +ys: List<&2, A>
  {List.append(&2, A, List.reverse.go(&2, A, ys, Nil{}), List.reverse.go(&2, A, xs, Nil{})) == List.reverse.go(&2, A, List.append(&2, A, xs, ys), Nil{}) : List<&2, A>}

def reverse_append_acc(A, xs, ys):
  match xs:
    case Nil{}: reverse_accumulator(A, ys, Nil{})
    case Con{+head, +rest}:
      %reverse_accumulator(A, List.append(&2, A, rest, ys), [head]) : {List.append(&2, A, List.reverse.go(&2, A, ys, Nil{}), List.reverse.go(&2, A, rest, [head])) == _ : List<&2, A>}
      %reverse_append_acc(A, rest, ys) : {List.append(&2, A, List.reverse.go(&2, A, ys, Nil{}), List.reverse.go(&2, A, rest, [head])) == List.append(&2, A, _, [head]) : List<&2, A>}
      %reverse_accumulator(A, rest, [head]) : {List.append(&2, A, List.reverse.go(&2, A, ys, Nil{}), _) == List.append(&2, A, List.append(&2, A, List.reverse.go(&2, A, ys, Nil{}), List.reverse.go(&2, A, rest, Nil{})), [head]) : List<&2, A>}
      %L.append_associative(A, List.reverse.go(&2, A, ys, Nil{}), List.reverse.go(&2, A, rest, Nil{}), [head]) : {_ == List.append(&2, A, List.append(&2, A, List.reverse.go(&2, A, ys, Nil{}), List.reverse.go(&2, A, rest, Nil{})), [head]) : List<&2, A>}
      {==}

law reverse_append:
  for -A: Data
  for +xs: List<&2, A>
  for +ys: List<&2, A>
  {List.append(&2, A, List.reverse(&2, A, ys), List.reverse(&2, A, xs)) == List.reverse(&2, A, List.append(&2, A, xs, ys)) : List<&2, A>}

def reverse_append(A, xs, ys):
  reverse_append_acc(A, xs, ys)

law reverse_involution:
  for -A: Data
  for +xs: List<&2, A>
  {List.reverse(&2, A, List.reverse(&2, A, xs)) == xs : List<&2, A>}

def reverse_involution(A, xs):
  match xs:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %reverse_accumulator(A, rest, [head]) : {List.reverse.go(&2, A, _, Nil{}) == head <> rest : List<&2, A>}
      %reverse_append_acc(A, List.reverse.go(&2, A, rest, Nil{}), [head]) : {_ == head <> rest : List<&2, A>}
      %reverse_involution(A, rest) : {List.append(&2, A, [head], List.reverse.go(&2, A, List.reverse.go(&2, A, rest, Nil{}), Nil{})) == head <> _ : List<&2, A>}
      {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
