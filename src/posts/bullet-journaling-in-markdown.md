---
title: Bullet journaling in Markdown
date: 2025-02-05
tags: pkm neovim
---

I like [bullet journaling](https://en.wikipedia.org/wiki/Bullet_journal), since it has enough
information for me to glance over a page and have an idea of what is going on.

![](bullet-journal.png)

The idea is simple enough that it can be implemented in Markdown. Therefore, this blog will
include information on regards of how I implement this idea and some inspirations.

## Setup

I'm implementing this in Neovim using the `marksman` LSP (since it's what I know and like).

## Formatting

I translate **rapid logging bullets** as follows:

- `- [ ]`; Task equivalent to "•"
- `- [x]`; Done task, equivalent to "X"
- `- [-]`; Canceled task, equivalent to "-"
- `- [>]`; Deferred task, equivalent to "<"
- `- [<]`; Carry over task, equivalent to ">"
- `**...**`; Event, equivalent to "O" (I use it conjunction to the `#meeting` tag, more on that
  later)
- `-`; Notes, equivalent to "-"
- `=`; Feelings (rarely use them, but are useful for rants from time to time)

Additionally, we have **signifiers** that can be translated to Markdown as follows:

- `#tag` is used to tag each task (key for this method)
- **bold text** for priority (equivalent to *")
- *italics* for inspirations (equivalent to "!")
- `#explore` tag for exploration (equivalent to "eye")

## Improvements thanks to being in a computer

Since this is my "digital notes", I make use of quality-of-life improvements that come from
it being digital media.

1. I use at least one tags ALWAYS and it's to categorize my notes.

I have 4 main note types: `#idea` (for original content), `#reference` (for literature, mainly)
, `#journal` (to track what I'm doing; here is where I use the aforementioned Markdown bullet
journal) and `#moc` (Map-of-contents, basically a manually drawn indexes).

2. I use `sort` to... well... sort bullets. This gives my notes a cleaner structure.

In Neovim, you can simply select the code to sort and press `:sort`

3. I also have backlogs with tasks I have jotted down to do at some moment.

I generate this from time to time to compile all the tasks that are "open" (`- [ ]`), since this
means this where not properly taken care of (either by doing this, deferring, carrying over, or
simply removing)

4. Heavily customized Neovim config that makes using all of this easy.

Outside the scope of this blog post, but investing time on developing tools that fit the needs
you want is fun and crucial to make using them second nature.
