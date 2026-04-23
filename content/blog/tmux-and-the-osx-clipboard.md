+++
title = "tmux and the OSX Clipboard"
description = "Fixing clipboard integration between tmux and macOS using reattach-to-user-namespace."
slug = "tmux-and-the-osx-clipboard"
date = 2012-04-12

[extra]
cover = "https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=800&q=80"
+++

I started using [tmux][tmux] recently after a) I was informed that GNU screen is
basically an outdated POS, and b) an [excellent book][tmuxbook] on the subject
was published. I'm glad to have made the switch, as tmux is a wonderful
improvement over screen. However, on OSX, I found that the `pbcopy` and
`pbpaste` commands (among other things) would no longer work from within a tmux
session.

After a bit of searching, I found [this post][rtoc] that explains how to make
things right again.

TL;DR:

``` sh run this
brew install reattach-to-user-namespace
```

``` sh add this to ~/.tmux.conf
# Reattach to user namespace so that clipboard integration with OSX works again
set-option -g default-command "reattach-to-user-namespace -l zsh"
```

Obviously, replace `zsh` above with whatever you use for your shell.

[tmux]: http://tmux.sourceforge.net/ "tmux"
[tmuxbook]: http://pragprog.com/book/bhtmux/tmux "tmux: Productive Mouse-Free Development"
[rtoc]: http://writeheavy.com/2011/10/23/reintroducing-tmux-to-the-osx-clipboard.html "Reintroducing tmux to the OSX Clipboard"
