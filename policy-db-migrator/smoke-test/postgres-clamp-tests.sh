#!/bin/sh
#============LICENSE_START===============================================
#  Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.
#  ========================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  SPDX-License-Identifier: Apache-2.0
#  ============LICENSE_END=================================================
# shellcheck disable=SC2039
# shellcheck disable=SC2086
# shellcheck disable=SC2012
echo "Start of test $(date +%F-%T)"

export POLICY_HOME=/opt/app/policy
export SQL_USER=${PGSQL_USER}
export SQL_PASSWORD=${PGSQL_PASSWORD}
export SCRIPT_DIRECTORY=postgres
export SCHEMA=clampacm

# Test variables
TOTAL_COUNT=0
A_UPGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1400/upgrade/*.sql | wc -l)
A_DOWNGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1400/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$A_UPGRADE_COUNT
TOTAL_SQLS_DOWNGRADE=$A_DOWNGRADE_COUNT

B_UPGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1500/upgrade/*.sql | wc -l)
B_DOWNGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1500/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$B_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$B_DOWNGRADE_COUNT))

C_UPGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1600/upgrade/*.sql | wc -l)
C_DOWNGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1600/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$C_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$C_DOWNGRADE_COUNT))

D_UPGRADE_COUNT_A=$(ls /home/${SCHEMA}/postgres/1601/upgrade/*.sql | wc -l)
D_UPGRADE_COUNT_B=$(ls /home/${SCHEMA}/postgres/1700/upgrade/*.sql | wc -l)
D_UPGRADE_COUNT=$(($D_UPGRADE_COUNT_A+$D_UPGRADE_COUNT_B))
D_DOWNGRADE_COUNT_A=$(ls /home/${SCHEMA}/postgres/1601/downgrade/*.sql | wc -l)
D_DOWNGRADE_COUNT_B=$(ls /home/${SCHEMA}/postgres/1700/downgrade/*.sql | wc -l)
D_DOWNGRADE_COUNT=$(($D_DOWNGRADE_COUNT_A+$D_DOWNGRADE_COUNT_B))
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$D_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$D_DOWNGRADE_COUNT))

E_UPGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1701/upgrade/*.sql | wc -l)
E_DOWNGRADE_COUNT=$(ls /home/${SCHEMA}/postgres/1701/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$E_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$E_DOWNGRADE_COUNT))

NEW_SQL_EXECUTIONS=0
PREVIOUS_SQL_EXECUTIONS=0
RECENT_SQL_EXECUTIONS=0
TEST_STATUS="FAIL"
TEST_MSG=""
TESTS=0
PASSED=0
FAILED=0

run_sql() {
  local user="${1}" schema="${2}" sql="${3}"
  PGSQL="psql -U ${user} -d ${schema} -h ${SQL_HOST}"
  ${PGSQL} --command "${sql}"
  return $?
}

start_test() {
  echo ""
  echo "############################################################################################################"
  echo ""
  let TESTS=$TESTS+1
  echo "Starting test $TESTS"
  PREVIOUS_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS
}

end_test() {
  echo "Ending test $TESTS"
  reportStatus=$(/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o report | tail -3)
  echo "Status: $reportStatus"
  RECENT_SQL_EXECUTIONS=$(echo $reportStatus | cut -f1 -d' ' | sed 's/(//')
}

check_results() {
  local operation="${1}" startVer="${2}" endVer="${3}" newRecords="${4}" filesRan="${5}"

  echo ""
  echo "Test summary: operation:$operation, from:$startVer, to:$endVer, new executions:$newRecords, sqlFiles:$filesRan"
  # Convert to number
  startVer=$(echo ${startVer} | awk '{$0=int($0)}1')
  endVer=$(echo ${endVer} | awk '{$0=int($0)}1')

  if [ ${startVer} -eq ${endVer} ] && [ $newRecords -eq $filesRan ] && [ $newRecords -eq 0 ]; then
    TEST_MSG="No ${operation} required"
    TEST_STATUS="PASS"
    let PASSED=$PASSED+1
  elif [ "${operation}" == "upgrade" ] && [ ${startVer} -le ${endVer} ] && [ $newRecords -eq $filesRan ]; then
    TEST_MSG="Successful ${operation}"
    TEST_STATUS="PASS"
    let PASSED=$PASSED+1
  elif [ "${operation}" == "downgrade" ] && [ ${startVer} -ge ${endVer} ] && [ $newRecords -eq $filesRan ]; then
    TEST_MSG="Successful ${operation}"
    TEST_STATUS="PASS"
    let PASSED=$PASSED+1
  else
    TEST_MSG="Errors occurred during ${operation}"
    TEST_STATUS="FAIL"
    let FAILED=$FAILED+1
  fi
  echo ""
  echo "*** Test $TESTS: $TEST_STATUS , $TEST_MSG, current version: $END_VERSION ***"
  echo ""
}

# Test 1 - Upgrade to 1701
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade -t 1701
end_test
let TOTAL_COUNT=$A_UPGRADE_COUNT+$B_UPGRADE_COUNT+$C_UPGRADE_COUNT+$D_UPGRADE_COUNT+$E_UPGRADE_COUNT
check_results 'upgrade' "0" "1701" $RECENT_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 2 - downgrade to 1700
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o downgrade -f 1701 -t 1700
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "1701" "1700" $NEW_SQL_EXECUTIONS $E_DOWNGRADE_COUNT

sleep 5

# Test 3 - downgrade to 1600
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o downgrade -f 1700 -t 1600
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "1700" "1600" $NEW_SQL_EXECUTIONS $D_DOWNGRADE_COUNT

sleep 5

# Test 4 - downgrade to 1500
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o downgrade -f 1600 -t 1500
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "1600" "1500" $NEW_SQL_EXECUTIONS $C_DOWNGRADE_COUNT

sleep 5

# Test 5 - downgrade to 1400
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o downgrade -f 1500 -t 1400
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "1500" "1400" $NEW_SQL_EXECUTIONS $B_DOWNGRADE_COUNT

sleep 5

# Test 6 - upgrade to 1500
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade -f 1400 -t 1500
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'upgrade' "1400" "1500" $NEW_SQL_EXECUTIONS $B_UPGRADE_COUNT

sleep 5

# Test 7 - upgrade to 1500
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade -f 1500 -t 1600
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'upgrade' "1500" "1600" $NEW_SQL_EXECUTIONS $C_UPGRADE_COUNT

sleep 5

# Test 8 - upgrade to 1700
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade -f 1600 -t 1700
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'upgrade' "1600" "1700" $NEW_SQL_EXECUTIONS $D_UPGRADE_COUNT

sleep 5

# Test 9 - upgrade to 1701
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade -f 1700 -t 1701
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'upgrade' "1700" "1701" $NEW_SQL_EXECUTIONS $E_UPGRADE_COUNT

sleep 5

# Test 10 - run upgrade on db where tables already exist and migration schema is empty
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o downgrade -f 1701 -t 1400
run_sql $SQL_USER "migration" "DROP TABLE IF EXISTS migration;"
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade -t 1701
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
let TOTAL_COUNT=$B_UPGRADE_COUNT+$B_DOWNGRADE_COUNT+$C_UPGRADE_COUNT+$C_DOWNGRADE_COUNT+$D_UPGRADE_COUNT+$D_DOWNGRADE_COUNT+$E_UPGRADE_COUNT+$E_DOWNGRADE_COUNT
check_results 'upgrade' "1701" "1701" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

#sleep 5

# Test 11 - Full downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o downgrade -f 1701 -t 0
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "1701" "0" $NEW_SQL_EXECUTIONS $TOTAL_SQLS_DOWNGRADE

sleep 5

# Test 12 - Full upgrade
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'upgrade' "0" "1701" $NEW_SQL_EXECUTIONS $TOTAL_SQLS_UPGRADE

# Install database
/opt/app/policy/bin/prepare_upgrade.sh ${SCHEMA}
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o upgrade
/opt/app/policy/bin/db-migrator-pg -s ${SCHEMA} -o report

echo
echo "-----------------------------------------------------------------------"
echo "Number of Tests: $TESTS, Tests Passed: $PASSED, Tests Failed: $FAILED"
echo "-----------------------------------------------------------------------"

echo "End of test $(date +%F-%T)"

nc -lk -p 6824

exit 0
