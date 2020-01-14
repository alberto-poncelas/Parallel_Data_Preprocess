#!/bin/bash


# Usage: bash split_train_dev.sh file.L1 file.L2 90
# last number should be a number between 0 and 100. Represents the number of the train size

if [ "$#" -lt 2 ]; then
	printf "ERROR: At least one file and the percentage must be provided \n"
	exit
fi


if [ "$#" -gt 3 ]; then
	printf "ERROR: More than two languages not supported. \n"
	exit
fi



if [ "$#" -eq 2 ]; then
	FILE1=$1
	PERCENT=$2
	NUM_LANG=1
	FILE1_NOEXTENSION=$(echo "$FILE1" | awk -F"." '{print substr($0,1, length($0)-length($NF)-1)}')
	L1=$(echo "$FILE1" | awk -F"." '{print $NF}')
fi



if [ "$#" -eq 3 ]; then
	FILE1=$1
	FILE2=$2
	PERCENT=$3
	NUM_LANG=2
	FILE1_NOEXTENSION=$(echo "$FILE1" | awk -F"." '{print substr($0,1, length($0)-length($NF)-1)}')
	L1=$(echo "$FILE1" | awk -F"." '{print $NF}')
	FILE2_NOEXTENSION=$(echo "$FILE2" | awk -F"." '{print substr($0,1, length($0)-length($NF)-1)}')
	L2=$(echo "$FILE2" | awk -F"." '{print $NF}')
fi



re='^[0-9]+$'
if ! [[ $PERCENT =~ $re ]] ; then
   echo "ERROR: Last parameter must be a number"
   exit
fi





#Executie the split

if [ "$NUM_LANG" -eq 1 ]; then
	FILE_SIZE=$(sed -n '$=' $FILE1)
	TRAIN_SIZE=$(($FILE_SIZE * $PERCENT / 100))
	DEV_SIZE=$(($FILE_SIZE - $TRAIN_SIZE))
	printf "The file (%s lines) is split in: train (%s lines) and dev (%s lines). \n" "$FILE_SIZE" "$TRAIN_SIZE" "$DEV_SIZE"
	### shuff and split
	tmp_dir=$(mktemp -d)
	cat $FILE1 | shuf > $tmp_dir/shuffled_file
	head -$TRAIN_SIZE $tmp_dir/shuffled_file > $FILE1_NOEXTENSION".train.$LANG"
	tail -$DEV_SIZE $tmp_dir/shuffled_file > $FILE1_NOEXTENSION".dev.$LANG"
	rm -r $tmp_dir
fi


if [ "$NUM_LANG" -eq 2 ]; then
	FILE_SIZE=$(sed -n '$=' $FILE1)
	TRAIN_SIZE=$(($FILE_SIZE * $PERCENT / 100))
	DEV_SIZE=$(($FILE_SIZE - $TRAIN_SIZE))
	printf "The file (%s lines) is split in: train (%s lines) and dev (%s lines). \n" "$FILE_SIZE" "$TRAIN_SIZE" "$DEV_SIZE"
	### shuff and split
	tmp_dir=$(mktemp -d)
	paste -d "\t" $FILE1 $FILE2 | shuf > $tmp_dir/shuffled_file
	head -$TRAIN_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $1}' > $FILE1_NOEXTENSION".train.$L1"
	head -$TRAIN_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $2}' > $FILE2_NOEXTENSION".train.$L2"
	tail -$DEV_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $1}' > $FILE1_NOEXTENSION".dev.$L1"
	tail -$DEV_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $2}' > $FILE2_NOEXTENSION".dev.$L2"
	rm -r $tmp_dir
fi



