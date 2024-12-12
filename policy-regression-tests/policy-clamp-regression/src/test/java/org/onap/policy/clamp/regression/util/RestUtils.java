/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2025 Nordix Foundation. All rights reserved.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */

package org.onap.policy.clamp.regression.util;

import static io.restassured.config.EncoderConfig.encoderConfig;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;

public class RestUtils {
    private static final String ACM_URL = "http://0.0.0.0:30007/";
    private static final String USERNAME = "runtimeUser";
    private static final String PASSWORD = "zb!XztG34";

    /**
     * Get RequestSpecification with authentication.
     *
     * @return a RequestSpecification
     */
    public static RequestSpecification getRequestSpecification() {
        return RestAssured.given()
                .auth().basic(USERNAME, PASSWORD)
                .baseUri(ACM_URL);
    }

    /**
     * Get RequestSpecification with json.
     *
     * @param jsonContent the json body
     * @return a RequestSpecification
     */
    public static RequestSpecification getRsJson(String jsonContent) {
        return getRequestSpecification()
                .config(RestAssured.config().encoderConfig(encoderConfig()
                        .encodeContentTypeAs("", ContentType.JSON)))
                .contentType(ContentType.JSON)
                .accept(ContentType.JSON)
                .body(jsonContent);
    }
}
