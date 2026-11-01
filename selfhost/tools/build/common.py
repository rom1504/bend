"""Small identity and child-process helpers; the outer disk guard owns resources."""
import hashlib
import json
import math
import os
from pathlib import Path
import signal
import subprocess
import threading
import time

ROOT = Path(__file__).resolve().parents[3]
DIAGNOSTIC_ENV = ('LD_PRELOAD', 'BEND_SAMPLE_OUT', 'BEND_SAMPLE_CONTEXT_OUT',
                  'BEND_PROFILE_EVENTS_OUT', 'BEND_PROFILE_COUNTERS')


def require(value, message):
    if not value:
        raise ValueError(message)


def workspace(value=None):
    root = Path(value or ROOT).resolve(strict=True)
    require((root / 'selfhost').is_dir(), 'Explicit workspace must contain selfhost/')
    return root


def pin(value):
    path = Path(value).resolve(strict=True)
    digest, size = hashlib.sha256(), 0
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
            size += len(block)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def verify(row):
    got = pin(row['file'])
    require(all(got[k] == row[k] for k in ('bytes', 'sha256')),
            'Changed input: ' + row['file'])
    return Path(got['file'])


def same_bytes(left, right):
    with Path(left).open('rb') as a, Path(right).open('rb') as b:
        while True:
            x, y = a.read(1024 * 1024), b.read(1024 * 1024)
            if x != y:
                return False
            if not x:
                return True


def write_json(path, value):
    path = Path(path)
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def fresh_output(value, root):
    path = Path(value).absolute()
    require(path == path.resolve() and not path.exists() and not path.is_symlink(),
            'Fresh nonsymlink output required: ' + str(path))
    require(path.is_relative_to(root / 'selfhost/build'),
            'Output must be inside explicit workspace selfhost/build/')
    path.mkdir(parents=True)
    return path


def clean_environment():
    require(not any(name in os.environ for name in DIAGNOSTIC_ENV),
            'Ambient diagnostic instrumentation must be unset')


def timeout(value):
    require(math.isfinite(value) and 0 < value <= 86400,
            'A finite positive timeout of at most 86400 seconds is required')
    return value


def kill(child):
    if child.poll() is None:
        try:
            os.killpg(child.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    child.wait()


def run(command, *, cwd, stdout, stderr, seconds, env=None):
    """One child session, exact file output, bounded deadline; no resource guard."""
    seconds = timeout(seconds)
    row = dict(command=list(map(str, command)), limitSeconds=seconds,
               complete=False, started=time.time())
    child, done, expired = None, threading.Event(), threading.Event()
    start = time.monotonic()
    try:
        with Path(stdout).open('xb') as so, Path(stderr).open('xb') as se:
            child = subprocess.Popen(row['command'], cwd=cwd, env=env,
                                     stdout=so, stderr=se, start_new_session=True)

            def deadline():
                if not done.is_set():
                    expired.set()
                    try:
                        os.killpg(child.pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass

            timer = threading.Timer(seconds, deadline)
            timer.daemon = True
            try:
                timer.start()
                _, status, usage = os.wait4(child.pid, 0)
                child.returncode = os.waitstatus_to_exitcode(status)
                done.set()
                row.update(exitCode=child.returncode, userSeconds=usage.ru_utime,
                           systemSeconds=usage.ru_stime, peakRssKiB=usage.ru_maxrss,
                           timedOut=expired.is_set())
            finally:
                done.set()
                timer.cancel()
                if timer.ident is not None:
                    timer.join()
        row['complete'] = child.returncode == 0 and not expired.is_set()
    except BaseException as error:
        row['error'] = repr(error)
        if child is not None:
            kill(child)
            row['exitCode'] = child.returncode
    finally:
        row['seconds'] = time.monotonic() - start
        for name, path in [('stdout', stdout), ('stderr', stderr)]:
            if Path(path).is_file():
                row[name] = pin(path)
    return row


def changed_inputs(inputs):
    changed = []
    for row in inputs:
        try:
            verify(row)
        except (OSError, ValueError):
            changed.append(row['file'])
    return changed
