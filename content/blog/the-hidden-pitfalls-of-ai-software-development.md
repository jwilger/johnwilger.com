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

Teams that adopt AI coding assistants generally keep one rule from before: the engineer is responsible for reviewing and understanding every line of code that ships. I hold to that rule myself. I followed it on a small personal project and still received emails from Google confirming payments of just under $2,000. The code was sound. What I hadn't reviewed was the cost of running it, and the reason I hadn't applies to any team using these tools.

I'd been trying different AI-assisted development workflows so that I could advise clients and colleagues on which tools and methods to use. One setup I found promising was [Goose](https://block.github.io/goose/), an agent that runs on the developer's machine and works with the system through extensions. I'd given it a `.goosehints` file with instructions for test-driven development in the ping-pong pairing style, where one partner writes a failing test and the other makes it pass. I was impressed by what it could do and by how far it could be adjusted to a particular way of working.

As part of the experiment I had Goose help me write a small command-line utility in TypeScript. It takes a CSV file in which each record is a latitude and longitude, and writes a new CSV that adds the name, website, and telephone number of the business at that location, looked up through the Google Places API. I had never used the Places API and don't write TypeScript regularly, so the job would probably have taken me two or three hours alone. With the assistant it took about an hour. The result was complete and working, had full test coverage and decent code, and processed a test file of about 10,000 rows without trouble.

The first version looked up only the business name. I checked the pricing for the Places API before running it. The first 10,000 requests were free, and requests beyond that, up to 100,000, cost $5 per 1,000. A 20,000-row input would have cost about $50. That seemed reasonable for an experiment, but I didn't want to spend more than necessary, so I used a 10,000-row file to stay near the free tier and expected to pay $5 or $10 for the extra requests made during testing.

Once that version worked, I asked Goose to add the website and phone number to the output. It updated the solution and its tests without rewriting large parts of the code, and did the job well.

The pricing I had looked at was for the tier Google calls Place Details Essentials. Asking for those two extra fields moved every request into Place Details Enterprise. At that tier only 1,000 requests a month are free, and each additional 1,000 costs $20. I ran my tests and then the whole file, was pleased with the output, and learned what I'd done when the emails arrived later that day.

This probably wouldn't have happened if I had written the code by hand. To find out how to request those two fields, I'd have had to read the Places API documentation, and I'd likely have noticed there that they belonged to a different pricing tier. The assistant already knew how to request them, so I never opened the documentation. Part of the time I saved was time I'd have spent learning what the change cost.

Goose isn't at fault, and the same thing could happen with any coding assistant built on a language model. The better the tool is and the more it's trusted, the more likely this becomes, because a good assistant removes more of the reading an engineer would otherwise do. I had reviewed the code before running it and understood what each line did. I hadn't considered the other things a professional engineer is supposed to weigh, and the cost of running the software is one of them. The responsibility for that is mine and not the tool's.

It was a personal project, so I'm the only one who paid. A less experienced developer could make the same mistake in a production system that handles far more records every month, with a client's money. Reviewing every line of code wouldn't prevent it. When an assistant does the looking up, a team has to review on purpose the things that reading documentation used to bring to an engineer's attention: what a call costs, what limits apply to it, and what it does to the systems it touches.
