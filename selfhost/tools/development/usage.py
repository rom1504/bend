#!/usr/bin/env python3
"""Local Codex telemetry snapshots. No network, model calls or log-content export."""
import argparse
import datetime as dt
import json
import os
from pathlib import Path
import sqlite3

KEYS = ('input_tokens', 'cached_input_tokens', 'output_tokens',
        'reasoning_output_tokens', 'total_tokens')


def last_usage(path):
    # Bounded tail reads: never load a whole long-running conversation.
    with Path(path).open('rb') as stream:
        size = stream.seek(0, 2)
        latest_limits = None
        for limit in (262144, 1048576, 4194304):
            start = max(0, size - limit)
            stream.seek(start)
            if start:
                stream.readline()
            for line in reversed(stream.read().splitlines()):
                try:
                    event = json.loads(line)
                except (ValueError, UnicodeError):
                    continue
                payload = event.get('payload') or {}
                if (latest_limits is None and event.get('type') == 'event_msg' and
                        payload.get('type') == 'token_count' and payload.get('rate_limits')):
                    latest_limits = (event['timestamp'], payload['rate_limits'])
                if (event.get('type') == 'event_msg' and
                        payload.get('type') == 'token_count' and payload.get('info')):
                    if latest_limits:
                        payload['rate_limits'] = latest_limits[1]
                        payload['_limits_observed_at'] = latest_limits[0]
                    return event['timestamp'], payload
            if start == 0:
                break
    return None, None


def snapshot(home, root):
    con = sqlite3.connect((home / 'state_5.sqlite').resolve().as_uri() + '?mode=ro', uri=True)
    con.row_factory = sqlite3.Row
    try:
        rows = [dict(r) for r in con.execute(
            'SELECT id, source, rollout_path, model, reasoning_effort, agent_path FROM threads')]
    finally:
        con.close()
    parents = {}
    for row in rows:
        try:
            source = json.loads(row['source'])
            parents[row['id']] = source['subagent']['thread_spawn']['parent_thread_id']
        except (ValueError, TypeError, KeyError):
            pass
    selected = {root}
    while True:
        expanded = selected | {child for child, parent in parents.items() if parent in selected}
        if expanded == selected:
            break
        selected = expanded
    if not any(r['id'] == root for r in rows):
        raise ValueError('Root thread is absent from the local database')
    result = {'schema': 1, 'root': root,
              'captured_at': dt.datetime.now(dt.timezone.utc).isoformat(),
              'threads': [], 'warnings': [], 'reported_limits': None}
    for row in rows:
        if row['id'] not in selected:
            continue
        try:
            stamp, payload = last_usage(row['rollout_path'])
        except OSError:
            stamp, payload = None, None
        if payload is None:
            result['warnings'].append('No recent token event for ' + row['id'])
            continue
        totals = payload['info']['total_token_usage']
        result['threads'].append({
            'id': row['id'], 'agent': row['agent_path'] or '/root',
            'latest_model': row['model'], 'latest_effort': row['reasoning_effort'],
            'observed_at': stamp, 'tokens': {k: totals.get(k, 0) for k in KEYS}})
        if row['id'] == root:
            result['reported_limits'] = {
                'observed_at': payload.get('_limits_observed_at', stamp),
                'value': payload.get('rate_limits')}
    result['totals'] = {k: sum(t['tokens'][k] for t in result['threads']) for k in KEYS}
    return result


def compare(now, before):
    if before.get('schema') != 1 or before['root'] != now['root']:
        raise ValueError('Baseline must use schema 1 and the same root thread')
    old = {t['id']: t for t in before['threads']}
    current = {t['id']: t for t in now['threads']}
    warnings, rows = [], []
    if old.keys() - current.keys():
        warnings.append('Some baseline threads lack current telemetry; delta is incomplete')
    for key, row in current.items():
        previous = old.get(key)
        delta = {k: row['tokens'][k] - (previous['tokens'][k] if previous else 0) for k in KEYS}
        if any(v < 0 for v in delta.values()):
            warnings.append('Counter reset for ' + key + '; delta omitted')
            continue
        if previous is None:
            warnings.append('Newly observed thread ' + key + '; its full counters enter the delta')
        rows.append({'id': key, 'agent': row['agent'], 'tokens': delta})
    elapsed = (dt.datetime.fromisoformat(now['captured_at']) -
               dt.datetime.fromisoformat(before['captured_at'])).total_seconds()
    if elapsed <= 0:
        raise ValueError('Baseline must precede this snapshot')
    totals = {k: sum(r['tokens'][k] for r in rows) for k in KEYS}
    points = {}
    a, b = before.get('reported_limits'), now.get('reported_limits')
    av, bv = (a or {}).get('value') or {}, (b or {}).get('value') or {}
    if av.get('limit_id') == bv.get('limit_id'):
        for window in ('primary', 'secondary'):
            x, y = av.get(window), bv.get(window)
            if (x and y and x.get('resets_at') == y.get('resets_at') and
                    x.get('window_minutes') == y.get('window_minutes')):
                change = y['used_percent'] - x['used_percent']
                seconds = (dt.datetime.fromisoformat(b['observed_at'].replace('Z', '+00:00')) -
                           dt.datetime.fromisoformat(a['observed_at'].replace('Z', '+00:00'))).total_seconds()
                if change >= 0 and seconds > 0:
                    points[window] = {'percentage_points': change,
                                      'per_hour': change * 3600 / seconds}
    return {'elapsed_seconds': elapsed, 'tokens': totals, 'threads': rows,
            'output_tokens_per_hour': totals['output_tokens'] * 3600 / elapsed,
            'account_limit_changes': points, 'warnings': warnings}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--home', type=Path, default=Path('/home/ai/.codex'))
    parser.add_argument('--thread', default=os.getenv('CODEX_THREAD_ID'))
    parser.add_argument('--snapshot', type=Path, help='Write a fresh metadata-only JSON file')
    parser.add_argument('--baseline', type=Path)
    parser.add_argument('--output-token-budget', type=int,
                        help='Advisory interval cap; includes reasoning, exit 2 when exceeded')
    parser.add_argument('--quota-points-per-hour', type=float,
                        help='Advisory account-limit burn rate; requires comparable limit events')
    args = parser.parse_args()
    if not args.thread:
        parser.error('Provide --thread or CODEX_THREAD_ID')
    if (args.output_token_budget is not None or args.quota_points_per_hour is not None) and not args.baseline:
        parser.error('Budget checks require --baseline')
    if any(v is not None and v <= 0 for v in (args.output_token_budget, args.quota_points_per_hour)):
        parser.error('Budget values must be positive')
    now = snapshot(args.home, args.thread)
    if args.baseline:
        now['interval'] = compare(now, json.loads(args.baseline.read_text()))
    alerts = []
    interval = now.get('interval', {})
    if args.output_token_budget and interval['tokens']['output_tokens'] > args.output_token_budget:
        alerts.append('Output-token interval budget exceeded')
    if args.quota_points_per_hour:
        changes = interval['account_limit_changes']
        if not changes:
            now['warnings'].append('No comparable limit events; quota-rate cap cannot be evaluated')
        for name, change in changes.items():
            if change['per_hour'] > args.quota_points_per_hour:
                alerts.append(name + ' reported account-limit burn rate exceeded')
    now['alerts'] = alerts
    now['limitations'] = [
        'Tokens are not Codex credits or exact quota cost; no conversion is assumed.',
        'Cached input is included in input; reasoning is included in output. Do not add either twice.',
        'Latest model/effort does not attribute historical counters to that model/effort.',
        'Limit events may be stale and reflect account-wide activity, not only this agent tree.',
        'Snapshots are asynchronous observations, not an atomic billing ledger.',
        'Advisory exits cannot enforce a hard platform spending limit or stop agents.']
    if args.snapshot:
        with args.snapshot.open('x') as stream:
            json.dump(now, stream, indent=2)
            stream.write('\n')
    display = {k: v for k, v in now.items() if k != 'threads'}
    display['observed_threads'] = len(now['threads'])
    if 'interval' in display:
        display['interval'] = dict(display['interval'])
        display['interval']['top_output_consumers'] = sorted(
            display['interval'].pop('threads'), key=lambda r: r['tokens']['output_tokens'], reverse=True)[:5]
    print(json.dumps(display, indent=2))
    return 2 if alerts else 0


if __name__ == '__main__':
    raise SystemExit(main())
