# Slackerton

A mostly useless Hedwig Slackbot for a local slack.

Uses my fork of [Hedwig_Slack](https://github.com/matthewoden/hedwig_slack), to enable support for Slack threading.

## Current Responders:

### Help

Lists out the current responders, and how to use them:

```
matthewoden: slackerton help
slackerton:
  slackerton help - Displays all of the help commands that slackerton knows about.
  slackerton help <query> - Displays all help commands that match <query>.
  mathbear/decide <options> - Makes a decision based on input. Format: decide 1 is left. 2 is right.
  slap <username> | me - Slaps the user
  wiki <query>*- Searches wikipedia, returning the first result.
  google <query> - gets the first google results for your query.
  search starfinder|pathfinder <query> - searches the SRD, returning the first result for your query.
  hey doc <ask for a joke> - Returns a joke.
  pop quiz - Asks a trivia question. Answer with the letters provided.
```

---

### Natural Language Support (Dad Jokes)

If you talk directly to the bot, it has some level of natural language support.

Currently, supports the following actions:

#### Admin Controls

Allows for Admin-limited controls, based on a list of users stored in Dynamo. Admins are namespaced to the current slack workspace. (in case that ever matters)

Possible actions:

- add an admin\*
- remove an admin\*
- list admins

\*indicates an action that requires elevated privledges.

```
matthewoden: hey doc add @jeremy as an admin
slackerton: @matthewoden Ok, I've made @jeremy and admin
```

```
matthewoden: hey doc remove superuser from @jeremy
slackerton: @matthewoden Ok, I've removed @jeremy from the list of admins
```

```
matthewoden: hey doc, who's in charge around here
slackerton: The current admins: @matthewoden, @jeremy
```

#### News Report

Gets the latest breaking news about a subject.

See a full list of [news sources](NEWSSOURCES.md)

```
matthewoden: hey doc whats the latest on the trade war?
slackerton:
*Asian shares slip on trade war anxiety, yuan steadies*
Hideyuki Sano, Reuters - Wednesday, July 4, 2018

Asian stocks slipped on Wednesday on the specter of a Sino-U.S. trade war ahead of an end-of-week deadline for U.S. tariffs on $34 billion worth of Chinese imports while the yuan stabilized after China's central bank moved to calm nervous investors.
http://feeds.reuters.com/~r/reuters/topNews/~3/9e4RbwNEHUw/asian-shares-slip-on-trade-war-anxiety-yuan-steadies-idUSKBN1JU03V
```

#### Terrible dad jokes

"Tell me a joke", "Tell me something funny", "Tell me a dog joke", etc.

Powered by icanhazdadjoke.com

```
matthewoden: hey doc tell me a carrots joke
slackerton: What did celery say when he broke up with his girlfriend? She wasn't right for me, so I really don't carrot all.
```

### Spelling Bee (Definitons, Pronunciations, Examples of use)

"What does WORD mean?", "How do you say WORD?", "Can you use WORD in a sentence?"

Powered by Wordnik.

```
matthewoden: hey doc define cat
slackerton:
Cat, noun
1. A small carnivorous mammal (Felis catus or F. domesticus) domesticated since early times as a catcher of rats and mice and as a pet and existing in several distinctive breeds and varieties.
2. Any of various other carnivorous mammals of the family Felidae, which includes the lion, tiger, leopard, and lynx.
3. The fur of a domestic cat.
```

#### Trivia

Runs a single round of trivia. Once the question is posted, you have 15 seconds to respond. Answers are case insensitive.

It tries to avoid repeat questions.

```
matthewoden: pop quiz
slackerton: POP QUIZ HOT SHOT:
  Which slogan did the fast food company, McDonald's, use before their "I'm Lovin' It" slogan?

  Choices:
  A Making People Happy Through Food
  B Why Pay More!?
  C Have It Your Way
  D We Love to See You Smile

  Reply with just: A, B, C, D

matthewoden: a
joe_bob: b
slackerton: Times Up!

The answer was: D

Winners for this round: ...Nobody!
```

but eventually all responders will work through it. Runs on my library for [AWS Lex](https://github.com/matthewoden/lex)

---

### Trivia (Supplemental)

As noted above, but can be invoked by saying "pop quiz"

---

### Dad Jokes (Supplemental)

Listens for any use of `"I'm <phrase>"`, and greets the user as if that phrase was their name. Runs randomly, so not every use will trigger it.

```
matthewoden: I'm so tired today
slackerton: @matthewoden: Hi "so tired today", I'm dad!
```

---

### Slap

Old school IRC troutslap. Slap yourself, or slap @user.

```
matthewoden: slap me
slackerton: slaps @matthewoden around a bit with a large trout. :fish:

matthewoden: slap @some_user
slackerton: slaps @some_user around a bit with a large trout. :fish:
```

---

### Search

Searches various sites, returning the first result found. Useful grabbing a quick explainer in the context of chat.

If enabled, slack will flesh out the url, showing a preview.

#### Wikipedia

Grabs the best matching result from wikipedia

```
matthewoden: wiki kickflip
matthewoden: @matthewoden: https://en.wikipedia.org/wiki/Kickflip
```

#### Google

Grabs the first (non-ad) result from google.

```
matthewoden: google albinoblacksheep
slackerton: @matthewoden: https://www.albinoblacksheep.com/
```

#### Pathfinder

Searches the (unofficial) pathfinder srd

```
matthewoden: search pathfinder elves
slackerton: @matthewoden: https://www.d20pfsrd.com/races/core-races/elf/
```

#### Starfinder

Searches the (unofficial) starfinder srd

```
matthewoden: search starfinder grenade
slackerton: @matthewoden: http://www.starjammersrd.com/feats/combat-feats/grenade-proficiency-combat/
```

---

### Mathbear / Decider

Mathbear makes the hard decisions. Give 'em a set of choices and get the answer.

```
matthewoden: decide 1 is keep the puppy. 2 is sell the puppy into slavery
slackerton: 1: sell the puppy into slavery
matthewoden: you monster
```
