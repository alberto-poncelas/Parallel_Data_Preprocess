#!/bin/bash


#Load config
PATH_CURRENT_SCRIPT=$(dirname "$0")
source $PATH_CURRENT_SCRIPT/config


display_usage() { 
	echo "Usage: bash tokenize_truecase.sh LANGS" 
	echo "* LANGS: Comma-separated list of languages"
} 

if [ "$#" -ne 1 ]
	then
	display_usage;
	exit 0
fi




langs=$1
LANG_ARRAY=($(echo $langs | sed 's/,/ /g')) 




##tokenize
for LANG in "${LANG_ARRAY[@]}"
do
	printf "Processing language: %s\n" "$LANG"
	files=$(ls *.$LANG)
	for f in $files; do 
		echo $f
		$PREPROCESS_PATH/tokenizer.perl -l $LANG < $f > $f".tokenized"
	done
done


##learn truecase
tmp_dir=$(mktemp -d)
for LANG in "${LANG_ARRAY[@]}"
do
	if [ -f truecase-model"_$LANG" ]
	then
		printf "truecase model for language %s already exists.\n" "$LANG"
	else
		printf "Processing language: %s\n" "$LANG"
		files=$(ls *.$LANG)
		for f in $files; do 
			cat $f".tokenized" >> $tmp_dir/"all_"$LANG
		done
		$TRUECASER_PATH/train-truecaser.perl --model truecase-model"_$LANG" --corpus $tmp_dir/"all_"$LANG
	fi
done
rm -r $tmp_dir



##apply truecase
for LANG in "${LANG_ARRAY[@]}"
do
	printf "Processing language: %s\n" "$LANG"
	files=$(ls *.$LANG)
	for f in $files; do 
		echo $f
		filename_without_extension=$(echo "$f" | awk -F"." '{print substr($0,1, length($0)-length($NF)-1)}')
		$TRUECASER_PATH/truecase.perl --model truecase-model"_$LANG"  < $f".tokenized" > $filename_without_extension".true."$LANG
	done
done



