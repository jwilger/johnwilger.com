+++
title = "Generative AI is a UX Revolution"
description = "How conversational AI interfaces are breaking the GUI vs. CLI dichotomy and creating a new paradigm for human-computer interaction."
slug = "generative-ai-is-a-ux-revolution"
date = 2024-03-12
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/upload/v1709947871106/d67141a9-cb94-4a05-aaca-4cbade411abd.webp"
[taxonomies]
tags = ["ai", "ux", "generative-ai"]
+++

When I first engaged with computers, the landscape was predominantly shaped by command-line interfaces, a stark contrast to the GUI-based systems like Windows or MacOS that later emerged and democratized computing. This transformation was monumental, making technology accessible to a broader audience. Yet, it also introduced a dichotomy: while GUIs simplified interactions for the majority, they often fell short for expert users who valued the precision and efficiency of command-line interfaces. This divide underscored a technological gap where neither GUIs nor command-line interfaces could entirely meet the diverse needs of users. Attempts to redesign expert interfaces into graphical formats frequently resulted in a confusing mishmash of buttons and menus, complicating the user experience for novices without offering significant advantages to experts over the command line. Consequently, we find ourselves in a world where applications are often neither intuitive nor efficient, highlighting a significant challenge in the quest for inclusive and effective user interfaces.

In my role as a software engineer, I prefer using command-line and keyboard-driven tools. I avoid using the mouse while programming, not because I think "real programmers don't use mice," but because reaching for the mouse is significantly slower for tasks like navigating files, editing text, and running programs. Therefore, you'll often find me in a full-screen terminal window, using tmux (a tool for managing multiple terminal sessions in one window) and vim (a highly customizable text editor). Over time, I've developed a set of configuration tweaks and shell scripts that help me work efficiently. I use a minimalist UI that keeps the code I'm working on in focus, without the distraction of unnecessary UI elements that require mouse clicks.

![This is my entire main screen when programming.](https://cdn.hashnode.com/res/hashnode/image/upload/v1709939093205/b1a60861-5844-4855-8ec2-84377132c4e2.png align="center")

However, for those unfamiliar with these tools, becoming immediately productive in this environment can be quite challenging. I've been working this way for over 20 years, and I’m still finding new ways to boost my efficiency with vim. Given that I use this application almost daily for long hours as a crucial tool of my trade, the time invested in learning to use it as efficiently as possible is highly worthwhile. That said, I wouldn't suggest that all user interfaces should require this level of expertise to be effective. When I come across a system I'm not familiar with, I really value a simple, intuitive interface that helps me do the right thing.

On the other side of the spectrum, there are people who aren't as familiar with computer technology and can get frustrated by systems, even when those systems are meant to be used with a mouse or trackpad. My wife is one such person. She's not computer illiterate, but she often gets frustrated with websites and applications when she knows what she wants to do but can't find the right buttons to press to make it happen.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1709941595065/2804c54e-2218-4d1d-928c-f38cdce625f0.webp align="center")

Recently, at [Artium](https://artium.ai/), I've been involved in building [a new product called APEX](https://apex.artium.ai/), where we are exploring a new approach to how users interact with applications. APEX is a tool to help you take an idea for a software product and bring that idea to life by walking you through the process of defining the problem space, refining the product vision and value proposition, and then focusing on the key users of the application and how they will use it. The goal is to arrive at an actionable plan for building the initial version of your product and provide you with the information you need to create a proposal and business plan that will help you launch your product. The primary interaction with APEX involves exchanging messages with a generative AI assistant. However, this is not just an AI chatbot that is generating text in a chat window for you to copy and paste into your plan. Our assistant is actively updating the representation of your product on-screen as your conversation progresses.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1710267850978/5b83104c-e624-4469-99be-6325a60c1830.png align="center")

This style of interaction represents a pivotal shift from the traditional dichotomy of GUI and command-line interfaces. By adopting a conversational, AI-driven approach, we can create a unified interface that intuitively adapts to the user's expertise level—simplifying the learning curve for novices while providing the depth and efficiency that experts crave. This adaptability showcases how generative AI can transcend the limitations of previous technologies, offering a seamless, inclusive user experience that traditional interfaces have struggled to provide.

While getting ready to launch our open beta for APEX, I asked my wife to try using the application to plan out a product. She was able to get through the entire process, and amazingly, I didn't hear her get frustrated with it even once. She is a registered nurse by trade, and as I mentioned before, she is often frustrated with computer programs; this is not someone who has experience with product design or comes to the table with a high level of knowledge about computer systems. When I asked her about the experience, she told me that she much preferred this way of interacting with a computer because it was just like having a conversation with another person. Rather than having to feel overwhelmed by options or frustrated that she couldn't figure out how to change something, she was able to simply converse with the assistant and watch the updates happen in the display of the product. And there are no "wrong answers" when talking to the assistant. If you misunderstand a question or simply choose to focus on a different aspect of the product, the assistant is able to adjust, guide, and redirect to help you complete your task.

What is amazing to me is that this style of interaction is equally appealing to me as an expert user of the system. While the conversation and guidance of the assistant can be essential for a novice user who doesn't necessarily understand how to approach product planning, as someone who does understand both the process and the types of information that APEX manages, I am able to very quickly create a product plan without ever touching my computer's mouse by simply being explicit with the assistant with my directions. I can directly say "set the product title to MyAwesomeProduct", and it does it. If I say "use Elixir, Phoenix, and LiveView with a Postgres data store", it updates the Technology section without me having to wait for the assistant to ask me about that. If I already have text-based documentation about a product idea (typed notes from a client planning session, for example), I can simply paste those notes into the assistant window and tell it to create a product plan based on those notes.

Despite the promise of generative AI in enhancing UX, several challenges loom. One significant concern is the potential for AI to misunderstand user intent, leading to frustrating experiences or, in worst-case scenarios, harmful outcomes. Ensuring that AI systems can accurately interpret and act on a wide range of human inputs is crucial for their success. Additionally, ethical considerations are at the heart of deploying generative AI in any user-facing application. Issues such as bias in AI responses, transparency in how AI decisions are made, and the autonomy of users in guiding the AI's actions are critical. As we integrate AI more deeply into our lives, ensuring these systems enhance rather than undermine human autonomy, respect user privacy, and promote fairness and inclusivity will be essential. By addressing these ethical challenges head-on, we can harness the benefits of generative AI while minimizing potential harms. Addressing these challenges requires new approaches to software testing to account for the non-deterministic nature of generative AI responses. At Artium, we have also been pioneering the use of [Continuous Alignment Testing](https://artium.ai/insights/test-driving-ai-applications) to ensure that products using generative AI are able to function with a high degree of confidence and safety.

The impact of generative AI on UX design, as shown by our work on APEX, is clear. By enabling a more natural, conversational interaction with technology, we're doing more than just making applications more accessible and efficient; we're changing how humans interact with computers. This move towards intuitive, adaptive interfaces suggests a future where technology truly serves everyone, no matter their background or level of expertise. As we keep improving and broadening the abilities of generative AI, the potential for innovation in UX seems endless. The evolution from command lines to conversational interfaces is just the start of a UX revolution that will keep growing and surprising us.

*I did not and could not have produced APEX on my own in the time that we were able to bring this together. APEX would not have been possible without the team that created it:*

* *Cauri Jaye*
    
* *Ross Hale*
    
* *Serena Epstein*
    
* *Michael McCormick*
    
* *Ryan Durling*
    
* *Nick Mahoney*
    
* *George Wambold*
    
* *Nafisa Rawji*
    
* *Mark Whaley*
    
* *James Lenhart*
    
* *Chay Landaverde*
    
* *Gene Gurvich*
    
* *Randy Lutcavich*
    
* *John Wilger*
    
* *and the rest of the Artium team who supported our work*
