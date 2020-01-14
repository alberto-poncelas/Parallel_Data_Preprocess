#!/bin/bash




#Load config
PATH_CURRENT_SCRIPT=$(dirname "$0")
source $PATH_CURRENT_SCRIPT/config


####################################
########## MAIN FUNCTIONS ##########
####################################

tokenize(){
	for LANG in "${LANG_ARRAY[@]}"
	do
		echo "tokenizing $FILEPATH.$LANG ..."
		$PREPROCESS_PATH/tokenizer.perl -l $LANG < $FILEPATH.$LANG > $FILEPATH".tok."$LANG
	done
}



learn_truecase(){
	get_model_path
	for LANG in "${LANG_ARRAY[@]}"
	do
		echo "learning truecaser from $FILEPATH.$LANG ..."
		$TRUECASER_PATH/train-truecaser.perl --model $MODEL/truecase-model".$LANG" --corpus $FILEPATH".$LANG"
	done
}




apply_truecase(){
	get_model_path
	for LANG in "${LANG_ARRAY[@]}"
	do
		echo "Applying truecaser ..."
		$TRUECASER_PATH/truecase.perl --model $MODEL/truecase-model.$LANG  < $FILEPATH.$LANG > $FILEPATH".true."$LANG
	done
}



tokenize_and_truecase(){
	get_model_path
	tmp_dir=$(mktemp -d)
	for LANG in "${LANG_ARRAY[@]}"
	do
		$PREPROCESS_PATH/tokenizer.perl -l $LANG < $FILEPATH.$LANG > $tmp_dir/filename".tok."$LANG
		$TRUECASER_PATH/train-truecaser.perl --model $MODEL/truecase-model.$LANG --corpus $tmp_dir/filename".tok."$LANG
		$TRUECASER_PATH/truecase.perl --model $MODEL/truecase-model.$LANG  < $tmp_dir/filename".tok."$LANG > $FILEPATH".true."$LANG
	done
	rm -r $tmp_dir
}




learn_BPE_onelang(){
	echo "learning BPE from $FILEPATH.$L1"
	get_model_path
	if [ -z ${numeric_op+x} ]; then echo "num_operations is not defined"; exit; else num_operations=$numeric_op; fi
	codes_file=$MODEL/codes_file$num_operations
	vocab_file=$MODEL/vocab_file$num_operations
	python $BPETOOLS/learn_joint_bpe_and_vocab.py --input $FILEPATH.$L1 -s $num_operations -o $codes_file --write-vocabulary $vocab_file
}


learn_BPE_joined(){
	echo "learning BPE from $FILEPATH.$L1 and $FILEPATH.$L2"
	get_model_path
	if [ -z ${numeric_op+x} ]; then echo "num_operations is not defined"; exit; else num_operations=$numeric_op; fi
	codes_file=$MODEL/codes_file$num_operations
	vocab_file=$MODEL/vocab_file$num_operations
	python $BPETOOLS/learn_joint_bpe_and_vocab.py --input $FILEPATH.$L1 $FILEPATH.$L2 -s $num_operations -o $codes_file --write-vocabulary $vocab_file.$L1 $vocab_file.$L2
}


apply_BPE(){
	get_model_path
	if [ -z ${numeric_op+x} ]; then echo "num_operations is not defined"; exit; else num_operations=$numeric_op; fi
	codes_file=$MODEL/codes_file$num_operations
	vocab_file=$MODEL/vocab_file$num_operations
	for LANG in "${LANG_ARRAY[@]}"
	do
		echo "Applying BPE to $FILEPATH.$LANG"
		python $BPETOOLS/apply_bpe.py -c $codes_file --vocabulary $vocab_file.$LANG --vocabulary-threshold 50 < $FILEPATH.$LANG > $FILEPATH.BPE"$num_operations".$LANG
	done
}




BPE(){ #both learn and apply BPE
	if [ $NUM_LANGS == 2 ]; then learn_BPE_joined;  else learn_BPE_onelang;  fi 
	apply_BPE
}




split_train_dev(){
	if [ -z ${numeric_op+x} ]; then echo "num_operations is not defined"; exit; else PERCENT=$numeric_op; fi
	FILE_SIZE=$(sed -n '$=' $FILEPATH".$L1")
	TRAIN_SIZE=$(($FILE_SIZE * $PERCENT / 100))
	DEV_SIZE=$(($FILE_SIZE - $TRAIN_SIZE))
	printf "The file (%s lines) is split in %s training lines and %s dev lines\n" "$FILE_SIZE" "$TRAIN_SIZE" "$DEV_SIZE"
	### shuff and split
	tmp_dir=$(mktemp -d)
	cat $FILEPATH".$L1" | shuf > $tmp_dir/shuffled_file
	head -$TRAIN_SIZE $tmp_dir/shuffled_file > $FILEPATH".train.$L1"
	tail -$DEV_SIZE $tmp_dir/shuffled_file > $FILEPATH".dev.$L1"
	rm -r $tmp_dir
}





split_train_dev_twoLang(){
	if [ -z ${numeric_op+x} ]; then echo "num_operations is not defined"; exit; else PERCENT=$numeric_op; fi
	FILE_SIZE=$(sed -n '$=' $FILEPATH".$L1")
	TRAIN_SIZE=$(($FILE_SIZE * $PERCENT / 100))
	DEV_SIZE=$(($FILE_SIZE - $TRAIN_SIZE))
	printf "The file (%s lines) is split in %s training lines and %s dev lines\n" "$FILE_SIZE" "$TRAIN_SIZE" "$DEV_SIZE"
	### shuff and split
	tmp_dir=$(mktemp -d)
	paste -d "\t" $FILEPATH".$L1" $FILEPATH".$L2" | shuf > $tmp_dir/shuffled_file
	head -$TRAIN_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $1}' > $FILEPATH".train.$L1"
	head -$TRAIN_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $2}' > $FILEPATH".train.$L2"
	tail -$DEV_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $1}' > $FILEPATH".dev.$L1"
	tail -$DEV_SIZE $tmp_dir/shuffled_file | awk -F"\t" '{print $2}' > $FILEPATH".dev.$L2"
	rm -r $tmp_dir
}






#####################################
########## OTHER FUNCTIONS ##########
#####################################




display_usage() { 
	echo "This script must include the following parameters" 
    echo "  -e      function to execute (tokenize|learn_truecase|apply_truecase|tokenize_truecase|learn_BPE|apply_BPE|BPE|split)"
    echo "  -l      languages (comma separated)"
    echo "  -f      path of the file"
    echo "  -m      path of the model (optional)"
    echo "  -n      numeric parameter (necesary for some methods)"
} 




split_in_langs(){
LANG_LIST=$1
NUM_LANGS=$(echo $LANG_LIST | awk -F"," '{print NF}')
L1=$(echo $LANG_LIST | awk -F"," '{print $1}')
L2=$(echo $LANG_LIST | awk -F"," '{print $2}')
if [ -z ${L2+x} ]; then 
	LANG_ARRAY=( $L1 ); 
else 
	LANG_ARRAY=( $L1 $L2 ); 
fi
}


get_model_path(){
if [ -z ${model+x} ]; then 
	echo "model path not defined. Setting to $file_directory"
	MODEL=$file_directory; 
fi
}








while getopts ":e:l:f:n:m:" opt; do
  case $opt in
    e) method="$OPTARG"
    ;;
    l) langs="$OPTARG"
    ;;
    f) filepath="$OPTARG"
    ;;
    n) numeric_op="$OPTARG"
    ;;
    m) MODEL="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done



#check the parameters
if [ -z ${method+x} ] || [ -z ${langs+x} ] || [ -z ${filepath+x} ]; then
	display_usage;
	exit 0
fi





printf "Argument method is %s\n" "$method"
printf "Argument filepath is %s\n" "$filepath"
printf "Argument langs is %s\n" "$langs"




##get languages
split_in_langs $langs
printf "Number of languages: %s\n" "$NUM_LANGS"
printf "Language 1: %s\n" "$L1"
printf "Language 2: %s\n" "$L2"





##get file information
file_directory=$(dirname "$filepath") #get directory of the file
filename=$(basename -- "$filepath") #get the name of the file
extension="${filename##*.}" #get the extension of the file
filename_without_extension="${filename%.*}" #get the file without the (language) extension
FILEPATH=$file_directory/$filename_without_extension
printf "The file (without extension) is: %s\n" "$FILEPATH"




##execute method
case $method in
	tokenize) tokenize
	;;
	learn_truecase) learn_truecase
	;;
	apply_truecase) apply_truecase
	;;
	tokenize_truecase) tokenize_and_truecase
	;;
	learn_BPE) if [ $NUM_LANGS == 2 ]; then learn_BPE_joined;  else learn_BPE_onelang;  fi 
	;;
	apply_BPE) apply_BPE
	;;
	BPE) BPE
	;;
	split) if [ $NUM_LANGS == 2 ]; then split_train_dev_twoLang;  else split_train_dev;  fi 
	;;
	*) echo "Invalid method $method" ; exit 0
	;;
esac





