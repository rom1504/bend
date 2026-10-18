import Base
import ./candidate.bend as H

# Prepare candidate from unchanged IR model and the exact safe prefix of
# memory.bend before nx_m_pointer. These constrain helpers, not the whole pass.
law fresh_root_ranges:
  for +ao: U32
  for +aw: U32
  for +ae: U32
  for +bo: U32
  for +bw: U32
  for +be: U32
  {H.nx_m_disjoint(H.NxMAddr{0, ao, ae}, aw, H.NxMAddr{1, bo, be}, bw) == True{} : Bool}

def fresh_root_ranges(ao, aw, ae, bo, bw, be): {==}

law overlap_widths:
  for +ae: U32
  for +be: U32
  {H.nx_m_disjoint(H.NxMAddr{0, 0, ae}, 8, H.NxMAddr{0, 4, be}, 4) == False{} : Bool}

def overlap_widths(ae, be): {==}

law adjacent_widths:
  for +ae: U32
  for +be: U32
  {H.nx_m_disjoint(H.NxMAddr{0, 0, ae}, 4, H.NxMAddr{0, 4, be}, 8) == True{} : Bool}

def adjacent_widths(ae, be): {==}

law reverse_overlap_widths:
  for +ae: U32
  for +be: U32
  {H.nx_m_disjoint(H.NxMAddr{0, 4, ae}, 4, H.NxMAddr{0, 0, be}, 8) == False{} : Bool}

def reverse_overlap_widths(ae, be): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
