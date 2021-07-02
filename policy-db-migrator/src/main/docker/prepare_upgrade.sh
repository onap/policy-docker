#!/bin/sh
# ============LICENSE_START=======================================================
#  Copyright (C) 2021 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

if [ $# -lt 1 ]; then
    echo "args: schema-name" >&2
    exit 1
fi

export SCHEMA=$1
export POLICY_HOME=/opt/app/policy
export operation=upgrade

cd $POLICY_HOME

# Create schema directory for upgrade
mkdir -p $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/
# Remove any files from previous operations
rm -rf $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/* 2>/dev/null
# Create upgrade directories
cd /home/policy/sql && find . -type d -not -path '*/*/downgrade/*' -not -path '*/*/downgrade' \
	-exec mkdir -p $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/{} \;
# Copy file to upgrade directories
cd /home/policy/sql && find . -type f  -not -path '*/*/downgrade/*' -not -path '*/*/downgrade'  \
	-exec cp -au '{}' $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/{} \;
# Update SQL files with commands required for them to run
find $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/* -type f -name *.sql -exec sed -i '19iUSE policyadmin;' {} \;
find $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/* -type f -name *.sql -exec sed -i '20iSET FOREIGN_KEY_CHECKS = 0;' {} \;
find $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/* -type f -name *.sql -exec \
        sh -c 'echo "SET FOREIGN_KEY_CHECKS = 1;" >> "$1"' -- {} \;

releases=$(find $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/*/*/upgrade -type d | sort -u | rev | cut -f2-3 -d/ | rev)
for release in $releases
do
        name=$(echo $release | cut -f1 -d/)
        version=$(echo $release | cut -f2 -d/)

        echo "Preparing $operation version: $version"

done
echo "Done"
