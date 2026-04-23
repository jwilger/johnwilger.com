+++
title = "The Hidden Pitfalls of AI Software Development"
description = "How a $2,000 surprise from the Google Places API taught me that AI-assisted coding requires reviewing more than just the code."
slug = "the-hidden-pitfalls-of-ai-software-development"
date = 2025-03-11
[extra]
cover = "https://cdn.hashnode.com/res/hashnode/image/stock/unsplash/mQTTDA_kY_8/upload/d7c503048890c755f33d92530c7d7736.jpeg"
[taxonomies]
tags = ["software", "ai", "software-engineering", "lessons-learned", "copilot"]
+++

*Before we start, I want to make it clear that I'm not going to "blame the controller" for losing this game. I've always believed that a software engineer using AI assistants to write code is still responsible for reviewing and understanding every line of that code, and this situation is no different. Even though the issue I faced was unexpected, it's still completely my responsibility. I'm just relieved that I'm the only one affected and that it didn't happen in a situation involving a client.*

I've been trying out different AI-assisted software development workflows recently so I can guide clients and colleagues on which tools and methods to use or avoid. One setup I find quite promising is [Goose](https://block.github.io/goose/), an on-machine AI agent that interacts with the system through extensions using an MCP server. When used with a `.goosehints` file, which gives instructions for a ping-pong pairing, TDD approach to development, I've been quite impressed with its capabilities and how it can be adjusted to fit specific workflow preferences.

As part of my experimentation, I used Goose to help create a small TypeScript CLI utility. This tool takes a CSV file, where each record is a latitude/longitude coordinate pair, as input and outputs a new CSV file that includes the associated business name, website, and telephone number from the Google Places API. This task, having never used the Places API before and not being a regular TypeScript author, would likely have taken me 2-3 hours to complete. With AI assistance, it was done in about an hour. It was a complete, working solution that easily processed a test file with about 10,000 rows. It had full test coverage, and the code quality was decent, if not perfect. Success, right?

The problem is that bugs and low-quality code aren't the only issues that can cause trouble.

In my first attempt at creating this utility, I only extracted the business names from the Places API for each record. A quick check of the Places API pricing showed that I could make 10,000 requests for free, and additional requests up to 100,000 would cost $5 per 1,000 requests. Running an input file with 20,000 rows would cost about $50. I thought this expense was reasonable for the experiment, but I also wanted to avoid unnecessary spending. So, I decided to use a 10,000-row input file to stay closer to the free tier and maybe only spend $5-10 on the extra requests needed during testing.

Once I got the basic version working by refining the solution with Goose, I then asked Goose if I could also include the website URL and phone number for the business in the output. Goose was happy to help and did a great job updating the existing solution, including the tests, without unnecessarily rewriting major parts of the code.

At this point, anyone familiar with the Google Places API is probably shaking their head and laughing at my mistake.

The pricing I was looking at was for their "Place Details Essentials" level of requests. By simply asking for these two extra fields, URL and phone number, the request automatically moved to their "Place Details Enterprise" tier, which is much more expensive. At this tier, you only get 1,000 requests per month for free, and you pay **$20 per 1,000 requests** for anything beyond that! You can imagine my shock and horror when I received emails from Google later that day saying they had received payments from me totaling just under $2,000.00!

This probably wouldn't have happened if I had been writing this code without AI assistance. I would have needed to review the API documentation for the Places API to find out how to get those two additional fields of data. At that point, I likely would have noticed that this would move me into a different pricing tier. However, since using AI assistance meant I didn't need to look up this information myself, I didn't notice the change. I happily ran my tests and then the entire test file, and I was quite pleased with the output. It was a job well done, and it probably took about an hour less than it would have if I had written the code myself.

This post is not a criticism of Goose specifically; the issue I faced could happen with any LLM-based coding assistant. In fact, I would argue that the better the tool (and the more you trust it), the more likely you are to encounter a similar issue. The problem wasn't with the code itself. I reviewed the code before running it and made sure I understood what each line was doing. What I didn't do was thoroughly consider other factors that a professional software engineer should evaluate, such as the financial cost of running the solution. Thankfully, this was just a personal project and not a client system, so I'm the only one dealing with the consequences. Now imagine if a less-experienced developer made a similar mistake in a production system that processed many more records over a month. The consequences of that decision could be much worse.

While AI-assisted coding tools like Goose can significantly enhance productivity and streamline the development process, they also introduce new challenges and responsibilities for developers. It's crucial for software engineers to remain vigilant and thoroughly review not just the code, but also the broader implications of their work, such as financial costs and potential impacts on production systems. This experience underscores the importance of maintaining a balance between leveraging AI capabilities and exercising professional diligence to avoid costly oversights. As AI tools continue to evolve, developers must adapt and refine their practices to ensure they harness these technologies effectively and responsibly.
