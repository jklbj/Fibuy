# FiBuy API

API to store and retrieve confidential development files (configuration, transactions)

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/transactions/`: returns all transaction IDs
- GET `api/v1/transactions/[ID]`: returns details about a single transaction with given ID
- POST `api/v1/transactions/`: creates a new transactions

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```