"""Two independent, sequential guards authorized in the post-N2 serial slot."""
import subprocess
import sys
from pathlib import Path

jobs=[
 ['--rss-mib','3072','reuse-api02','90','96',
  'selfhost/.assets/bin/bun','selfhost/tools/build/hosted.mjs','acquire',
  '--source','selfhost/build/phase198/reuse-api-src02/compiler.bend','--exports','selfhost/build/phase198/reuse-api-src02/exports.json',
  '--out','selfhost/build/phase198/reuse-api02','--engine','selfhost/.assets/bin/bun','--upstream','selfhost/.bootstrap/upstream-phase182'],
 ['reuse-pairwise01','75','32',sys.executable,'-B','research/phase198/reuse/pairwise/screen.py','--out','selfhost/build/phase198/reuse-pairwise01'],
]
result=[subprocess.run([sys.executable,'-B','research/phase198/qualification/job.py',*job]).returncode for job in jobs]
raise SystemExit(max(result))
