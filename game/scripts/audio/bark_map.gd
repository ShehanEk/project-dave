extends RefCounted
## The guards' and Staffers' spoken barks (N05): the caption text each BrawlerTuning
## carries (data/tuning/night_guard.tres and staffer.tres: voice_notice, voice_windup,
## voice_hurt), mapped to the cue that speaks it. The cues are ElevenLabs-only
## (Audio.ELEVEN_ONLY_CUES) and play through Audio.play_sfx(cue, position) at the
## speaker, so the caption and the voice always agree. A line with no entry here (a new
## bark that has no recording yet) is caption-only. No `class_name` (the project's
## import-cache rule): callers preload it by path.

const CUES := {
	"Harlan! Get on the fucking ground!": &"bark_guard_ground",
	"Security! Don't you move!": &"bark_guard_security",
	"There he is — hands where I can see them!": &"bark_guard_there_he_is",
	"Don't make me do this!": &"bark_guard_dont_make_me",
	"Last warning!": &"bark_guard_last_warning",
	"Fuck — he's shooting!": &"bark_guard_hes_shooting",
	"Shit! Shots fired!": &"bark_guard_shots_fired",
	"Please stay where you are, Dr. Harlan.": &"bark_staffer_stay",
	"Please return to your workstation, Dave.": &"bark_staffer_workstation",
	"Please hold still.": &"bark_staffer_hold_still",
	"...Dave?": &"bark_staffer_dave",
}


## The cue that speaks `text`, or &"" when the line has no recording.
static func cue_for(text: String) -> StringName:
	return CUES.get(text, &"")
