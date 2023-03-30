#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2022-2023 Nordix Foundation.
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

# This script generates dummy robot result files for jenkins.

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

export ROBOT_LOG_DIR=${WORKSPACE}/csit/archives/$2

mkdir -p $ROBOT_LOG_DIR

echo "CSIT in kubernetes is disabled. Generating dummy results..."

cat >${ROBOT_LOG_DIR}/output.xml <<EOF
<robot generator="Robot 6.1a1 (Python 3.11.2 on linux)" rpa="false" schemaversion="4">
<statistics>
<total>
<stat pass="1" fail="0" skip="0">All Tests</stat>
</total>
<tag>
</tag>
<suite>
<stat pass="1" fail="0" skip="0" id="s1" name="Dummy-Test">Dummy-Test</stat>
</suite>
</statistics>
<errors></errors>
</robot>
EOF

cat >${ROBOT_LOG_DIR}/log.html <<EOF
<!DOCTYPE html>
<head>
    <style media="all" type="text/css">
        /* Generic and misc styles */
        body {
            font-family: Helvetica, sans-serif;
            font-size: 0.8em;
            color: black;
            padding: 6px;
            background: white;
        }
        table {
            table-layout: fixed;
            word-wrap: break-word;
            empty-cells: show;
            font-size: 1em;
        }
        th, td {
            vertical-align: top;
        }
        br {
            mso-data-placement: same-cell; /* maintain line breaks in Excel */
        }
        hr {
            background: #ccc;
            height: 1px;
            border: 0;
        }
        a, a:link, a:visited {
            text-decoration: none;
            color: #15c;
        }
        a > img {
            border: 1px solid #15c !important;
        }
        a:hover, a:active {
            text-decoration: underline;
            color: #61c;
        }
        .parent-name {
            font-size: 0.7em;
            letter-spacing: -0.07em;
        }
        .message {
            white-space: pre-wrap;
        }
        /* Headers */
        #header {
            width: 65em;
            height: 3em;
            margin: 6px 0;
        }
        h1 {
            float: left;
            margin: 0 0 0.5em 0;
            width: 75%;
        }
        h2 {
            clear: left;
        }
        #generated {
            float: right;
            text-align: right;
            font-size: 0.9em;
            white-space: nowrap;
        }
        /* Documentation headers */
        .doc > h2 {
            font-size: 1.2em;
        }
        .doc > h3 {
            font-size: 1.1em;
        }
        .doc > h4 {
            font-size: 1.0em;
        }
        /* Status text colors -- !important allows using them in links */
        .fail {
            color: #ce3e01 !important;
            font-weight: bold;
        }
        .pass {
            color: #098a09 !important;
        }
        .skip {
            color: #927201 !important;
            font-weight: bold;
        }
        .label {
            padding: 2px 5px;
            font-size: 0.75em;
            letter-spacing: 1px;
            white-space: nowrap;
            color: black;
            background-color: #ddd;
            border-radius: 3px;
        }
        .label.debug, .label.trace, .label.error, .label.keyword {
            letter-spacing: 0;
        }
        .label.pass, .label.fail, .label.error, .label.skip, .label.warn {
            font-weight: bold;
        }
        .label.pass {
            background-color: #97bd61;
            color: #000 !important;
        }
        .label.fail, .label.error {
            background-color: #ce3e01;
            color: #fff !important;
        }
        .label.skip, .label.warn {
            background-color: #fed84f;
            color: #000 !important;
        }
        /* Top right header */
        #top-right-header {
            position: fixed;
            top: 0;
            right: 0;
            z-index: 1000;
            width: 12em;
            text-align: center;
        }
        #report-or-log-link a {
            display: block;
            background: black;
            color: white;
            text-decoration: none;
            font-weight: bold;
            letter-spacing: 0.1em;
            padding: 0.3em 0;
            border-bottom-left-radius: 4px;
        }
        #report-or-log-link a:hover {
            color: #ddd;
        }
        #log-level-selector {
            padding: 0.3em 0;
            font-size: 0.9em;
            border-bottom-left-radius: 4px;
            background: #ddd;
        }
        /* Statistics table */
        .statistics {
            width: 65em;
            border-collapse: collapse;
            empty-cells: show;
            margin-bottom: 1em;
        }
        .statistics tr:hover {
            background: #f4f4f4;
            cursor: pointer;
        }
        .statistics th, .statistics td {
            border: 1px solid #ccc;
            padding: 0.1em 0.3em;
        }
        .statistics th {
            background-color: #ddd;
            padding: 0.2em 0.3em;
        }
        .statistics td {
            vertical-align: middle;
        }
        .stats-col-stat {
            width: 4.5em;
            text-align: center;
        }
        .stats-col-elapsed {
            width: 5.5em;
            text-align: center;
        }
        .stats-col-graph {
            width: 9em;
        }
        th.stats-col-graph:hover {
            cursor: default;
        }
        .stat-name {
            float: left;
        }
        .stat-name a, .stat-name span {
            font-weight: bold;
        }
        .tag-links {
            font-size: 0.9em;
            float: right;
            margin-top: 0.05em;
        }
        .tag-links span {
            margin-left: 0.2em;
        }
        /* Statistics graph */
        .graph, .empty-graph {
            border: 1px solid #ccc;
            width: auto;
            height: 7px;
            padding: 0;
            background: #aaa;
        }
        .empty-graph {
            background: #eee;
        }
        .pass-bar, .fail-bar, .skip-bar {
            float: left;
            height: 100%;
        }
        .fail-bar {
            background: #ce3e01;
        }
        .pass-bar {
            background: #97bd61;
        }
        .skip-bar {
            background: #fed84f;
        }
        /* Tablesorter - adapted from provided Blue Skin */
        .tablesorter-header {
            background-image: url(data:image/gif;base64,R0lGODlhCwAJAIAAAH9/fwAAACH5BAEAAAEALAAAAAALAAkAAAIRjAOnBr3cnIr0WUjTrC9e9BQAOw==);
            background-repeat: no-repeat;
            background-position: center right;
            cursor: pointer;
        }
        .tablesorter-header:hover {
            background-color: #ccc;
        }
        .tablesorter-headerAsc {
            background-image: url(data:image/gif;base64,R0lGODlhCwAJAKEAAAAAAH9/fwAAAAAAACH5BAEAAAIALAAAAAALAAkAAAIUlBWnFr3cnIr0WQOyBmvzp13CpxQAOw==);
            background-color: #ccc !important;
        }
        .tablesorter-headerDesc {
            background-image: url(data:image/gif;base64,R0lGODlhCwAJAKEAAAAAAH9/fwAAAAAAACH5BAEAAAIALAAAAAALAAkAAAIUlAWnBr3cnIr0WROyDmvzp13CpxQAOw==);
            background-color: #ccc !important;
        }
        .sorter-false {
            background-image: none;
            cursor: default;
        }
        .sorter-false:hover {
            background-color: #ddd;
        }
        </style>


</head>
<body>
  <div id="statistics-container">
    <h2>Test Statistics</h2>
    <table class="statistics tablesorter tablesorter-default tablesorter2e2fe879cc465" id="total-stats" role="grid">
      <thead>
        <tr role="row" class="tablesorter-headerRow">
          <th class="stats-col-name tablesorter-header tablesorter-headerUnSorted" data-column="0" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="total-stats" unselectable="on" aria-sort="none" aria-label="Total Statistics: No sort applied, activate to apply an ascending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Total Statistics</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="1" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="total-stats" unselectable="on" aria-sort="none" aria-label="Total: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Total</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="2" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="total-stats" unselectable="on" aria-sort="none" aria-label="Pass: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Pass</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="3" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="total-stats" unselectable="on" aria-sort="none" aria-label="Fail: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Fail</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="4" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="total-stats" unselectable="on" aria-sort="none" aria-label="Skip: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Skip</div>
          </th>
          <th class="stats-col-elapsed tablesorter-header tablesorter-headerUnSorted" title="Total execution time of these tests. Excludes suite setups and teardowns." data-column="5" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="total-stats" unselectable="on" aria-sort="none" aria-label="Elapsed: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Elapsed</div>
          </th>
          <th class="stats-col-graph tablesorter-header sorter-false tablesorter-headerUnSorted" data-column="6" scope="col" role="columnheader" aria-disabled="true" unselectable="on" aria-sort="none" aria-label="Pass / Fail / Skip: No sort applied, sorting is disabled" style="user-select: none;">
            <div class="tablesorter-header-inner">Pass / Fail / Skip</div>
          </th>
        </tr>
      </thead>
      <tbody aria-live="polite" aria-relevant="all">
        <tr class="row-0" role="row">
          <td class="stats-col-name">
            <div class="stat-name">
              <span>All Tests</span>
            </div>
          </td>
          <td class="stats-col-stat">1</td>
          <td class="stats-col-stat">1</td>
          <td class="stats-col-stat">0</td>
          <td class="stats-col-stat">0</td>
          <td class="stats-col-elapsed" title="Total execution time of these tests. Excludes suite setups and teardowns.">00:00:00</td>
          <td class="stats-col-graph">
            <div class="graph">
              <div class="pass-bar" style="width: 100%" title="100%"></div>
              <div class="fail-bar" style="width: 0%" title="0%"></div>
              <div class="skip-bar" style="width: 0%" title="0%"></div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <table class="statistics tablesorter tablesorter-default tablesorter8e8ffd77a824a" id="tag-stats" role="grid">
      <thead>
        <tr role="row" class="tablesorter-headerRow">
          <th class="stats-col-name tablesorter-header tablesorter-headerUnSorted" data-column="0" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="tag-stats" unselectable="on" aria-sort="none" aria-label="Statistics by Tag: No sort applied, activate to apply an ascending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Statistics by Tag</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="1" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="tag-stats" unselectable="on" aria-sort="none" aria-label="Total: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Total</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="2" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="tag-stats" unselectable="on" aria-sort="none" aria-label="Pass: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Pass</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="3" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="tag-stats" unselectable="on" aria-sort="none" aria-label="Fail: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Fail</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="4" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="tag-stats" unselectable="on" aria-sort="none" aria-label="Skip: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Skip</div>
          </th>
          <th class="stats-col-elapsed tablesorter-header tablesorter-headerUnSorted" title="Total execution time of these tests. Excludes suite setups and teardowns." data-column="5" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="tag-stats" unselectable="on" aria-sort="none" aria-label="Elapsed: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Elapsed</div>
          </th>
          <th class="stats-col-graph tablesorter-header sorter-false tablesorter-headerUnSorted" data-column="6" scope="col" role="columnheader" aria-disabled="true" unselectable="on" aria-sort="none" aria-label="Pass / Fail / Skip: No sort applied, sorting is disabled" style="user-select: none;">
            <div class="tablesorter-header-inner">Pass / Fail / Skip</div>
          </th>
        </tr>
      </thead>
      <tbody aria-live="polite" aria-relevant="all">
        <tr class="row-0" role="row">
          <td class="stats-col-name">No Tags</td>
          <td class="stats-col-stat"></td>
          <td class="stats-col-stat"></td>
          <td class="stats-col-stat"></td>
          <td class="stats-col-stat"></td>
          <td class="stats-col-elapsed" title="Total execution time of these tests. Excludes suite setups and teardowns."></td>
          <td class="stats-col-graph">
            <div class="empty-graph"></div>
          </td>
        </tr>
      </tbody>
    </table>
    <table class="statistics tablesorter tablesorter-default tablesorter06030fd685e0f" id="suite-stats" role="grid">
      <thead>
        <tr role="row" class="tablesorter-headerRow">
          <th class="stats-col-name tablesorter-header tablesorter-headerUnSorted" data-column="0" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="suite-stats" unselectable="on" aria-sort="none" aria-label="Statistics by Suite: No sort applied, activate to apply an ascending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Statistics by Suite</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="1" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="suite-stats" unselectable="on" aria-sort="none" aria-label="Total: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Total</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="2" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="suite-stats" unselectable="on" aria-sort="none" aria-label="Pass: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Pass</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="3" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="suite-stats" unselectable="on" aria-sort="none" aria-label="Fail: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Fail</div>
          </th>
          <th class="stats-col-stat tablesorter-header tablesorter-headerUnSorted" data-column="4" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="suite-stats" unselectable="on" aria-sort="none" aria-label="Skip: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Skip</div>
          </th>
          <th class="stats-col-elapsed tablesorter-header tablesorter-headerUnSorted" title="Total execution time of this suite." data-column="5" tabindex="0" scope="col" role="columnheader" aria-disabled="false" aria-controls="suite-stats" unselectable="on" aria-sort="none" aria-label="Elapsed: No sort applied, activate to apply a descending sort" style="user-select: none;">
            <div class="tablesorter-header-inner">Elapsed</div>
          </th>
          <th class="stats-col-graph tablesorter-header sorter-false tablesorter-headerUnSorted" data-column="6" scope="col" role="columnheader" aria-disabled="true" unselectable="on" aria-sort="none" aria-label="Pass / Fail / Skip: No sort applied, sorting is disabled" style="user-select: none;">
            <div class="tablesorter-header-inner">Pass / Fail / Skip</div>
          </th>
        </tr>
      </thead>
      <tbody aria-live="polite" aria-relevant="all">
        <tr onclick="makeElementVisible('s1')" class="row-0" role="row">
          <td class="stats-col-name" title="pap">
            <div class="stat-name">
              <span href="#s1">
                <span class="parent-name"></span>Dummy Test</span>
            </div>
          </td>
          <td class="stats-col-stat">1</td>
          <td class="stats-col-stat">1</td>
          <td class="stats-col-stat">0</td>
          <td class="stats-col-stat">0</td>
          <td class="stats-col-elapsed" title="Total execution time of this suite.">00:00:00</td>
          <td class="stats-col-graph">
            <div class="graph">
              <div class="pass-bar" style="width: 100%" title="100%"></div>
              <div class="fail-bar" style="width: 0%" title="0%"></div>
              <div class="skip-bar" style="width: 0%" title="0%"></div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</body>
</html>
EOF

cp ${ROBOT_LOG_DIR}/log.html ${ROBOT_LOG_DIR}/report.html
