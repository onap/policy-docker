/*
*  ============LICENSE_START=======================================================
*  feature-distributed-locking
*  ================================================================================
*  Copyright (C) 2024 Nordix Foundation.
*  ================================================================================
*  Licensed under the Apache License, Version 2.0 (the "License");
*  you may not use this file except in compliance with the License.
*  You may obtain a copy of the License at
*
*       http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and
*  limitations under the License.
*  ============LICENSE_END=========================================================
*/

SET foreign_key_checks=0;

CREATE TABLE if NOT EXISTS locks(
    resourceId VARCHAR(128),
    host VARCHAR(128),
    owner VARCHAR(128),
    expirationTime TIMESTAMP DEFAULT '1971-01-01 00:00:00.000000',
    PRIMARY KEY (resourceId),
    INDEX idx_expirationTime(expirationTime),
    INDEX idx_host(host));

SET foreign_key_checks=1;
