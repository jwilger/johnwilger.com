+++
title = "The Language Model Is Just Another User"
description = "A CQRS-inspired approach to integrating LLMs: treat the language model as a user sending commands, not an internal system component."
slug = "the-language-model-is-just-another-user"
date = 2024-03-21
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/upload/v1710488977293/f0de341d-eb7f-446f-bf7e-275578260c49.webp"

[taxonomies]
tags = ["ai", "openai", "llm", "generative-ai"]
+++

A feature built on a language model tends to work in the demo and for a while afterwards. Then a response arrives in a form the code didn't expect, and something breaks. The team adjusts the prompt, adjusts the code, and waits for the next failure. A product in that condition is hard to call finished, and it's reasonable to wonder whether the technology can support anything more ambitious than a chatbot.

I was in that position the first time I worked on an application that relied heavily on OpenAI's chat completion API. I'd spent years managing APIs inside a large service infrastructure, and I approached this one the same way: a JSON API, where a request goes to a known endpoint and data comes back in a specified format. As development went on, the unpredictability of the responses caught up with us. Features that worked one day caused errors the next, and we fell into a cycle of adjusting the application code and the prompts in turn. I couldn't in good conscience tell my client the application was complete when it might fail at any time.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710518866017/e8877cff-7fb0-4e49-ae69-1f47a2847c94.webp align="center")

What got us out was a change in how we thought about the model. We had been treating it as a component inside the system. It works better to treat it as another user of the system, one whose input is validated like anyone else's.

The architecture we were already using pointed the way. We were building the application in Elixir with the Commanded library, in the style known as event sourcing and CQRS (Command Query Responsibility Segregation), which I've long liked. In that style, when a user does something that changes the system's state, such as submitting an order form, the action is captured as a command, a statement of the intent to change something. The system checks the command and carries it out, and the result is either an error message or an event recording the change. Those events are the authoritative record of the application's state, and no data changes without one.

The system recorded events for the language model's changes as it did for a person's. It's possible to write an event directly to the event stream, but Commanded makes it much easier to define a command and let the system execute it. So the model's changes went through commands as well, and it took me longer than I'd like to admit to see what that meant. The human user and the language model were changing the system's state through the same mechanism.

That made me reconsider what we were using the model for. In most applications, a language model produces results that a skilled user could produce without it. We use it to close a gap in knowledge or in time. It's less a part of the application than an assistant in working with the application.

I described in [an earlier piece on generative AI and user experience](/blog/generative-ai-is-a-ux-revolution/) how we let a language model control parts of an application that a person would previously have operated. The application was [APEX](https://apex.artium.ai/), which we built at Artium to help produce product plans grounded in the needs of the business. We could have designed it conventionally. The user would click a node, click an edit button, fill out a form for each section, and click save, and to add generative AI we'd have put a small button beside each text field and used the model to fill in that one field.

We made conversation the primary way of working with APEX. The user talks with "the Artisan," which does more than supply text for the user to paste into a field. It updates the text itself, in the right place.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710490780687/caa42080-902b-4113-aa17-a01b8be68c7e.png align="center")

The experience resembles editing a Google Doc with someone while you're on a call together. You read what they've written and suggest a change, and the text changes in front of you as your partner edits it from another computer. In APEX the partner is a language model that knows how to use the application. Sometimes it offers its own opinions, and when you're explicit it does what you say. Some of its results are right the first time, and others need another round.

If the model's output is treated as though a person had typed it into a form, the problem of unpredictable responses has a well-understood solution, which is form validation.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710490806221/24df3557-4a7a-46ca-8616-59286bca8716.webp align="center")

In practice, that means building the application as though several people can edit the same things at the same time, and then teaching the model to operate it. Two human users might exchange chat messages about the document they're working on. A text response from the model gets the same treatment: the application executes the `SendMessage` command that runs when a person clicks send. If the model decides a document's title should change, it has to return a message that the client code can translate into an `UpdateTitle` command, the same one that runs when a person clicks the edit link beside the title, changes the text, and clicks save.

How the system responds to an invalid change is an essential part of the approach. Language models work best with plain human language. Their ability to work with code is useful and improving, but they do better with ordinary prose. An incorrect call from the model should therefore get the response a person would get, which is a description of the error in natural language.

We had a rule, for example, that document titles must be unique, and we enforced it where commands are executed. When a title was already taken, the system recorded no `TitleUpdated` event and returned an error: "Another document already uses the title Foo Bar Baz." A model that sees that message has enough information to correct itself and try `UpdateTitle` again with a different title. A model that receives a terse code such as `dup_title` is less likely to understand that an error occurred, or to fix it.

The approach has further benefits. An application built this way is already prepared for collaboration between people, or between people and a model, if that's wanted later. It's also clear what to do when the model sends invalid data or tries something that isn't available to it, such as calling a function that doesn't exist or that it isn't permitted to use: the system refuses, as it would refuse a person, and says why. And there's a large body of experience in designing collaborative-editing applications, which can guide the design of applications that include a model.

For someone deciding whether a generative AI feature is ready to ship, the useful question is where the model's output goes. If it passes through the validation that applies to every user, an unexpected response produces an error message and a second attempt. If it goes straight into the system as trusted data, an unexpected response produces a failure in front of a customer.
