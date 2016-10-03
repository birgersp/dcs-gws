TARGETS=(mist/mist_4_3_74.lua bajas/bajas.lua)
OUTPUT=build/bajas-standalone.lua
COMMENT_PREFIX=--

echo Writing to \"$OUTPUT\"...
> $OUTPUT

first=1
for index in ${!TARGETS[*]}; do

	if [ $first -eq 0 ]; then
		echo "" >> $OUTPUT
		echo "" >> $OUTPUT
	else
		first=0
	fi

	item=${TARGETS[$index]}
	
	echo $COMMENT_PREFIX " " $item >> $OUTPUT
	echo "" >> $OUTPUT
	echo Copying $item...
	cat $item >> $OUTPUT
done

echo Done