/*
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2025 OpenInfra Foundation Europe. All rights reserved.
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

ALTER TABLE automationcompositionelement
 ALTER COLUMN definition_name DROP NOT NULL,
 ALTER COLUMN definition_name DROP DEFAULT,
 ALTER COLUMN definition_version DROP NOT NULL,
 ALTER COLUMN definition_version DROP DEFAULT,
 ALTER COLUMN deploystate DROP NOT NULL,
 ALTER COLUMN deployState DROP DEFAULT,
 ALTER COLUMN lockState DROP NOT NULL,
 ALTER COLUMN lockState DROP DEFAULT,
 ALTER COLUMN substate DROP NOT NULL,
 ALTER COLUMN substate DROP DEFAULT,
 ALTER COLUMN outproperties DROP NOT NULL,
 ALTER COLUMN outproperties DROP DEFAULT,
 ALTER COLUMN properties DROP NOT NULL,
 ALTER COLUMN properties DROP DEFAULT;
