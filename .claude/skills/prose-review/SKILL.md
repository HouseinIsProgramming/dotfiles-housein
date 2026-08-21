---
name: prose-review
description: Review prose against seven rules: state facts plainly, name things explicitly, keep sentences simple, use one plain word per thing, cut what carries no information, stay timeless unless naming a version, and make comments say what the code cannot. Works on guide pages, code comments and JSDoc, on any file or block of text, and on a draft about to be posted such as a GitHub review comment or PR description. Use before opening a PR which touches prose, when reviewing someone else's, or before posting drafted text.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Bash(git diff *)
  - Bash(git show *)
  - Bash(git log *)
  - Bash(gh api repos/*)
  - Bash(gh pr view *)
  - AskUserQuestion
user-invocable: true
---

# Prose Review

Reviews prose and returns rewrites. It works on three kinds of text:

- The prose a change adds or edits: guide pages under `docs/docs/guides/`, code comments, and the
  JSDoc which feeds the generated reference docs.
- Any file or block of text handed to it.
- A draft which is about to be posted somewhere: a GitHub review comment, a PR description, an
  issue reply, a Slack or Discord message.

The rules follow the spirit of ASD-STE100, the controlled English used for aircraft maintenance
manuals: one word per meaning, short sentences, an actor for every verb, and every word carrying
information. This skill applies those principles without the ASD-STE100 approved word list, so the
vocabulary a writer may use is not restricted to a fixed set.

## Usage

```
/prose-review                 # Review prose added on the current branch
/prose-review 1234            # Review prose added by a PR
/prose-review draft.md        # Review a file
/prose-review "<text>"        # Review text given directly
```

An agent which has drafted something to post can run this skill over its own draft first and post
the rewrite.

## The rules

Five rules for all prose:

1. State facts plainly.
2. Name things explicitly.
3. Keep sentence structure simple.
4. Use one plain word per thing.
5. Cut what carries no information.

One more for text which will be read long after it was written:

6. Write timelessly, unless you can name a version.

One more for code comments:

7. Say what the code cannot.

Apply them as separate passes. A sentence which satisfies one rule often breaks another, and
reading for everything at once means finding one problem per sentence and moving on. Step 10 asks
for a line per rule, which is how you know each pass happened.

Which rules apply depends on what the text is:

| Text | Rules |
|---|---|
| Guide pages, README files, docs | 1-6 |
| Code comments and JSDoc | 1-7 |
| Review comments, PR descriptions, issue replies, chat messages | 1-5 |
| Migration guides, release notes, changelog entries, commit messages | 1-5 |

The last two groups are read alongside a specific change, so describing what changed is correct
there and rule 6 does not apply.

## Step 1: Get the text

For a file, a block of text, or a draft you are about to post, read it as written and go straight
to Step 2.

For a branch or a PR in the `vendurehq/vendure` repo, read `references/vendure-changes.md`. It has
the commands which extract the added prose, and the rules for regenerating the reference docs
afterwards.

## Step 2: State facts plainly

Say what the thing is and why it is that way. Rhetorical shapes make prose sound composed rather
than informative.

**Defining something by what it is not.**

| Rewrite | Instead of |
|---|---|
| This is a memoization layer. Entries are never evicted. | This is not a cache, it is a memoization layer. |
| The job runs on the worker. | The job does not just run anywhere, it runs on the worker. |

**Naming an absence instead of what happens.** This covers "X rather than Y" and "X instead of Y"
where Y is something which does not happen. The sentence sounds like a comparison, but only one
side exists, so it never states the consequence.

| Rewrite | Instead of |
|---|---|
| Nothing checks the ordering. A `ConfigService` built before `preBootstrapConfig` runs sees an incomplete list. | The invariant is relied on rather than enforced. |
| Nothing checks the ordering at runtime. This comment is the only record of it. | The ordering is documented rather than checked. |

The test is whether both sides name something which exists. Two implementations and one chosen is
an ordinary comparative, covered in Step 9. A side which names no mechanism at all belongs here.

**Asking a question and answering it.**

| Rewrite | Instead of |
|---|---|
| The old ID is kept because existing webhooks reference it. | Why keep the old ID? Because existing webhooks reference it. |

**Fragments arranged for rhythm.**

| Rewrite | Instead of |
|---|---|
| The request is not retried, and there is no fallback. | No retry. No fallback. No second chance. |

**Typography doing the work of a sentence.** Italics used to hold two phrases apart usually means
the sentence never explained the difference.

| Rewrite | Instead of |
|---|---|
| The first selects which record to load. The second selects how it is formatted. | The first selects *which record* to load. The second selects *how it is formatted*. |

**A coined phrase reused as though it had been defined.** If a term is worth using in three files,
define it once in a doc comment and link to it. Otherwise say what you mean each time, even if the
sentence gets longer.

## Step 3: Name things explicitly

Ask of every sentence: could a reader who has not read the implementation say what it refers to? If
a noun, a pronoun or a verb leaves that open, replace it with the actual name.

**A metaphor standing in for a plain noun.**

| Rewrite | Instead of |
|---|---|
| iterates the array of language codes | walks the chain |
| the returned array of codes | the returned chain |

**A term the prose never defines.**

| Rewrite | Instead of |
|---|---|
| checked once in the database and once in the in-memory cache | checked once per source |

**Figurative agency.** Inanimate things do not want, ask or decide.

| Rewrite | Instead of |
|---|---|
| limits each request to at most 40 lookups | puts a ceiling on how much work one request can ask for |

**A verb with no object.** "Falls back", "handles it", "cleans up" and "fails gracefully" all
describe nothing on their own.

| Rewrite | Instead of |
|---|---|
| falls back to the Channel's default language | falls back |
| logs the error and returns an empty array | handles the error appropriately |

**A passive with no actor.** "Is relied on", "is enforced", "is handled" leave out the thing which
does it. Name the actor, or rewrite so the thing which acts is the subject.

| Rewrite | Instead of |
|---|---|
| `preBootstrapConfig` populates the entity list before any `ConfigService` exists. | The entity list is populated before it is needed. |
| Nothing checks this at runtime. | This is not enforced. |

A passive is fine when the actor genuinely does not matter. "The row is deleted when the Channel is
removed" needs no subject, because which code performs the delete is not the point of the sentence.

**A pronoun or bare noun phrase with no clear referent.** When a sentence contains two candidate
nouns, repeat the name. "The invariant", "the constraint" and "this behaviour" fail the same test
as "it" when what they refer to appears only in an earlier sentence.

| Rewrite | Instead of |
|---|---|
| The strategy is consulted only after the cache misses. | It is consulted only after that. |
| Nothing checks that `preBootstrapConfig` runs first. | The invariant is not checked. |

A definite noun phrase is fine when what it refers to is in the same sentence.

## Step 4: Keep sentence structure simple

One idea per sentence. Split anything which needs a second pass to parse.

Two things to look for. First, distance between a subject and its verb. Second, more than one
subordinate clause in a sentence.

Instead of:

> Sending the display language explicitly also stops the browser's own header, which reflects the
> operating system locale rather than anything chosen in the application, from deciding it instead.

Rewrite as:

> Browsers send a header derived from the operating system locale. Set the display language
> explicitly so that value is not used.

In the original, the subject "Sending" and its verb "stops" are eleven words apart. The clause
between them interrupts the sentence, and "it" has two possible referents.

Instead of:

> The service, which is instantiated once per request and holds no state of its own, delegates to
> the strategy, so it can be replaced without touching callers.

Rewrite as:

> The service delegates to the strategy, so the strategy can be replaced without touching callers.
> A new service instance is created for each request and holds no state.

## Step 5: Use one plain word per thing

ASD-STE100 keeps one approved word for each meaning and forbids synonyms. Three habits break that.

**A different word for the same thing.** Pick one name and repeat it. A reader who meets "the
handler", "the callback" and "the hook" across three paragraphs has to work out whether they are
one thing or three.

| Rewrite | Instead of |
|---|---|
| The event handler runs on the worker. A handler which throws is retried three times. | The event handler runs on the worker. A callback which throws is retried three times. |

**A long word where a short one exists.**

| Rewrite | Instead of |
|---|---|
| use | utilise, leverage |
| lets you | enables you to, facilitates |
| about | with regard to, in terms of |
| because | due to the fact that |
| starts | initiates, kicks off |
| change | modification, adjustment |

**More than three nouns in a row.** Break the run with a preposition or a relative clause.

| Rewrite | Instead of |
|---|---|
| the strategy which handles errors raised during config validation | the config validation error handling strategy |

## Step 6: Cut what carries no information

Apply one test to every sentence: if you delete it, does the reader lose a fact? A drafted review
comment or chat reply usually loses several whole sentences to this rule.

**Preamble.** Lead with the finding.

| Rewrite | Instead of |
|---|---|
| `OrderService.applyCoupon` is called twice on the same request. | Thanks for the detailed PR. I have gone through the changes carefully, and there is one thing I wanted to flag. `OrderService.applyCoupon` is called twice on the same request. |

**Restating the request.** The reader wrote it, so they know what they asked for. Delete "You
asked me to check whether the migration is reversible" and start with the answer.

**Self-narration.** "Let me examine the resolver", "I will now check the tests" and "Good catch"
describe the reviewer, not the code. Delete them.

**Hedges and intensifiers.** "Very", "quite", "really", "significantly", "it is worth noting
that", "it seems that" and "arguably" add no fact.

| Rewrite | Instead of |
|---|---|
| The query runs once per row. | It is worth noting that this query may possibly run once per row. |

Genuine uncertainty is a fact and belongs in the text. State it in one plain sentence, such as "I
did not run the migration, so I have not confirmed this."

**A closing summary.** A final paragraph which repeats the points above gives the reader nothing
they have not just read. End on the last point.

**A structure holding one item.** A heading over a single paragraph, a table with one row, a list
with one bullet, or a numbered list of one finding. Write the sentence on its own.

**Structure repeated at two levels.** A bulleted summary followed by the same points as prose is
the same content twice. Keep the one which carries the detail.

## Step 7: Write timelessly, unless you can name a version

Comments and guide prose are read by people who have no idea your change happened. A sentence
which only makes sense next to the diff is broken for every later reader.

Authors break this rule most often while fixing the others, because "as it did before" is a natural
thing to write when you have just changed something.

Grep the added prose:

```bash
grep -inE '\bbefore\b|\bpreviously\b|\bnow\b|no longer|used to|as it always|\bstill\b|\bchanged\b'
```

Then apply one test to each hit: **can you name the version?**

**No version to name.** The sentence is describing the diff. Delete the comparison and state
current behaviour.

| Rewrite | Instead of |
|---|---|
| Resolves against the Channel default. | Still resolves against the Channel default, as it did before. |
| An unregistered handler is skipped. | A handler which is no longer registered is skipped. |
| Browsers send a header derived from the operating system locale. A client which relies on the query parameter alone will resolve against that locale. | A client which has been relying on the query parameter alone will now start resolving against the OS locale instead. |

**A version to name.** Documenting a change against a specific release is legitimate and often
required. Name the version explicitly, so the note stays true as it ages.

| Correct | Why |
|---|---|
| `@since 3.8.0` on a new API member | The generated reference docs render this, and it dates itself |
| From 3.8.0 this returns an empty array. Earlier versions returned `null`. | An upgrader needs both halves, and both are anchored to a release |
| `:::info Added in 3.8.0` in a guide page | Marks a section as new without implying the reader saw the change |

The distinction is whether a reader in two years can still act on the sentence. "As it did before"
gives them nothing. "Earlier versions returned `null`" tells them exactly which versions.

Migration guides, release notes, changelog entries, commit messages, PR descriptions and review
comments are all read alongside a specific change, so change narration is correct there by default.

## Step 8: Say what the code cannot

This step applies to code comments only.

A comment earns its place by saying why the code is this way, what breaks otherwise, and what was
ruled out. A sentence which restates the code below it should be deleted rather than rewritten. If
the two lines beneath the comment already show what it says, remove it.

The half most often missing is what breaks otherwise. A comment which gives a constraint but not
its consequence leaves the reader to work out what the failure looks like. That is the one thing
the code cannot show them.

| Rewrite | Instead of |
|---|---|
| Importing `getAllEntities` here would create a module cycle. A `ConfigService` built before `preBootstrapConfig` runs sees an incomplete entity list. | Unifying the source would create a cycle, so the invariant is relied on rather than enforced. |

Say what the failure looks like from the outside. "Sees an incomplete entity list" tells the reader
what to check. "Is not enforced" tells them a rule exists and nothing more.

## Step 9: Do not over-correct

Flagging these wastes the author's time and makes the review look mechanical.

**"Still" and "now" used logically rather than temporally.** "A client sending `pt-br` still
matches `pt_BR`" means despite the casing. "The list is now sorted" inside a step-by-step
explanation means at this point in the procedure. Neither refers to a previous version.

**Ordinary comparatives.** "A format check rather than an enum check" describes a choice between
two implementations. Both sides name something which exists, and the author chose one, so it is not
the pattern in Step 2. Flag it only when the second side names no mechanism at all, as "enforced"
does in "relied on rather than enforced".

**Stated uncertainty.** "I did not run the e2e suite" and "this depends on whether the subscriber
is registered" are facts the reader needs. Step 6 removes hedging which softens a claim the author
is sure of, and leaves genuine doubt in place.

**A term repeated because it is the name.** Step 5 asks for one word per thing, so repeating
`OrderService` six times is correct. Do not replace repetition with pronouns to break it up.

**Structure which carries several items.** A list of four findings or a table of three columns
helps the reader. Step 6 removes containers holding one thing.

**Passives where the actor does not matter.** Step 3 asks for an actor when the sentence is
explaining a design decision. "The record is deleted on cascade" is describing behaviour, and
naming the code which performs the delete would add nothing.

**Short sentences in sequence.** Three sentences in a row are a problem only when they carry one
idea between them for rhythm. If each carries a fact, leave them alone.

**Necessary length.** Rule 3 is about structure, not word count. A long sentence with one subject,
one verb and one clause is fine.

## Step 10: Account for every rule

Before reporting anything, write one line per rule which applies to this text, in order. Each line
is the rule number and either the count of findings or the word `clean`:

```
1 state facts plainly: 1
2 name things explicitly: 4
3 keep sentence structure simple: 3
4 one plain word per thing: clean
5 cut what carries no information: 2
6 write timelessly: n/a (review comment)
7 say what the code cannot: n/a (not code comments)
```

The account is the pass. A rule you cannot write a line for is a rule you did not run, and reading
for all of them at once produces one finding per sentence and a blended judgement. Go back and read
for that rule alone.

Then rewrite, and write the account a second time over the rewritten text. A rewrite which clears
one rule often breaks another: splitting a long sentence introduces a pronoun, cutting preamble
leaves a dangling pronoun in the first sentence, replacing change narration invites a passive, and
naming a thing you have just split out invites a coined noun. Stop when an account comes back clean
on every rule.

Report the account itself only if asked. It exists to make each pass happen.

## Step 11: Report

When reviewing a branch, a PR or someone else's file, list each finding with the file, the
sentence, and the rewrite. Group by rule, so the author can see which they are prone to. Apply the
fixes if asked.

When the text is a draft about to be posted, return the rewritten text and nothing else. The
caller wants something to post, so a list of findings makes them do the edit themselves. Say in one
line what you cut only if a whole section is gone.
