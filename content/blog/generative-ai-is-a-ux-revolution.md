+++
title = "Generative AI is a UX Revolution"
description = "An interface designed for beginners slows experts down, and one designed for experts loses beginners. A conversational assistant that operates the application can serve both."
slug = "generative-ai-is-a-ux-revolution"
date = 2024-03-12
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/upload/v1709947871106/d67141a9-cb94-4a05-aaca-4cbade411abd.webp"

[taxonomies]
tags = ["ai", "ux", "generative-ai"]
+++

A team designing an interface usually has to choose whom to disappoint. An interface that a newcomer can use on the first day tends to slow down the people who use it all day, and one built for those people tends to leave the newcomer lost. Many applications end up somewhere in between and serve neither group well. A conversational assistant that can operate the application offers a way out of that choice, and I've watched it work for two very different users.

The choice is as old as the graphical interface. When I started using computers, the command line was the usual way to work with one. Windows and the Mac made computers usable by far more people, and they did it by putting everything on the screen where it could be found. Experts kept the command line because it's precise and quick. Attempts to give expert tools a graphical form often produced crowded screens of buttons and menus that confused beginners and gave experts nothing they didn't already have.

I'm on the expert side of that divide in my own work. I prefer command-line and keyboard-driven tools, and I avoid the mouse while programming because reaching for it is slower for navigating files, editing text, and running programs. I usually work in a full-screen terminal with tmux, which manages several terminal sessions in one window, and vim, a highly customizable text editor. Over the years I've built up configuration and shell scripts that keep the code in view and everything else off the screen.

![This is my entire main screen when programming.](https://cdn.hashnode.com/res/hashnode/image/upload/v1709939093205/b1a60861-5844-4855-8ec2-84377132c4e2.png align="center")

Someone unfamiliar with these tools wouldn't be productive in that environment for a long time. I've worked this way for more than twenty years and still find ways to be more efficient with vim. Because I use it for long hours nearly every day, the time spent learning it has been worth it. I wouldn't ask that of the users of most software. When I meet a system I don't know, I want a simple interface that helps me do the right thing.

My wife is at the other end. She isn't computer illiterate, but websites and applications often frustrate her, because she knows what she wants to do and can't find the buttons that do it.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1709941595065/2804c54e-2218-4d1d-928c-f38cdce625f0.webp align="center")

At [Artium](https://artium.ai/) I've been part of the team building [APEX](https://apex.artium.ai/), a tool that takes an idea for a software product and walks its owner through defining the problem, refining the vision and value proposition, and identifying the key users and how they'll use the product. The result is an actionable plan for a first version, with the information needed for a proposal and a business plan. The main way of using APEX is to exchange messages with a generative AI assistant. The assistant doesn't produce text for the user to copy into the plan. It updates the plan on the screen as the conversation goes on.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710267850978/5b83104c-e624-4469-99be-6325a60c1830.png align="center")

While we were preparing the open beta, I asked my wife to plan a product with it. She's a registered nurse, with no background in product design and no particular knowledge of computer systems. She got through the whole process, and I didn't hear her get frustrated once. She told me afterwards that she much preferred working this way because it was like having a conversation with another person. She wasn't overwhelmed by options or stuck looking for the way to change something. She talked with the assistant and watched the plan update. There were no wrong answers, either. When she misunderstood a question or chose to concentrate on a different part of the product, the assistant adjusted and steered her back toward finishing the task.

The same interface suits me as an expert. I understand the planning process and the information APEX manages, so I skip the guidance and give direct instructions, and I can build a product plan quickly without touching the mouse. If I say "set the product title to MyAwesomeProduct," the title changes. If I say "use Elixir, Phoenix, and LiveView with a Postgres data store," the Technology section is updated without my waiting to be asked about it. If I already have notes on a product idea, such as what I typed during a planning session with a client, I paste them in and tell the assistant to build the plan from them.

One design served a nurse who dislikes most software and an engineer who avoids the mouse, and neither of us had to learn it. The assistant gave her as much guidance as she needed and stayed out of my way, which no arrangement of menus and buttons does.

The approach brings problems of its own. An assistant can misunderstand what a user meant, and when it acts on the misunderstanding the result is frustrating at best and harmful at worst. Its responses can be biased, its reasons for a change can be unclear, and a user has to remain able to direct and overrule it. Its output also varies from one run to the next, so the testing methods used for conventional software don't settle whether it behaves correctly. At Artium we've been developing [Continuous Alignment Testing](https://artium.ai/insights/test-driving-ai-applications) to give products built on generative AI a measurable level of confidence and safety.

For a company planning a product, this changes an early decision. The question of whether to design for the newcomer or the expert has been a choice between two markets, or a compromise that satisfied neither. Where the work can be described in conversation, one interface can now serve both.

*APEX was the work of a team, and I couldn't have produced it alone in the time we had:*

- Cauri Jaye
- Ross Hale
- Serena Epstein
- Michael McCormick
- Ryan Durling
- Nick Mahoney
- George Wambold
- Nafisa Rawji
- Mark Whaley
- James Lenhart
- Chay Landaverde
- Gene Gurvich
- Randy Lutcavich
- John Wilger
- and the rest of the Artium team who supported our work
