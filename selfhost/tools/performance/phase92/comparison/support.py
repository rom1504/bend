"""Shared, offline authentication for the same-source native compiler comparison."""
import hashlib, importlib.util, json, sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
P = ROOT / 'selfhost/tools/performance'
SOURCE = 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
UPSTREAM = '059266225b77c8ca256ac6b25ee5c21449bab151'
LAUNCHER = P / 'phase90/runtime-migration01/native.py'
POINTER = LAUNCHER.with_name('native-admission.json')

def pin(file):
    file = Path(file).resolve(strict=True); digest = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''): digest.update(block)
    return dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)

def read(file): return json.loads(Path(file).read_text())

def verify(record):
    actual = pin(record['file']); assert actual['sha256'] == record['sha256'], actual['file']
    assert 'bytes' not in record or actual['bytes'] == record['bytes'], actual['file']
    return actual

def authenticate(build_path, native_pointer=None):
    inputs = {}
    def bind(value):
        item = verify(value) if isinstance(value, dict) else pin(value)
        assert inputs.setdefault(item['file'], item) == item
        return item
    bind(__file__); bind(LAUNCHER)
    spec = importlib.util.spec_from_file_location('phase92_public_native', LAUNCHER)
    launcher = importlib.util.module_from_spec(spec); spec.loader.exec_module(launcher)
    admission, selection = launcher.load(native_pointer or POINTER)
    for item in selection.values(): bind(item)
    for key in ['binary','source','c','base','runtime','template','build']: bind(admission[key])
    for item in admission['parts'] + admission['effects'] + [admission['cache']['carrier']]: bind(item)
    assert admission['source']['sha256'] == SOURCE
    build_pin = bind(build_path); build = read(build_pin['file'])
    assert build['complete'] and build.get('cPatched', False) is False
    for key in ['source','c','image','clang']: bind(build[key])
    assert build['source']['sha256'] == SOURCE
    checked_pin = bind(build['acquisition'] if 'acquisition' in build else build['checked'])
    checked = read(checked_pin['file'])
    assert checked['complete'] and checked['inputsUnchanged'] and checked['upstream'] == UPSTREAM
    assert checked['holes'] == 0 and {'load','check','emit-c'} <= {phase['name'] for phase in checked['phases']}
    assert verify(checked['source'])['sha256'] == build['source']['sha256']
    assert verify(checked['c']) == verify(build['c'])
    for item in checked['inputs']: bind(item)
    for key in ['method','upstreamPinEvidence']:
        if key in checked: bind(checked[key])
    guard_pin = bind(build['guard']); guard = read(guard_pin['file'])
    assert guard['complete'] and guard['returncode'] == 0 and not guard.get('stoppedFor') and not guard.get('interrupted')
    assert guard['command'] == build['command'] and guard['finished'] and guard['wallSeconds'] > 0
    for key in ['method','buildInputs']:
        if key in build: bind(build[key])
    if 'buildInputs' in build:
        for item in read(build['buildInputs']['file']):
            bind(dict(file=item['path'], sha256=item['sha256'], bytes=item['bytes']))
    own_build = read(admission['build']['file']); bind(own_build['guard'])
    own_guard = read(own_build['guard']['file'])
    assert own_build['complete'] and own_guard['complete'] and own_guard['returncode'] == 0
    def flags(command, compiler, source, output):
        tail = command[command.index(compiler):]
        assert tail.count(source) == tail.count(output) == 1
        assert tail[tail.index('-o')+1] == output
        normalized = [x for x in tail if x not in [source, output, '-ftime-report']]
        assert normalized == [compiler, '-isystem', str(Path(compiler).parents[1]/'include/clang'), '-O2', '-o', '-lm', '-pthread']
        return normalized
    signature = flags(build['command'], build['clang']['file'], build['c']['file'], build['image']['file'])
    assert signature == flags(own_guard['command'], build['clang']['file'], own_build['c']['file'], admission['binary']['file'])
    b1 = dict(admission, binary=build['image'])
    context = dict(kind='phase92-matched-native-compiler-authentication', source=bind(build['source']),
        upstream=UPSTREAM, build=build_pin, checked=checked_pin, nativeSelection=selection,
        clang=bind(build['clang']), optimizationFlags=signature, roles={
            'b1':dict(admission=b1, argvSentinel=False, producer='pinned TypeScript C backend; upstream C runtime'),
            'b2':dict(admission=admission, argvSentinel=True, producer='self-emitted native07; own C runtime')},
        scope='Same frozen Bend source and request assets; backend/runtime representation differs. Upstream IO.args supplies executable head, own runtime uses explicit sentinel. Authentication alone is not a new B1 conformance admission.')
    for item in inputs.values(): assert pin(item['file']) == item
    context['inputs'] = list(inputs.values())
    return context

def native_args(context, role, source, prefix, calls=1, live=False):
    assert role in ['b1','b2'] and calls in [1,5]
    item = context['roles'][role]; admission = item['admission']
    argv = [admission['binary']['file'], '--threads','1','--gpu','off','--']
    if item['argvSentinel']: argv.append(admission['argvSentinel'])
    argv.extend([str(Path(source).resolve()),admission['base']['file'],admission['runtime']['file'],
                 admission['effectsDir'],str(Path(prefix).resolve()),str(calls)])
    if not live: argv.extend([admission['cache']['carrier']['file'], admission['cache']['stamp']])
    return argv

def unchanged(context):
    for item in context['inputs']: assert pin(item['file']) == item
