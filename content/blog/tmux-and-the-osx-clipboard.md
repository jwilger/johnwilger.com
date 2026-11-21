+++
title = "tmux and the OSX Clipboard"
description = "Fixing clipboard integration between tmux and macOS using reattach-to-user-namespace."
slug = "tmux-and-the-osx-clipboard"
date = 2012-04-12

[extra]
cover = "https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=800&q=80"

+++

On OS X, the `pbcopy` and `pbpaste` commands stop working inside a [tmux][tmux] session, along with a few other things. I ran into this soon after switching to tmux from GNU screen. I'd been told that screen was badly outdated, and an [excellent book][tmuxbook] on tmux had just been published. I'm glad I switched, because tmux is a clear improvement.

[This post][rtoc] explains the clipboard fix. In short, install `reattach-to-user-namespace`:

``` sh run this
brew install reattach-to-user-namespace
```

and add this to `~/.tmux.conf`:

``` sh add this to ~/.tmux.conf
# Reattach to user namespace so that clipboard integration with OSX works again
set-option -g default-command "reattach-to-user-namespace -l zsh"
```

Replace `zsh` with whatever shell you use.

[tmux]: http://tmux.sourceforge.net/ "tmux"
[tmuxbook]: http://pragprog.com/book/bhtmux/tmux "tmux: Productive Mouse-Free Development"
[rtoc]: http://writeheavy.com/2011/10/23/reintroducing-tmux-to-the-osx-clipboard.html "Reintroducing tmux to the OSX Clipboard"
