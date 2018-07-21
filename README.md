# Slackerton

A mostly useless Hedwig Slackbot for a local slack, but can be run in multiple slack channels.

Uses my fork of [Hedwig_Slack](https://github.com/matthewoden/hedwig_slack), to enable support for Slack threading.

## Structure

- slackerton - core services, cache warmer, credential store
- slackerton_chat - contains logic for the chat interface. Responders for Hedwig, Resolvers for AWS Lex
- slackerton_web - TODO: contains the logic for the web interface

## Current Responders/Resolvers:

Lists out the current responders, and how to use them:

### Basic responders

slackerton help - Displays all of the help commands that slackerton knows about.

### Natural Language

Most responders focus use some level of natural language processing. [View all responders with example responses.](RESPONDERS.md)

#### Fun and Games:

Hey doc

... tell me a joke - Returns a joke.

... lets play trivia - Asks a trivia question. Answer with the letters provided.

#### General Knowledge:

Hey doc

... what's the latest on / whats the news about <topic> - Grabs the top trending news from one of 63 sources.

... what is / who is / where is <thing> - Provides general information about a topic

... can you define / how do you pronounce / can you give an example of <thing> - grammar information

#### Weather Alerts:

... put severe weather alerts in this channel

... remove weather alerts from here

... tell me about severe weather

#### Feature Requests:

... feature request: <request> - Files a feature request on the github project.

#### Admin Controls:

Hey doc
... add @user as an admin - adds a user as an admin

... remove @user from admins - removes user from admins

... list admins - lists admins for the current slack team

... ignore @user - stop responding to a user

... unignore @user - stop ignoring a user

... list ignored - lists all ignored users for the current team

---
