#!/bin/bash

OPUS_VERSION="1.5.2"

# OK so ideally I'd like to have something like:
# #cgo SOURCES opus/a.c opus/b.c etc...
# unfortunately, there is no way with #cgo to specify I want to add out-of-tree source files. That could be nice to have.
# so we generate a bunch of files for each opus file to be included. Putting it all in one file fails because of static functions.

# clean
rm inc-*.go

cd opus-$OPUS_VERSION

genfile() {
	local file="$1"
	local COND="$2"
	local FN=`echo "inc-$file" | sed 's#/\{1,\}#-#g;s/_/-/g'`
	FN="../${FN/.c/}.go"

	echo "Processing: $file"

	echo -n >"$FN" # empty file
	if [ x"$COND" != x ]; then
		echo "// +build $COND" >>"$FN"
		echo >>"$FN"
	fi

	# actual file
	cat >>"$FN" <<EOF
package opus

/*
#include <opus-$OPUS_VERSION/$file>
*/
import "C"
EOF
}

# Note: ARM-specific directories (celt/arm, silk/arm) are excluded because:
# - silk/arm requires fixed-point mode (FIXED_POINT) but we use float
# - celt/arm has RTCD conflicts without full ARM optimization support
# ARM builds will use the generic C implementation instead.
for dir in src celt silk celt/x86 silk/float silk/x86; do
	COND=""
	case `basename "$dir"` in
		x86)
			COND="x86 amd64"
			;;
	esac

	for file in $dir/*.c; do
		if [ ! -f "$file" ]; then
			continue
		fi
		case $file in
			*test_*)
				# skip
				;;
			*demo*)
				# skip
				;;
			*sse4_1*)
				# go won't let us compile for sse4-1
				;;
			*avx*)
				# go won't let us compile for avx/avx2 without per-file CFLAGS
				;;
			*ne10*)
				# NE10 is an optional ARM library not typically available
				;;
			src/opus_compare.c)
				;;
			*)
				genfile "$file" "$COND"
		esac
	done
done
