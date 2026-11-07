import Base

# REJECTED SOURCE PROPOSAL. Do not execute as a successful trace control.
# IO.print builds a foreign request; only the runtime IO event loop handles it.
# An ordinary IO.OP match below cannot execute that request: it fail-stops when
# the value is neither Emit nor Halt. See bend2/comp.ts:1146 (mat_ctrs).
# Preserved as a negative architectural finding; no target was run.
type P173EffectBox is Data:
  P173EffectValue{+value: U32, +stamp: U32}
  P173EffectIgnored{+stamp: U32}

def p173oe_get(box: P173EffectBox) -> U32:
  match box:
    case P173EffectValue{value,stamp}: value
    case P173EffectIgnored{stamp}: 0

def p173oe_set(box: P173EffectBox, replacement: U32) -> P173EffectBox:
  match box:
    case P173EffectValue{value,stamp}: P173EffectValue{replacement,stamp}
    case P173EffectIgnored{stamp}: P173EffectIgnored{stamp}

def p173oe_stamp(box: P173EffectBox) -> U32:
  match box:
    case P173EffectValue{value,stamp}: stamp
    case P173EffectIgnored{stamp}: stamp

def p173oe_extract(operation: IO.OP<U32>) -> U32:
  match operation:
    case Emit{value}: value
    case Halt{code,message}: code

def p173oe_worker(+value: U32) -> U32:
  p173oe_extract(IO.print("worker:" ++ U32.show(value),U32,
    unit => Emit{U32.add(value,1)}))

def p173oe_change(+box: P173EffectBox) -> P173EffectBox:
  p173oe_set(box,p173oe_worker(p173oe_get(box)))

def main() -> IO(U32):
  do IO<U32>:
    Unit <- IO.print("before")
    +original : P173EffectBox = P173EffectValue{5,9}
    +changed : P173EffectBox = p173oe_change(original)
    Unit <- IO.print("after:" ++ U32.show(p173oe_get(changed)) ++ ":" ++ U32.show(p173oe_get(original)))
    +ignored : P173EffectBox = p173oe_change(P173EffectIgnored{7})
    Unit <- IO.print("ignored:" ++ U32.show(p173oe_stamp(ignored)))
    IO.pure(U32,0)

# WITHDRAWN predicted stdout/exit0 (invalid operational premise):
# before
# worker:5
# after:6:5
# worker:0
# ignored:7
# These lines are not an oracle. Use owned-decomposition-io.bend/.stdout for
# the legal IO.bind-based gate, whose transformed composition is pure and whose
# separate genuine IO-worker reference preserves the effect trace explicitly.
