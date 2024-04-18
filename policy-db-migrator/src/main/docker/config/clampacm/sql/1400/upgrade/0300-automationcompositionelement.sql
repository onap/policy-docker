/*
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2024 Nordix Foundation
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

CREATE TABLE clampacm.automationcompositionelement (elementId VARCHAR(255) NOT NULL, definition_name VARCHAR(255) NULL, definition_version VARCHAR(255) NULL, deployState TINYINT DEFAULT NULL NULL, `description` VARCHAR(255) NULL, instanceId VARCHAR(255) NULL, lockState TINYINT DEFAULT NULL NULL, message VARCHAR(255) NULL, operationalState VARCHAR(255) NULL, outProperties MEDIUMTEXT NULL, participantId VARCHAR(255) NULL, properties MEDIUMTEXT NULL, restarting BIT NULL, useState VARCHAR(255) NULL, CONSTRAINT PK_AUTOMATIONCOMPOSITIONELEMENT PRIMARY KEY (elementId));