// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT

//go:build integration
// +build integration

package metrics_multiple_namespace

import (
	"flag"
	"fmt"
	"github.com/aws/amazon-cloudwatch-agent/integration/test"
	"log"
	"testing"
	"time"
)

const (
	RetryTime        = 15
	ConfigJSON       = "/config.json"
	ConfigOutputPath = "/opt/aws/amazon-cloudwatch-agent/bin/config.json"
)

var clusterName = flag.String("clusterName", "", "Please provide the os preference, valid value: windows/linux.")

func TestNumberMetricDimension(t *testing.T) {
	parameters := []struct {
		testName     string
		resourcePath string
		namespace    []string
		metricName   []string
	}{
		{
			testName:     "Send metrics with multiple namespaces",
			resourcePath: "resources/multiple_namespace",
			namespace:    []string{"Namespace1", "Namespace2"},
			metricName:   []string{"mem_used_percent", "used_percent"},
		},
		{
			testName:     "Send metrics with single namespace",
			resourcePath: "resources/single_namespace",
			namespace:    []string{"Namespace1", "Namespace1"},
			metricName:   []string{"mem_used_percent", "used_percent"},
		},
	}

	for _, parameter := range parameters {
		t.Run(parameter.testName, func(t *testing.T) {
			test.CopyFile(parameter.resourcePath+ConfigJSON, ConfigOutputPath)
			err := test.StartAgent(configOutputPath, false)

			time.Sleep(agentRuntime)
			log.Printf("Agent has been running for : %s", agentRuntime.String())
			test.StopAgent()

			// test for cloud watch metrics
			cxt := context.Background()
			dimensionFilter := buildDimensionFilterList(parameter.numberDimensionsInCW)
			client := test.GetCWClient(cxt)
			
			for index, _ := range parameter.namespace {
				expectedMetric := parameter.metricName[index]
				expectedNamespace := parameter.namespace[index]
				listMetricsInput := cloudwatch.ListMetricsInput{
					MetricName: aws.String(expectedMetric),
					Namespace:  aws.String(expectedNamespace),
				}
				
				data, err := client.ListMetrics(cxt, &listMetricsInput)
				if err != nil {
					t.Errorf("Error getting metric data %v", err)
				}
				if len(data.Metrics) == 0 {
					t.Errorf("No metrics found metric name %v namespace %v",
						expectedMetric, expectedNamespace)
				}
			}
		})
	}
}
