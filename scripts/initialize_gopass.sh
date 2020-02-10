#!/usr/bin/env bash
#example: initialize_gopass.sh git@github.com:<YOURORGANIZATION>/<YOURSECRETSTORE> <YOURSECRETSTORE>

SECRET_REPOSITORY=$1
SECRET_STORE=$2
LOGFILE=gopass.log

GOPASS_VERSION="1.8.6"


# Script for initial secret and key declaration for gpg/gopass
set -e

function initialize_ssh {
#initialize ssh to checkout secret store
mkdir $HOME/.ssh
cp ssh-key/identity $HOME/.ssh/id_rsa
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/id_rsa
}

function import_and_trust_gpg-key {
# import gpg keys to keystore
gpg --import $HOME/gpg-import/argo.asc &>> $LOGFILE
# trust imported keys
for fpr in $(gpg --list-keys --with-colons  | awk -F: '/fpr:/ {print $10}' | sort -u &>> $LOGFILE); do  echo -e "5\ny\n" |  gpg --command-fd 0 --expert --edit-key $fpr trust &>> $LOGFILE ; done
}

function  initialize_gopass_store {
#init gopass witht the technical gpg user
# e.g.: gopass  --yes init --crypto gpg-id <YOURID> --rcs gitcli
gopass  --yes init --crypto gpg-id $(gpg --list-keys --with-colons  | awk -F: '/pub:/ {print $5}') --rcs gitcli &>> $LOGFILE
}

function clone_remote_gopass_store {
# checkout the customers passtore
gopass --yes clone $SECRET_REPOSITORY $SECRET_STORE --sync gitcli &>> $LOGFILE
}

initialize_ssh
import_and_trust_gpg-key
initialize_gopass_store
clone_remote_gopass_store

