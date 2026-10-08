import Base
import ./child.bend as C

# The root's dotted name is distinct from imported internal child:Box.
# Their display spelling is the same, so display text is not a recursion key.
type child.Box is Type:
  Root{value: C.Box}

def main() -> child.Box:
  Root{C.make()}

#|Error: main's type child.Box cannot be printed (a function, a Type, an erased or dependent field)
#|exit 1
