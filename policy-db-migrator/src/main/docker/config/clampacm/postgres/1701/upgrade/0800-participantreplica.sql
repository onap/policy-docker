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

update participantreplica set lastMsg = now() where lastMsg is null;
update participantreplica set participantState = '1' where participantState is null;

ALTER TABLE participantreplica
 ALTER COLUMN lastMsg SET NOT NULL,
 ALTER COLUMN participantId SET NOT NULL,
 ALTER COLUMN participantId SET DEFAULT '',
 ALTER COLUMN participantState SET NOT NULL,
 ALTER COLUMN participantState SET DEFAULT 1;
