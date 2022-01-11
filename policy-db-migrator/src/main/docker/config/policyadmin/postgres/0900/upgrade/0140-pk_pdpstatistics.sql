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

UPDATE pdpstatistics as p SET id=t.row_num FROM (SELECT name, version, timeStamp, ROW_NUMBER() OVER (ORDER BY timeStamp ASC) AS row_num FROM pdpstatistics GROUP BY name, version, timeStamp) AS t WHERE p.name=t.name AND p.version=t.version AND p.timeStamp=t.timeStamp;

ALTER TABLE pdpstatistics ADD CONSTRAINT PK_PDPSTATISTICS PRIMARY KEY (ID, name, version);
