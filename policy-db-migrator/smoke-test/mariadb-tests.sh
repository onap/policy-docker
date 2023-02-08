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
export SQL_PASSWORD=policy_user
export SQL_HOST=mariadb
export MYSQL_ROOT_PASSWORD=secret
export SCHEMA=policyadmin
export SCRIPT_DIRECTORY=sql

# Test variables
TOTAL_COUNT=0
H_UPGRADE_COUNT=$(ls /home/policy/sql/0800/upgrade/*.sql | wc -l)
H_DOWNGRADE_COUNT=$(ls /home/policy/sql/0800/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$H_UPGRADE_COUNT
TOTAL_SQLS_DOWNGRADE=$H_DOWNGRADE_COUNT

I_UPGRADE_COUNT=$(ls /home/policy/sql/0900/upgrade/*.sql | wc -l)
I_DOWNGRADE_COUNT=$(ls /home/policy/sql/0900/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$I_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$I_DOWNGRADE_COUNT))

J_UPGRADE_COUNT=$(ls /home/policy/sql/1000/upgrade/*.sql | wc -l)
J_DOWNGRADE_COUNT=$(ls /home/policy/sql/1000/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$J_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$J_DOWNGRADE_COUNT))

K_UPGRADE_COUNT=$(ls /home/policy/sql/1100/upgrade/*.sql | wc -l)
K_DOWNGRADE_COUNT=$(ls /home/policy/sql/1100/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$K_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$K_DOWNGRADE_COUNT))

L_UPGRADE_COUNT=$(ls /home/policy/sql/1200/upgrade/*.sql | wc -l)
L_DOWNGRADE_COUNT=$(ls /home/policy/sql/1200/downgrade/*.sql | wc -l)
TOTAL_SQLS_UPGRADE=$(($TOTAL_SQLS_UPGRADE+$L_UPGRADE_COUNT))
TOTAL_SQLS_DOWNGRADE=$(($TOTAL_SQLS_DOWNGRADE+$L_DOWNGRADE_COUNT))

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

# SQL statements
PDPSTATISTICS="CREATE TABLE IF NOT EXISTS pdpstatistics ("
PDPSTATISTICS=${PDPSTATISTICS}"PDPGROUPNAME VARCHAR(120) NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"PDPSUBGROUPNAME VARCHAR(120) NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"POLICYDEPLOYCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"POLICYDEPLOYFAILCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"POLICYDEPLOYSUCCESSCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"POLICYEXECUTEDCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"POLICYEXECUTEDFAILCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"POLICYEXECUTEDSUCCESSCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS2=${PDPSTATISTICS}"POLICYUNDEPLOYCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS2=${PDPSTATISTICS2}"POLICYUNDEPLOYFAILCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS2=${PDPSTATISTICS2}"POLICYUNDEPLOYSUCCESSCOUNT BIGINT DEFAULT NULL NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"timeStamp datetime NOT NULL, "
PDPSTATISTICS2=${PDPSTATISTICS2}"timeStamp datetime DEFAULT NULL NULL, "
PDPSTATISTICS2=${PDPSTATISTICS2}"ID BIGINT NOT NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"name VARCHAR(120) NOT NULL, "
PDPSTATISTICS2=${PDPSTATISTICS2}"name VARCHAR(120) NOT NULL, "
PDPSTATISTICS=${PDPSTATISTICS}"version VARCHAR(20) NOT NULL,"
PDPSTATISTICS2=${PDPSTATISTICS2}"version VARCHAR(20) NOT NULL,"
PDPSTATISTICS=${PDPSTATISTICS}"CONSTRAINT PK_PDPSTATISTICS PRIMARY KEY (timeStamp, name, version));"
PDPSTATISTICS2=${PDPSTATISTICS2}"CONSTRAINT PK_PDPSTATISTICS PRIMARY KEY (ID, name, version));"

IDX_TSIDX1="CREATE INDEX IDX_TSIDX1 ON pdpstatistics(timeStamp, name, version);"
INSERT="INSERT INTO pdpstatistics(PDPGROUPNAME,PDPSUBGROUPNAME,POLICYDEPLOYCOUNT,POLICYDEPLOYFAILCOUNT,POLICYDEPLOYSUCCESSCOUNT,"
INSERT1="${INSERT}""POLICYEXECUTEDCOUNT,POLICYEXECUTEDFAILCOUNT,POLICYEXECUTEDSUCCESSCOUNT,timeStamp,name,version)"
INSERT2="${INSERT}""POLICYEXECUTEDCOUNT,POLICYEXECUTEDFAILCOUNT,POLICYEXECUTEDSUCCESSCOUNT,POLICYUNDEPLOYCOUNT,"
INSERT2="${INSERT2}""POLICYUNDEPLOYFAILCOUNT,POLICYUNDEPLOYSUCCESSCOUNT,timeStamp,ID,name,version)"
SQL1="${INSERT1}"" values('groupname', 'subgroup',1,1,1,1,1,1,now(),'test1', '1.0')"
SQL2="${INSERT1}"" values('groupname', 'subgroup',1,1,1,1,1,1,now(),'test1', '1.0')"
SQL3="${INSERT2}"" values('groupname', 'subgroup',1,1,1,1,1,1,1,1,1,now(),3,'test1', '1.0')"
SQL4="${INSERT2}"" values('groupname', 'subgroup',1,1,1,1,1,1,1,1,1,now(),4,'test1', '1.0')"
SQL5="${INSERT1}"" values('groupname', 'subgroup',1,1,1,1,1,1,now(),'test2', '1.0')"
SQL6="${INSERT1}"" values('groupname', 'subgroup',1,1,1,1,1,1,now(),'test2', '1.0')"

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

# Test 1 - Upgrade to Istanbul
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
start_test
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -t 0900
end_test
let TOTAL_COUNT=$H_UPGRADE_COUNT+$I_UPGRADE_COUNT
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $RECENT_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 2 - downgrade to 0800
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $I_UPGRADE_COUNT

sleep 5

# Test 3 - upgrade to 0900
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 0800 -t 0900
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $I_UPGRADE_COUNT

sleep 5

# Test4 - run upgrade on db where tables already exist and migration schema is empty
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
run_sql "root" "${MYSQL_ROOT_PASSWORD}" "${SCHEMA}" "DROP DATABASE IF EXISTS migration;"
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -t 0900
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS
check_results $END_STATUS 'upgrade' "0800" "${END_VERSION}" $NEW_SQL_EXECUTIONS $I_UPGRADE_COUNT

sleep 5

# Test5  - upgrade after failed downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "DROP table pdpstatistics;"
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${PDPSTATISTICS2}"
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${IDX_TSIDX1}"
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 0800 -t 0900
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
# (files run before error * 2) + 1 to run the file again
let TOTAL_COUNT=11
check_results $END_STATUS 'upgrade' "0800" "0900" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test6 - Downgrade after failed downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "DROP table pdpstatistics;"
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${PDPSTATISTICS2}"
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${IDX_TSIDX1}"
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
# +1 to run the file again
let TOTAL_COUNT=$I_UPGRADE_COUNT+1
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test7  - downgrade after failed upgrade
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "DROP table pdpstatistics;"
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 0800 -t 0900
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${PDPSTATISTICS}"
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
# (files run before error * 2) + 1 to run the file again
let TOTAL_COUNT=3
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 8 - Upgrade after failed upgrade
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "DROP table pdpstatistics;"
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 0800 -t 0900
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${PDPSTATISTICS}"
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -t 0900
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
# +1 to run the file again
let TOTAL_COUNT=$I_UPGRADE_COUNT+1
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 9 - Upgrade when pdpstatistics contains data
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
start_test
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${SQL1}"
sleep 1
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${SQL2}"
sleep 1
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade -f 0800 -t 0900
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${SQL3}"
sleep 1
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${SQL4}"
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
# +1 to run the file again
let TOTAL_COUNT=$I_UPGRADE_COUNT
check_results $END_STATUS 'upgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_COUNT

sleep 5

# Test 10 - downgrade to 0800 with records in pdpstatistics
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0900 -t 0800
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${SQL5}"
sleep 1
run_sql "${SQL_USER}" "${SQL_PASSWORD}" "${SCHEMA}" "${SQL6}"
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $I_UPGRADE_COUNT

sleep 5

# Test 11 - downgrade from 0800
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 0800
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "${END_VERSION}" $NEW_SQL_EXECUTIONS $H_DOWNGRADE_COUNT

sleep 5

# Test 12 - Full upgrade
start_test
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o upgrade
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'upgrade' "0" "${END_VERSION}" $NEW_SQL_EXECUTIONS $TOTAL_SQLS_UPGRADE

sleep 5

# Test 13 - Full downgrade
start_test
/opt/app/policy/bin/prepare_downgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator -s ${SQL_DB} -o downgrade -f 1200 -t 0
end_test
let NEW_SQL_EXECUTIONS=$RECENT_SQL_EXECUTIONS-$PREVIOUS_SQL_EXECUTIONS
check_results $END_STATUS 'downgrade' "${START_VERSION}" "0" $NEW_SQL_EXECUTIONS $TOTAL_SQLS_DOWNGRADE

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
