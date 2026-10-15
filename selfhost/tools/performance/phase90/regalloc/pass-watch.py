#!/usr/bin/env python3
"""Bounded live Clang pass/RSS diagnostic; invoke ONLY inside the outer guard."""
import argparse, collections, hashlib, json, os, re, selectors, subprocess, sys, time
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('command', nargs=argparse.REMAINDER)
a = p.parse_args(); cmd = a.command[1:] if a.command[:1] == ['--'] else a.command
assert cmd and '-fdebug-pass-manager' in cmd
out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
start = time.monotonic(); events = collections.deque(maxlen=64); counts = collections.Counter()
state = dict(complete=False, compilerSucceeded=None, command=cmd, startedUnix=time.time(), stderrBytes=0,
             stderrLines=0, truncatedLineBytes=0, nonPassBytes=0, droppedCountKeys=0)
state['methodSha256'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
child = subprocess.Popen(cmd, stderr=subprocess.PIPE)  # Inherit outer guard process group.
state['childPid'] = child.pid; os.set_blocking(child.stderr.fileno(), False)
sel = selectors.DefaultSelector(); sel.register(child.stderr, selectors.EVENT_READ)
pending = b''; error_tail = b''; error_head_bytes = 0; last_pass = None; last_bisect = None
prefixes = ('Running pass:', 'Running analysis:', 'Invalidating analysis:',
            'Clearing all analysis results for:', 'Skipping pass:', 'BISECT:')
head = (out/'nonpass-head.log').open('wb', buffering=0)
samples = (out/'samples.jsonl').open('w', buffering=1)

def rss_tree(pid):
    todo, seen, rows = [pid], set(), []
    while todo:
        n = todo.pop()
        if n in seen: continue
        seen.add(n)
        try:
            status = Path(f'/proc/{n}/status').read_text()
            rss = next((int(l.split()[1])*1024 for l in status.splitlines() if l.startswith('VmRSS:')), 0)
            rows.append(dict(pid=n, rssBytes=rss))
            todo.extend(map(int, Path(f'/proc/{n}/task/{n}/children').read_text().split()))
        except (OSError, ValueError, StopIteration): pass
    return rows

def line(raw):
    global error_tail, error_head_bytes, last_pass, last_bisect
    state['stderrLines'] += 1
    text = raw.decode('utf-8', errors='replace').strip()
    if text.startswith(prefixes):
        event = dict(seconds=round(time.monotonic()-start, 6), text=text[:2048])
        events.append(event)
        key = re.sub(r'\(\d+\)', '(N)', text.split(' on ', 1)[0])[:240]
        if key not in counts and len(counts) >= 512:
            key = '<other>'; state['droppedCountKeys'] += 1
        counts[key] += 1
        if text.startswith('Running pass:'): last_pass = event
        if text.startswith('BISECT:'): last_bisect = event
    else:
        chunk = raw+b'\n'; state['nonPassBytes'] += len(chunk)
        keep = chunk[:max(0, 131072-error_head_bytes)]
        head.write(keep); error_head_bytes += len(keep)
        error_tail = (error_tail+chunk)[-65536:]

def snapshot():
    rows = rss_tree(child.pid)
    sample = dict(seconds=round(time.monotonic()-start, 6), unix=time.time(),
                  treeRssBytes=sum(r['rssBytes'] for r in rows), processes=rows,
                  lastPass=last_pass, lastBisect=last_bisect, stderrBytes=state['stderrBytes'])
    samples.write(json.dumps(sample, separators=(',', ':'))+'\n')
    report = dict(state, sample=sample, recentEvents=list(events), counts=dict(counts))
    temp = out/'state.tmp'; temp.write_text(json.dumps(report, indent=2)+'\n')
    temp.replace(out/'state.json')
    temp = out/'nonpass-tail.tmp'; temp.write_bytes(error_tail); temp.replace(out/'nonpass-tail.log')

next_sample = 0.0
while sel.get_map():
    now = time.monotonic()
    if now >= next_sample:
        snapshot(); next_sample = now+0.5
    for key, _ in sel.select(timeout=max(0.0, next_sample-time.monotonic())):
        data = os.read(key.fd, 65536)
        if not data:
            sel.unregister(key.fileobj)
            if pending: line(pending)
            pending = b''; continue
        state['stderrBytes'] += len(data)
        pieces = data.split(b'\n')
        for i, piece in enumerate(pieces):
            room = max(0, 8192-len(pending)); pending += piece[:room]
            state['truncatedLineBytes'] += max(0, len(piece)-room)
            if i < len(pieces)-1: line(pending); pending = b''
rc = child.wait(); state.update(complete=True, returncode=rc, compilerSucceeded=rc == 0)
snapshot(); samples.close(); head.close(); child.stderr.close(); sel.close()
print(json.dumps(dict(diagnostic=str(out), returncode=rc, stderrBytes=state['stderrBytes'])), flush=True)
sys.exit(rc if rc >= 0 else 128-rc)
