
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

##### Batched log entry request:

```bash
curl \
  --verbose \
  -X POST \
  -u 'admin:password' \
  localhost:7890/STG_BEACON_METRIC_LOGS/L16 \
  -d "89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp
89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from down to upppppppppp"
```

##### Single log entry request:

```bash
curl \
  --verbose \
  -X POST \
  -u 'admin:password' \
  localhost:7890/STG_BEACON_METRIC_LOGS/L16 \
  -d "89 <45>1 2023-04-10T17:12:02.000-07:00 host heroku web.1 - State changed from up to DOWWWWWWWN"
```


## Publishing this code to heroku:

```bash
git push heroku main
```

## Deploying this to an app on Heroku as a log drain:

```bash
heroku drains:add https://username:password@cloudwatch-log-drain.herokuapp.com/STG_BEACON_METRIC_LOGS/L16 -a l16-staging
```

### Making requests to the app running in Heroku:

```bash
curl \
  --verbose \
  -X POST \
  -u 'username:password' \
  https://cloudwatch-log-drain.herokuapp.com/STG_BEACON_METRIC_LOGS/L16 \
  -d '89 <45>1 2023-03-18T00:01:28.723822+00:00 host heroku web.1 - State changed from down to up'
```

### What log drains are on the app already?

```bash
$ heroku drains -a l16-staging --json
 ›   Warning: heroku update available from 7.60.1 to 7.69.1.
[
  {
    "addon": null,
    "created_at": "2023-04-04T14:32:15Z",
    "id": "9816b310-cb9e-40b4-a3fd-34810e5901de",
    "token": "d.ba9e648f-a721-4b01-8439-d4a6f7202ff8",
    "updated_at": "2023-04-04T14:32:15Z",
    "url": "https://drain:AKIA2B4KATWSQ72TYBU5@cloudwatch-log-drain.herokuapp.com/STG_BEACON_METRIC_LOGS/L16"
  }
]
```
