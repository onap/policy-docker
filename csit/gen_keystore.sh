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

if [ $# -ne 1 ]; then
    echo "arg(s): jks-output-file-name" >&2
    exit 1
fi

OUTFILE="$1"

dn="C=US, O=ONAP, OU=OSAAF, OU=policy@policy.onap.org:DEV, CN=policy"
san=`paste -sd , config/dns_keystore.txt`

rm -f $OUTFILE

keytool -genkeypair -alias "policy@policy.onap.org" -validity 30 \
    -keyalg RSA -dname "$dn" -keystore $OUTFILE \
    -keypass Pol1cy_0nap -storepass Pol1cy_0nap -ext "SAN=$san"

chmod 644 $OUTFILE
