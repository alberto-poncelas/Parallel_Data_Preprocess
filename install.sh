

PATH_CURRENT_SCRIPT=$(dirname "$0")

cd $PATH_CURRENT_SCRIPT/scripts

wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/tokenizer/tokenizer.perl
wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/recaser/truecase.perl
wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/recaser/train-truecaser.perl


#git clone https://github.com/rsennrich/subword-nmt.git
git clone -b 'v0.3' --single-branch --depth 1 https://github.com/rsennrich/subword-nmt.git

chmod +x tokenizer.perl
chmod +x truecase.perl
chmod +x train-truecaser.perl


cd $PATH_CURRENT_SCRIPT


