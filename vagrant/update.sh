#!/bin/bash

comp=$1

case $comp in

common)
    git fetch http://gerrit.onap.org/r/policy/common refs/changes/81/5781/3 && git checkout FETCH_HEAD
    ;;

drools-pdp)
    git fetch http://gerrit.onap.org/r/policy/drools-pdp refs/changes/99/5799/3 && git checkout FETCH_HEAD
    ;;

drools-applications)
    git fetch http://gerrit.onap.org/r/policy/drools-applications refs/changes/77/6077/2 && git checkout FETCH_HEAD
    ;;

engine)
    git fetch http://gerrit.onap.org/r/policy/engine refs/changes/81/6081/2 && git checkout FETCH_HEAD
    ;;

docker)
   git fetch http://gerrit.onap.org/r/policy/docker refs/changes/79/6079/2 && git checkout FETCH_HEAD
   ;;

esac
