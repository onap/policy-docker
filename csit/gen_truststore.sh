#!/bin/bash
#
# ===========LICENSE_START====================================================
#  Copyright (C) 2021 AT&T Intellectual Property. All rights reserved.
# ============================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=====================================================
#

#
# Generates a root certificate and truststore for use by the various policy
# docker images.
#

DIR="${0%/*}/config"
cd "${DIR}"

OUTFILE=policy-truststore
ALIAS=onap.policy.csit.root.ca
PASS=Pol1cy_0nap

keytool -list -alias ${ALIAS} -keystore ${OUTFILE} -storepass "${PASS}" \
	>/dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "Truststore already contains a policy root CA - not re-generating"
    exit 0
fi

openssl req -new -keyout cakey.pem -out careq.pem -passout "pass:${PASS}" \
            -subj "/C=US/ST=New Jersey/OU=ONAP/CN=policy.onap"

openssl x509 -signkey cakey.pem -req -days 3650 -in careq.pem \
            -out caroot.cer -extensions v3_ca -passin "pass:${PASS}"

keytool -import -noprompt -trustcacerts -alias ${ALIAS} \
            -file caroot.cer -keystore "${OUTFILE}" -storepass "${PASS}"

chmod 644 "$OUTFILE"
