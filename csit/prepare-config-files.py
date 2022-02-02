#
# ============LICENSE_START====================================================
#  Copyright (C) 2022 Nordix Foundation.
# =============================================================================
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END======================================================

import os
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process configuration files for https/ssl '
                                                 'disabling.')
    parser.add_argument('--https', default="true",
                        help='enable or disable https/ssl connection. '
                             'use https=true or https=false')

    https_enabled = parser.parse_args().https
    message_router_port = '3905' if https_enabled == "true" else '3904'

    current_dir = os.getcwd()
    config_dir = current_dir + "/config/"

    files = []
    for (dirpath, dirnames, filenames) in os.walk(config_dir):
        for filename in filenames:
            files.append(os.path.join(dirpath, filename))

    for file in files:
        try:
            with open(file, 'r+') as f:
                content = f.read()
                new_content = content.replace("HTTPS_ENABLED", https_enabled)
                new_content = new_content.replace("MESSAGE_ROUTER_PORT", message_router_port)

                if new_content != content:
                    f.seek(0)
                    f.truncate()
                    f.write(new_content)
        except UnicodeDecodeError:
            print("File didn't open: ", file)

    exit(0)
