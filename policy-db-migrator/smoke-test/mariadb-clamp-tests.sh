#!/bin/sh
# ============LICENSE_START====================================================
#  Copyright (C) 2024 Nordix Foundation.
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
export SQL_USER=${MYSQL_USER}
export SQL_PASSWORD=${MYSQL_PASSWORD}
export SCRIPT_DIRECTORY=sql
export SCHEMA=clampacm

# Test variables
TOTAL_COUNT=0
A_UPGRADE_COUNT=$(ls /home/${SQL_DB}/sql/1400/upgrade/*.sql | wc -l)
A_DOWNGRADE_COUNT=$(ls /home/${SQL_DB}/sql/1400/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$A_UPGRADE_COUNT
TOTAL_SQLS_DOWNGRADE=$A_DOWNGRADE_COUNT

B_UPGRADE_COUNT=$(ls /home/${SQL_DB}/sql/1500/upgrade/*.sql | wc -l)
B_DOWNGRADE_COUNT=$(ls /home/${SQL_DB}/sql/1500/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$B_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$B_DOWNGRADE_COUNT))

C_UPGRADE_COUNT=$(ls /home/${SQL_DB}/sql/1600/upgrade/*.sql | wc -l)
C_DOWNGRADE_COUNT=$(ls /home/${SQL_DB}/sql/1600/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$C_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$C_DOWNGRADE_COUNT))

NEW_SQL_EXECUTIONS=0
START_VERSION=""
PREVIOUS_SQL_EXECUTIONS=0
END_VERSION=""
RECENT_SQL_EXECUTIONS=0
END_STATUS=0
TEST_STATUS="FAIL"
TEST_MSG=""
TESTS=0
PASSED=0
FAILED=0

run_sql() {
  local user="${1}" password="${2}" schema="${3}" sql="${4}"
  MYSQL="mysql -u${user} -p${password} -h ${SQL_HOST} ${schema}"
  ${MYSQL} --execute "${sql}"
  return $?
}

start_test() {
  echo ""
  echo "############################################################################################################"
  echo ""
  let TESTS=$TESTS+1
  reportStatus=$(/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o report | tail -2)
  echo "Starting test $TESTS"
  echo "$reportStatus"
  START_VERSION=$(echo $reportStatus | cut -f13 -d' ')
  PREVIOUS_SQL_EXECUTIONS=$(echo $reportStatus | cut -f1 -d' ')

  if [ "${START_VERSION}" == "" ]; then
    START_VERSION="0"
    PREVIOUS_SQL_EXECUTIONS=0
  fi
}

end_test() {
  reportStatus=$(/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o report | tail -2)
  echo "Ending test $TESTS"
  echo "$reportStatus"
  END_VERSION=$(echo $reportStatus | cut -f13 -d' ')
  RECENT_SQL_EXECUTIONS=$(echo $reportStatus | cut -f1 -d' ')
  END_STATUS=$(echo $reportStatus | cut -f7 -d' ')
}

check_results() {
  local status="${1}" operation="${2}" startVer="${3}" endVer="${4}" newRecords="${5}" filesRan="${6}"

  echo ""
  echo "Test summary: status:$status, operation:$operation, from:$startVer, to:$endVer, new executions:$newRecords, sqlFiles:$filesRan"
  # Convert to number
  startVer=$(echo ${startVer} | awk '{$0=int($0)}1')
  endVer=$(echo ${endVer} | awk '{$0=int($0)}1')

  if [ ${startVer} -eq ${endVer} ] && [ $newRecords -eq $filesRan ] && [ $newRecords -eq 0 ]; then
    TEST_MSG="No ${operation} required"
    TEST_STATUS="PASS"
    let PASSED=$PASSED+1
  elif [ $status -eq 1 ] && [ "${operation}" == "upgrade" ] && [ ${startVer} -le ${endVer} ] && [ $newRecords -eq $filesRan ]; then
    TEST_MSG="Successful ${operation}"
    TEST_STATUS="PASS"
    let PASSED=$PASSED+1
  elif [ $status -eq 1 ] && [ "${operation}" == "downgrade" ] && [ ${startVer} -ge ${endVer} ] && [ $newRecords -eq $filesRan ]; then
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

# Test 1 - Upgrade to 1600
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -t 1600
end_test
let TOTAL_COUNT=$A_UPGRADE_COUNT+$B_UPGRADE_COUNT+$C_UPGRADE_COUNT
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $RECENT_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 2 - downgrade to 1500
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 1600 -t 1500
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $C_DOWNGRADE_COUNT

sleep 5

# Test 3 - downgrade to 1400
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 1500 -t 1400
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $B_DOWNGRADE_COUNT

sleep 5

# Test 4 - upgrade to 1500
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 1400 -t 1500
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $B_UPGRADE_COUNT

sleep 5

# Test 5 - upgrade to 1600
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 1500 -t 1600
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $C_UPGRADE_COUNT

sleep 5

# Test 6 - run upgrade on db where tables already exist and migration schema is empty
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 1600 -t 1400
run_sql "root" "${MYSQL_ROOT_PASSWORD}" "${SCHEMA}" "DROP DATABASE IF EXISTS migration;"
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -t 1600
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
let TOTAL_COUNT=$C_DOWNGRADE_COUNT+$C_UPGRADE_COUNT+$B_DOWNGRADE_COUNT+$B_UPGRADE_COUNT
check_results $END_STATUS 'upgrade' "1400" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 7 - Full downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 1600 -t 0
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "0" $NEW_SQL_EXECUTIONS $TOTAL_SQLS_DOWNGRADE

sleep 5

# Test 8 - Full upgrade
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'upgrade' "0" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_SQLS_UPGRADE

# Install database
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o report

echo
echo "-----------------------------------------------------------------------"
echo "Number of Tests: $TESTS, Tests Passed: $PASSED, Tests Failed: $FAILED"
echo "-----------------------------------------------------------------------"

echo "End of test $(date +%F-%T)"

nc -lk -p 6824

exit 0
