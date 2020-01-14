
Parallel Data Preprocess
===

This is a wrapper with several preprocessing techniques used for Machine Translation


# Instalation


Execute `bash install.sh` to download the scripts and grant execution permission

Alternativelly, edit `config` file with your own paths. 



# Examples of usage of preprocessing




###  Tokenize and truecase

Apply both tokenization and truecase to all langues listed (comma separated).
Truecase model is learned from the tokenized files (unless a truecased model exists in the folder)


```
cd example
bash ../tokenize_truecase.sh en,es
```




###  BPE

Learn (if BPE models does not exist) and apply BPE.
In case of providing more than one language, the model is jointly learned

Execute joined BPE with 10 merge operations:
```
cd example
bash ../BPE.sh en,es 10
```

###  Shuffle and split

Shuffle and split files into train and dev. If two files are provided, then the sentences are paired so they are also paired after shuffling.

Use 80% for train and 20% for dev. Provide 80 as parameter:

```
cd example
bash ../preprocess.sh data.en data.es 80
```
