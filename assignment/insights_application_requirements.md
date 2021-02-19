# Insights application

## Goal

This application is responsible for insights in your cloning performance. The current strategy is that you define a static window regardless of currency pair. This is inefficient, as you'll only start "correcting" when it's too late.

Thus this application will consume the `finished-chunks` topic. It'll monitor __the succesfully__ cloned chunks and keep it in its application state. It will print a message every second displaying an overview of the average chunks that were clone in the total time. A sample calculation would be:

* No data present in the app, a chunk (BTC_USDT) was cloned for 24 hrs. It contained 24 entries, so the app will display a table with the row:
  * `"| pair      | entries/day | entries/hr |  N entries  | total time frame in days, hrs, seconds |"`
  * `"| BTC_USDT  | 24/day      | 1/hr       |  24 entries | 1 days, 0 hrs, 0 seconds               |"`
* Another chunk is cloned for the same currency pair, containing 72 entries (timeframe is again 24 hrs). The new report is:
  * `"| pair      | entries/day | entries/hr |  N entries  | total time frame in days, hrs, seconds |"`
  * `"| BTC_USDT  | 48/day      | 2/hr       |  96 entries | 2 days, 0 hrs, 0 seconds               |"`

You decide what the OTP structure looks like. Though keep in mind - it has to be robust. State doesn't need to be persisted across restarts.

## Data flow

You'll consume the `finished-chunks` topic and do a calculation. Every 1 second, you print a message to your console.

## Libraries and usage for this application

We provide 1 libraries for you:

* [Messages library](https://github.com/distributed-applications-2021/assignment-messages). This will describe how the data in the messages should be put on your Kafka topics.

Look at the readme / API overview how to use it.

## Constraints

The project name is `WorkerInsights`. You're expected to only have 1 application (so no need to horizontally scale).
