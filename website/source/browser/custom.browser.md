---
title: How to build your custom browser on top of chromium
---

<div class="balloon_l">
  <div class="faceicon"><img src="../icon/otter_says.png" alt="faceicon" ></div>
  <p class="says">
  In this entry, I will explain how you can build your own custom browser using Chromium project. My goal is not to create a browser from scratch; If that's what you want to do, you should check<a href="https://serenityos.org/" style="display:inline"> SerenityOS project</a> (<a href="https://awesomekling.github.io/Ladybird-a-new-cross-platform-browser-project/">link</a>). The purpose of this research was to learn more about how current browsers (e.g., Brave, Opera, Chrome, Edge) are constructed using the Chromium project as a base.
  </p>
</div>

# What's Chromium

According to their [website](https://www.chromium.org/Home/), _"Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web"_. Most of the popular browsers people use daily (Google Chrome, Brave, Edge, Opera...) are based on this project.

<div class="column" title="Chromium vs Google Chrome">
  <div style="overflow: hidden">
    <div style="float: left;">
        If you are wondering why I said Google Chrome is based on Chromium, YES <b> Chromium is not the same as Chrome</b>. Take a look <a href="https://chromium.googlesource.com/chromium/src.git/+/HEAD/docs/chromium_browser_vs_google_chrome.md">(link)</a>.
    </div>
  </div>
</div>

Chromium project also includes other open-source projects (OSS) like the following ones:

-   _ChromiumOS:_ Root repo of many for the Linux and web-based OS
-   _V8:_ JavaScript and WASM runtime. (NodeJS uses this)
-   _Skia:_ Low level graphics
-   _Angle:_ 3D graphics
-   _Devtools-frontend:_ Browser developer tools UI
-   _WebRTC:_ Real time audio/video library used by many browsers.
-   ...

For a complete list could be found at the [link](https://chromium.googlesource.com/). Some of them are used as dependencies in the Chromium browser.

# Source code

The important folders we should be aware of are ([link](https://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code/)):

-   _chrome:_ Application layer of Google Chrome.
-   _content:_ Multi-process sandboxed implementation of the web platform ([link](https://chromium.googlesource.com/chromium/src/+/HEAD/content/README.md)).
-   _third_party/blink/:_ The web engine responsible for turning HTML, CSS and scripts into paint commands and other state changes. Web engine forked from WebKit.

Some years ago they separated _chrome_ and _content_ folder in order to have a modularized code. This structure allows to be easier to reutilize the code in other projects.

## How to search on the code

Before we download the code, let me explain how to navigate this large codebase. Chromium provides a [website](https://source.chromium.org/chromium) where we can search for specific parts of the code. Depending on your goal, this task of finding and understanding the code could be really complex. Chromium website provides code paths for common operations ([link](https://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code/#code-paths-for-common-operations)). Let's try a dumb example in which we want to change the menu that appears when we do right click in the webpage.

![right-click-menu](/browser/custom.browser/right_click_menu.png)

For this task, I will use the [search website](https://source.chromium.org/chromium) I mentioned earlier. In this case, I will search for the text _"Send to your devices"_ because it will be easier.

![search](/browser/custom.browser/search_text.png)

As we might expect, they use _i18n_ (internalization) for providing multi-language support. So, let's search using the id _"IDS_CONTEXT_MENU_SEND_TAB_TO_SELF"_.

![search](/browser/custom.browser/search_id.png)

After searching through the Context Menu code, I finally found the code that is responsible for rendering the menu:

![search](/browser/custom.browser/search_code.png)

# Build our custom browser

## Download and build

In this section I will download and build the project. For this task, it as simple as follow the following [wiki](https://github.com/chromium/chromium/blob/main/docs/linux/build_instructions.md). Compiling time may vary depending on your setup but it can take a couple of hours or even longer. In the meantime, you could read other articles of this website tackling other topics ;)

## Modifications

Once we make the changes, the build of the binary will be faster because it will only recompile the changes. If you want to learn how to make some stupid changes to the source code, take a look the following resources:

-   _[Video](https://www.youtube.com/watch?v=p34rr443eE0)_ tutorial: The first resource is a video tutorial that shows you how to change the name and logo of the browser.
-   _[Beginners guide to contribute](https://meowni.ca/posts/chromium-101/)_ article : The second resource is a tutorial that shows you how to add a new button to the avatar menu and contribute to the project.

![websecbrowser](/browser/custom.browser/websecbrowser.png)

# Brave Example

In the second part of this entry, we will explain how Brave is built on top of Chromium project. Brave provides some [_wikis_](https://github.com/brave/brave-browser/wiki) on their github project explaining how it works more in depth ([Brave Patching](https://github.com/brave/brave-browser/wiki/Patching-Chromium)) or the [_deviations_](<https://github.com/brave/brave-browser/wiki/Deviations-from-Chromium-(features-we-disable-or-remove)>) from Chromium. In this section I just provide a few examples of this patching process.

## Brave Startup Patching

Brave adds command line switches before launching the browser as Chromium does. This patch includes code of Chromium allowing to call the original function after a few command line modifications.

```C++
// File: brave-core/chromium_src/chrome/app/chrome_main_delegate.cc
// ...

#define BasicStartupComplete BasicStartupComplete_ChromiumImpl
#include "src/chrome/app/chrome_main_delegate.cc"
#undef BasicStartupComplete

// ...


absl::optional<int> ChromeMainDelegate::BasicStartupComplete() {
    // After some command line switches
    // ...

    // The code returns to the original code of Chromium
    return ChromeMainDelegate::BasicStartupComplete_ChromiumImpl();
}

```

## Pinned CA certificates

On _deviations_ they claimed that they have replaced the list of hostnames with pinned CA certificates with a Brave-specific one. In this case, they used a similar approach. When the function is called, they just change the arguments to Brave ones.

```C++
// File: brave-core/chromium_src/net/tools/transport_security_state_generator/input_file_parsers.cc
// ...

#define ParseJSON ParseJSON_ChromiumImpl
#define ParseCertificatesFile ParseCertificatesFile_ChromiumImpl
#include "src/net/tools/transport_security_state_generator/input_file_parsers.cc"
#undef ParseCertificatesFile
#undef ParseJSON

// ...

bool ParseCertificatesFile(base::StringPiece certs_input,
                           Pinsets* pinsets,
                           base::Time* timestamp) {

    base::StringPiece brave_certs = R"(RAW CERTIFICATES)"

    return ParseCertificatesFile_ChromiumImpl(brave_certs, pinsets, timestamp);
}

//...


bool ParseJSON(base::StringPiece json,
               TransportSecurityStateEntries* entries,
               Pinsets* pinsets) {
    // Other stuff..
    base::StringPiece brave_json = R"(RAW JSON)"

    return ParseJSON_ChromiumImpl(brave_json, entries, pinsets);
}

```

# Final words

If you want to learn more, just be _brave_ (ba dum tsss!) and take a look the real code of both projects. You could start searching for a specific behavior or checking the [examples](https://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code/#code-paths-for-common-operations) provided by developers. Also, I recommend you to start reading some of the design documents.

If you have any recommendation/mistake/feedback, feel free to reach me [twitter](https://twitter.com/alberto_fdr) :)

## References:

-   [Chromium project website](https://www.chromium.org/chromium-projects/)
-   _Recommended:_ [Chromium Overview Video](https://www.youtube.com/watch?v=u11lbUWEeYI)
-   _Recommended:_ [Chrome Comic Book](https://www.google.com/googlebooks/chrome/)
