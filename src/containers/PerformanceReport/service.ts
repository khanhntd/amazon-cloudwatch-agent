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
  PerformanceMetricReport,
  PerformanceMetricReportParams,
  ServiceLatestVersion,
  ServicePRInformation,
} from "./data.js";
export async function GetLatestPerformanceReports(): Promise<
  PerformanceMetricReport[]
> {
  return GetPerformanceReports({
    TableName: process.env.REACT_APP_DYNAMODB_NAME,
=======
import moment from "moment";
import { AxionConfig, OctokitConfig } from "../../common/Axios";
import { OWNER_REPOSITORY, SERVICE_NAME, USE_CASE } from "../../common/Constant";
import { PerformanceMetricReport, PerformanceMetricReportParams, ServiceLatestVersion, ServicePRInformation } from "./data.js";
export async function GetLatestPerformanceReports(): Promise<PerformanceMetricReport[]> {
  return GetPerformanceReports({
    TableName: process.env.REACT_APP_DYNAMODB_NAME || "",
>>>>>>> e0784b5 (Change to type script and add performance)
    Limit: USE_CASE.length,
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
            N: moment().unix().toString(),
          },
        ],
      },
    },
    ScanIndexForward: false,
  });
}

<<<<<<< HEAD
async function GetPerformanceReports(
  params: PerformanceMetricReportParams
): Promise<PerformanceMetricReport[]> {
=======
async function GetPerformanceReports(params: PerformanceMetricReportParams): Promise<PerformanceMetricReport[]> {
>>>>>>> e0784b5 (Change to type script and add performance)
  return AxionConfig.post("/", { Action: "Query", Params: params })
    .then(function (body: { data: { Items: PerformanceMetricReport[] } }) {
      return body?.data?.Items;
    })
    .catch(function (error: unknown) {
      return Promise.reject(error);
    });
}

export async function GetServiceLatestVersion(): Promise<ServiceLatestVersion> {
  return OctokitConfig.request("GET /repos/{owner}/{repo}/releases/latest", {
    owner: OWNER_REPOSITORY,
<<<<<<< HEAD
    repo: process.env.REACT_APP_GITHUB_REPOSITORY,
=======
    repo: process.env.REACT_APP_GITHUB_REPOSITORY || "",
>>>>>>> e0784b5 (Change to type script and add performance)
  })
    .then(function (body: any) {
      return body?.data;
    })
    .catch(function (error: unknown) {
      return Promise.reject(error);
    });
}

<<<<<<< HEAD
export async function GetServicePRInformation(
  commit_sha: string
): Promise<ServicePRInformation> {
  return OctokitConfig.request(
    "GET /repos/{owner}/{repo}/commits/{commit_sha}/pulls",
    {
      owner: OWNER_REPOSITORY,
      repo: process.env.REACT_APP_GITHUB_REPOSITORY,
      commit_sha: commit_sha,
    }
  )
=======
export async function GetServicePRInformation(commit_sha: string): Promise<ServicePRInformation> {
  return OctokitConfig.request("GET /repos/{owner}/{repo}/commits/{commit_sha}/pulls", {
    owner: OWNER_REPOSITORY,
    repo: process.env.REACT_APP_GITHUB_REPOSITORY || "",
    commit_sha: commit_sha,
  })
>>>>>>> e0784b5 (Change to type script and add performance)
    .then(function (body: { data: any[] }) {
      return Promise.resolve(body.data.at(0));
    })
    .catch(function (error: unknown) {
      return Promise.reject(error);
    });
<<<<<<< HEAD
}
=======
}
>>>>>>> e0784b5 (Change to type script and add performance)
