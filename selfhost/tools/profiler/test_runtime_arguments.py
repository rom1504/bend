"""Runtime argument metadata and source controls; no compiler or target executes."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

import freeze
import run
import runtime

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, HERE/filename)
    result = importlib.util.module_from_spec(spec); spec.loader.exec_module(result)
    return result


control = module('profiler_control_arguments', 'check-runtime.py')
stages = module('profiler_stage_arguments', 'stages-build-v1.py')


class RuntimeArguments(unittest.TestCase):
    def test_legacy_control_and_actual_rts_arguments(self):
        old = json.loads(control.EXPECTED.read_text())
        new = json.loads(control.RTS_EXPECTED.read_text())
        rts = dict(runtimeArgumentConvention='bend-rts-v1')
        self.assertEqual(control.select_control({}), (control.CONTROL,control.EXPECTED))
        self.assertEqual(control.control_arguments({},old),[])
        self.assertEqual(control.select_control(rts),(control.RTS_CONTROL,control.RTS_EXPECTED))
        self.assertEqual(control.control_arguments(rts,new),['+RTS','--threads','1','--gpu','off','-RTS'])
        for plan, expected in [(rts,old),({},new),(rts,dict(new,argumentProtocol='embedded-legacy-v1'))]:
            with self.assertRaises(ValueError):control.control_arguments(plan,expected)

    def test_runtime_environment_refuses_ambient_rts_only_for_rts_provider(self):
        self.assertEqual(run.validate_runtime_environment({}, {'BENDRTS':'--threads 8'}),'bend-legacy-v1')
        rts = dict(runtimeArgumentConvention='bend-rts-v1')
        self.assertEqual(run.validate_runtime_environment(rts,{}),'bend-rts-v1')
        for value in ['', '--threads 8']:
            with self.assertRaisesRegex(ValueError,'BENDRTS'):
                run.validate_runtime_environment(rts,{'BENDRTS':value})
        with self.assertRaises(ValueError):run.validate_runtime_environment({'runtimeArgumentConvention':'unknown'},{})

    def test_versioned_control_changes_only_entry_and_retains_every_oracle(self):
        old_main = ('int main(int argc, char **argv) {\n  (void)argc;\n'
                    '  char *runtime_argv[] = {argv[0], "--threads", "1", "--gpu", "off", NULL};\n'
                    '  return p111_rt_main(5, runtime_argv, &program);\n}')
        new_main = 'int main(int argc, char **argv) {\n  return p111_rt_main(argc, argv, &program);\n}'
        for stem in ['runtime-control','runtime-drop-control']:
            with self.subTest(stem=stem):
                document = json.loads((HERE/'controls'/(stem+'-argv-v1.expected.json')).read_text())
                adaptation = document.pop('entryAdaptation')
                old_source = ROOT/adaptation['originalSource']['file']
                old_expected = ROOT/adaptation['originalExpectation']['file']
                for path,expected in [(old_source,adaptation['originalSource']),(old_expected,adaptation['originalExpectation']),
                                      (ROOT/document['source']['file'],document['source'])]:
                    self.assertEqual({k:run.pin(path)[k] for k in ['bytes','sha256']},
                                     {k:expected[k] for k in ['bytes','sha256']})
                self.assertEqual((ROOT/document['source']['file']).read_text().replace(new_main,old_main,1),old_source.read_text())
                previous = json.loads(old_expected.read_text())
                document['source'] = previous['source']
                self.assertEqual(document.pop('runtimeArgumentConvention'),'bend-rts-v1')
                self.assertEqual(document.pop('argumentProtocol'),'caller-argv-v1')
                self.assertEqual(document,previous)

    def test_freezing_preserves_explicit_convention_and_runner_refuses_before_execution(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            for name in ['program','stdout','stderr','recipe']:(root/name).write_bytes(b'')
            variant=dict(name='compiler',command=['program','+RTS','-RTS'],stdout='stdout',stderr='stderr',
                         runtimeArgumentConvention='bend-rts-v1')
            recipe=dict(cwd=directory,workloads=[dict(name='x',variants=[variant])])
            frozen=freeze.freeze(recipe,root/'recipe')
            self.assertEqual(frozen['workloads'][0]['variants'][0]['runtimeArgumentConvention'],'bend-rts-v1')
            run.save(root/'manifest.json',frozen)
            with patch.object(sys,'argv',['run','--manifest',str(root/'manifest.json'),'--out',str(root/'out'),'--check-only']), \
                 patch.dict(run.os.environ,{'BENDRTS':'--threads 8'}),patch.object(run,'execute') as execute:
                with self.assertRaisesRegex(ValueError,'BENDRTS'):run.main()
                execute.assert_not_called()
            self.assertFalse((root/'out').exists())

    def test_runtime_and_stage_plans_propagate_convention_without_compilation(self):
        for convention in [None,'bend-rts-v1']:
            with self.subTest(convention=convention),tempfile.TemporaryDirectory() as directory:
                root=Path(directory)
                # Deliberately synthetic source/object: these plans are never executed.
                (root/'runtime.c').write_text('\n'.join(old for _,old,_ in runtime.changes()))
                (root/'program.o').write_bytes(b'metadata fixture, not an object')
                manifest=dict(runtime=run.pin(root/'runtime.c'),headers=[],programObject=run.pin(root/'program.o'),
                              compiler=sys.executable,linker=sys.executable)
                if convention:manifest['runtimeArgumentConvention']=convention
                run.save(root/'input.json',manifest)
                with patch.object(sys,'argv',['runtime','--manifest',str(root/'input.json'),'--out',str(root/'base')]), \
                     contextlib.redirect_stdout(io.StringIO()):runtime.main()
                base=json.loads((root/'base/plan.json').read_text())
                self.assertEqual(base['runtimeArgumentConvention'],convention or 'bend-legacy-v1')
                self.assertTrue(base['reverseExact']);self.assertFalse(base['compiled']);self.assertEqual(len(base['jobs']),2)
                run.save(root/'owners.json',{'fids':[dict(fid=0,symbol='s0',role='direct_segment')]})
                run.save(root/'table.json',{})
                (root/'unwind-table.h').write_text('/* metadata fixture */\n')
                source=HERE/'sample.c'
                run.save(root/'sampler.json',dict(complete=True,returncode=0,inputs=[run.pin(root/'table.json')],
                    snapshots=[run.pin(source),run.pin(root/'unwind-table.h')],
                    command=[sys.executable,'-DBEND_PROFILE_UNWIND_TABLE="'+str(root/'unwind-table.h')+'"',str(source),'-o',str(root/'sampler.so')]))
                run.save(root/'spec.json',dict(schema='bend-native-stage-spec-v1',ownerMap=run.pin(root/'owners.json'),
                    programObject=run.pin(root/'program.o'),unwindTable=run.pin(root/'table.json'),
                    markers=[dict(label='begin',fid=0,symbol='s0',multiplicity='once')],requiredOrder=['begin'],intervals=[]))
                argv=['stages','--spec',str(root/'spec.json'),'--runtime-plan',str(root/'base/plan.json'),
                      '--sampler-build',str(root/'sampler.json'),'--out',str(root/'stage')]
                with patch.object(sys,'argv',argv),contextlib.redirect_stdout(io.StringIO()):stages.main()
                result=json.loads((root/'stage/plan.json').read_text())
                self.assertEqual(result['runtimeArgumentConvention'],convention or 'bend-legacy-v1')
                self.assertFalse(result['compiled']);self.assertFalse(result['executed'])

    def test_exact_fourteen_hooks_remain_reversible_on_current_runtime(self):
        original=(ROOT/'selfhost/src/runtime/qbe/runtime.c').read_bytes()
        changed,edits=runtime.materialize(original)
        self.assertEqual(len(edits),14)
        for row in reversed(edits):changed=changed.replace(row['diagnostic'].encode(),row['original'].encode(),1)
        self.assertEqual(changed,original)


if __name__=='__main__':unittest.main()
