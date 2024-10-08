#!/bin/bash -xv
# Copyright (C) 2022, 2024 Nordix Foundation. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

psql -U postgres -d postgres --command "CREATE USER ${PGSQL_USER} WITH PASSWORD '${PGSQL_PASSWORD}';"

for db in migration pooling policyadmin policyclamp operationshistory clampacm
do
    psql -U postgres -d postgres --command "CREATE DATABASE ${db};"
    psql -U postgres -d postgres --command "ALTER DATABASE ${db} OWNER TO ${PGSQL_USER} ;"
    psql -U postgres -d postgres --command "GRANT ALL PRIVILEGES ON DATABASE ${db} TO ${PGSQL_USER} ;"
done