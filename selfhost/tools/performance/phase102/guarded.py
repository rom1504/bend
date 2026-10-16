"""Phase100 guard helper, with only the versioned long-argument guard substituted."""
from pathlib import Path
import shutil,subprocess,sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
PERF=ROOT/'selfhost/tools/performance'
sys.path.insert(0,str(PERF/'phase100'))
import run as R
pin,read,save=R.pin,R.read,R.save

def guarded(directory, argv, seconds=60, cpu='3'):
    assert shutil.disk_usage(ROOT).free > 512 * 1024**2, 'Need 512 MiB disk reserve'
    command = [sys.executable, '-B', str(Path(__file__).with_name('guard-long-args.py')),
               '--out', str(directory), '--seconds', str(seconds), '--cpu', cpu,
               '--rss-mib', '2048', '--available-mib', '4096', '--',
               sys.executable, '-B', str(PERF / 'phase46/execute.py'),
               str(directory / 'child.json'), *map(str, argv)]
    child = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    process = read(directory / 'process.json') if (directory / 'process.json').exists() else {}
    record = dict(guard=pin(directory / 'process.json') if process else None,
                  guardExit=child.returncode, process=process)
    if (directory / 'child.json').exists():
        inner = read(directory / 'child.json')
        record.update(receipt=pin(directory / 'child.json'),
                      seconds=inner['processSeconds'], rssKiB=inner['maxRssKiB'],
                      userSeconds=inner['userSeconds'], systemSeconds=inner['systemSeconds'])
    save(directory.parent / (directory.name + '-job.json'), record)
    assert child.returncode == 0 and process.get('complete') and not process.get('stoppedFor'), (
        'Target failed; inspect retained logs', str(directory), child.stderr)
    return record, inner

