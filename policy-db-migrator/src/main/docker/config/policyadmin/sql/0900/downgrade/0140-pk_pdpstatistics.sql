/*
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2021 Nordix Foundation
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
DELETE FROM pdpstatistics WHERE (id,name,version) IN (select id, name, version FROM (select max(id) as id, name, version, timeStamp FROM pdpstatistics WHERE (name,version,timestamp) IN (SELECT name, version, timeStamp FROM pdpstatistics GROUP BY name, version, timeStamp HAVING count(*) > 1) GROUP BY name, version, timeStamp) t);

ALTER TABLE pdpstatistics DROP CONSTRAINT PRIMARY KEY;

UPDATE pdpstatistics set ID = 0;
