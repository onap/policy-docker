/*-
 * ============LICENSE_START=======================================================
 * ONAP POLICY
 * ================================================================================
 * Copyright (C) 2021 AT&T Intellectual Property. All right reserved.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END============================================
 * ===================================================================
 *
 */
println 'Project version: ' + project.properties['dist.project.version']
if (project.properties['dist.project.version'] != null) {
    def versionArray = project.properties['dist.project.version'].split('-')
    def minMaxVersionArray = versionArray[0].tokenize('.')
    if (project.properties['dist.project.version'].endsWith("-SNAPSHOT")) {
        project.properties['project.docker.latest.minmax.tag.version'] =
             minMaxVersionArray[0] + "." + minMaxVersionArray[1] + "-SNAPSHOT-latest"
     } else {
        project.properties['project.docker.latest.minmax.tag.version'] =
             minMaxVersionArray[0] + "." + minMaxVersionArray[1] + "-STAGING-latest"
     }
     println 'New tag for docker: ' + properties['project.docker.latest.minmax.tag.version']
}
