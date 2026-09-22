#!/usr/bin/env python3
"""Report wait4 resources without changing the native child's exit semantics."""
import os
import signal
import sys
import time

started = time.monotonic()
pid = os.fork()
if pid == 0:
    try:
        os.execv(sys.argv[1], sys.argv[1:])
    except OSError as error:
        print(str(error), file=sys.stderr, flush=True)
        os._exit(127)
_, status, usage = os.wait4(pid, 0)
print(f"ANNOTATION_RESOURCE wall={time.monotonic()-started:.6f} user={usage.ru_utime:.6f} sys={usage.ru_stime:.6f} rssKiB={usage.ru_maxrss}", file=sys.stderr, flush=True)
code = os.waitstatus_to_exitcode(status)
if code < 0:
    signal.signal(-code, signal.SIG_DFL)
    os.kill(os.getpid(), -code)
sys.exit(code)
