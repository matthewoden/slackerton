# Responders/Natural Language Processing

Almost all responders use some level of natural language support.

## Admin Controls

### Admin User Management

CRUD operations for users with elevated access. Admins are namespaced to the current slack workspace. (in case that ever matters)

Possible actions:

- add an admin\*
- remove an admin\*
- list admins

```
matthewoden: hey doc add @jeremy as an admin
slackerton: Are you sure I should add them to the list of admins?
matthewoden: yes
slackerton: @matthewoden Ok, I've made @jeremy an admin
```

```
matthewoden: hey doc remove superuser from @jeremy
slackerton: Are you sure I should remove them to the list of admins?
matthewoden: yes
slackerton: @matthewoden Ok, I've removed @jeremy from the list of admins
```

```
matthewoden: hey doc, who's in charge around here
slackerton: The current admins: @matthewoden, @jeremy
```

### Ignore users

Abusing the bot can result in a massive amount of updates. Rather than disable the bot, you can disable the troublemakers

- ignore user\*
- unignore user\*
- list ignored users

\*indicates an action that requires elevated privledges.

```
matthewoden: hey doc ignore @jeremy
slackerton: Are you sure I should ignore that user?
matthewoden: yes
slackerton: @matthewoden Ok, I'll stop listening to @jeremy
```

```
matthewoden: hey doc stop ignoring @jeremy
slackerton: Are you sure I should stop ignoring that user?
matthewoden: yes
slackerton: @matthewoden Ok, I've stop ignoring @jeremy
```

```
matthewoden: hey doc, who's ignored here?
slackerton: The following users are ignored: @matthewoden, @jeremy
```

\*indicates an action that requires elevated privledges.

## General Knowledge

Basic, googleable items. Grabs a summary from wikipedia.

"What is X?" "Who is Y?" "Where is Z?"

matthewoden: hey doc what is an ocelot?
slackerton:
_Ocelot_
The ocelot is a wild cat native to the southwestern United States, Mexico, Central and South America. It is listed as Least Concern on the IUCN Red List as the population is estimated to comprise more than 40,000 mature individuals and is considered stable. Its fur was once regarded as particularly valuable, but legal trade of i
ts fur ceased decades ago.

### News

Gets the latest breaking news about a subject.

See a full list of [news sources](NEWSSOURCES.md)

```
matthewoden: hey doc whats the latest on the trade war?
slackerton:
_Asian shares slip on trade war anxiety, yuan steadies_
Hideyuki Sano, Reuters - Wednesday, July 4, 2018

Asian stocks slipped on Wednesday on the specter of a Sino-U.S. trade war ahead of an end-of-week deadline for U.S. tariffs on $34 billion worth of Chinese imports while the yuan stabilized after China's central bank moved to calm nervous investors.
http://feeds.reuters.com/~r/reuters/topNews/~3/9e4RbwNEHUw/asian-shares-slip-on-trade-war-anxiety-yuan-steadies-idUSKBN1JU03V

matthewoden: hey doc whats the latest news on the trade war
slackerton: Sorry, I don't have anything new about that.
```

### Spelling Bee

"What does WORD mean?", "How do you say WORD?", "Can you use WORD in a sentence?"

Powered by Wordnik.

```
matthewoden: hey doc define cat
slackerton:
Cat, noun

1.  A small carnivorous mammal (Felis catus or F. domesticus) domesticated since early times as a catcher of rats and mice and as a pet and existing in several distinctive breeds and varieties.
2.  Any of various other carnivorous mammals of the family Felidae, which includes the lion, tiger, leopard, and lynx.
3.  The fur of a domestic cat.
```

## Fun and Games

### Terrible dad jokes

"Tell me a joke", "Tell me something funny", "Tell me a dog joke", etc.

Powered by icanhazdadjoke.com

```
matthewoden: hey doc tell me a carrots joke
slackerton: What did celery say when he broke up with his girlfriend? She wasn't right for me, so I really don't carrot all.
```

Also:
Listens for any use of `"I'm <phrase>"`, and greets the user as if that phrase was their name. Runs randomly so not every use will trigger it.

```
matthewoden: I'm so tired today
slackerton: @matthewoden: Hi "so tired today", I'm dad!
```

### Trivia

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
