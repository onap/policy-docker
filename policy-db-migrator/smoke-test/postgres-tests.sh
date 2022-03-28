#!/bin/sh
# ============LICENSE_START====================================================
#  Copyright (C) 2022 Nordix Foundation.
# =============================================================================
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
# ============LICENSE_END======================================================
# shellcheck disable=SC2039
# shellcheck disable=SC2086
# shellcheck disable=SC2012

echo "Start of test $(date +%F-%T)"

export POLICY_HOME=/opt/app/policy
export SQL_USER=policy_user
export SQL_HOST=postgres
export SQL_PASSWORD=policy_user
export SCHEMA=policyadmin
export POSTGRES_PASSWORD=secret
export SCRIPT_DIRECTORY=postgres

# Test variables
TOTAL_COUNT=0
HONOLULU_COUNT=96
ISTANBUL_COUNT=13
JAKARTA_COUNT=9

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
  reportStatus=$(/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o report | tail -3)
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

# Test 1 - Upgrade to Istanbul
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o upgrade -t 0900
end_test
let TOTAL_COUNT=$HONOLULU_COUNT+$ISTANBUL_COUNT
check_results 'upgrade' "0" "0900" $RECENT_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 2 - downgrade to 0800
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o downgrade -f 0900 -t 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "0900" "0800" $NEW_SQL_EXECUTIONS $ISTANBUL_COUNT

sleep 5

# Test 3 - upgrade to 1000
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o upgrade -f 0800 -t 1000
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
let TOTAL_COUNT=$ISTANBUL_COUNT+$JAKARTA_COUNT
check_results 'upgrade' "0800" "1000" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test4 - run upgrade on db where tables already exist and migration schema is empty
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o downgrade -t 0800
run_sql "postgres" "postgres" "DROP DATABASE IF EXISTS migration;"
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o upgrade -t 0900
end_test
check_results 'upgrade' "0800" "0900" $RECENT_SQL_EXECUTIONS $ISTANBUL_COUNT

sleep 5

# Test5 - downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o downgrade -f 0900 -t 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "0900" "0800" $NEW_SQL_EXECUTIONS $ISTANBUL_COUNT

sleep 5


# Test 6 - downgrade from 0800
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o downgrade -f 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results 'downgrade' "0800" "0" $NEW_SQL_EXECUTIONS $HONOLULU_COUNT

sleep 5

# Test 7 - Full upgrade
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o upgrade
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
let TOTAL_COUNT=$HONOLULU_COUNT+$ISTANBUL_COUNT+$JAKARTA_COUNT
check_results 'upgrade' "0" "1000" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 13 - Full downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o downgrade -f 1000 -t 0
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
let TOTAL_COUNT=$HONOLULU_COUNT+$ISTANBUL_COUNT+$JAKARTA_COUNT
check_results 'downgrade' "1000" "0" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

echo
echo "-----------------------------------------------------------------------"
echo "Number of Tests: $TESTS, Tests Passed: $PASSED, Tests Failed: $FAILED"
echo "-----------------------------------------------------------------------"

echo "End of test $(date +%F-%T)"

nc -lk -p 6824

exit 0
