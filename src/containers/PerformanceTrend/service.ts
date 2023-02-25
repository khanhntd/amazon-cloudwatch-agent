<<<<<<< HEAD
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT

import moment from "moment";
import { AxionConfig, OctokitConfig } from "../../common/Axios";
import {
  OWNER_REPOSITORY,
  SERVICE_NAME,
  USE_CASE,
} from "../../common/Constant";
import {
  PerformanceTrendData,
  PerformanceTrendDataParams,
  ServiceCommitInformation,
} from "./data";
export async function GetPerformanceTrendData(): Promise<
  PerformanceTrendData[]
> {
  const currentUnixTime = moment().unix();
  return GetPerformanceTrend({
    TableName: process.env.REACT_APP_DYNAMODB_NAME,
=======
import moment from "moment";
import { AxionConfig, OctokitConfig } from "../../common/Axios";
import { OWNER_REPOSITORY, SERVICE_NAME, USE_CASE } from "../../common/Constant";
import { PerformanceTrendData, PerformanceTrendDataParams, ServiceCommitInformation } from "./data";
export async function GetPerformanceTrendData(): Promise<PerformanceTrendData[]> {
  const currentUnixTime = moment().unix();
  return GetPerformanceTrend({
    TableName: process.env.REACT_APP_DYNAMODB_NAME || "",
>>>>>>> e0784b5 (Change to type script and add performance)
    Limit: USE_CASE.length * 25,
    IndexName: "ServiceDate",
    KeyConditions: {
      Service: {
        ComparisonOperator: "EQ",
        AttributeValueList: [
          {
            S: SERVICE_NAME,
          },
        ],
      },
      CommitDate: {
        ComparisonOperator: "LE",
        AttributeValueList: [
          {
            N: currentUnixTime.toString(),
          },
        ],
      },
    },
    ScanIndexForward: false,
  });
}

<<<<<<< HEAD
async function GetPerformanceTrend(
  params: PerformanceTrendDataParams
): Promise<PerformanceTrendData[]> {
=======
async function GetPerformanceTrend(params: PerformanceTrendDataParams): Promise<PerformanceTrendData[]> {
>>>>>>> e0784b5 (Change to type script and add performance)
  return AxionConfig.post("/", { Action: "Query", Params: params })
    .then(function (body: { data: { Items: any[] } }) {
      return body?.data?.Items;
    })
    .catch(function (error: unknown) {
      return Promise.reject(error);
    });
}

<<<<<<< HEAD
export async function GetServiceCommitInformation(
  commit_sha: string
): Promise<ServiceCommitInformation> {
  return OctokitConfig.request("GET /repos/{owner}/{repo}/commits/{ref}", {
    owner: OWNER_REPOSITORY,
    repo: process.env.REACT_APP_GITHUB_REPOSITORY,
=======
export async function GetServiceCommitInformation(commit_sha: string): Promise<ServiceCommitInformation> {
  return OctokitConfig.request("GET /repos/{owner}/{repo}/commits/{ref}", {
    owner: OWNER_REPOSITORY,
    repo: process.env.REACT_APP_GITHUB_REPOSITORY || "",
>>>>>>> e0784b5 (Change to type script and add performance)
    ref: commit_sha,
  })
    .then(function (value: { data: any }) {
      return Promise.resolve(value?.data);
    })
    .catch(function (error: unknown) {
      return Promise.reject(error);
    });
<<<<<<< HEAD
}
=======
}
>>>>>>> e0784b5 (Change to type script and add performance)
