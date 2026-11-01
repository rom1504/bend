"""ELF address mapping and sampler coverage; retained semantics from the qualified profiler helper."""
import subprocess


def command(*args):
    return subprocess.check_output(args, text=True)


def load_segments(path):
    segments = []
    for line in command("readelf", "-W", "-l", str(path)).splitlines():
        fields = line.split()
        if fields and fields[0] == "LOAD":
            segments.append(tuple(int(fields[i], 16) for i in (1, 2, 4)))
    if not segments:
        raise ValueError(f"No ELF load segments in {path}")
    return segments


def virtual_address(pc, mapping, segments):
    offset = pc - mapping["start"] + mapping["offset"]
    for file_offset, address, file_size in segments:
        if file_offset <= offset < file_offset + file_size:
            return address + offset - file_offset
    return None


def coverage_summary(header):
    scope = header.get("sampler_scope", "main_thread")
    if scope not in ("main_thread", "all_created_threads"):
        raise ValueError(f"Unknown sampler scope: {scope}")
    process_cpu = header.get("process_cpu_ns", 0)
    main_fraction = header["main_thread_cpu_ns"] / process_cpu if process_cpu > 0 else None
    all_threads = scope == "all_created_threads"
    cpu = header.get("sampled_thread_cpu_ns", 0) if all_threads else header["main_thread_cpu_ns"]
    sampled_fraction = cpu / process_cpu if process_cpu > 0 else None
    reasons = []
    lifecycle = True
    if all_threads:
        required = ("sampled_thread_cpu_ns", "threads_allocated", "threads_ready",
                    "threads_ended", "thread_overflow", "thread_clock_failures", "timer_disarm_failures")
        missing = [key for key in required if key not in header]
        if missing:
            raise ValueError(f"Incomplete all-thread sampler metadata: {missing}")
        if header["threads_allocated"] != header["threads_ready"] or header["threads_ready"] < 1:
            lifecycle = False
            reasons.append("Some allocated thread slots were never ready")
        for key in ("thread_overflow", "thread_clock_failures", "timer_disarm_failures"):
            if header[key]:
                lifecycle = False
                reasons.append(f"{key}={header[key]}")
    enough_samples = header["samples"] >= 500
    if not enough_samples:
        reasons.append("Fewer than 500 delivered samples")
    near_complete = sampled_fraction is not None and sampled_fraction >= 0.95
    if sampled_fraction is None:
        reasons.append("Process CPU time was not recorded")
    elif not near_complete:
        reasons.append("Sampled thread clocks cover less than 95% of process CPU")
    return {
        "scope": scope, "main_thread_cpu_fraction": main_fraction,
        "sampled_thread_cpu_fraction": sampled_fraction,
        "minimum_process_cpu_fraction": 0.95, "minimum_samples": 500,
        "enough_samples": enough_samples, "thread_lifecycle_complete": lifecycle,
        "near_complete_process_cpu_coverage": near_complete and lifecycle,
        "usable_for_process_cpu_attribution": near_complete and lifecycle and enough_samples,
        "limitations": reasons,
    }
