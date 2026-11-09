"""Public x86 metadata/publication tests; compiler and runtime calls are mocked."""
import argparse
from contextlib import redirect_stdout
import importlib.util
import io
import os
from pathlib import Path
import shutil
import sys
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import test_build as fixtures
from common import pin, write_json
spec = importlib.util.spec_from_file_location('public_x86', Path(__file__).with_name('public-native.py'))
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
native_spec = importlib.util.spec_from_file_location('native_shell', Path(__file__).resolve().parents[2]/'native.py')
N = importlib.util.module_from_spec(native_spec); native_spec.loader.exec_module(N)


class PublicX86(unittest.TestCase):
    file = fixtures.BuildFixtures.file
    script = fixtures.BuildFixtures.script
    save = fixtures.BuildFixtures.save

    def setUp(self):
        fixtures.BuildFixtures.setUp(self)
        self.doc['upstream'] = '9'*40
        self.doc['assets'].pop('qbe')
        self.doc['toolchains']['x86'] = self.doc['toolchains'].pop('qbe')
        files = {}
        for name, original in [('x86/bend',self.producer), ('qbe/runtime.o',self.runtime), ('base.bend',self.base)]:
            destination = self.root/'selfhost/dist'/name; destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(original, destination)
            relative = 'selfhost/dist/'+name; files[relative] = dict(pin(destination),file=relative)
        self.identity = {'bytes':31,'sha256':'a'*64}
        image = files['selfhost/dist/x86/bend']; runtime = files['selfhost/dist/qbe/runtime.o']
        self.doc['assets'].update({'x86-n2':image,'qbe-runtime':runtime})
        self.doc['images']['x86-n2'] = dict(host='native',stage='N2',protocol='native-x86-source-v1',
            targets=['x86'],sourceIdentity=self.identity,linkedRuntime=runtime,linkedRuntimeABI=11102,
            runtimeArgumentConvention='bend-rts-v1',preparationModes=['cache','live'])
        self.doc['runtimePolicies'] = {'qbe-runtime':dict(runtimeABI=11102,runtimeArgumentConvention='bend-rts-v1')}
        self.current = dict(kind='bend-current-bindings',version=1,complete=True,gateStatus={'qualified':True},
            upstream=self.doc['upstream'],files=files,providers={'base':files['selfhost/dist/base.bend'],'qbeRuntime':runtime},
            components={'x86':dict(host='native',stage='N2',protocol='native-x86-source-v1',capabilities=['x86'],
                image=image,sourceIdentity=self.identity,runtimeArgumentConvention='bend-rts-v1')})
        directory = self.root/'selfhost/manifests'; directory.mkdir()
        self.manifest = directory/'assets-native.json'; self.save()
        self.selector = directory/'current.json'; write_json(self.selector,self.current)
        for name in ['native.py','cli.mjs']:(self.root/'selfhost'/name).write_text('transport fixture')

    def emitted(self, args):
        args.out.mkdir()
        product = args.out/'program.s'; product.write_bytes(b'.text\n.globl main\nmain:\n')
        return dict(complete=True,inputs=[pin(args.source)],product=pin(product))

    def built(self, args):
        args.out.mkdir()
        product = args.out/'program'; product.write_bytes(b'opaque mocked ELF')
        return dict(complete=True,inputs=[pin(args.source)],binary=pin(product),jobs=[])

    def test_selected_component_runtime_and_assets_must_agree(self):
        P.selected(self.root)
        self.doc['images']['x86-n2']['linkedRuntimeABI'] = 11101; self.save()
        with self.assertRaisesRegex(ValueError,'runtime binding'): P.selected(self.root)
        self.doc['images']['x86-n2']['linkedRuntimeABI'] = 11102; self.save()
        self.doc['runtimePolicies']['qbe-runtime']['runtimeArgumentConvention'] = 'bend-legacy-v1'; self.save()
        with self.assertRaisesRegex(ValueError,'runtime binding'): P.selected(self.root)
        self.doc['runtimePolicies']['qbe-runtime']['runtimeArgumentConvention'] = 'bend-rts-v1'; self.save()
        self.current['components']['x86']['sourceIdentity'] = dict(self.identity,sha256='b'*64)
        write_json(self.selector,self.current)
        with self.assertRaisesRegex(ValueError,'binding differs'): P.selected(self.root)

    def test_atomic_publication_preserves_bytes_mode_and_existing_paths(self):
        original = self.file('product.s',b'assembly bytes\n\n'); output = self.root/'out.s'
        P.publish(pin(original),output,False)
        self.assertEqual(output.read_bytes(),original.read_bytes())
        self.assertEqual(output.stat().st_mode & 0o777,0o644)
        with self.assertRaisesRegex(ValueError,'already exists'): P.publish(pin(original),output,True)
        dangling = self.root/'dangling.s'; dangling.symlink_to(self.root/'absent')
        with self.assertRaisesRegex(ValueError,'already exists'): P.publish(pin(original),dangling,False)
        alias = self.root/'alias'; alias.symlink_to(self.root,target_is_directory=True)
        with self.assertRaisesRegex(ValueError,'parent symlink'): P.output_path(alias/'new.s')
        self.assertFalse(list(self.root.glob('.bend-x86-*')))

    def test_destination_race_does_not_replace_the_new_file(self):
        product = self.file('product',b'complete artifact'); output = self.root/'race'
        link = os.link
        def race(source,destination,**kwargs):
            output.write_bytes(b'other writer')
            return link(source,destination,**kwargs)
        with patch.object(P.os,'link',side_effect=race), self.assertRaises(FileExistsError):
            P.publish(pin(product),output,True)
        self.assertEqual(output.read_bytes(),b'other writer')
        self.assertFalse(list(self.root.glob('.bend-x86-*')))

    def test_assembly_and_elf_dispatch_are_exact_and_confined(self):
        assembly = self.root/'output.s'
        with patch.object(P.request,'execute',side_effect=self.emitted) as emit, patch.object(P.native,'build') as build:
            self.assertEqual(P.main([str(self.source),'-o',str(assembly)],self.root),0)
            self.assertEqual(emit.call_args.args[0].target,'x86'); build.assert_not_called()
        self.assertEqual(assembly.read_bytes(),b'.text\n.globl main\nmain:\n')
        output = self.root/'output'
        with patch.object(P.native,'build',side_effect=self.built), patch.object(P.request,'execute') as emit:
            self.assertEqual(P.main(['--target','x86',str(self.source),'-o',str(output)],self.root),0)
            emit.assert_not_called()
        self.assertEqual(output.read_bytes(),b'opaque mocked ELF')
        self.assertEqual(output.stat().st_mode & 0o777,0o755)
        self.assertFalse(list((self.root/'selfhost/build').glob('public-x86-*')))

    def test_run_protects_argv_and_preserves_exit_code(self):
        with patch.object(P.native,'build',side_effect=self.built), patch.object(P.subprocess,'run',return_value=argparse.Namespace(returncode=23)) as run:
            self.assertEqual(P.main(['--target','x86',str(self.source),'--run','--','+RTS','a b'],self.root),23)
        self.assertEqual(run.call_args.args[0][1:],['+RTS','--threads','1','--gpu','off','-RTS','--RTS','+RTS','a b'])
        self.assertFalse(Path(run.call_args.args[0][0]).exists())

    def test_failure_or_existing_input_never_publishes(self):
        output = self.root/'never.s'
        with patch.object(P.request,'execute',return_value={'complete':False,'error':'refused'}), patch.object(P,'diagnostics'):
            self.assertEqual(P.main([str(self.source),'-o',str(output)],self.root),1)
        self.assertFalse(output.exists())
        with patch.object(P.request,'execute') as emit, self.assertRaisesRegex(ValueError,'already exists'):
            P.main([str(self.source),'-o',str(self.source)],self.root)
        emit.assert_not_called()

    def test_guard_directory_is_confined_and_still_temporary(self):
        folder = self.root/'selfhost/build/guard/scratch'
        with patch.dict(os.environ,{'BEND_PUBLIC_BUILD_ROOT':str(folder)}), patch.object(P.native,'build',side_effect=self.built):
            self.assertEqual(P.main([str(self.source),'-o',str(self.root/'program')],self.root),0)
        self.assertEqual(list(folder.iterdir()),[])
        with patch.dict(os.environ,{'BEND_PUBLIC_BUILD_ROOT':str(self.root/'elsewhere')}):
            with self.assertRaisesRegex(ValueError,'inside selfhost/build'):
                P.main([str(self.source),'-o',str(self.root/'another')],self.root)

    def test_native_shell_routes_only_options_before_application_separator(self):
        self.current['components']['nativeCli'] = dict(host='native',stage='N1',protocol='native-public-cli-v1',
            image=self.current['components']['x86']['image'])
        write_json(self.selector,self.current)
        helper = str(self.root/'selfhost/tools/build/public-native.py')
        image = str(self.root/'selfhost/dist/x86/bend')
        cases = [(['--target','x86','input.bend','-o','program'],True),
                 (['input.bend','-o','program.s'],True),
                 (['input.bend','-o','program'],False),
                 (['--version'],False),
                 (['input.bend','--run','--','--target','x86'],False),
                 (['input.bend','--run','--','-o','data.s'],False)]
        for arguments, x86 in cases:
            with (self.subTest(arguments=arguments), patch.object(N,'__file__',str(self.root/'selfhost/native.py')),
                    patch.object(N.sys,'argv',['native.py',*arguments]), patch.object(N.os,'execv',side_effect=StopIteration) as execute):
                with self.assertRaises(StopIteration): N.main()
            self.assertEqual(execute.call_args.args,
                (sys.executable,[sys.executable,'-B',helper,*arguments]) if x86 else (Path(image),[image,*arguments]))

    def test_combined_help_does_not_execute_a_compiler(self):
        for flag in ['--help','-h']:
            stream = io.StringIO()
            with patch.object(N.sys,'argv',['native.py',flag]), patch.object(N.os,'execv') as execute, redirect_stdout(stream):
                N.main()
            execute.assert_not_called()
            for text in ['OUTPUT.c','--target x86','OUTPUT.s','Build an ELF','--run','--live','--version']:
                self.assertIn(text,stream.getvalue())


if __name__ == '__main__': unittest.main()
