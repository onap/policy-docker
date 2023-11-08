/*
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2023 Nordix Foundation
 *  ================================================================================
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  SPDX-License-Identifier: Apache-2.0
 *  ============LICENSE_END=========================================================
 */

CREATE TABLE IF NOT EXISTS pdpstatistics (
    PDPGROUPNAME VARCHAR(120) NULL,
    PDPSUBGROUPNAME VARCHAR(120) NULL,
    POLICYDEPLOYCOUNT BIGINT DEFAULT NULL NULL,
    POLICYDEPLOYFAILCOUNT BIGINT DEFAULT NULL NULL,
    POLICYDEPLOYSUCCESSCOUNT BIGINT DEFAULT NULL NULL,
    POLICYEXECUTEDCOUNT BIGINT DEFAULT NULL NULL,
    POLICYEXECUTEDFAILCOUNT BIGINT DEFAULT NULL NULL,
    POLICYEXECUTEDSUCCESSCOUNT BIGINT DEFAULT NULL NULL,
    POLICYUNDEPLOYCOUNT BIGINT DEFAULT NULL NULL,
    POLICYUNDEPLOYFAILCOUNT BIGINT DEFAULT NULL NULL,
    POLICYUNDEPLOYSUCCESSCOUNT BIGINT DEFAULT NULL NULL,
    ID BIGINT NOT NULL,
    timeStamp TIMESTAMP(6) NOT NULL,
    name VARCHAR(120) NOT NULL,
    version VARCHAR(20) NOT NULL,
    CONSTRAINT PK_PDPSTATISTICS PRIMARY KEY (ID));
