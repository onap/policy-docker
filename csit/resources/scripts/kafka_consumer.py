#!/usr/bin/env python3
#
# ============LICENSE_START====================================================
#  Copyright (C) 2023 Nordix Foundation.
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

# Python utility to fetch kafka topic and look for required messages.
# Accepts the arguments {topic_name} and {list of expected values} and {timeout} to verify the kafka topic.


from confluent_kafka import Consumer, KafkaException
import sys
import time

def consume_kafka_topic(topic, expected_values, timeout):
    config = {
            'bootstrap.servers': 'localhost:29092',
            'group.id': 'testgrp',
            'auto.offset.reset': 'earliest'
    }
    consumer = Consumer(config)
    consumer.subscribe([topic])
    try:
        start_time = time.time()
        while time.time() - start_time < timeout:
                msg = consumer.poll(1.0)
                if msg is None:
                    continue
                if msg.error():
                    if msg.error().code() == KafkaException._PARTITION_EOF:
                        sys.stderr.write(f"Reached end of topic {msg.topic()} / partition {msg.partition()}\n")
                        print('ERROR')
                        sys.exit(404)
                    else:
                        # Error
                        raise KafkaException(msg.error())
                else:
                    # Message received
                    message = msg.value().decode('utf-8')
                    if verify_msg(expected_values, message):
                        print(message)
                        sys.exit(200)
    finally:
        consumer.close()

def verify_msg(expected_values, message):
    for item in expected_values:
        if item not in message:
            return False
    return True


if __name__ == '__main__':
    topic_name = sys.argv[1]
    timeout = sys.argv[2]  # timeout in seconds for verifying the kafka topic
    expected_values = sys.argv[3:]
    consume_kafka_topic(topic_name, expected_values, timeout)
