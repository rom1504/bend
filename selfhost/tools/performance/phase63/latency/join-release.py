"""Read-only State09 release join; import has no side effects or target execution."""
from pathlib import Path


def collect(root, pin, read):
    """Validate completed receipts and current files; missing evidence raises.

    ``pin(Path)`` returns at least file/sha256 and records that input in the
    caller's identity set; ``read(Path)`` returns parsed JSON. No report is
    written here. The caller must invoke this only after release writers close.
    """
    root = Path(root).resolve()
    project = root/'selfhost'
    raw = project/'build/phase63'
    release = raw/'release-state09'
    names = ['install', 'verify-before', 'legacy42', 'default24', 'verify-after']

    def load(file):
        file = Path(file)
        if not file.is_file():
            raise FileNotFoundError('Missing completed State09 release evidence: '+str(file))
        pin(file)
        return read(file)

    def verify(row, base=None):
        file = Path(row.get('file', row.get('path', '')))
        assert str(file) not in {'', '.'}, 'Missing file identity'
        if not file.is_absolute():
            assert base is not None
            file = Path(base)/file
        actual = pin(file)
        assert actual['sha256'] == row['sha256'], str(file)
        if 'bytes' in row:
            assert file.stat().st_size == row['bytes'], str(file)
        return actual

    plan_file = raw/'release-state09-plan.json'
    commands_file = raw/'release-state09-commands.json'
    execution_file = raw/'release-state09-execution/report.json'
    helper_file = raw/'release-state09-helper-integrity/report.json'
    for file in [plan_file, commands_file, execution_file, helper_file]:
        if not file.is_file():
            raise FileNotFoundError('Missing completed State09 release evidence: '+str(file))
    plan, commands, execution = map(load, [plan_file, commands_file, execution_file])
    assert plan['kind'] == 'phase53-default-release-qualification-plan' and plan['executed'] is False
    assert commands['kind'] == 'phase58-root-release-launch-plan' and commands['executed'] is False
    assert plan['cwd'] == commands['cwd'] == str(root)
    assert Path(plan['output']) == release
    assert verify(commands['sourcePlan'])['sha256'] == pin(plan_file)['sha256']
    assert execution['kind'] == 'phase55-retention-execution'
    assert execution['complete'] is True and execution['pass'] is True and execution['returncode'] == 0
    assert Path(execution['plan']) == commands_file and execution['planSha256'] == pin(commands_file)['sha256']
    assert [row['name'] for row in plan['steps']] == names
    assert [row['name'] for row in commands['commands']] == names
    assert [row['name'] for row in execution['steps']] == names
    for item in plan['tools'] + commands['inputs']:
        verify(item)
    attempt = load(verify(plan['attempt'])['file'])
    assert Path(plan['attempt']['file']) == raw/'checked-state09/attempt.json'
    assert attempt['checked'] is True and attempt['artifactKind'] == 'derived-b1'
    bootstrap = load(verify(attempt['bootstrapReport'])['file'])
    assert plan['api']['sha256'] == verify(attempt['api'])['sha256']
    assert plan['sourceSha256'] == bootstrap['sourceSha256']
    api_sha, source_sha = plan['api']['sha256'], plan['sourceSha256']
    runtime_sha = verify(plan['directRuntime'])['sha256']

    processes = []
    for expected, command, result in zip(plan['steps'], commands['commands'], execution['steps']):
        assert expected['guardedArgv'] == command['command'] == result['command']
        assert command['environment'] == result['environment']
        assert command['expected'] == expected['expected'] and result['returncode'] == 0
        assert result['finished'] >= result['started']
        job = release/('job-'+expected['name'])
        process_file = job/'process.json'
        process = load(process_file)
        assert process['complete'] is True and process['returncode'] == 0
        assert process['command'] == ['taskset', '-c', '3', *expected['argv']]
        assert process['rssLimitBytes'] == 2048*1024*1024
        assert process['availableFloorBytes'] == 4096*1024*1024
        assert not any(process.get(key) for key in ['error', 'signal', 'timedOut', 'overflow'])
        processes.append(dict(name=expected['name'], receipt=pin(process_file), wallSeconds=process['wallSeconds']))
        if expected['name'] in {'install', 'verify-before', 'verify-after'}:
            observed = load(job/'stdout.log')
            assert observed['complete'] is True and observed['newBootstrap'] is False
            assert observed['artifact'] == 'equality-derived-b1'
            assert observed['api']['sha256'] == api_sha and observed['sourceSha256'] == source_sha

    installed_file = project/'dist/release.json'
    installed = load(installed_file)
    installed_id = pin(installed_file)
    assert installed['kind'] == 'bend-default-equality-release' and installed['newBootstrap'] is False
    assert installed['artifact'] == 'equality-derived-b1'
    assert installed['sourceSha256'] == source_sha and installed['directRuntimeSha256'] == runtime_sha
    assert installed['runtimeSha256'] == attempt['runtime']['sha256']
    files = {item['path']: item for item in installed['files']}
    checkout = {item['path']: item for item in installed['checkout']}
    assert len(files) == len(installed['files']) and len(checkout) == len(installed['checkout'])
    for item in installed['files'] + installed['checkout']:
        verify(item, project)
    assert files['dist/typed-api.mjs']['sha256'] == api_sha
    assert files['dist/release-lineage/checked-api.mjs']['sha256'] == attempt['checkedApi']['sha256']
    assert files['dist/release-lineage/checked-bootstrap.json']['sha256'] == attempt['bootstrapReport']['sha256']
    assert files['dist/base.bend']['sha256'] == attempt['base']['sha256']
    assert checkout['src/runtime/js/direct.mjs']['sha256'] == runtime_sha
    closure = plan['packagerClosure']
    graph_sha = verify(closure['graphSnapshot'])['sha256']
    assert verify(closure['graphCurrent'])['sha256'] == checkout['tools/base-cache-graph.mjs']['sha256'] == graph_sha
    assert verify(closure['currentRelease'])['sha256'] == verify(closure['after'])['sha256']
    helper_provenance = [row for row in bootstrap['provenance']['inputs']
        if row.get('role') == 'host-tool' and Path(row['file']).name == 'base-cache-graph.mjs']
    assert len(helper_provenance) == 1 and verify(helper_provenance[0])['sha256'] == graph_sha

    launcher_file = release/'legacy42/launcher.json'
    launcher = load(launcher_file)
    assert launcher['complete'] is True and launcher['pass'] is True and launcher['steps'] == 42
    assert launcher['expectedApi'] == api_sha
    legacy_file = Path(verify(launcher['checks'])['file'])
    assert legacy_file == release/'legacy42/checks/report.json'
    legacy = load(legacy_file)
    assert legacy['pass'] is True and len(legacy['steps']) == 42 and legacy['apiSha256'] == api_sha
    assert legacy['actualCpu'] == '3'
    assert not legacy['changedOrdinaryInputs'] and not legacy['changedRelocatedInputs'] and not legacy['changedFixtures']
    assert legacy['relocation']['createdUpstreamCheckout'] is False
    for step in legacy['steps']:
        assert step['pass'] is True and step['exitCode'] == 0
        assert not any(step.get(key) for key in ['signal', 'error', 'timedOut', 'overflow'])
    default_file = release/'default24/report.json'
    default = load(default_file)
    assert default['complete'] is True and default['pass'] is True and len(default['steps']) == 24
    assert (default['expectedApi'], default['expectedSource'], default['expectedRuntime']) == (api_sha, source_sha, runtime_sha)
    assert default['actualCpu'] == '3' and all(step['pass'] is True for step in default['steps'])
    for evidence in [legacy, default]:
        assert verify(evidence['release'])['sha256'] == installed_id['sha256']

    helper = load(helper_file)
    assert helper['kind'] == 'phase63-release-graph-helper-integrity'
    assert helper['complete'] is True and helper['pass'] is True
    assert helper['compilerExecuted'] is False and helper['installedReleaseMutated'] is False
    assert [item['name'] for item in helper['checks']] == [
        'installed-helper-bound-to-checked-provenance', 'copied-inventory-verifies',
        'tampered-helper-rejected', 'missing-helper-rejected', 'helper-omitted-from-inventory-rejected']
    assert all(item['pass'] is True for item in helper['checks'])
    assert verify(helper['release'])['sha256'] == installed_id['sha256']
    assert verify(helper['helper'])['sha256'] == graph_sha
    assert verify(helper['packager'])['sha256'] == closure['after']['sha256']
    assert verify(helper['patch'])['sha256'] == verify(closure['patch'])['sha256']
    verify(helper['producer'])

    pre_file = raw/'preinstall-preservation.json'
    pre = load(pre_file)
    assert pre['pass'] is True and all(row['pass'] is True for row in pre['checks'])
    assert {(row['baseline'], row['count']) for row in pre['checks']} == {
        ('implementation/phase63/evidence/inherited-files.json', 110),
        ('selfhost/build/phase63/installed-before.json', 7)}
    before_file = raw/'installed-before.json'
    before = load(before_file)
    assert before['pass'] is True and len(before['files']) == 7
    previous_api = next(row['sha256'] for row in before['files'] if Path(row['file']) == project/'dist/typed-api.mjs')
    history = project/'dist/release-history'/previous_api
    for row in before['files']:
        previous_path = Path(row['file']).relative_to(project/'dist')
        verify(dict(row, file=str(history/previous_path)))
    inherited_file = root/'implementation/phase63/evidence/inherited-files.json'
    inherited = load(inherited_file)
    assert len(inherited['files']) == 110 and len({row['file'] for row in inherited['files']}) == 110
    for row in inherited['files']:
        verify(row, root)

    return dict(complete=True, **{'pass': True}, artifact='equality-derived-b1', installed=installed_id,
        attempt=pin(raw/'checked-state09/attempt.json'), apiSha256=api_sha, sourceSha256=source_sha,
        directRuntimeSha256=runtime_sha, graphHelperSha256=graph_sha, plan=pin(plan_file),
        commands=pin(commands_file), execution=pin(execution_file), processes=processes,
        legacy42=pin(legacy_file), legacyLauncher=pin(launcher_file), default24=pin(default_file),
        helper5=pin(helper_file), preservedPriorFiles=7, priorApiSha256=previous_api,
        inheritedFiles=110, preinstallPreservation=pin(pre_file), installedBefore=pin(before_file),
        inheritedBaseline=pin(inherited_file),
        scope='Selected installed identities, five completed release jobs, legacy42/default24, helper5, '
        'seven previous release files and 110 inherited files verified. No new compiler execution or '
        'closed historical-tree/archive preservation claim is made by this join.')
