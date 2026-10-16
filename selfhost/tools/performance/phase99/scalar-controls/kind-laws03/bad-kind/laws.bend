import Base
import ./candidate.bend as H

# Observe all transport metadata independently of the assigned scalar kinds.
type P99Slot is Data:
  P99Slot{+id: U32, +word: String}

def slots(bindings: List<&2, H.NC_Binding>) -> List<&2, P99Slot>:
  match bindings:
    case Nil{}: Nil{}
    case Con{H.NC_Binding{id, word, kind}, rest}: Con{P99Slot{id, word}, slots(rest)}

def first_kind(bindings: List<&2, H.NC_Binding>) -> H.N_WordKind:
  match bindings:
    case Nil{}: H.N_W64{}
    case Con{H.NC_Binding{id, word, kind}, rest}: kind

law slots_cons:
  for +slot: P99Slot
  for +xs: List<&2, P99Slot>
  for +ys: List<&2, P99Slot>
  for same: {xs == ys : List<&2, P99Slot>}
  {Con{slot, xs} == Con{slot, ys} : List<&2, P99Slot>}

def slots_cons(slot, xs, ys, same):
  %same : {Con{slot, xs} == Con{slot, _} : List<&2, P99Slot>}
  {==}

# Universal metadata preservation includes arbitrary duplicate IDs and names,
# unmatched tails and kind lists of either length.
law kind_transport_preserves_slots:
  for +bindings: List<&2, H.NC_Binding>
  for kinds: List<&2, H.N_WordKind>
  {slots(H.nk_typed_bindings(bindings, kinds)) == slots(bindings) : List<&2, P99Slot>}

def kind_transport_preserves_slots(bindings, kinds):
  match bindings kinds:
    case Nil{} Nil{}: {==}
    case Nil{} Con{kind, more}: {==}
    case Con{binding, rest} Nil{}: {==}
    case Con{H.NC_Binding{id, +word, old}, +rest} Con{kind, +more}:
      slots_cons(P99Slot{id, word}, slots(H.nk_typed_bindings(rest, more)), slots(rest), kind_transport_preserves_slots(rest, more))

# The supplied fact must actually reach the continuation binding. This says
# nothing about whether a runtime value justifies that fact.
law kind_transport_preserves_head_kind:
  for id: U32
  for word: String
  for old: H.N_WordKind
  for +kind: H.N_WordKind
  for rest: List<&2, H.NC_Binding>
  for more: List<&2, H.N_WordKind>
  {first_kind(H.nk_typed_bindings(Con{H.NC_Binding{id, word, old}, rest}, Con{kind, more})) == kind : H.N_WordKind}

def kind_transport_preserves_head_kind(id, word, old, kind, rest, more): {==}

law opaque_private_word_stays_term:
  {H.nf_param_type(H.N_W64{}) == "Term" : String}

def opaque_private_word_stays_term(): {==}

law opaque_private_box_stays_term:
  {H.nf_param_type(H.N_Box{}) == "Term" : String}

def opaque_private_box_stays_term(): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
