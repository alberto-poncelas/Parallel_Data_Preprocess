#!/bin/bash


#Load config
PATH_CURRENT_SCRIPT=$(dirname "$0")
source $PATH_CURRENT_SCRIPT/config






# Usage: bash BPE.sh language_list  num_operations
# If several languages are provided then join BPE is learned


langs=$1
num_operations=$2



LANG_ARRAY=($(echo $langs | sed 's/,/ /g')) 




if [ ${#LANG_ARRAY[@]} -eq 1 ]; then
	SUFFIX="_$langs";
else
	SUFFIX="";
fi

echo $SUFFIX


codes_file=codes_file$num_operations"$SUFFIX"
vocab_file=vocab_file$num_operations"$SUFFIX"


if [ -f "$vocab_file" ]; then
	echo "BPE model "$vocab_file" found.";
else
	echo "Learning BPE model.";
	tmp_dir=$(mktemp -d)
	for LANG in "${LANG_ARRAY[@]}"
	do
		files=$(ls *.true.$LANG)
		for f in $files; do 
			cat $f >> $tmp_dir/"file"
		done
	done
	python $BPETOOLS/learn_joint_bpe_and_vocab.py --input $tmp_dir/"file" -s $num_operations -o $codes_file --write-vocabulary $vocab_file
	rm -r $tmp_dir
fi





echo "Applying BPE"
for LANG in "${LANG_ARRAY[@]}"
do
	files=$(ls *.true.$LANG)
	for f in $files; do 
		filename_without_extension=$(echo "$f" | awk -F"." '{print substr($0,1, length($0)-length($NF)-1)}')
		python $BPETOOLS/apply_bpe.py -c $codes_file --vocabulary $vocab_file --vocabulary-threshold 50 < $f > $filename_without_extension.BPE"$num_operations".$LANG
	done
done



