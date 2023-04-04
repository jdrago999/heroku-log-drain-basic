
# Basic Heroku Log Drain

## Environment Variables

* `PORT`
  * What TCP port the server should bind to.
  * Optional
  * Default: 4567
* `USER`
  * The basic authentication username
  * Required
* `PASS`
  * The basic authentication password
  * Required
* AWS Credentials: (required to send logs to AWS CloudWatch)
  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`
  * `AWS_DEFAULT_REGION`

## Local Development and Testing

1. Export the required variables into your environment, eg:

```bash
export PORT=7890
export USER=admin
export PASS=s3cr3tpa55
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=YYYYYYYYYYYYYYYYYYYYYY
export AWS_DEFAULT_REGION=us-east-1
```

2. Start the program:

(First, make sure you have `foreman` installed via `sudo gem install foreman`)

```bash
foreman start
```

The `foreman` command will read `Procfile` and run whatever is specified there, just like on Heroku.

3. Make a request to the log drain:

```bash
curl \
  --verbose \
  -X POST \
  -u 'admin:s3cr3tpa55' \
  localhost:7890/BEACON_METRIC_LOGS/STAGING \
  -d '89 <45>1 2023-03-18T00:01:28.723822+00:00 host heroku web.1 - State changed from down to up'
```
