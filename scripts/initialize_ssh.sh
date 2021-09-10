#!/usr/bin/env bash

LOGFILE=gopass.log

function initialize_ssh {
    eval "$(ssh-agent -s)" &>> ${LOGFILE}
    for SSHFILE in $(ls $HOME/.ssh); do ssh-add -k $HOME/.ssh/${SSHFILE} &>> ${LOGFILE}; done
}

initialize_ssh
