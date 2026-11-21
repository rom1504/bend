import json,sys,subprocess,time
from pathlib import Path
for file in sys.argv[1:]:
    p=Path(file);args=json.loads(p.read_bytes())
    print('START',p.name,time.strftime('%H:%M:%S',time.gmtime()),flush=True)
    rc=subprocess.run(args).returncode
    print('END',p.name,rc,time.strftime('%H:%M:%S',time.gmtime()),flush=True)
    if rc: sys.exit(rc)
