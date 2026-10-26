# V02 moves a forbidden local-binder match into a parameter match.
# V01 and its parser refusal remain preserved. Expected ordinary result42.
import Base

type P144ProbeRow is Data:
  P144ProbeRow{value: U32, note: String}

def p144probe_default() -> P144ProbeRow:
  P144ProbeRow{0,"none"}

def p144probe_head(rows: List<&2,P144ProbeRow>) -> P144ProbeRow:
  match rows:
    case Nil{}: p144probe_default()
    case Con{head,rest}: head

def p144probe_project(row: P144ProbeRow) -> U32:
  match row:
    case P144ProbeRow{value,note}: value

def p144probe_value(rows: List<&2,P144ProbeRow>) -> U32:
  p144probe_project(p144probe_head(rows))

def main() -> U32:
  p144probe_value([P144ProbeRow{42,"found"}])
