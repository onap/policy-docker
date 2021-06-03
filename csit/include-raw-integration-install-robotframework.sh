#!/bin/bash
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2015 The Linux Foundation and others.
# Modification Copyright 2021. Nordix Foundation.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
# vim: sw=4 ts=4 sts=4 et ft=sh :

ROBOT_VENV="/tmp/v/robot"
echo ROBOT_VENV="${ROBOT_VENV}" >> "${WORKSPACE}/env.properties"

echo "Python version is: $(python3 --version)"

# The --system-site-packages parameter allows us to pick up system level
# installed packages. This allows us to bake matplotlib which takes very long
# to install into the image.
python3 -m venv "${ROBOT_VENV}"

source "${ROBOT_VENV}/bin/activate"

set -exu

# Make sure pip3 itself us up-to-date.
python3 -m pip install --upgrade pip

echo "Installing Python Requirements"
python3 -m pip install -r pylibs.txt
odltools -V
pip3 freeze
