import Base
import ./production-v01.bend as P

# Deliberately false: removing not without swapping the two branches.
law reject_unswapped_condition:
  {P.kc(Bool,Bool.not(False{}),u => True{},u => False{}) ==
   P.kc(Bool,False{},u => True{},u => False{}) : Bool}

def reject_unswapped_condition():
  {==}
