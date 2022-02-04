[![codecov](https://codecov.io/gh/aws/amazon-cloudwatch-agent/branch/master/graph/badge.svg?token=79VYANUGOM)](https://codecov.io/gh/aws/amazon-cloudwatch-agent)

# Amazon CloudWatch Agent
The Amazon CloudWatch Agent is software developed for the [CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)

## Overview
The Amazon CloudWatch Agent enables you to do the following:

- Collect more system-level metrics from Amazon EC2 instances across operating systems. The metrics can include in-guest metrics, in addition to the metrics for EC2 instances. The additional metrics that can be collected are listed in [Metrics Collected by the CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html).
- Collect system-level metrics from on-premises servers. These can include servers in a hybrid environment as well as servers not managed by AWS.
- Retrieve custom metrics from your applications or services using the StatsD and collectd protocols. StatsD is supported on both Linux servers and servers running Windows Server. collectd is supported only on Linux servers.
- Collect logs from Amazon EC2 instances and on-premises servers, running either Linux or Windows Server.

Amazon CloudWatch Agent uses the open-source project [telegraf](https://github.com/influxdata/telegraf) as its dependency. It operates by starting a telegraf agent with some original plugins and some customized plugins.

### Setup
* [Configuring IAM Roles](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html)
* [Installation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html)
* [Configuring the CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file.html)

### Troubleshooting
* [Troubleshooting CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/troubleshooting-CloudWatch-Agent.html)

## Building and running Amazon CloudWatch Agent 
Use the following instructions to build and run Cloudwatch Agent:
* To build and run from source, you must [install go]((https://golang.org/doc/install)) and use `make build`. For more information on requirements and building from source with different platforms, please follow [this document](docs/build/build-run-cwagent-from-source.md)
* To build and run from container, you can simply use the below command. For more information on building from containers with different platforms, please follow [this document](amazon-cloudwatch-container-insights/cloudwatch-agent-dockerfile)
```
docker buildx build -f amazon-cloudwatch-container-insights/cloudwatch-agent-dockerfile/Dockerfile .
```
### Make Targets
The following targets are available. Each may be run with `make <target>`.

| Make Target              | Description |
|:-------------------------|:------------|
| `build`                  | `build` builds the agent for Linux, Debian and Windows amd64 environment |
| `release`                | *(Default)* `release` builds the agent and also packages it into a RPM, DEB and ZIP package |
| `clean`                  | `clean` removes build artifacts |
| `dockerized-build`       | build using docker container without local go environment |

## Versioning
It is using [Semantic versioning](https://semver.org/)

## Distributions
Use the following instructions to install Cloudwatch Agent:
* [Official release from s3](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/download-cloudwatch-agent-commandline.html)
* [Nightly build from s3](docs/build/nightly-build.md)

## Security disclosures
If you think you’ve found a potential security issue, please do not post it in the Issues.  Instead, please follow the instructions [here](https://aws.amazon.com/security/vulnerability-reporting/) or [email AWS security directly](mailto:aws-security@amazon.com).

## License

MIT License

Copyright (c) 2015-2019 InfluxData Inc.
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to  the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN  NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

