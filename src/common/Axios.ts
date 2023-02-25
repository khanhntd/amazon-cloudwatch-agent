<<<<<<< HEAD
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT

=======
>>>>>>> e0784b5 (Change to type script and add performance)
import { Octokit } from "@octokit/rest";
import axios from "axios";

export const AxionConfig = axios.create({
<<<<<<< HEAD
  baseURL: process.env.REACT_APP_DYNAMODB_URL,
=======
  baseURL:process.env.REACT_APP_DYNAMODB_URL,
>>>>>>> e0784b5 (Change to type script and add performance)
  timeout: 3000,
  headers: {
    "x-api-key": process.env.REACT_APP_DYNAMODB_TOKEN,
  },
  responseType: "json",
  maxRedirects: 21,
});

export const OctokitConfig = new Octokit({
  auth: process.env.REACT_APP_GITHUB_SECRET_TOKEN,
});
