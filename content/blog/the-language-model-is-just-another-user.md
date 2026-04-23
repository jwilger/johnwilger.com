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

The first time I worked on an application that heavily relied on OpenAI's chat completion API, my years of experience managing APIs within an extensive service infrastructure shaped my approach. It seemed straightforward: it was just another JSON API where you send a request to a known endpoint and get back data in a specific format. However, as the development progressed, we encountered problems due to the unpredictable nature of the generative AI responses. Features that worked one day would suddenly cause errors the next, leading us into a repetitive cycle of tweaking the application code and the prompts we were using. This situation was unsustainable; I couldn't in good conscience tell my client that their application was "complete" when it could break down at any moment. Is building anything more sophisticated than a fancy chatbot using this technology even possible?

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710518866017/e8877cff-7fb0-4e49-ae69-1f47a2847c94.webp align="center")

The system architecture we were using led me to a realization that has completely changed how I now integrate generative AI features into an application. I've always appreciated event-sourcing and CQRS (Command Query Responsibility Separation) architectures. We were developing this application in Elixir using the Commanded library. In this architecture, whenever a user performs an action that changes the system's state (like submitting an order form), this action is captured as a "command" that shows the intent to change the state. This command is checked and carried out, leading to either an error message or a state-change event. These events are the truth for the entire application's state, and no changes to the system's data happen without a matching event. The system records events in response to the language model's changes, just like those made by human users. Although it's possible to write an event directly to the event stream, the Commanded library makes it much easier to create a simple command that the system can execute, which results in the recording of an event.

It took me longer than I'd like to admit to see how everything fit together. The human user and the language model change the system's state using the same basic process: the command. Once I realized this, I wondered if we were approaching this from the wrong perspective. What are we using generative AI for? In most situations, a language model is creating results that a skilled user could also achieve on their own; we use these models as an aid to help us bridge a gap in either knowledge or efficiency. They aren't a *part* of the application as much as they are an assistant in *working with* it.

As I mentioned in [an earlier piece about how generative AI is changing UX paradigms](https://johnwilger.com/generative-ai-is-a-ux-revolution), we successfully let the language model control many aspects of an application humans would have previously performed. When creating [APEX](https://apex.artium.ai/), a generative-AI-integrated application we made at Artium to help produce product plans that are well-grounded in the needs of the business, we could have taken a different approach to the interaction. We could have had the user click on nodes, click an edit button, fill out a form with the information they wanted in each section, and click "save," and to incorporate generative AI, we could have put a little AI-sparkle button next to the text fields and used the model to fill in just that one piece.

Instead, the primary means of interacting with APEX is via a back-and-forth conversation with "the Artisan." The Artisan isn't just a chatbot that gives you the text to put into a form field; it can also update that text for you in the right spot.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710490780687/caa42080-902b-4113-aa17-a01b8be68c7e.png align="center")

Imagine you're on a call with someone and you’re collaborating on a Google Doc. You read through the text they've just written and suggest changes. Right before your eyes, you see the text change as your writing partner edits the document on another computer. Once upon a time, that felt magical; today, it's mundane.

Using APEX to build a product plan is similar to this style of collaborative editing. The difference is that your writing partner is a language model that understands how to use the application. Sometimes, it offers its own opinions, but it also does what you say verbatim when you are explicit. Sometimes, it produces results you will love; sometimes, you need to iterate on its suggestions.

Witnessing this approach come together, I realized that this is precisely where generative AI can shine when integrated into our applications. I also learned how we can make language models a much more reliable part of our systems.

Rather than treating the language model as an internal component of your system, a better approach is to consider it as just another user sitting at their computer and sending inputs to the system. By treating the output from the language model *precisely* as if it had been typed into a form by a human user, the solutions to non-deterministic inputs suddenly become clear. It's just form validation.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710490806221/24df3557-4a7a-46ca-8616-59286bca8716.webp align="center")

Build your application as though multiple humans can concurrently and collaboratively edit the same entities. Then, teach your model to control your application. For example, your two human users might have a text chat about the documents they are working on. Treat text responses from the language model the same way; your application code processes the response by executing the same SendMessage command that a human user invokes if they click the send button on a message they typed. If the language model determines it needs to change the title of a document, it must send a message back that your client code can translate into an application command such as UpdateTitle. This command, again, is the same UpdateTitle command that the system will execute if a user clicks an "edit" link next to the title, changes the text, and then hits "save."

How you handle an invalid attempt to change the system data is an essential aspect of this approach. Language models work best with plain, human language. While their ability to run completions of computer code is currently helpful and still improving, typical language models are better at working with good old-fashioned prose. Because of this, you should respond to the incorrect function call in the same way you'd react to the human user: show it the natural language descriptions of the errors.

For example, we have a rule that a document title must be unique in the system. We enforce this invariant at the command execution layer. When a title is not unique, instead of recording a TitleUpdated event, the system responds with an error message: "Another document already uses the title Foo Bar Baz." If the language model sees this error in your response, it will have enough information to correct itself and attempt to execute the UpdateTitle command again with a different title. If, instead, the model receives a machine-friendly error message like "dup\_title," there is less of a chance that it will interpret that to mean an error occurred or that it will sufficiently address the mistake.

Treating generative AI as just another user of your application means that you'll also be well-situated to add human/human or human/human/AI collaboration, should that be desired. It becomes more apparent how to handle errors when you receive invalid data or when the model tries to interact with your application in ways that aren't available to it, such as hallucinating functionality that doesn't exist or isn't permitted. Additionally, much knowledge and experience exists in designing UX for collaborative-editing applications. Rather than reinventing the wheel, we can rely on this existing body of knowledge to guide how we approach UX for generative-AI-enhanced applications.

By changing your perspective on the role that generative AI plays in your application, you can both delight your users and create an application that is more fault-tolerant and easier to maintain.
