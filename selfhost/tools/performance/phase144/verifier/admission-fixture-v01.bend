# Small source-only admission discriminator. No verifier/datatype names from the
# compiler are recognized. Expected ordinary result42, if independently run.
import Base

type P144ProbeRow is Data:
  P144ProbeRow{value: U32, note: String}

def p144probe_default() -> P144ProbeRow:
  P144ProbeRow{0,"none"}

def p144probe_head(rows: List<&2,P144ProbeRow>) -> P144ProbeRow:
  match rows:
    case Nil{}: p144probe_default()
    case Con{head,rest}: head

def p144probe_value(rows: List<&2,P144ProbeRow>) -> U32:
  row: P144ProbeRow = p144probe_head(rows)
  match row:
    case P144ProbeRow{value,note}: value

def main() -> U32:
  p144probe_value([P144ProbeRow{42,"found"}])
