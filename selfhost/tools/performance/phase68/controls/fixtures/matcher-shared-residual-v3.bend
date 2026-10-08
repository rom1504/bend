# Successor of the preserved failing fixture: full-argument matcher syntax
# and an explicit constructor type at the shared let. Same ownership witness.
import Base

type TextBox68 is Data:
  TextBox68{value: String}

def append_boxes68(box: TextBox68, other: TextBox68) -> String:
  match box:
    case TextBox68{prefix}:
      match other:
        case TextBox68{suffix}:
          String.append(prefix, suffix)

def call_box68(f: TextBox68 -> String, box: TextBox68) -> String:
  f(box)

def main() -> String:
  +box = {TextBox68{"keep"} : TextBox68}
  String.append(append_boxes68(box, box), call_box68(append_boxes68(box), box))

#|"keepkeepkeepkeep"
