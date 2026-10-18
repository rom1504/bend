import Base
import ./model.bend as M

# Frozen direct meaning of consume, construct and transfer. This deliberately
# does not call the candidate selector, reuse test, claim, take or fused helper.
# The Bool result is permission to overwrite the consumed parent allocation;
# it is not an observation that the unfused implementation reused an address.
def reference_value(child: M.NxoLawChild) -> String:
  match child:
    case M.NxoLawTrivial{value}: value
    case M.NxoLawHeapChild{value, aliases}: value

def reference_claim(child: M.NxoLawChild) -> M.NxoLawChild:
  match child:
    case M.NxoLawTrivial{value}: M.NxoLawTrivial{value}
    case M.NxoLawHeapChild{value, aliases}: M.NxoLawHeapChild{value, 1n+aliases}

def reference_finish(tag: U32, keep_first: Bool, first: M.NxoLawChild, second: M.NxoLawChild, other: M.NxoLawChild, aliases: M.NxoLawAliases, reuse: Bool) -> M.NxoLawResult:
  match keep_first:
    case True{}: M.NxoLawResult{reuse, tag, first, other, second, aliases, False{}}
    case False{}: M.NxoLawResult{reuse, tag, second, other, first, aliases, False{}}

def consume_build_transfer(tag: U32, keep_first: Bool, parent: M.NxoLawParent, other: M.NxoLawChild) -> M.NxoLawResult:
  match parent:
    case M.NxoLawUnique{first, second}:
      reference_finish(tag, keep_first, first, second, other, M.NxoLawGone{}, True{})
    case M.NxoLawShared{extra, +first, +second}:
      reference_finish(tag, keep_first, reference_claim(first), reference_claim(second), other,
        M.NxoLawLiveAliases{1n+extra, reference_value(first), reference_value(second)}, False{})
    case M.NxoLawImmortal{+first, +second}:
      reference_finish(tag, keep_first, M.NxoLawTrivial{first}, M.NxoLawTrivial{second}, other,
        M.NxoLawStaticAliases{first, second}, False{})
