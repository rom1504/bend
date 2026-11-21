"""Use the independently expected Phase200 public shape probe, starting from original source."""
from pathlib import Path
import sys
import json
from hashlib import sha256
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent.parent/'phase200/tree'))
from controls import materialize
case,rows,expected=materialize('stock')
(HERE/'shape.bend').write_text(case)
(HERE/'shape.stdout').write_text(expected)
assert len(rows)==44 and sha256(expected.encode()).hexdigest()=='9f0f1e01f0437f8adac2fe79aa0bfa642b517050b94b41bec18b15e1cd0a25bd'
