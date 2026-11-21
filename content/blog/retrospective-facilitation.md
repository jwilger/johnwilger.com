+++
title = "Retrospective Facilitation"
description = "Practical techniques for facilitating effective team retrospectives that surface hidden issues before they become problems."
slug = "retrospective-facilitation"
date = 2009-01-13

[extra]
cover = "https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&q=80"

+++

A team that believes things are going well is tempted to skip its retrospective. Before the release retrospective I facilitated yesterday for the ProjectDX team, some of us felt that a full day wouldn't gain us much. We had made good progress on the action items from the previous one, and the general feeling was that things were going basically well. We held it anyway, and it uncovered a number of issues that could have grown into much larger problems if we hadn't thought about them until their effects were obvious.

It was my second time facilitating a release retrospective for this team. The first, in October, went reasonably well considering that I was asked to facilitate as it started and had no time to prepare. This one went better because I knew in advance.

Most of the activities came from Diana Larsen and Esther Derby's book, Agile Retrospectives. We began with "ESVP" (Explorer, Shopper, Vacationer, Prisoner), which gauges how interested the group is in the work of the retrospective itself. In an anonymous vote, almost everyone identified as an Explorer. I generally trust the outcome with this group, though I did wonder whether anyone gave the answer they thought they were supposed to give.

## Building the timeline

Next I asked the team to construct a timeline of events from the past release. Our cycle consists of two three-week sprints followed by a two-week internal Alpha testing period and a two-week customer Beta testing period. Before the retrospective I had drawn the timeline on our whiteboard and divided it into a section for each of those. It looked something like this:

| Sprint 1 (11/03) | Sprint 2 (11/24) | Alpha (12/15) | Beta (12/29) |
| --- | --- | --- | --- |
| 11/03 | 11/24 | 12/15 | 12/29 |

I asked everyone to think of any events in that period that were meaningful to them in any way, write each one on a sticky note, and place the note at roughly the right spot on the timeline. I set a 45-minute time box. We were free to look back at calendars, email, and the commit logs from our SCM, and I said it was fine to take a break if you couldn't remember any more events, as long as you were back on time for the next step.

I let the team organize itself and didn't ask people to work in pairs. At first everyone worked alone. As the more obvious events went up on the board, people began working in groups to come up with more. By the end of the 45 minutes the whiteboard was full.

The area below the timeline was meant for a graph of energy and emotion levels. JD Huntington had the good idea of adding a rough bar graph of our commit volume there as well, taken from GitHub's activity graphs.

After a last chance to add sticky notes, each person took a turn at the board with markers, putting a blue dot next to any event they felt positive about and a red dot next to any they felt negative about. Then I asked them to think about their energy and emotion through the release and draw a line graph of their ups and downs in the bottom section. We looked at each iteration in turn, and I asked the team for observations about the data. We captured those in bullet lists at the bottom of the whiteboard as further data for analysis.

## Patterns and shifts

After lunch we used the "Patterns & Shifts" activity to generate insights from the timeline. We gathered at the whiteboard, and I asked each person to mark any point where they felt there had been a shift or transition of some kind, and to draw lines between any events, graph points, and observations they felt were related.

When no one could see any more connections, I asked the team to look for patterns among the connections and the shifts. The first thing we noticed was that the real shift between iterations kept happening about three days after the time box ended. I asked the team to keep that in mind as a possible concern for the next phase and not to discuss it at length then.

The next observation was that a number of connections had long lines spanning two or more iterations. I asked everyone to concentrate on those and look for cases where we had noticed an issue early and not addressed it until much later. In some cases the length of the line only meant that the work had taken that long, or that we had consciously decided not to address the issue right away.

The other cases led to a discovery. Chris noticed that where lines crossed the boundaries between iterations, they probably indicated a parallel cycle that we were trying to force into our release cycle. We have an explicit product release cycle and, at the same time, a customer deployment cycle that we had never made explicit.

## Circle of Questions

With the patterns identified, it was time to discuss them, along with anything else on our minds, and come up with a few action items for the next release cycle. For this I used the "Circle of Questions" activity. The group sits in a circle, and each person in turn asks a question of the person on their immediate left. The question can be about anything that isn't offensive or an attack, though it helps to concentrate on the insights from the previous stage. The person on the left answers as well as they can and then asks the person on their own left another question, or the same question if they'd like a better answer. This continues until the allotted time is up or you have gone around the whole circle twice, whichever comes last. Go around the complete circle. If some people get more turns to ask or answer than others, it can send the wrong message.

What I like about Circle of Questions is what it does for a mixed group, where some people tend to dominate the conversation and others tend to stay quiet. Everyone gets to ask their questions and have their opinions heard, and the most boisterous people aren't treated as the only ones with something valuable to say. We have that mix, and the activity worked very well for us.

We came away with a number of things to change for the next release cycle. None of the action items was directly related to the insights from the timeline. Those insights are still valuable, and they're in the notes we post to our internal wiki, so we may come back to them soon. We were running over on time and had to wrap up, though the discussion could have gone on.

Please don't hold retrospectives only when your team feels there's a problem to deal with. If you hold them regularly, whether or not you feel you need to, you will uncover issues before they become problems. A team with obvious issues might choose different activities from the ones we used. The timeline activity is good at finding potential improvements when everything seems to be going well, so try it the next time your team is tempted to skip a retrospective because no one sees a serious problem.
