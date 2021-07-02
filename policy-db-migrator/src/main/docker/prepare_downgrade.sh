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
export operation=downgrade

cd $POLICY_HOME

# Create schema directory for upgrade
mkdir -p $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/
# Remove any files from previous operations
rm -rf $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/* 2>/dev/null
# Copy files to downgrade directories
cd /home/policy/sql && find . -type f  -not -path '*/upgrade/*' -not -path '*/upgrade'  -print0  \
   | cpio --null -pud $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/

releases=$(find $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/*/downgrade -type d | sort -u | rev | cut -f2 -d/ | rev)
for release in $releases
do
        echo "Preparing $operation release version: $release"
done
echo "Done"
