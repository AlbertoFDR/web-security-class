---
title: Everything you ever wanted to know about Web Tracking (but were afraid to ask)
---

<div class="balloon_l">
  <div class="faceicon"><img src="../icon/otter_says.png" alt="faceicon" ></div>
  <p class="says">
  <i>Has it ever happened to you that your mom searched for something on your computer, such as Christmas decorations or food, and afterwards, you noticed ads for related products appearing on every page you visited?</i>. 
  <b>In this entry</b>, I will explain <b>how web tracking works</b> in the real world, with the goal of providing readers an <b>initial</b> idea of the practice. To achieve this, I will introduce techniques such as <b>device fingerprinting</b>, as well as existing mitigations.
  </p>
</div>

# Table of contents
1. [Introduction](#Introduction)
2. [How a webpage can identify a User?](#How-a-webpage-can-identify-a-User)
      -  [User Identification Mechanisms](#User-Identification-Mechanisms-aka-Device-Identification)
      -  [Stateful techniques](#Stateful-Techniques)

          1.  [Cookies](#Cookies)
          2.  [Cache: ETags metadata](#Cache-Metadata-ETags)
          3.  [Cache: PNG image](#Cache-PNG-image)
          4.  [HSTS for tracking](#HSTS-for-tracking)
          5.  [Cache: Favicon](#Cache-Favicon)
          6.  [Other script-accessible storage mechanisms](#Other-script-accessible-storage-mechanisms)
          7.  [Putting the Puzzle Together: Evercookie project](#Putting-the-Puzzle-Together-Evercookie-project)

      -  [Stateless techniques (Browser Fingerprinting)](#Stateless-Techniques-aka-Device-fingerprinting)
          
          1.  [XS Leask for Web Tracking](#XS-Leaks-for-Web-Tracking)
          2.  [Other Stateless Method](#Other-stateless-methods)

3. [Web Tracking in-the-Wild](#Web-Tracking-in-the-Wild)

      -  [document.referer](#document-referer)
      -  [Bounce Tracking](#bounce-tracking)
      -  [Sharing Information](#Trackers’-Gossip-Sharing-Information)
      -  [Invisible Pixels](#Invisible-Pixels)
      -  [Identifier as a URL parameter](#Identifier-as-a-URL-parameter)
      -  [Identifying Information](#Identifying-Information)
      

4. [Mitigations](#Mitigations)
      -  [Generic Solutions](#Generic-solutions)
      -  [Specific Defenses](#Specific-defenses)
          1.  [Storage Mitigation](#Storage-mitigation)
          2.  [HSTS mitigation](#HSTS-mitigation)
          3.  [Referer mitigation](#Referer-mitigation)
          4.  [Bounce Tracking mitigation](#Bounce-Tracking-mitigation)
          5.  [Query Parameters mitigation](#Query-Parameters-mitigation)
          6.  [Hardware-based attributes mitigation](#Hardware-based-attributes-mitigation)
5. [Historical Notes](#Historical-Notes)


# Introduction 
### What is Web Tracking? 

To introduce the topic, I will use an image to explain the idea. Suppose you visit _'https://foo.com/'_, which imports an iframe or a simple image from _'https://tracker.com/'_. Later, you visit _'https://bar.com/'_, which also imports the same resource. At this point, the third-party agent _'tracker.com'_ has tracked your activity across multiple websites (using cookies). __Warning:__ Third-party cookies have been mitigated in different ways, which we will explore in more detail later.

![tracking-example](/advanced/web.tracking/sample_web_tracking.svg)

# How a webpage can identify a User? 

In the previous case, the user was tracked using cookies, which is one form of user identification. The cookie was the first mechanism for identifying a user in the stateless HTTP protocol, introduced in 1994 by Netscape ([first RFC](https://www.rfc-editor.org/rfc/rfc2109))([RFC](https://www.rfc-editor.org/rfc/rfc6265.html))([Netscape Proposal](https://web.archive.org/web/20020803110822/wp.netscape.com/newsref/std/cookie_spec.html)). Cookies were introduced for cases like online shopping in which the server needs to identify you in order to know your cart of products.

<div class="column" title="RFC">
  <div style="overflow: hidden">
    <div style="float: left;">
      <i>
        "A Request for Comments (RFC) is a publication in a series from the principal technical development and standards-setting bodies for the Internet, most prominently the Internet Engineering Task Force (IETF). An RFC is authored by individuals or groups of engineers and computer scientists in the form of a memorandum describing methods, behaviors, research, or innovations applicable to the working of the Internet and Internet-connected systems."</i> 
        <a href='https://en.wikipedia.org/wiki/Request_for_Comments'>(Wikipedia)</a>.
    </div>
  </div>
</div>

### User Identification Mechanisms (aka Device Identification)

The mechanisms to uniquely identify a user are usually split into two main groups:

- *Stateful:* In these mechanisms the information is stored in the client's computer. Some examples of this group are: cookies, ETags, localStorage or sessionStorage. 
- *Stateless:* Mechanisms that don't need to store any kind of information in user devices. These mechanism rely on a set of software/hardware feature that the computer has. 

### Stateful Techniques

#### Cookies 

<div class="column" title="Cookie Definition">
  <div style="overflow: hidden">
    <div style="float: left;">
      <i>
        "Some cookies are necessary for sites to be able to work properly. For example, when you log into a website, the site stores a cookie, unique to you, so that it knows who you are as you navigate around the site. Without cookies, you wouldn’t be able to stay logged in as you used a site."</i>
        <a href='https://brave.com/glossary/cookie/'>by Brave</a>.
    </div>
  </div>
</div>

The simplest definition of cookies is that they are an identifier generated by the server, which enables the server to recognize the user among other users. The RFC documents linked previously contain the standard formalization of cookies ([RFC 1997](https://www.rfc-editor.org/rfc/rfc2109))([RFC 2011](https://www.rfc-editor.org/rfc/rfc6265.html)). The term 'User-Agent' is used in the RFC to refer to the browser. For further explanation of [Cookies](/web.today/cookies).

The nature of cookies is to enable tracking. This tracking could be harmless, such as remembering your session on your bank's website or saving items in your shopping cart. However, in other cases such as third-party cookies, this tracking extends to following you across different web pages, which compromises the user's privacy. To use a metaphor, it is not the same for a shop owner to check if you are trying to steal in their shop, as it is to follow you in your daily life.


#### Cache Metadata: ETags 

The ETag (entity tag) header is an HTTP response header that is used to identify a specific version of a resource on the web server. It is typically used for cache validation, allowing web clients to check whether the version of a resource they have in their cache is still current. The main goal of this cache technique is to reduce network traffic and improve the page loading time. In the following draw you can see a simple explanation of how 'ETag' header works.

![etags](/advanced/web.tracking/etags.svg)

The ETag header is primarily used for caching purposes. However, it could be used for tracking by assigning different ETag keys to each user ([demo](https://lucb1e.com/randomprojects/cookielesscookies/)). In this scenario, when the user visits the website for the second time, the server would receive the ETag containing the user's ID ([link](https://levelup.gitconnected.com/no-cookies-no-problem-using-etags-for-user-tracking-3e745544176b))([year 2000 report](https://seclists.org/bugtraq/2000/Mar/331))([paper](https://ptolemy.berkeley.edu/projects/truststc/education/reu/11/Posters/AyensonMWambachDpaper.pdf)). This idea could also be applied for the tag *Last-Modified* header (In browsers this data could be required to be a date).

#### Cache: PNG image

By exploiting the cache, it is possible to track a user's online activity. For instance, a webpage may embed a PNG image that contains the user's ID within its content. To retrieve this image/ID for future requests, the webpage specifies that the image should be cached. As a result, subsequent requests made by the user will retrieve the cached version of the image, thus restoring the ID.

#### HSTS for tracking

HTTP Strict Transport Security (HSTS) is a web security mechanism that allows websites to enforce secure communication (HTTPS) between a client and a server. The mechanism involves implementing a header (`strict-transport-security`) that instructs the user to establish a secure HTTPS connection instead of an insecure one. This behavior can be leveraged to store a user identifier securely. Frank provides an excellent explanation ([blog](https://frank.sauerburger.io/2019/01/30/tls-tracking.html))([demo webpage](http://tls-tracking.sauerburger.com/)) of how to exploit this behavior to generate a user identifier, despite the fact that it was not the intended purpose of HSTS. The following draw provides an illustration of the aforementioned idea:

![hsts](/advanced/web.tracking/hsts.svg)

#### Cache: Favicon

Favicons images are another technique that can be used to fingerprint a user, taking advantage of the cache. The idea is a little bit similar to HSTS for tracking explained before. In this case I recommend directly the [paper](https://www.cs.uic.edu/~polakis/papers/solomos-ndss21.pdf) ([code](https://github.com/jonasstrehle/supercookie)).

#### Other script-accessible storage mechanisms

In addition to cookies, modern web browsers offer various other script-accessible storage mechanisms for web applications to store data on the client-side. These storage options provide web developers with more flexibility in managing user data and preferences, and can help improve web performance and user experience. Some of the most commonly used storage mechanisms include localStorage, sessionStorage, JavaScript Objects (e.g., window.name or navigator), IndexedDB and WebSQL. 

#### Putting the Puzzle Together: Evercookie project

<div class="column" title="Evercookie Definition">
  <div style="overflow: hidden">
    <div style="float: left;">
      <i>
      "evercookie is a javascript API available that produces extremely persistent cookies in a browser. Its goal is to identify a client even after they've removed standard cookies, Flash cookies (Local Shared Objects or LSOs), and others. evercookie accomplishes this by storing the cookie data in several types of storage mechanisms that are available on the local browser. Additionally, if evercookie has found the user has removed any of the types of cookies in question, it recreates them using each mechanism available.</i> <a href='https://samy.pl/evercookie/'>Evercookie Webpage</a>.
    </div>
  </div>
</div>


Evercookie ([code](https://github.com/samyk/evercookie)) ([webpage](https://samy.pl/evercookie/)) is a project that utilizes a variety of techniques to persistently store user identifiers, and will attempt to recreate them if they are deleted from any of the storage methods. These techniques are: Standard Cookies, Flash Local Shared Objects (Deprecated), Silverlight Isolated Storage (Deprecated), CSS History Knocking (Deprecated), ETags, Web Cache, HSTS, window.name, userData Storage (Deprecated), sessionStorage, localStorage, Web SQL, PNG image, IndexedDB and Java Applet techniques (Deprecated).



### Stateless Techniques (aka Device fingerprinting)

Device fingerprinting refers to the ability to identify a device based on its unique software or hardware characteristics. The objective of these methods is to obtain as many features as possible in order to generate a more unique identifier. In the following table, I expose some stateless methods:

| **Mechanism**                        | **Origin**                                                               | **Type**                     |
| ------------------------------------ | --------------------------------------------------------------------------------------- | ---------------------------- |
| User-Agent             | HTTP Header                                                                                     | Attribute-based             |
| Accept-Language             | HTTP Header                                                                                     | Attribute-based             |
| screen resolution            | JavaScript API                                                                                     | Hardware-based             |
| Canvas, WebGL             | JavaScript API                                                                                     | Hardware-based             |
| Mobile Sensors             | JavaScript API                                                                                     | Hardware-based             |
| ...             | ...                                                                                     | ...            |


If you want to check the code snippet for some of these methods, you can check out the well-known library ['fingerprintjs'](https://github.com/fingerprintjs/fingerprintjs).


###### XS Leaks for Web Tracking

<div class="column" title="What is XS Leaks?">
  <div style="overflow: hidden">
    <div style="float: left;">
      <i>
      "Cross-site leaks (aka XS-Leaks, XSLeaks) are a class of vulnerabilities derived from side-channels (<a href='https://owasp.org/www-pdf-archive/Side_Channel_Vulnerabilities.pdf'>link</a>) built into the web platform. They take advantage of the web’s core principle of composability, which allows websites to interact with each other, and abuse legitimate mechanisms to infer information about the user." 
      </i>
      <a href='https://xsleaks.dev/'>XS-Leaks Website</a>.
    </div>
  </div>
</div>


XS Leaks can also be used to fingerprint a user. For instance, suppose the user has previously visited "https://foo.com/". In this case, there are two straightforward examples. First example: if a new webpage contains a link to "https://foo.com/", the link will appear in a different color because the user has already visited it ([blog](https://blog.jeremiahgrossman.com/2006/08/i-know-where-youve-been.html)). Second example: if the new webpage imports an iframe of the "https://foo.com/" webpage and then loads an image that can be displayed in the iframe, the image's loading time will vary depending on whether it has successfully loaded inside the iframe. This difference in loading time can be used to fingerprint the user. This second example was patched some years ago addind the key of the top-level frame for the cache key. Another simple example of XSLeaks for fingerprinting is the Performance API. This API implementation allowed for very precise measurement of how long a computer takes to complete an operation, which could be used to differentiate between devices and fingerprint them. However, this technique was patched by reducing the precision of the API. I suggest referring to the web for further information on this topic ([XS Leaks Website](https://xsleaks.dev/)).

###### Other stateless methods

Other examples of stateless methods that are less commonly found in the wild have been discovered. One of them is a study of fingerprinting a user by their **typing cadence**, which checks the speed of a person typing their credentials in order to create a pattern ([link](https://arstechnica.com/tech-policy/2010/02/firm-uses-typing-cadence-to-finger-unauthorized-users/)). Another example of such a method is **scanning localhost ports using websockets** in order to check services listening in any port (e.g., Discord). If you want to understand more this last technique I recommend a previous article in this web ([link](/browser/web.to.app)). Similar to the websockets technique, in which the webpage could check some common desktop applications, there is another technique called 'scheme flooding' that checks custom protocol (e.g., msteams://, skype://, spotify://...). The article for this technique is published in the following page ([link](https://fingerprint.com/blog/external-protocol-flooding/)).

# Web Tracking in-the-Wild

As the reader may notice, cookies can be used to track a user across different websites ([research paper](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6234427)). The first web tracker was cookie-based and was discovered in 1996 in <i>microsoft.com</i> from <i>digital.net</i>. This tracker was found by an 'archaeological' study conducted by Lerner et al. ([link](https://www.usenix.org/system/files/conference/usenixsecurity16/sec16_paper_lerner.pdf)), who used the Wayback Machine ([Archive project](https://archive.org/)). For this term, I recommend the following research article by Franziska Roesner as a suggested reading ([link](https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final17.pdf)) which introduces the topic very well. Let's take one of the previous examples to illustrate the most basic tracking behavior:

![cookie](/advanced/web.tracking/cookie-tracking.svg)

In the figure, the third-party agent (<i>bar.com</i>) will know the different webpages Groot and Baby Yoda have visited by embedding an image. This technique also applies to other tags such as \<iframe\>. 


### document.referer 

The "document referer" is an HTTP header that indicates the webpage from which the user came from. As shown in the following illustration, this header can be problematic when it discloses not only the domain from which the user came from, but also the entire URL including its parameters (e.g., cookie as param or a path that you need to be logged). Similar to the previous one, browsers implement constrains for this header.

![google](/advanced/web.tracking/document-referer.svg)

### Bounce Tracking (coming soon...)

### Trackers' Gossip: Sharing Information

In order to construct a more comprehensive user profile, third-party domains must combine the profiles they have gathered from various websites. Cookie syncing is one of the most well-known methods for accomplishing this. I highly recommend the paper of Nataliia Bielova in this topic ([link](https://arxiv.org/pdf/1812.01514.pdf)). In the following picture from Nataliia's paper you can see a basic example of one domain (A.com) sharing his cookie with another domain, so in that case the second domain (B.com) will know that for the site A.com the user has the cookie id=1234.

![syncing](/advanced/web.tracking/cookie-syncing.png)

In the following subsections I will talk about some of these techniques.

#### Invisible Pixels

Invisible pixels are empty elements used for tracking or for sharing information among trackers. One example would be an empty image or an image of 1x1 size.

![invisible-pixels](/advanced/web.tracking/invisible-pixels.svg)

#### Identifier as a URL parameter
A technique that has been observed to circumvent mitigations meant to block third-party cookies (explained later) involves adding the cookie or a identifier as a parameter within the URL. It's worth noting that this technique isn't solely utilized for tracking purposes, as it can also be used for login functionalities. To provide a clearer understanding of this technique, here's a simplified representation of the Google login process as an example.

![google](/advanced/web.tracking/google-login.svg)

It's important to note that this technique has also been addressed by certain browser mitigations, such as parameter blacklisting, which we'll discuss in more detail shortly.

#### Identifying Information

In this entry, I've covered numerous techniques that don't require any personal information from the user. However, what if you are logged with your email address?"

![identity](/advanced/web.tracking/identity-information.svg)

This technique takes advantage of your 'stable' information like the email address. [Asuman Senol](https://www.asumansenol.com/) et. al. ([conference](https://www.usenix.org/conference/usenixsecurity22/presentation/senol)) presented a study demonstrating that form information (e.g., email adress) can be sent without clicking the submission button.

# Mitigations

Compatibility with the web ecosystem is often a significant concern in the deployment of mitigations for web security and privacy issues. In other words, it could happen that the deployment of a mitigation can break your bank login. In such a scenario, the user may adopt one of two approaches. The first option is to attempt logging into their bank account using a different browser vendor. The second option is to disable any mitigation measures implemented by the browser. This is one of mainly issues when a mitigation is applied in the web ecosystem.


## Generic solutions

There is no universal solution for all types of web tracking. The DoNotTrack header was introduced in 2009 as a means for users to indicate their preference for being tracked. However, this header has since been deprecated and, in some cases, has been repurposed as an additional feature for device identification. 

Disabling JavaScript by default is another potential solution to limit web tracking, although it may render your daily internet use impossible. If you also disable cookies and cache, it could significantly reduce your chances of being tracked. To reduce the entropy of device fingerprinting and the fingerprinting surface, vendors have attempted to standardize most of the browser features. This means that if two devices return the same values, it would be difficult to determine which of them visited a webpage. For instance, features like the User-Agent header, browser languages, fonts, etc. are commonly standardized. The World Wide Web Consortium (w3c) provides an article for general mitigation of browser fingerprinting in Web Specifications ([link](https://www.w3.org/TR/fingerprinting-guidance/)). Although not a foolproof approach ([paper](https://www.kapravelos.com/publications/ephemeralstorage-www22.pdf), [paper2](https://www.kapravelos.com/publications/pg-sigs-sp20.pdf), [paper3](https://dl.acm.org/doi/pdf/10.1145/3392144)...), one potential remedy is to utilize blacklisting or heuristics to identify tracking components within the webpage. This technique is very common among extensions, such as ad and tracking blocking extensions.


<div class="column" title="Common Fingerprint">
  <div style="overflow: hidden">
    <div style="float: left;">
      <i>"...the best way to mitigate against browser tracking is to implement a fingerprint for your browser that all users of your browser will share. The larger your user base the more rewarding this policy becomes. Even with a relatively small userbase this approach is still useful as long as you can close off as many sources of client entropy as possible. A browser with a small userbase is inherently more vulnerable to tracking if it leaks entropy than a browser with a large userbase suffering from a similar problem."</i> 
      <a href='https://trac.webkit.org/wiki/Fingerprinting'>(WebKit)</a>.
    </div>
  </div>
</div>


## Specific defenses

### Storage mitigation

A solution to cookie tracking that is being applied in some browsers is the limitation/blocking of third-party storage (e.g., Cookies, localStorage...). This mitigation applies not only cookies but also DOM Storage (localStorage, sessionStorage and IndexedDB), Cache (HTTP, image, favicon, HSTS...), Broadcast Channel and Shared Workers. In the following image the reader can see the two different mitigation in this kind. The example shows cookies for simplifying the draw.

![cookie-state](/advanced/web.tracking/cookie-state.svg)
  
`State 0` means when the browser/User-Agent has no protection for storage. In that case, the User Identifier (UID) saved by the 3-party will remain for each of the visited page (if included) and would allow to track the user. The The purpose of deploying `Mitigation 1` as an interim measure was to prevent all web pages that use any type of storage methods (cookie, localStorage...) from being disrupted. In the case of Brave, this solution was called [_Ephemeral Storage_](https://brave.com/privacy-updates/7-ephemeral-storage/). In the case of Firefox is called [_State Partitioning_](https://hacks.mozilla.org/2021/02/introducing-state-partitioning/). In simple words, the solution is basically to add the Top-Level-Frame as a key in the moment of the storage, so if this third party is embedded in another (top-level-frame) webpage it would have an empty storage and if returns to the key (top-level-frame, iframe) it would have the previous storage. The final perfect mitigation is basically blocking any type of storage mechanisms of 3-party. 


To gain insight into the mitigation and minor performance decrease of HTTP Cache, I suggest referring to this concise article ([link](https://developer.chrome.com/blog/http-cache-partitioning/#what_is_the_impact_of_this_behavioral_change)). There are still some cases which are not partitioned ([link](https://privacytests.org/)/[Brave Article](https://brave.com/privacy-updates/14-partitioning-network-state/)) and also there are some methods to 'bypass' or get access to the 1-party context([Storage Access API](https://developer.mozilla.org/en-US/docs/Web/API/Storage_Access_API)).

### HSTS mitigation

In certain browsers, the previous mitigation explained would impact the HSTS cache. Since the previous solution was not completely effective in mitigating this attack, so different solutions have applied. In the case of [webkit](https://webkit.org/blog/8146/protecting-against-hsts-abuse/) they implement some techniques to limit this attack, such as, limiting HSTS State to the Hostname or eTLD+1. For Brave, they applied a solution in which the HSTS Cache is removed after the webpage is closed [link](https://github.com/brave/brave-browser/issues/18830). 



### Referer mitigation

The [referer-policy HTTP response header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy) is used to control how much information is included in the Referer header when a user clicks on a link or visits a page. In order to mitigate the referer, one can reduce the header to only include the domain, particularly when it is a cross-origin request (removing path and parameters).

[Brave Mitigation](https://github.com/brave/brave-browser/issues/13464) ([code](https://github.com/brave/brave-core/blob/master/browser/net/brave_site_hacks_network_delegate_helper.cc)/[code2](https://github.com/brave/brave-core/blob/master/components/brave_shields/browser/brave_shields_util.cc)): They use `strict-origin-when-cross-origin` value of the `referrer policy` as default.
[Webkit](https://webkit.org/blog/8311/intelligent-tracking-prevention-2-0/): `referrer` header "is downgraded to just the page’s origin for third party requests to domains that have been classified as possible trackers by ITP and have not received user interaction.".


### Bounce Tracking mitigation (coming soon...)


### Query Parameters mitigation
As previously stated, using URL request parameters is one way to exchange information between pages. To address this issue, an extended approach is to create a blacklist of commonly used tracking parameters in the URL. Some of these parameters are included in the webpage [PrivacyTests](https://privacytests.org/). In the following snippet code of brave browser ([Github](https://github.com/brave/brave-core/blob/master/browser/net/brave_query_filter.cc)), some tracking parameters that are removed are shown: 

![brave-query-mitigation](/advanced/web.tracking/query-parameter-brave-mit.png)

An important challenge in addressing this privacy concern is the difficulty in determining whether a parameter is serving as an identifier, a timestamp, or another undefined goal. Audrey et. al. [[paper](https://dl.acm.org/doi/abs/10.1145/3517745.3561415)] presented a contribution trying to identify this User Identifiers (UID) in parameters. 
<div class="column" title="Incognito Mode">
  <div style="overflow: hidden">
    <div style="float: left;">
    "Many federated logins send authentication tokens in URLs or through the postMessage API, both of which work fine under ITP 2.0. However, some federated logins use popups and then rely on third-party cookie access once the user is back on the opener page. Some instances of this latter category stopped working under ITP 2.0 since domains with tracking abilities are permanently partitioned". <a href="https://webkit.org/blog/8311/intelligent-tracking-prevention-2-0/"> Webkit ITP 2.0 article.</a>
    </div>
  </div>
</div>

### Hardware-based attributes mitigation

In the context of hardware-based fingerprinting, one proposed solution is **randomization**. Essentially, this involves WebAPIs (such as canvas) that are typically used for fingerprinting returning a random value each time a page is visited, or when a user closes and reopens the browser. The Brave Browser also adopts a similar strategy known as "farbling", where the API's typical output is deliberately randomized with insignificant variations that would go unnoticed by human users. These “farbled” values are deterministically generated using a per-session, per-eTLD+1 seed2 so that a site will get the exact same value each time it tries to fingerprint within the same session, but that different sites will get different values, and the same site will get different values on the next session ([blog](https://brave.com/privacy-updates/4-fingerprinting-defenses-2.0/)). In some cases this techniques are really difficult to deploy ([issue](https://github.com/w3c/deviceorientation/issues/85)).

In other fingerprinting techniques, such as performance fingerprinting, a mitigation that has been implemented involves **reducing the precision of the WebAPIs** within the Performance category. For example, instead of returning values in microseconds, the precision has been reduced to milliseconds.

# Conclusion

In this article, I have primarily focused on desktop fingerprinting, but web tracking on Android devices could potentially be more severe. Mitigating web tracking can be challenging, as some of these techniques are integral to the functioning of the web ecosystem, and they are also utilized to differentiate between human users and bots. There is a substantial amount of academic research in this area, and I highly recommend keeping up-to-date with new publications. As the web ecosystem continues to evolve and introduce new features like a new WebAPI, it may uncover novel "opportunities" for new security and privacy concerns. If you want to check a survey in this topic I recommend [Laperdrix's paper](https://dl.acm.org/doi/pdf/10.1145/3386040).

_When playing hide and seek, it's often better to hide where everyone else is hiding rather than going it alone. If you get caught in the first case, there's still a chance that you might make it out safely. But if you're hiding by yourself and get found, that's game over._

<div class="column" title="Incognito Mode">
  <div style="overflow: hidden">
    <div style="float: left;">
    The primary distinction between a browser's incognito/private mode and its regular mode is that, when you exit the incognito mode, all information including cookies, cached files, and browsing history is wiped out and nothing is stored. To some extent, this reasoning is being extended to the regular mode as well, in order to leverage the benefits of not retaining data that could be utilized for fingerprinting purposes later on.
    </div>
  </div>
</div>


### Browsers Privacy Comparison

[Arthur Edelstein](https://github.com/arthuredelstein) has undertaken a project to compare the various mechanisms offered by the leading web browsers. If you're interested in exploring the differences, I highly recommend visiting his project [PrivacyTest](https://privacytests.org/). For a more comprehensive analysis of each browser's defenses, I suggest checking out their developers' blogs ([webkit](https://webkit.org/tracking-prevention/)/[brave](https://brave.com/privacy-updates/)) or, in some instances, delving directly into the code ([chromium](https://source.chromium.org/chromium)/[brave](https://github.com/brave/brave-core)). Some of these implementations could lead to unexpected leaks, such as Intelligent Tracking Prevention (ITP) non-default feature of Safari ([Information Leaks via Safari's Intelligent Tracking Prevention](https://arxiv.org/abs/2001.07421)).

# Historical Notes 

In this section, I would like to bring attention to significant points from the Cookie RFCs. One notable aspect of the RFC from 1997 is that it includes a section that discusses the potential privacy concerns associated with cookie sharing.

![rfc97](/advanced/web.tracking/rfc1997.png)

The standard RFC for cookies further elaborates on these concerns. In this latest RFC, they explicitly discuss web tracking and third-party tracking. In the final sentence, they also mention that trackers could potentially bypass cookie-blocking measures by using parameters within the URL.

![rfc11](/advanced/web.tracking/rfc2011.png)


## References:

-   _Recommended:_ [Fingeprinting Article Chromium (Artur Janc and Michal Zalewski)](https://sites.google.com/a/chromium.org/dev/Home/chromium-security/client-identification-mechanisms)
-   _Recommended:_ [Fingeprinting Article WebKit](https://sites.google.com/a/chromium.org/dev/Home/chromium-security/client-identification-mechanisms)
-   Panopticlick/CoverYourTracks: [Link](https://coveryourtracks.eff.org/)
-   Fingerprintjs2. Get your FP: [Link](https://valve.github.io/fingerprintjs2/).


### Thanks for reading
If you have any recommendation/mistake/feedback, feel free to reach me [twitter](https://twitter.com/alberto_fdr) :)
