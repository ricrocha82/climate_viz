#!/usr/bin/env bash

file=$1 
# $1 means use the first argument after the name of the script in the command line

# remove file if it already exists
rm data/$file

# bash script to download data with wget
# for windows need to be downloaded (google "gnu wget for windows")
# linux or Mac (mamba install -c conda-forge wget)
wget -P data/ https://www.ncei.noaa.gov/pub/data/ghcn/daily/$file

# check if is excutable
# ls -lth code/
# if it's not, type:
# chmod +x code/get_ghcnd_data.bash

# code/get_ghcnd_data.bash ghcnd-inventory.txt