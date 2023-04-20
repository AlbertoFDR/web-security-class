---
title: "Treasure Planet: Web-to-App Communication 🪐"
---

<div class="balloon_l">
  <div class="faceicon"><img src="../icon/otter_says.png" alt="faceicon" ></div>
  <p class="says">
  Let's take Discord as an example. When you are surfing the internet and you click a button to join a discord channel, automatically, your desktop Discord app opens. In other words, a webpage is opening an application of your system. How the **** could be this possible? Is this really secure?
  </p>
</div>

# General mechanisms

Actual browsers have different type of methods to handle the communication between Website to Applications. In this entry I will only focus in some of these mechanisms so, I highly encourage to read this serie of articles [link](https://textslashplain.com/2019/08/28/browser-architecture-web-to-app-communication-overview/) by [ericlaw](http://en.gravatar.com/ericlaw1979). These articles provides a bigger picture and a detailed explainition of some of them. Also, he provides a really good discussion of the security risk inherited by this mechanisms. Following tables provides a summary list.

| **Mechanism**                        | **DesktopOS independent**                                                               | **Type**                     |
| ------------------------------------ | --------------------------------------------------------------------------------------- | ---------------------------- |
| App protocol (websec://)             | Yes                                                                                     | Fire-and-forget              |
| File downloads                       | Yes                                                                                     | Fire-and-forget              |
| File System Access API               | Yes                                                                                     | Read-and-write               |
| Extension (Native Message API)       | Yes (¿Safari?)                                                                          | Bi-directional communication |
| Drag&Drop                            | Yes                                                                                     | Fire-and-forget              |
| System clipboard                     | Yes                                                                                     | Fire-and-forget              |
| Local Web Server                     | Yes                                                                                     | Bi-directional communication |
| DirectInvoke/ClickOnce               | Windows only                                                                            | Fire-and-forget              |
| getInstalledRelatedApps()            | Windows only [(caniuse)](https://caniuse.com/mdn-api_navigator_getinstalledrelatedapps) | Bi-directional communication |
| AppLinks                             | Deprecated                                                                              | Fire-and-forget              |
| Legacy Plugins/Active X architecture | Deprecated                                                                              | Bi-directional communication |

Mobile specific:

| **Mechanism**        | **MobileOS independent** | **Type**        |
| -------------------- | ------------------------ | --------------- |
| Android Intents      | Android                  | Fire-and-forget |
| Android Instant Apps | Android                  | Fire-and-forget |

Browser dev specific:

-   Site-Locked Private APIs
-   Native Url Protocols

In the following sections I will focus in Application protocols and Local Web Servers.

# App protocols

A simple explanation of application protocols would be to define a new 'protocol'. So, instead of using "http" or "file", you define a new special key (e.g., 'websec://'). Defining a new protocol allows to describe how this protocol must be handle by the browser. In technical words, the idea is to define a new [URL scheme](https://www.rfc-editor.org/rfc/rfc1738) that will open a desktop application. As the reader might notice, improperly parsing URI schemes could produce [critical vulnerabilities](https://claroty.com/team82/research/exploiting-url-parsing-confusion). One of the application I found that this mechanisms is used is Microsoft Teams ([msteams://](https://teams.microsoft.com/dl/launcher/launcher.html?url=%2F_%23%2Fl%2Fentity%2Ffe4a8eba-2a31-4737-8e33-e5fae6fee194%2Ftasklist123%3FwebUrl%3Dhttps%3A%2F%2Ftasklist.e8xample.com%2F123%26label%3DTask%2520List%2520123&type=entity&deeplinkId=c2ae6d30-7df4-4499-a283-cb27605499c1&directDl=true&msLaunch=true&enableMobilePage=true&suppressPrompt=true)). In the following code snippet you can see how through the Chromium code comments developers could be also confused of URL parsing.

![allowed](/browser/web.to.app/url_code_comment.png)

<div class="column" title="URI scheme vs URL scheme">
  <div style="overflow: hidden">
    <div style="float: left;">
        Uniform Resource Identifier (URI) scheme identifies a resource using a name, location or both. Uniform Resource Locator (URL) scheme identifies the location of a unique resource. So, URL scheme is a subset of URI schemes defined by the syntax of: [scheme]://[user]:[password]@[host]:[port]/[url-path]. <a href="https://danielmiessler.com/study/difference-between-uri-url/">More info</a>. <a href="https://www.rfc-editor.org/rfc/rfc1738">RFC</a>.
    </div>
  </div>
</div>

### Security Risk

These mechanisms inherits some security risks (e.g., Browser Sandbox Scape). As [ericlaw](http://en.gravatar.com/ericlaw1979) describe in his blog, main security risk are:

_"**Input Sanitization:** App Protocols were not designed with the expectation that the app could be exposed to potentially dangerous data from the web at large."_

_"**Context information:** When the protocol is invoked by the browser, it simply bundles up the URL and passes it on the command line to the target application. The app doesn’t get any information about the caller (e.g. “What browser or app invoked this?“, “What origin invoked this?“, etc) and thus it must make any decisions solely on the basis of the received URL.."_

### Default schemes/protocol

Chromium based browser have a set of defined protocols in the code. It could be that this set of 'default' protocols may vary depending on the browser or the OS. In the case of Brave Browser, they have a small wiki on their github [Wiki: Adding a protocol scheme to Brave](https://github.com/brave/brave-browser/wiki/Adding-a-protocol-scheme-to-Brave). The **standard schemes** defined in [`HTML spec`](https://html.spec.whatwg.org/multipage/system-state.html#normalize-protocol-handler-parameters) are:

-   _http/https:_ Normal scheme used for HTTP/s protocol navigation.
-   _file:_ Allows to retrieve/view local files (e.g., file:///home/websec/Downloads/Syllabus.pdf).
-   _chromium or browser family (e.g., microsoft-edge, brave):_ Used for internal browser pages (e.g., chromium://settings).
-   _mailto:_ It opens your default mail application to send an email to the person that follows the scheme (e.g., mailto:websec@abc.com).
-   _tel:_ If you have your phone connected to your computer, it allows to make calls.
-   All: bitcoin ftp ftps geo im irc ircs magnet mailto matrix mms news nntp openpgp4fpr sftp sip sms smsto ssh tel urn webcal wtai xmpp

<div class="column" title="Disclaimer">
  <div style="overflow: hidden">
    <div style="float: left;">
        As <a src="https://blogs.igalia.com/jfernandez/author/jfernandez/">Javier Fernandez</a>  describes in <a src="https://blogs.igalia.com/jfernandez/2022/08/10/new-custom-handlers-component-for-chrome/">some entries</a> in Igalia's blog, they changed the logic from `/chrome` to `/components`. Following this logic, the classes or code could change in the following years.
    </div>
  </div>
</div>

The following class diagram by [jfernandez](https://blogs.igalia.com/jfernandez/author/jfernandez/) [post](https://blogs.igalia.com/jfernandez/2022/08/10/new-custom-handlers-component-for-chrome/) at Igalia's blog illustrates the multi-process architecture of the Custom Handler logic.

![allowed](/browser/web.to.app/class_protocol.png)
![allowed](/browser/web.to.app/url_security.png)

In order to have deeper look into how schemes are added, [jfernandez](https://blogs.igalia.com/jfernandez/author/jfernandez/) provides us with another class diagram.

![allowed](/browser/web.to.app/url_schemes.svg)
![allowed](/browser/web.to.app/url_util.png)

Despite [jfernandez](https://blogs.igalia.com/jfernandez/author/jfernandez/) provides us with a class diagram, it is really hard to take a look the real code running inside the browser. However, I encourage you to go and see it for yourself [(Chromium code)](https://source.chromium.org/).

### Custom protocol handlers

Chromium based browsers when a custom, not blocked, protocol is used prompt a popup asking if the link should be open or not.

![prompt](/browser/web.to.app/prompt.png)

If you want to **disable** this behavior in chromium-based browsers, you need to go to _Settings_ > _Site settings_ > _Additional permissions_ > _Protocol handlers_. In the case you want to check the behavior of your browser, I found this [website](https://webdbg.com/test/protocol/). In chromium-based browser you can check the allowed/ignored custom protocol in the _Preferences_ file inside the configuration of your browsers. In GNU/Linux, this file is located at _`~/.config/BROWSER/Default/Preferences`_.

![pref](/browser/web.to.app/preferences.png)

#### How to create a custom protocol/scheme handler

As I explained before, if the chromium-based browser doesn't know how to handle a custom protocol, it will use the OS preferences of the user. In my case, this default application is _xdg-open_. In the following lines, I will create a new custom protocol "note://". For Safari check the [link](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app). First, I created a simple script that will print the arguments received from the browser.

```bash
#!/bin/bash

echo -ne "\nArguments: $@ \n"
while true
    do
        sleep 5;
    done
```

After creating the script, we need to configure _'xdg-open'_ to use this script when a specific MimeType is matched. For this task, we need to create a _'.desktop'_ file like the following one:

```
[Desktop Entry]
Name=test
Exec=/path/test.sh %u
GenericName=asdasd
Type=Application
Terminal=true
MimeType=x-scheme-handler/note
```

Finally, we need to install this entry using the command _'xdg-desktop-menu install path/to/file.desktop'_. I used the [previous named website](https://webdbg.com/test/protocol/) to test the protocol and after accepting the prompt, our scripts receives the input:

![custom](/browser/web.to.app/custom_protocol.png)

# Local Web Server

Another mechanisms is to define a local web server. When the Desktop application is running, a local socket is opened waiting for a connection. Websites only have to create a WebSocket to the used port and the communication will take place. This mechanisms is used by Discord, explained more in depth in the following section. In order to find any of this local web server, you may run `netstat -tlpn` in Linux and `netstat -ab` in Windows. This command will print opened ports and the application that is listening. One of the **key protection** used by this method is **_'origin'_**. **Origin Header** indicates the scheme, hostname and port of the website creating the websocket. _Origin_ is a _restricted header_ that could not be change it.

### Case Study: Discord

In this section I will use Discord to take a look how this _'Local Web Server'_ mechanisms is implemented. As I mentioned before, we can see in the following screenshot that Discord Desktop App is listening in a specific port for the connection.

![netstat](/browser/web.to.app/discord_ws3.png)

If we visit an invitation link on Discord website we would see how a WebSocket is created to "ws://127.0.0.1:6463" in which Discord Desktop App is listening.

![devtools](/browser/web.to.app/discord_ws2.png)

In the following screenshot you could see all the messages exchanged between the Discord Website and Discord Desktop App.

![devtools](/browser/web.to.app/discord_wireshark.png)

In order to interact with the websocket created by the Discord Desktop App, I created the following snippet written in python. Notice _origin header_ declaration on the script.

```python
from websocket import create_connection

# Create connection
ws = create_connection("ws://127.0.0.1:6463/?v=1", origin='https://discord.com/'})

# cmd = 'DISPATCH'
print(ws.recv())

# Opens the discord app with the a invitation channel
ws.send('{"cmd":"INVITE_BROWSER","args":{"code":"68x4ADt"},"nonce":"d973cf70-374a-4438-ba02-8929fbb069cf"}')

# Return channel info
print(ws.recv())

ws.close()

```

### Local Web Server Discovery

As the reader may be wondering, a website could create scanner of localhost to check for Local Web Servers. One example of this behavior was found in a [bank](https://www.theregister.com/2018/08/07/halifax_bank_ports_scans/), where the bank scanned computers to try to find any general Remote Access Trojans (RATs). Another example was found in [Ebay](https://nullsweep.com/why-is-this-website-port-scanning-me/), where the same behavior was observed.


# File System Access API (a.k.a. Native File System API)

I recently discovered the [FSA API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API) ([article](https://developer.chrome.com/articles/file-system-access/)), a powerful Web API that enables websites to interact with the file system and edit files. One notable example of this API in action is in Visual Studio, where users can read and modify files seamlessly. With FSA API, it's possible to edit your project folder directly from the browser, making it easy to update your local code from the website. By using this API, users can grant access (accepting the popup) to specific files or folders, giving websites the ability to make local modifications to them. Take a look at this [demo webpage](https://googlechromelabs.github.io/text-editor/). Although it's not a standard API, it has been implemented in browsers like Chromium, Microsoft Edge and Chrome. Partially supported by Opera and Safari.


## References:

-   _Recommended:_ [Article: Web-to-App Communication: App Protocols.](https://textslashplain.com/2019/08/29/web-to-app-communication-app-protocols/)
-   _Recommended:_ [Article: Browser Architecture: Web-to-App Communication Overview.](https://textslashplain.com/2019/08/28/browser-architecture-web-to-app-communication-overview/)
-   _Recommended:_ [Article: Bypassing App Protocol Prompts.](https://textslashplain.com/2020/02/20/bypassing-appprotocol-prompts/)
-   [Article: New Custom Handlers component for Chrome](https://blogs.igalia.com/jfernandez/2022/08/10/new-custom-handlers-component-for-chrome/). **TL;DR: Chromium src**.
-   [Article: Discovering Chrome’s pre-defined Custom Handlers.](https://blogs.igalia.com/jfernandez/2022/11/14/discovering-chromes-pre-defined-custom-handlers/) **TL;DR: Chromium src**.
-   [Exploiting: localghost: Escaping the Browser Sandbox Without 0-Days.](https://parsiya.net/blog/2020-08-13-localghost-escaping-the-browser-sandbox-without-0-days/)
