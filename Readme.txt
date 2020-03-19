================================================
          Project64, by Zilmar and Jabo
            Copyright (c) 1998 - 2001
  The Premiere Nintendo64 emulator for Windows
================================================

-------------------
Standard Disclaimer
-------------------

The N64 is a registered trademark of Nintendo, same goes for other companies mentioned above, or their products.

The authors are not affiliated with any of the companies mentioned, this software may be distributed for free, never sold in any way, as long as the original archive and software included is not modified in any way or distributed with ROM images.

You use this software at your own risk, the authors are not responsible for any loss or damage resulting from the use of this software. If you do not agree with these terms do not use this software, simple.

--------
Overview
--------

Project64 is an emulator that has been in developlment for a couple of years. We are proud to allow other people to use the product that we have made for their enjoyment. Project64 features emulation of the Reality Signal Processor, which was reverse engineered by zilmar. This information has produced an accurate interpreter that has turned in to a recompiler by jabo, setting it apart from some of the emulators in development today. Another feature in Project64 is an accurate and fast Display Processor graphics core for OpenGL and Direct3D, developed by jabo over the last few years.

--------
Features
--------

Internally Project64 features two advanced recompilers, for the R4300i and the RSP respectively, both based off of zilmar's original interpreters. Both the R4300i and RSP interpreters are available as alternatives to the recompilers via settings.

- The R4300i recompiler is written by zilmar. It features dynamic block creation and advanced optimizations due to it's register caching core. It also has self-mod protection schemes   implemented to maximize compatibility and speed.

- The RSP recompiler is written by jabo. This compiler creates dynamic blocks of code, and optimizes the signal processor code through various code analysis techniques. It makes use of MMX and SSE to provide real-time emulation of this powerful co-processor.

Project64 uses high-level emulation for graphics, and low level emulation for audio. Jabo wrote Direct3D and OpenGL plugins for graphics, they have high quality blending and texturing, with several microcodes implemented from Mario64 to Zelda64 between the plugins. High level microcode emulation is optimized using SSE, and 3DNow!, and some parts of texturing have MMX optimizations.

-------------------
System Requirements
-------------------

Windows95 or higher, Pentium III 600Mhz or higher, DirectX 7.0 with a Direct3D compatible Accelerator, at least 16 megs of Video RAM. It may be possible to run with a slower system and if you find it useable on it then enjoy. DirectX 8.0a is strongly recommended as it is one of the latest releases from microsoft.

- Good video hardware: 

Riva TNT, Riva TNT2, GeForce, GeForce 2, GeForce 3, ATI Radeon

- Bad video hardware:

Matrox G200 and G400 - Some blending errors, the G400 looks decent, will not be perfect.
ATI Rage Pro - It doesn't support constants well, it does support multitexturing though.

3Dfx Voodoo Banshee or Voodoo Series- The drivers for Direct3D are not that great, these cards have some limitations and are difficult to program for.

- Other Info:

General information - Some users reported disabling AGP Texturing in Direct3D via various advanced tweaking utilities availabe on the internet help fix lots of graphical glitches, this is probably due to poorly written drivers.

If you have a 3Dfx card, set your desktop to 16bpp, some 3Dfx cards don't do 32bpp Direct3D! Secondary devices (read: voodoo1, voodoo graphics, voodoo 2) are not supported by the graphics plugins included.

---------------
How to Use PJ64
---------------

PJ64 is a very easy emulator to use, open a rom and play a game. Look through the menus for the shortcut keys available, PJ has 11 save state slots for quick use. Most configuration is done through plugins, simplifying the main interface. The ROM browser, an optional component to the user interface, will allow you to browse different directories on your computer. The browser displays useful information that you should know before execution a game, and is quite convenient.

PJ64 features shell integration into windows explorer, allowing you to associate common N64 file extensions with Project64 for execution.

Below is information on some of the plugins included with PJ64. Additional information may be obtained in the documents directory.

-------
Plugins
-------

Below you will find additional information about some of the plugins included with project 64.

As Project64 version 1.40, the OpenGL plugin is discontinued. If you would like to use it download an older version of Project64.

Direct3D:
---------

- Texture type: 32-bit textures are are only used if the texture being downloaded requires that depth of precision. If this option is OFF some form of a 16-bit texture will be used which reduces quality. This option should generally be enabled unless your video card does not support 32-bit textures, or has severe performance penalties for using them.

- Anisotropic Filtering: Really nice filtering, only available on some cards, makes planes at an angle or distance have higher quality rasterization.

- Anti Aliasing - Depending on the implementation and video card, it should result in some kind of "FSAA" on some cards. On some cards it will do nothing either because it isn't supposed to, or the drivers are lying that the card can do it.

- Transforms: The difference to the user between the pipelines really is hard to tell at times, since there isn't much, no matter what lighting is done internally, but transforms can be done either way, the internal one is highly optimized for SSE and a little for 3DNow!. It's also important to mention the internal one works best on cards with hardware clipping.

- Validate Blending: this option is the best choice for people experiencing problems with blending, it will not fix problems. What it will do is manipulate what the requested modes until your video card accepts it or it gives up, generally this helps a great deal, but it's possible it may hurt things as well. This option is a must use especially for people on TNT cards.

- Force filter: the N64 has point filtering, and some games use it, if you hate how it looks just use this option, NOTE: if you turn on anisotropic it will use that instead of bilinear here.

- Display List Culling: some roms use this for bounding box testing, this reduces scene complexity which can lead to decent performance increases in certain games. Because it actually determines if objects will be rendered, there is always the chance it will make things disappear that should not, use at your own risk.

- Frame Buffer Option: this setting is for advanced users only, it may fix graphical glitches in some games (Zelda64, Banjo-Kazooie, and Mario Kart) but is best left on None so you don't loose lots of performance. This option is provided for debugging purposes mostly.

Audio Plugin:
-------------

There are two provided, one written by zilmar which is open-source (see the emulation64 web-site for our plugin spec) and one written by jabo. One of these should work well for you. For more information see the support site, a link is provided on our website.

In Jabo's Plugin the following options are available:

- Audio Sync: This makes the N64 audio thread wait until the PC has finished playing the last batch of audio before allowing it to continue, for obvious reasons this can cause problems in some games in terms of compatibility and sync, but usually works quite well.

- Log: If you check this and close the Config dialog, a Save As dialog will open asking the file name to start dumping audio to, open this dialog again and uncheck it to stop logging.

Input Plugin:
-------------

This plugin uses DirectInput, it has a fully configurable 4-player dialog. It supports lots of different game pads, and allows input from the keyboard at the same time.

Because the N64 has a large amount of buttons, a layout for one game may not be suitable for another. The profile feature solves this problem, it loads and save profiles for quick and easy access to different settings.

The plugin also supports dead zone tweaking. Some gamepads are not the most accurate devices, USB devices usually are the most accurate. This option can be considered a sensitivity control, increased deadzone makes it less sensitive, decreasing it makes it more sensitive to movement. This option is mostly dependent on the connection interface used (USB or gameport) and whether your device has analog stick capabilities, the default is a 25% deadzone.

RSP Plugin:
-----------

High level simulation of audio lists - This option is for users who have downloaded an audio plugin capable of simulating audio lists. A plugin with this capability is not included with Project64, our emulator uses low level RSP emulation to handle audio lists.

High level simulation of display lists - Currently there is no plugin included with project64 capable of rasterizing triangles in low level display lists for a multitude of reasons, however, this option is included for the possibility in the future.

CPU Type: the Recompiler is a great deal faster than the interpreter, however both are included in this option for you to try, compatibility should be optimal with the interpreter.

---------------
Saving in Games
---------------

PJ64 provides instant saves and saves like on the n64. Instant saves seem to work perfectly find in most cases but they are not perfect. It maybe possible to corrupt the n64 save you have with them. Test them out and see they should work with most games but we do not guarantee that they will work.

There is a settings dialog where you may change the plugins you are using, there is also other tabs, most of the options should be self explanatory, rom settings and the defaults are explained later.

Saves are stored in a different directory than the executable, by default it is in a subdirectory called "Saves", you may change this, among other directories, in the Settings dialog.

------------
Rom Settings
------------

You shouldn't need to modify the settings included with PJ64 for specific games, they should be setup for optimal performance in the rom database. However, here is a brief explanation of the settings.

- Default Memory Size: Project64 supports "Expansion Memory", this is a toggle between 8 megs of memory or 4, obviously only select 8 if you know the game requires it so you don't use up memory.

- Default Save Type: Should be left on default, if you know the details about a game's saving method than you can select the appropriate save type, again it's not necessary usually.

- Selfmod Method: this setting has an impact on performance and compatibility. Protected memory is the most compatible, and None is the fastest. The other ones do different things and may result in better performance than Protected memory, it's outside the scope of this document to explain them in greater detail, and they should be setup for you already.

- Max Speed: you can select a sync of 50 or 60 fps here if desired.

- Always use TLB: this is a compiler switch that some roms require, but some do not. Additional performance may be obtained by turning this switch off for roms that do not require it.

- Advanced Linking: This option determines the complexity with which Project64's r4300i compiler will link sections of code together, the advantage is generally more linking more speed, however this also can hurt speed for games that use a heavy amount of dynamic code.

- Large buffer: increases the amount of available memory available to the dynamic recompiler, use this if the game seems to pause when actions occur, this will prevent the compiler from resetting due to being out of memory.

--------------
Known Problems
--------------

Project64 is not perfect, there is some compatibility issues in terms of CPU, Graphics, and Audio that prevents games from functioning properly. See our support web site for a compatibility listing of games that are known to run with Project64, as well as problems that are known already.

Please do not expect games to be perfect, we put a lot of effort into this emulator, but every detail may not meet the guidelines for perfect emulation. If you want to experience games as they were meant to be played purchase a nintendo 64.

-------------------
Contact the Authors
-------------------

All our plugins use the Project64 plugin specifications, see our website for details.

=> Read this file entirely, use the message boards on the website for all feedback on PJ64, we do not have time to help people individually.

- If you don't at least meet the min requirements, don't ask us for help
- Do not ask if your system will work, or if we will support your hardware
- Do not ask us about games, we will not send them to you or tell you where to get them
- Do not ask us when a specific game will work
- Do not ask us when the next version will be out, for betas, or what features it will have
- Do not ask us about plugins we didn't write, contact the proper author
- Do not report problems with using our plugins in other emulators
- Do not email us files without permission
- Do not ask us about things not on pj64.net, like the message board, we have no control

no exceptions, if you want to ask these questions try a messageboard at our website. 
http://www.pj64.net

You can reach us at the following email addresses, if it's feedback on pj64 please think about what you are asking, lots of emails get ignored because you either aren't supposed to email us these questions (read above), or it's answered in this file or through the extensive amount of information available on our support website.

jabo@emulation64.com, zilmar@emulation64.com

You can always find updated contact info on our website.

------------------
Credits and Greets
------------------

We would like to thank the following people for their support and help, in no specific order.

hWnd, Cricket, F|RES, rcp, _Demo_, Phrodide, icepir8, TNSe, gerrit, schibo, Azimer, Lemmy, LaC, Anarko, duddie, Bpoint, StrmnNrmn, slacka, smiff

As well as the people we have forgotten.

[EOF]