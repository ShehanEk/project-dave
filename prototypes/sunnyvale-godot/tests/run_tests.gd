extends SceneTree
## Headless test runner.
##   Godot --headless --path . -s res://tests/run_tests.gd
##   Godot --headless --path . -s res://tests/run_tests.gd -- --filter=hero
## Runs every tests/cases/test_*.gd (a TestCase) in a fresh Session run.
## Exit code 0 only when every case passes with at least one check.

const CASES_DIR := "res://tests/cases"


## A GDScript runtime error ("SCRIPT ERROR: ...") inside a case aborts its
## run() coroutine, yet `await tc.run()` still returns normally, so the case
## would otherwise count as passed with its remaining checks silently skipped.
## This Logger records every script error so the runner can fail the case.
class ScriptErrorCatcher extends Logger:
	var errors: PackedStringArray = []
	var _mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String,
			rationale: String, _editor_notify: bool, error_type: int,
			_script_backtraces: Array) -> void:
		if error_type != Logger.ERROR_TYPE_SCRIPT:
			return
		_mutex.lock()
		errors.append("%s (%s:%d in %s)" % [rationale if rationale != "" else code, file, line, function])
		_mutex.unlock()

	func take() -> PackedStringArray:
		_mutex.lock()
		var out := errors
		errors = PackedStringArray()
		_mutex.unlock()
		return out


func _initialize() -> void:
	_run.call_deferred()


## Every test run gets its own throwaway user:// directory for
## CheckpointService, so no test case (M0-M3 cases that call Session.commit()
## included, now that commit() persists) ever touches a real player save.
## Removed again at the end regardless of pass/fail.
const TEST_SAVE_ROOT := "user://test_runs"


func _run() -> void:
	var filter := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--filter="):
			filter = arg.trim_prefix("--filter=")

	var checkpoint_service := root.get_node_or_null("/root/CheckpointService")
	var test_save_dir := "%s/%d" % [TEST_SAVE_ROOT, Time.get_ticks_usec()]
	if checkpoint_service:
		checkpoint_service.set_save_dir(test_save_dir)

	# AUD-01 regression guard: fingerprint the REAL save dir (never
	# `test_save_dir` above) before running anything. This harness never
	# touches that directory itself, so if any case leaves CheckpointService
	# pointed at it (e.g. by restoring DEFAULT_SAVE_DIR instead of the dir it
	# found on entry), every later-sorted case's Session/CheckpointService
	# calls would read/write/delete the player's real save — this catches
	# that even for a case this file doesn't know about yet.
	var real_dir_fingerprint := _fingerprint_default_save_dir()

	var files := Array(DirAccess.get_files_at(CASES_DIR))
	files = files.filter(func(f): return f.begins_with("test_") and f.ends_with(".gd"))
	files.sort()
	var failed := 0
	var ran := 0
	var catcher := ScriptErrorCatcher.new()
	OS.add_logger(catcher)
	for f in files:
		if filter != "" and not f.contains(filter):
			continue
		ran += 1
		var session := root.get_node_or_null("/root/Session")
		if session:
			session.new_run()
		if checkpoint_service:
			# Reassert the throwaway dir before every case (defense in depth
			# against AUD-01): a case must never be able to silently
			# redirect every later-sorted case at the real player's save.
			checkpoint_service.set_save_dir(test_save_dir)
			checkpoint_service.clear()
			checkpoint_service.debug_force_write_failure(false)
		var case_script: Script = load(CASES_DIR + "/" + f)
		# A case that fails to compile is a failure, not a hang (calling
		# new() on it would stop this coroutine and the runner never quits).
		if case_script == null or not case_script.can_instantiate():
			print("FAIL %s (script failed to compile; see the errors above)" % f)
			failed += 1
			continue
		var tc: TestCase = case_script.new()
		tc.name = f.get_basename()
		root.add_child(tc)
		catcher.take()
		await tc.run()
		tc.release_all()
		for err in catcher.take():
			tc.failures.append("script error aborted the case before it finished: " + err)
		if checkpoint_service and checkpoint_service.get_save_dir() != test_save_dir:
			tc.failures.append(
					"left CheckpointService save dir at '%s' instead of restoring the runner's throwaway dir '%s' (AUD-01 regression)"
					% [checkpoint_service.get_save_dir(), test_save_dir])
		var ok := tc.failures.is_empty() and tc.checks_run > 0
		if tc.checks_run == 0:
			tc.failures.append("no checks ran")
		print("%s %s (%d checks)" % ["PASS" if ok else "FAIL", f, tc.checks_run])
		for msg in tc.failures:
			print("    - " + msg)
		if not ok:
			failed += 1
		tc.queue_free()
		await process_frame

	if checkpoint_service:
		# Always leave the throwaway dir active before clearing/removing it,
		# regardless of what the last case did to the save dir.
		checkpoint_service.set_save_dir(test_save_dir)
		checkpoint_service.clear()
		checkpoint_service.remove_dir_recursive(test_save_dir)

	var real_dir_fingerprint_after := _fingerprint_default_save_dir()
	if real_dir_fingerprint != real_dir_fingerprint_after:
		print("FAIL: the real save dir changed during this test run (AUD-01 regression): %s -> %s"
				% [real_dir_fingerprint, real_dir_fingerprint_after])
		failed += 1

	OS.remove_logger(catcher)
	print("RESULT: %d/%d cases passed" % [ran - failed, ran])
	quit(1 if failed > 0 or ran == 0 else 0)


## {"checkpoint.json": "" | <modified-time>, "checkpoint.bak.json": "" | <modified-time>}
## for CheckpointService.DEFAULT_SAVE_DIR (the REAL player save dir, never
## this runner's throwaway one). Never reads file contents — only whether
## the real save was created, deleted or overwritten during this run, not
## what it contains. Used before and after the whole suite to prove this
## harness (and every case it ran) left the real save untouched.
func _fingerprint_default_save_dir() -> Dictionary:
	var dir: String = CheckpointService.DEFAULT_SAVE_DIR
	var out := {}
	for fname in ["checkpoint.json", "checkpoint.bak.json"]:
		var path := dir.path_join(fname)
		out[fname] = str(FileAccess.get_modified_time(path)) if FileAccess.file_exists(path) else ""
	return out
