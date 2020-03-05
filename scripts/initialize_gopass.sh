#!/usr/bin/env bash
#example: initialize_gopass.sh git@github.com:<YOURORGANIZATION>/<YOURSECRETSTORE> <YOURSECRETSTORE>

REPOSITORY_LIST_JSON=$1
GPGFOLDER=$2
SSHFOLDER=$3

GOPASS_VERSION="1.8.6"

# Script for initial secret and key declaration for gpg/gopass
set -e


function initialize_ssh {	
#initialize ssh to checkout secret store	
mkdir -p $HOME/.ssh	
cp $SSHFOLDER/* $HOME/.ssh
chmod 700 $HOME/.ssh	
chmod 600 $HOME/.ssh/*
}

function import_and_trust_gpg-key {
# import gpg keys to keystore
for gpgfile in $(ls ${GPGFOLDER}); do gpg --import ${GPGFOLDER}/${gpgfile} &>> $LOGFILE ; done
# trust imported keys
for fpr in $(gpg --list-keys --with-colons  | awk -F: '/fpr:/ {print $10}' | sort -u &>> $LOGFILE); do  echo -e "5\ny\n" |  gpg --command-fd 0 --expert --edit-key $fpr trust &>> $LOGFILE ; done
}

function  initialize_gopass_store {
#init gopass witht the technical gpg user
# e.g.: gopass  --yes init --crypto gpg-id <YOURID> --rcs gitcli
gopass  --yes init --crypto gpg-id $(gpg --list-keys --with-colons  | awk -F: '/pub:/ {print $5}') --rcs gitcli &>> $LOGFILE
}

function unmarshall_json_and_clone_remote {
# parse json and isolate stores
i=0
for store in $(echo ${REPOSITORY_LIST_JSON} | jq -r ".stores[].storename"); do
  SECRET_STORE=$(echo $REPOSITORY_LIST_JSON | jq -r ".stores[$i].storename")
  SECRET_REPOSITORY=$(echo $REPOSITORY_LIST_JSON | jq -r ".stores[$i].directory")
  clone_remote_gopass_store
  i=$i+1
  #savety sleep for git checkout and gopass
  sleep 5
done
}


function clone_remote_gopass_store {
# checkout the customers passtore
gopass --yes clone $SECRET_REPOSITORY $SECRET_STORE --sync gitcli &>> $LOGFILE
}

initialize_ssh
import_and_trust_gpg-key
initialize_gopass_store
unmarshall_json_and_clone_remote
