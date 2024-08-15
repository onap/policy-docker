/*
*  ============LICENSE_START=======================================================
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

CREATE TABLE operationshistory
(
    id             BIGINT NOT NULL,
    closedLoopName VARCHAR(255),
    requestId      VARCHAR(50),
    subrequestId   VARCHAR(50),
    actor          VARCHAR(50),
    operation      VARCHAR(50),
    target         VARCHAR(50),
    starttime      TIMESTAMP,
    outcome        VARCHAR(50),
    message        VARCHAR(255),
    endtime        TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE INDEX operationshistory_clreqid_index ON operationshistory (requestId, closedLoopName);
CREATE INDEX operationshistory_target_index ON operationshistory (target, operation, actor, endtime);
