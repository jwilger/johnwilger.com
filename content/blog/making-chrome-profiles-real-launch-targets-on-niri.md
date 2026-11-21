+++
title = "Making Chrome Profiles Real Launch Targets on Niri"
description = "A small Home Manager setup that turns Chrome profiles into explicit launchers and routes external links by the active Niri workspace."
slug = "making-chrome-profiles-real-launch-targets-on-niri"
date = 2026-07-05

[extra]
cover = "/images/blog/chrome-profile-launching-niri-cover.png"

[taxonomies]
tags = ["linux", "nixos", "home-manager", "niri", "desktop"]
+++

Anyone who keeps separate browser profiles for work and personal use has clicked a link and watched it open in the wrong one. I'd had that problem for a while on my Linux desktop, along with a related one: "open Chrome" had stopped being a complete instruction. Sometimes I meant the personal profile and sometimes the work one. Sometimes I clicked a link while working on a task that already had a browser window beside it, and I wanted the link to open there and not pull me to a Chrome window somewhere else.

Chrome has a profile picker, and I could have tried to configure it into doing what I wanted. I chose a different approach, and it applies well beyond browsers. When one action means different things in different situations, give each meaning its own named command, and leave every piece of state with the program that already owns it. The implementation is a short piece of desktop configuration.

My desktop runs Niri, a window manager that arranges windows on numbered workspaces, and I manage my user configuration declaratively with Home Manager, which builds it from Nix files. The three commands are:

```sh
chrome-personal [URL...]
chrome-work [URL...]
chrome-pick [URL...]
```

A small URL router called `nignite` sits on both of the paths by which a link reaches the browser: the desktop's default handler and clicks in the kitty terminal. The implementation is in my public NixOS configuration, in [`modules/home/desktop/nignite.nix`](https://github.com/jwilger/nixos-config/blob/chrome-profile-launchers/modules/home/desktop/nignite.nix), with the terminal path configured in [`modules/home/kitty.nix`](https://github.com/jwilger/nixos-config/blob/chrome-profile-launchers/modules/home/kitty.nix).

Launcher search now shows the two choices a person would make. Links go through the router. Chrome's own state is left alone.

![Noctalia launcher search showing Chrome Personal and Chrome Work as separate launch targets.](/images/blog/chrome-profile-launching-noctalia.png)

## What was wrong

Three annoyances were tangled together.

Launcher search was ambiguous. Searching for Chrome brought up the generic Google Chrome entry, which says nothing about the decision I usually had to make, personal profile or work profile.

Links didn't reliably land where I expected. On Niri I organize work by workspace, so if workspace 3 already has a browser window for a task, a link clicked on workspace 3 should usually open in that window. Jumping to a Chrome window on another workspace interrupts the task.

Chrome's profile picker is also application state that Chrome changes as it runs. I didn't want my Nix configuration managing Chrome's `Local State` file to influence which profile sat behind the generic launcher. Chrome owns that file, and a declarative configuration that edits it will be fighting the application.

Seen that way, the question to answer was which browser actions I wanted available from the desktop, and configuring Chrome's picker stopped being part of it.

## The profile commands

The profile launchers don't inspect Chrome's state or talk to the window manager. In Home Manager they're `writeShellApplication` derivations, each adding one Chrome flag:

```nix
chromePersonal = pkgs.writeShellApplication {
  name = "chrome-personal";
  runtimeInputs = [ browserPackage ];
  text = ''
    exec ${browserExe} --profile-directory=Default "$@"
  '';
};

chromeWork = pkgs.writeShellApplication {
  name = "chrome-work";
  runtimeInputs = [ browserPackage ];
  text = ''
    exec ${browserExe} --profile-directory="Profile 4" "$@"
  '';
};
```

The profile directory names come from Chrome's local profile metadata. On my machine `Default` is personal and `Profile 4` is work. Those names will differ on any other machine, which is why they belong in my machine's configuration.

The picker is about as small:

```nix
chromePick = pkgs.writeShellApplication {
  name = "chrome-pick";
  runtimeInputs = [
    chromePersonal
    chromeWork
    pkgs.fuzzel
  ];
  text = ''
    choice="$(printf 'Personal\nWork\n' | fuzzel --dmenu --prompt='Chrome profile: ' --lines=2 --width=24)" || exit 0

    case "$choice" in
      Personal)
        exec chrome-personal --new-window "$@"
        ;;
      Work)
        exec chrome-work --new-window "$@"
        ;;
      *)
        exit 0
        ;;
    esac
  '';
};
```

The `--new-window` flag is there for a reason. The picker appears only when the router hasn't found a Chrome window on the current workspace, so choosing a profile should create a window on that workspace. Without the flag, Chrome could reuse a session on another one.

![Fuzzel profile chooser with Personal and Work options.](/images/blog/chrome-profile-launching-fuzzel.png)

## Routing links by workspace

`nignite` is the default handler for URLs, and its policy has five steps:

1. Ask Niri which workspace is focused.
2. Look for a Chrome or Chromium window on that workspace.
3. If one exists, focus it and open the URL as a new tab.
4. If none exists, ask which profile to use.
5. If the chooser is canceled, do nothing.

It finds the focused workspace through Niri's JSON IPC:

```sh
focused_workspace_id="$(
  niri msg -j focused-window 2>/dev/null \
    | jq -er '.workspace_id // empty' 2>/dev/null \
    || niri msg -j workspaces 2>/dev/null \
    | jq -er '.[] | select(.is_focused == true) | .id' 2>/dev/null \
    || true
)"
```

The fallback to `workspaces` covers a case that's easy to miss: a workspace can be focused when no window on it is, and a script that asks only for the focused window gets nothing back.

With a workspace ID in hand, the router searches Niri's window list:

```sh
chrome_window_id="$(
  niri msg -j windows 2>/dev/null \
    | jq -er --argjson workspace_id "$focused_workspace_id" '
        [
          .[]
          | select(.workspace_id == $workspace_id)
          | select(
              ((.app_id // "") | test("chrome|chromium"; "i"))
              or ((.title // "") | test("chrome|chromium"; "i"))
            )
        ][0].id
      ' 2>/dev/null \
    || true
)"
```

If it finds a browser window, it focuses that window before handing Chrome the URL:

```sh
if [ -n "$chrome_window_id" ]; then
  niri msg action focus-window --id "$chrome_window_id" >/dev/null 2>&1 || true

  if [ "$#" -eq 0 ]; then
    exit 0
  fi

  exec ${browserExe} --new-tab "$@"
fi

exec chrome-pick "$@"
```

The router doesn't try to work out whether the current workspace is "personal" or "work." The desktop has no reliable way to know that. It makes a narrower decision: if a browser window already exists on this workspace, reuse it, and otherwise ask me.

## Desktop entries and terminal clicks

The launchers that appear in search are ordinary XDG desktop entries, the files a Linux desktop reads to list applications:

```nix
xdg.desktopEntries = {
  chrome-personal = {
    name = "Chrome Personal";
    exec = "${lib.getExe chromePersonal} %U";
    icon = "google-chrome";
    genericName = "Web Browser";
    noDisplay = false;
    terminal = false;
  };

  chrome-work = {
    name = "Chrome Work";
    exec = "${lib.getExe chromeWork} %U";
    icon = "google-chrome";
    genericName = "Web Browser";
    noDisplay = false;
    terminal = false;
  };
};
```

The generic Chrome entry is still declared, but hidden:

```nix
google-chrome = {
  name = "Google Chrome";
  noDisplay = true;
};
```

The router is hidden too, since I never launch it directly:

```nix
nignite = {
  name = "Chrome Workspace Router";
  exec = "${lib.getExe nignite} %U";
  icon = "google-chrome";
  noDisplay = true;
  terminal = false;
};
```

The MIME defaults, which tell the desktop which application opens which kind of content, point links and HTML at `nignite.desktop`:

```nix
xdg.mimeApps.defaultApplications = {
  "text/html" = "nignite.desktop";
  "x-scheme-handler/about" = "nignite.desktop";
  "x-scheme-handler/http" = "nignite.desktop";
  "x-scheme-handler/https" = "nignite.desktop";
  "x-scheme-handler/unknown" = "nignite.desktop";
};
```

That covers links opened from desktop applications. Clicks in the kitty terminal needed one more step. Kitty's default handler for a clicked URL is `xdg-open`. Even with the MIME defaults pointing at `nignite.desktop`, that extra `xdg-open` and desktop-launch layer could delay the workspace check until after focus had moved. In practice, shift-clicking a URL in a terminal could still reuse Chrome on another workspace when it should have prompted on the terminal's own.

The fix was to have kitty call the router directly:

```nix
programs.kitty.settings = {
  open_url_with = "nignite";
};
```

Terminal clicks now take the same route as every other link, without a launcher layer in front of the workspace check.

Taken together, the arrangement is:

- Noctalia shows `Chrome Personal` and `Chrome Work`.
- External links use `nignite.desktop`.
- Kitty URL clicks call `nignite` directly.
- The generic `Google Chrome` entry doesn't compete in launcher search.

The desktop entries serve as the interface between the shell, the launcher, the MIME database, and the browser commands. Once I treated them that way, the setup became much simpler.

I checked the behavior on the running desktop. Noctalia offered the two profile entries, Fuzzel prompted when the workspace had no Chrome window, kitty's parsed configuration contained `open_url_with nignite`, and links reused an existing Chrome window when one was present on the focused workspace.

## Who owns what

Each program in this arrangement owns one thing. Chrome owns profile state. Home Manager owns the commands, the desktop entries, the MIME defaults, and kitty's URL handler setting. Niri owns workspace information, Fuzzel owns the chooser, and Noctalia owns how the launcher presents its results.

Because of that, Home Manager doesn't edit Chrome's preferences, Chrome doesn't need to understand my workspace policy, and the launcher doesn't have to infer what I meant from one generic browser entry. Three commands with explicit names were enough:

```sh
chrome-personal
chrome-work
nignite https://example.com
```

I can search for the profile I mean, click links as usual, and have them open on the workspace I'm in whenever a browser window is already there.

The same approach works on problems larger than a desktop. When a tool keeps guessing wrong about what someone meant, the usual instinct is to add configuration until it guesses better. Naming the distinct actions and leaving each program's state alone is often less work, and it leaves less to break when one of those programs changes.
