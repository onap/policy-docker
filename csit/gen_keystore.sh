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
# Generates a self-signed keystore for use by the various policy docker
# images.
#

DIR="${0%/*}/config"
cd "${DIR}"

OUTFILE=ks.jks

ALIAS="policy@policy.onap.org"
PASS=Pol1cy_0nap

dn="C=US, O=ONAP, OU=OSAAF, OU=policy@policy.onap.org:DEV, CN=policy"

rm -f "${OUTFILE}"

keytool -genkeypair -alias "${ALIAS}" -validity 30 \
    -keyalg RSA -dname "${dn}" -keystore "${OUTFILE}" \
    -keypass "${PASS}" -storepass "${PASS}"

keytool -certreq -alias "${ALIAS}" -keystore ks.jks -file ks.csr \
    -storepass "${PASS}"

openssl x509 -CA caroot.cer -CAkey cakey.pem -CAserial caserial.txt \
    -req -in ks.csr -out ks.cer -passin "pass:${PASS}" \
    -extfile dns_ssl.txt -days 30

keytool -import -noprompt -file caroot.cer -keystore ks.jks \
    -storepass "${PASS}"

keytool -import -alias "${ALIAS}" -file ks.cer -keystore ks.jks \
    -storepass "${PASS}"

chmod 644 "$OUTFILE"
