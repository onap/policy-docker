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
cd $POLICY_HOME

mkdir -p $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/
rm -rf $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/* 2>/dev/null
cp -r /home/policy/sql/* $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/

releases=$(find /home/policy/sql/*/upgrade/*.* -type f -name *.sql | sed 's/-.*//' | sort -u | rev | cut -f1-3 -d/ | rev)
for release in $releases
do
        name=$(echo $release | cut -f1 -d/)
        operation=$(echo $release | cut -f2 -d/)
        version=$(echo $release | cut -f3 -d/)

        echo "Preparing $version-$name.$operation.sql"

        rm $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/$version-$name.$operation.sql >/dev/null 2>/dev/null
        cp $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/header-template.sql \
           $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/$version-$name.$operation.sql

        echo "USE ${SCHEMA};" >> $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/$version-$name.$operation.sql

        find $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/*/upgrade/ \
             -name ${version}*.sql -exec echo \\. {} \; | sort | nl | sort -n | cut -f 2- \
             >> $POLICY_HOME/etc/db/migration/${SCHEMA}/sql/$version-$name.$operation.sql
done
echo "Done"
