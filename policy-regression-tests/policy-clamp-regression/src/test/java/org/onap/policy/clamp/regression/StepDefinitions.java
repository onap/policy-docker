/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2024-2025 Nordix Foundation. All rights reserved.
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

package org.onap.policy.clamp.regression;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.TimeUnit;
import org.json.JSONException;
import org.json.JSONObject;
import org.onap.policy.clamp.regression.util.RestUtils;

public class StepDefinitions {
    private static String compositionId;
    private static String instanceId;
    private static String targetCompositionId;

    private Response response;

    /**
     * Verify ACM healthcheck.
     */
    @When("the acm health check endpoint is invoked {string}")
    public void isAcmEndpointRunning(String endpoint) {
        response = RestUtils.getRequestSpecification().get(endpoint);
    }

    /**
     * Verify commissioning.
     */
    @When("the ACM commissioning endpoint {string} is invoked with {string} {string}")
    public void commissioningIsAccepted(String endpoint, String filePath, String isMigration) throws IOException {
        var jsonContent = new String(Files.readAllBytes(Path.of(filePath)));
        response = RestUtils.getRsJson(jsonContent)
                .post(endpoint);
        var jsonPath = new JsonPath(response.getBody().asString());
        if (Boolean.parseBoolean(isMigration)) {
            targetCompositionId = jsonPath.getString("compositionId");
        } else {
            compositionId = jsonPath.getString("compositionId");
        }
    }

    /**
     * Register participants.
     */
    @When("the register participants endpoint is invoked {string}")
    public void registerParticipants(String endpoint) {
        response = RestUtils.getRequestSpecification().put(endpoint);
    }

    /**
     * Verify priming.
     */
    @When("the ACM participants are primed {string} {string}")
    public void primeTheParticipants(String endpoint, String isMigration) throws JSONException {
        var jsonBody = new JSONObject().put("primeOrder", "PRIME");
        response = RestUtils.getRsJson(jsonBody.toString())
                .put(endpoint.replace("{compositionId}",
                        Boolean.parseBoolean(isMigration) ? targetCompositionId : compositionId));
    }

    /**
     * Fetch composition by Id.
     */
    @When("the ACM composition is fetched {string}")
    public void fetchCompositionById(String endpoint) {
        response = RestUtils.getRequestSpecification()
                .get(endpoint.replace("{compositionId}", compositionId));
    }

    /**
     * Wait and retry requests until the keyword is present.
     */
    @Then("Wait and retry until the response contains the keyword {string} {string} {string}")
    public void waitUntilKeyword(String keyword, String endpoint, String isMigration) throws InterruptedException {
        var startTime = System.currentTimeMillis();
        var maxWaitTime = TimeUnit.MINUTES.toMillis(2); // 2 minutes in milliseconds
        var conditionMet = false;
        while (!conditionMet && System.currentTimeMillis() - startTime < maxWaitTime) {
            var jsonPath = new JsonPath(response.getBody().asString());
            switch (keyword) {
                case "PRIMED", "COMMISSIONED" -> {
                    conditionMet = keyword.equals(jsonPath.getString("state"));
                    if (!conditionMet) {
                        Thread.sleep(10000); // Wait for 10 second before retrying
                        fetchCompositionById(endpoint);
                    }
                }
                case "DEPLOYED", "UNDEPLOYED" -> {
                    conditionMet = keyword.equals(jsonPath.getString("deployState"));
                    if (!conditionMet) {
                        Thread.sleep(10000); // Wait for 10 second before retrying
                        fetchAcInstanceById(endpoint, isMigration);
                    }
                }
                default -> {
                    break;
                }
            }
        }
        assertTrue(conditionMet);
    }

    /**
     * Verify AC instantiation.
     */
    @When("the ACM instance is created {string} with {string}")
    public void instantiate(String endpoint, String filePath) throws IOException {
        var jsonContent = new String(Files.readAllBytes(Path.of(filePath)));
        response = RestUtils
                .getRsJson(jsonContent.replace("COMPOSITIONIDPLACEHOLDER", compositionId))
                .post(endpoint.replace("{compositionId}", compositionId));
        var jsonPath = new JsonPath(response.getBody().asString());
        instanceId = jsonPath.getString("instanceId");
    }

    /**
     * Verify update property.
     */
    @When("the AC instance property is updated {string} {string}")
    public void updateInstanceProperty(String endpoint, String filePath) throws IOException {
        var jsonContent = new String(Files.readAllBytes(Path.of(filePath)));
        response = RestUtils
                .getRsJson(jsonContent.replace("COMPOSITIONIDPLACEHOLDER", compositionId)
                        .replace("INSTANCEIDPLACEHOLDER", instanceId))
                .post(endpoint.replace("{compositionId}", compositionId));
        var jsonPath = new JsonPath(response.getBody().asString());
        instanceId = jsonPath.getString("instanceId");
    }

    /**
     * Verify AC deployment.
     */
    @When("the AC instance is deployed {string}")
    public void deployAcInstance(String endpoint) throws JSONException {
        var jsonBody = new JSONObject().put("deployOrder", "DEPLOY");
        response = RestUtils.getRsJson(jsonBody.toString())
                .put(endpoint.replace("{compositionId}", compositionId)
                        .replace("{instanceId}", instanceId));
    }

    /**
     * Fetch Ac instance by id.
     */
    @When("the AC instance is fetched {string} {string}")
    public void fetchAcInstanceById(String endpoint, String isMigration) {
        response = RestUtils.getRequestSpecification()
                .get(endpoint.replace("{compositionId}",
                                Boolean.parseBoolean(isMigration) ? targetCompositionId : compositionId)
                        .replace("{instanceId}", instanceId));
    }

    /**
     * Verify Ac undeployment.
     */
    @When("the AC instance is undeployed {string}")
    public void unDeployAcInstance(String endpoint) throws JSONException {
        var jsonBody = new JSONObject().put("deployOrder", "UNDEPLOY");
        response = RestUtils.getRsJson(jsonBody.toString())
                .put(endpoint.replace("{compositionId}", compositionId)
                        .replace("{instanceId}", instanceId));
    }

    /**
     * Verify Ac uninstantiation.
     */
    @When("the ACM instance is uninstantiated {string}")
    public void unInstantiate(String endpoint) {
        response = RestUtils.getRequestSpecification()
                .delete(endpoint.replace("{compositionId}", compositionId).replace("{instanceId}", instanceId));
    }

    /**
     * Fetch all Ac instances for the given composition id.
     */
    @When("all the AC instances are fetched {string}")
    public void fetchAllAcInstances(String endpoint) {
        response = RestUtils.getRequestSpecification()
                .get(endpoint.replace("{compositionId}", compositionId));
    }

    /**
     * Wait and retry request until the instance list is empty in the response.
     */
    @Then("Wait and retry until the ac instance list is empty {string}")
    public void waitUntilTheCondition(String endpoint) throws InterruptedException {
        var startTime = System.currentTimeMillis();
        var maxWaitTime = TimeUnit.MINUTES.toMillis(2); // 2 minutes in milliseconds
        var conditionMet = false;
        while (!conditionMet && System.currentTimeMillis() - startTime < maxWaitTime) {
            var size = response.getBody().jsonPath().getList("automationCompositionList").size();
            conditionMet = Integer.valueOf(0).equals(size);
            if (!conditionMet) {
                Thread.sleep(10000); // Wait for 10 second before retrying
                fetchAllAcInstances(endpoint);
            }
        }
    }

    /**
     * Verify de-priming.
     */
    @When("the ACM participants are deprimed {string}")
    public void deprimeTheParticipants(String endpoint) throws JSONException {
        var jsonBody = new JSONObject().put("primeOrder", "DEPRIME");
        response = RestUtils.getRsJson(jsonBody.toString())
                .put(endpoint.replace("{compositionId}", compositionId));
    }

    /**
     * Verify deletion of composition defintion.
     */
    @When("the AC definition is deleted {string}")
    public void deleteAcDefinition(String endpoint) {
        response = RestUtils.getRequestSpecification()
                .delete(endpoint.replace("{compositionId}", compositionId));
    }

    /**
     * Verify migration functionality.
     */
    @When("the ACM instance is migrated {string} with {string}")
    public void migrate(String endpoint, String filePath) throws IOException {
        var jsonContent = new String(Files.readAllBytes(Path.of(filePath)));
        response = RestUtils
                .getRsJson(jsonContent
                        .replace("COMPOSITIONIDPLACEHOLDER", compositionId)
                        .replace("INSTANCEIDPLACEHOLDER", instanceId)
                        .replace("COMPOSITIONTARGETIDPLACEHOLDER", targetCompositionId))
                .post(endpoint.replace("{compositionId}", compositionId));
    }

    /**
     * Verify the response status.
     */
    @Then("the response status code should be {int}")
    public void theUserEndpointIsUpAndRunning(int expectedStatus) {
        var status = response.getStatusCode();
        assertEquals(expectedStatus, status);
    }

    /**
     * Verify the response contains specific keywords.
     */
    @Then("the response should contain the updated properties {string} {string}")
    public void theUserEndpointIsUpAndRunning(String value1, String value2) {
        var body = response.getBody().asString();
        assertThat(body).contains(value1);
        assertThat(body).contains(value2);
    }
}
