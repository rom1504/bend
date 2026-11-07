"""Fixed harmless supervisor controls, no compiler jobs or detached children."""
import sys
import time
if sys.argv[1:] == ['pass']:
    time.sleep(.1)
elif sys.argv[1:] == ['fail']:
    raise SystemExit(7)
elif sys.argv[1:] == ['timeout']:
    time.sleep(3)
else:
    raise SystemExit(2)
