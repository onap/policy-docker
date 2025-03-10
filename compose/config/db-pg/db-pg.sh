#!/bin/bash -xv
# Copyright (C) 2022, 2024-2025 Nordix Foundation. All rights reserved
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
#
# SPDX-License-Identifier: Apache-2.0

psql -U postgres -d postgres --command "CREATE USER ${PGSQL_USER} WITH
    PASSWORD '${PGSQL_PASSWORD}' CREATEDB;"

for db in migration pooling policyadmin policyclamp operationshistory clampacm
do
    psql -U ${PGSQL_USER} -d postgres --command "CREATE DATABASE ${db};"
done