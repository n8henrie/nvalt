NB: @n8henrie's fork

Trying to keep nvALT alive by providing a CI-built version.

Please keep in mind:

- this project relies on a *very* old and insecure version of OpenSSL.
- the CI build will *not* work with SimpleNote as is
- to build locally you'll need `nix`

When you try to open the application, you will likely be greeted by a warning along the lines of:

- nvALT can't be opened because it is from an unidentified developer
- nvALT can't be opened because the developer cannot be verified
- nvALT can't be opened because Apple cannot check it for malicious software
- Apple could not verify "nvALT.app" is free of malware that may harm your Mac or compromise your privacy

An application must be signed by an Apple-provided developer certificate to avoid these warnings; these cost $100 / year and I do not have one at this point.

Luckily these warnings can be worked around and should be a one-time-only nuisance.

To open the application:

- right click (or control-click) the app and choose `Open`
- you'll likely have to approve a security warning pop-up

To make this change permanent, after doing the above:

- open `System Settings`
- go to the `Privacy & Security` settings
- scroll down and find the `Open Anyway` button for nvALT

For more information, please review Apple's official guidance on this process: <https://support.apple.com/en-us/102445>

# nvALT 2

A collaboration between Brett Terpstra (ttscoff) and David Halter (ElasticThreads) based on [DivineDominion's](github.com/divineDominion/nv) fork. nvALT adds a few features we'd been looking for (and let me get some coding practice).

![Screenshot](http://img.skitch.com/20110520-k5y4i6i3p8ciftq2dbs7rx64e7.jpg)

## Contents

- [About nvALT](#about-nvalt)
- [What it is](#what-it-is)
- [Additional Features](#additional-features)
- [Customization](#customization)
- [Download](#download)
- [Credits](#credits)

## About nvALT

nvALT is a fork of the original [Notational Velocity][notational] with some additional features and some interface modifications. It is a work in progress. I'm not listing it as a beta, as that would imply that it was on its way to being its own product. It's an experiment, and I hope you enjoy it!

## What it is

Notational Velocity is a way to take notes quickly and effortlessly using just your keyboard. You press a shortcut to bring up the window and just start typing. It will begin searching existing notes, filtering them as you type. You can use &#x2318;-J and &#x2318;-K to move through the list. Enter selects and begins editing. If you're creating a new note, you just type a unique title and press enter to move the cursor into a blank edit area. Check out the descriptions at [notational.net][notational] for a more eloquent synopsis.

## Additional Features

nvALT adds:

* Widescreen (horizontal) layout option
* Shortcut (&#x2318;-&#x2325;-N) to collapse the notes panel
* Markdown, Textile and MultiMarkdown support with Preview window
* HTML source code tab in the Preview window for fast copy/paste to blogs, etc.
* Unique interface design changes
* Fixes for a couple of bugs/annoyances
* Customizable HTML and CSS files for the Preview window
    * You can use Javascript in the templates to do a few neat tricks

## Customization

Select "Open Custom CSS Folder" within the Preview menu, and the application's supprt folder will open. You will find two files:` template.html` and `custom.css`. If you're handy with HTML and CSS, feel free to customize these in whatever way you like. You can add Javascript as well, but you'll need to load external scripts from a url or using a full file:// path. If worst comes to worst, you can just delete or rename your customizations and the default files will be put back in place automatically when you select the menu item again.

## Download

More info and a download for the compiled binary can be found at [brettterpstra.com/projects/nvalt](http://brettterpstra.com/projects/nvalt/)

## Credits

* [Notational Velocity][notational]
* Code: The original Notational Velocity [source code][original source] by Zachary Schneirov
* Code: DivineDominion's [MultiMarkdown fork][DivineDominion]
* Inspiration: [Elastic Threads' version](http://elasticthreads.tumblr.com/nv) of Notational Velocity

[notational]: http://notational.net/
[original source]: https://github.com/scrod/nv
[DivineDominion]: https://github.com/DivineDominion/nv

