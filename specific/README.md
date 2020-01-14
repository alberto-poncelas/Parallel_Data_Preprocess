
Parallel Data Preprocess
===

This is a wrapper with several preprocessing techniques used for Machine Translation


# Instalation


Execute `bash install.sh` to download the scripts and grant execution permission

Alternativelly, edit `config` file with your own paths. 



# Examples of usage of preprocessing


###  Tokenize

```
bash ./preprocess.sh -l en,es -f example/data -e tokenize
```
This creates the files `data.tok.en` and `data.tok.es` 

###  Learn truecase

```
bash ./preprocess.sh -l en,es -f example/data.tok -e learn_truecase
```

This creates the files `truecase-model.en` and `truecase-model.es` in the folder provided by -m paremeter (otherwise it is created in the same path of the file)


###  Apply truecase

```
bash ./preprocess.sh -l en,es -f example/data.tok -e apply_truecase
```
This creates the files `data.true.en` and `data.true.es` 

###  Tokenize and truecase

Apply both tokenization and truecase

```
bash ./preprocess.sh -l en,es -f example/data -e tokenize_truecase
```

###  Learn BPE

Learn BPE using 10 merge operations (provided in the parameter -n)

```
bash ./preprocess.sh -l en,es -f example/data.true -e learn_BPE -n 10
```

This creates the files `codes_file10`, `vocab_file10.en` and `vocab_file10.en` in the folder provided by -m paremeter (otherwise it is created in the same path of the file)


###  Apply BPE
```
bash ./preprocess.sh -l en,es -f example/data.true -e apply_BPE -n 10
```

This creates `data.BPE10.en` and `data.BPE10.es` files

###  BPE
Learn and apply BPE

```
bash ./preprocess.sh -l en,es -f example/data.true  -e BPE -n 10
```

###  Shuffle and split

Shuffle and split files into train and dev. For example, use 80% for train and 20% for dev: provide 80 as parameter -n

```
bash ./preprocess.sh -l en,es -f example/data.true -e split -n 80
```
