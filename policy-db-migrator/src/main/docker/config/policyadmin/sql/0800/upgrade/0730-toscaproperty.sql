/*
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2021, 2023 Nordix Foundation
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

CREATE TABLE IF NOT EXISTS toscaproperty (DEFAULTVALUE VARCHAR(255) DEFAULT NULL, `DESCRIPTION` VARCHAR(255) DEFAULT NULL, ENTRYSCHEMA LONGBLOB DEFAULT NULL, REQUIRED BOOLEAN DEFAULT 0, STATUS INT DEFAULT NULL, parentLocalName VARCHAR(120) NOT NULL, localName VARCHAR(120) NOT NULL, parentKeyVersion VARCHAR(15) NOT NULL, parentKeyName VARCHAR(120) NOT NULL, name VARCHAR(120) DEFAULT NULL, version VARCHAR(20) DEFAULT NULL, PRIMARY KEY PK_TOSCAPROPERTY (parentLocalName, localName, parentKeyVersion, parentKeyName));
