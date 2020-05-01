until startx -- vt${V_TERM_NR}; do
	echo "startx server crashed with exit code $?.  Respawning.." >&2
	sleep 1
done