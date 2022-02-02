/*
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2022 Nordix Foundation
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

CREATE TABLE IF NOT EXISTS toscatrigger (ACTION VARCHAR(255) NULL, toscaCondition BYTEA DEFAULT NULL NULL, toscaConstraint BYTEA DEFAULT NULL NULL, DESCRIPTION VARCHAR(255) NULL, EVALUATIONS INT DEFAULT NULL NULL, EVENTTYPE VARCHAR(255) NULL, METHOD VARCHAR(255) NULL, PERIOD BYTEA DEFAULT NULL NULL, SCHEDULE BYTEA DEFAULT NULL NULL, TARGETFILTER BYTEA DEFAULT NULL NULL, parentLocalName VARCHAR(120) NOT NULL, localName VARCHAR(120) NOT NULL, parentKeyVersion VARCHAR(15) NOT NULL, parentKeyName VARCHAR(120) NOT NULL, CONSTRAINT PK_TOSCATRIGGER PRIMARY KEY (parentLocalName, localName, parentKeyVersion, parentKeyName));
