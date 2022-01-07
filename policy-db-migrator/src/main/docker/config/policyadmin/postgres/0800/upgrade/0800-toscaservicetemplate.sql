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

CREATE TABLE IF NOT EXISTS toscaservicetemplate (DESCRIPTION VARCHAR(255) NULL, TOSCADEFINITIONSVERSION VARCHAR(255) NULL, derived_from_name VARCHAR(255) NULL, derived_from_version VARCHAR(255) NULL, name VARCHAR(120) NOT NULL, version VARCHAR(20) NOT NULL, capabilityTypesVersion VARCHAR(20) NULL, capabilityTypesName VARCHAR(120) NULL, dataTypesName VARCHAR(120) NULL, dataTypesVersion VARCHAR(20) NULL, nodeTypesVersion VARCHAR(20) NULL, nodeTypesName VARCHAR(120) NULL, policyTypesName VARCHAR(120) NULL, policyTypesVersion VARCHAR(20) NULL, relationshipTypesVersion VARCHAR(20) NULL, relationshipTypesName VARCHAR(120) NULL, topologyTemplateLocalName VARCHAR(120) NULL, topologyTemplateParentKeyName VARCHAR(120) NULL, topologyTemplateParentKeyVersion VARCHAR(15) NULL, topologyTemplateParentLocalName VARCHAR(120) NULL, CONSTRAINT PK_TOSCASERVICETEMPLATE PRIMARY KEY (name, version));
