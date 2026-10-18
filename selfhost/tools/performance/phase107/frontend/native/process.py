"""File-output child runner: Linux pidfd deadlines, portable polling fallback.

No pipes/capture, shell, process-tree policy, signals installed, or compiler policy.
The external guard still owns descendant-tree limits, as with subprocess.run.
"""
import errno
import math
import os
import selectors
import subprocess
import time

_pidfd_open=getattr(os,'pidfd_open',None)
_selector=selectors.DefaultSelector
_UNSUPPORTED={errno.ENOSYS,errno.EINVAL,errno.ENODEV,errno.ENOTSUP,errno.EPERM,errno.EACCES,errno.EMFILE,errno.ENFILE}

def _remaining(child,deadline,timeout):
    remaining=deadline-time.monotonic()
    if remaining<=0:
        if child.poll() is not None:return 0
        raise subprocess.TimeoutExpired(child.args,timeout)
    return remaining

def _wait(child,timeout,trace):
    if timeout is None:
        trace['method']='blocking';return child.wait()
    deadline=time.monotonic()+timeout
    if _pidfd_open is None:
        trace['method']='fallback';return child.wait(timeout=_remaining(child,deadline,timeout))
    fd=None;selector=None
    try:
        try:
            while fd is None:
                _remaining(child,deadline,timeout)
                if child.returncode is not None:
                    trace['method']='already-exited';return child.returncode
                try:fd=_pidfd_open(child.pid,0)
                except InterruptedError:continue
            selector=_selector()
            while True:
                _remaining(child,deadline,timeout)
                try:selector.register(fd,selectors.EVENT_READ);break
                except InterruptedError:continue
        except (NotImplementedError,OSError) as error:
            if isinstance(error,OSError) and error.errno not in _UNSUPPORTED|{errno.ESRCH}:raise
            if selector is not None:selector.close();selector=None
            if fd is not None:os.close(fd);fd=None
            trace['method']='fallback';trace['reason']=repr(error)
            return child.wait(timeout=_remaining(child,deadline,timeout))
        trace['method']='pidfd'
        while True:
            remaining=_remaining(child,deadline,timeout)
            if child.returncode is not None:return child.returncode
            try:ready=selector.select(remaining)
            except InterruptedError:continue
            if ready:return child.wait()
    finally:
        if selector is not None:selector.close()
        if fd is not None:os.close(fd)

def run(args,*,stdout,stderr,timeout=None,cwd=None,env=None,check=False):
    """Return CompletedProcess with pid/wait_method; timeout kills and reaps child."""
    if stdout==subprocess.PIPE or stderr==subprocess.PIPE:
        raise ValueError('process.run requires file/inherited/DEVNULL output, not PIPE')
    if timeout is not None and (not math.isfinite(timeout) or timeout<0):raise ValueError('invalid timeout')
    child=subprocess.Popen(args,stdout=stdout,stderr=stderr,cwd=cwd,env=env)
    trace={}
    try:code=_wait(child,timeout,trace)
    except BaseException as error:
        try:child.kill()
        except ProcessLookupError:pass
        finally:child.wait()
        if isinstance(error,subprocess.TimeoutExpired):
            error.pid=child.pid;error.wait_method=trace.get('method');error.returncode=child.returncode
        raise
    result=subprocess.CompletedProcess(args,code)
    result.pid=child.pid;result.wait_method=trace['method'];result.wait_fallback=trace.get('reason')
    if check:result.check_returncode()
    return result
