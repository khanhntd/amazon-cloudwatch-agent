<<<<<<< HEAD
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT
import { CssBaseline, ThemeProvider, Toolbar } from "@mui/material";
import React from "react";
=======
import { CssBaseline, ThemeProvider, Toolbar } from "@mui/material";
import  React from "react";
>>>>>>> e0784b5 (Change to type script and add performance)
import { Route, Routes } from "react-router-dom";
import { useTheme } from "../core/theme";
import { AppToolbar } from "./AppToolbar";
import { ErrorBoundary } from "./ErrorBoundary";
<<<<<<< HEAD
import {
  HomePage,
  PerformanceReport,
  PerformanceTrend,
  Wikipedia,
} from "./Routes";
export function App(): JSX.Element {
=======
import { HomePage, PerformanceReport, PerformanceTrend, Wikipedia } from "./Routes";
export function App():JSX.Element {
>>>>>>> e0784b5 (Change to type script and add performance)
  const theme = useTheme();
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <ErrorBoundary>
        <AppToolbar />
        <Toolbar />

        <Routes>
          <Route index element={<React.Suspense children={<HomePage />} />} />

<<<<<<< HEAD
          <Route
            path="/report"
            element={<React.Suspense children={<PerformanceReport />} />}
          />

          <Route
            path="/trend"
            element={<React.Suspense children={<PerformanceTrend />} />}
          />

          <Route
            path="/wiki"
            element={<React.Suspense children={<Wikipedia />} />}
          />
=======
          <Route path="/report" element={<React.Suspense children={<PerformanceReport />} />} />

          <Route path="/trend" element={<React.Suspense children={<PerformanceTrend />} />} />

          <Route path="/wiki" element={<React.Suspense children={<Wikipedia />} />} />
>>>>>>> e0784b5 (Change to type script and add performance)
        </Routes>
      </ErrorBoundary>
    </ThemeProvider>
  );
}
<<<<<<< HEAD
=======

>>>>>>> e0784b5 (Change to type script and add performance)
