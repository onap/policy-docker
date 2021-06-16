#!/usr/bin/env python3
# ============LICENSE_START====================================================
#  Copyright (C) 2021. Nordix Foundation. All rights reserved.
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
import socket
import sys


# set host (blank for localhost)
HOST = ''
# set port to first command line arguement
PORT = int(sys.argv[1])

socketListener = socket.socket();

try:
	# binding host and port using bind() function
	socketListener.bind((HOST, PORT))
except Exception as ex:
	# if any error occurs then exit
        print('Error occurred : ' + str(ex))
        sys.exit()


# starts listening
socketListener.listen()
print('Socket listener running ....')

# Accept connections
while True:
    connection, address = socketListener.accept()
    # print the address of connection
    print('Connection request from ' + address[0])
    # Send acknowledgement
    connection.send("OK".encode())
    # close the connection
    connection.close()
