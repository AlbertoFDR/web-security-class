---
title: "Storage Partitioning 📂: From each according to his ability, to each according to his needs." 
---

<div class="balloon_l">
  <div class="faceicon"><img src="../icon/otter_says.png" alt="faceicon" ></div>
  <p class="says">
  This article will explore a significant <b>upcoming transformation of the web</b>, taking place after the <b>deprecation of third-party cookies</b>. For this purpose, I will introduce the concept of Storage Partition and its intended usage by third-party agents.
  </p>
</div>

# Introduction 

Over the past years (2017-2023), there has been a significant surge of interest regarding the deprecation of third-party cookies. The topic of third-party cookie deprecation or partitioning has been actively discussed within [Privacy CG](https://www.w3.org/community/privacycg) groups since 2017 ([link](https://github.com/privacycg/storage-access/issues/75)). In the academic sphere, there has also been considerable interest surrounding this topic ([Jordan Jueckstock&Co](https://dl.acm.org/doi/pdf/10.1145/3485447.3512231)). In this blog entry, I will not only delve into the topic of cookies but also explore other aspects of the [Client-Side Storage Partitioning](https://github.com/privacycg/storage-partitioning) (e.g., localStorage, sessionStorage...). In this regard, [Michael Kleber](https://twitter.com/Log3overLog2) presents a compelling proposal (that I like) and comprehensive explanation of a [potential privacy model for the web](https://github.com/michaelkleber/privacy-model).



# The Challenge of Client-Side Storage

Client-side storage encompasses various storage mechanisms provided by web browsers, such as localStorage, sessionStorage, and cookies, among others. For a complete list, refer to the following [link](https://github.com/privacycg/storage-partitioning#remaining-user-agent-state). In the Storage dilemma, there has been two discussed solutions among the browser vendor to mitigate privacy and security (Timing Attacks, XS-Leaks or web tracking). The first solution entails partitioning third-party storage based on their top-level domain. For example, the cookie associated with an image named 'pizza.png' from the endpoint 'bubuspizzeria.com' would be distinct between the domains 'abc.com' and 'def.com'. I'll explain this solution later called Cookies Having Independent Partitioned State (CHIPS). The second solution, more aggressive, involves the default blocking and deprecation of third-party storage (e.g., cookies). For a different explanation, check the following [README of the proposal repository](https://github.com/privacycg/storage-partitioning#introduction).

<div class="column" title="Site vs Origin">
  <div style="overflow: hidden">
    <div style="float: left;">
        In these proposals, it is crucial to understand the distinction between a "site" and an "origin." The term "site" encompasses all subdomains associated with a particular domain. On the other hand, an "origin" does not include subdomains, focusing solely on the main domain itself. To illustrate, let's consider the domain "social.example." While the subdomain "tracking.social.example" belongs to the same site as "social.example," it is considered a different origin. <a href="https://html.spec.whatwg.org/#origin">(link to WHATWG Spec)</a>. <a href="https://tess.oconnor.cx/2020/10/parties#boundaries">(link to a page that explains perfectly)</a>.
    </div>
  </div>
</div>

# Cookies

The future of cookies stands as one of the most controversial and challenging topics. (SPAM ON 🪺) If you're in need of an introductory article on cookies, I highly recommend checking out [my own article on this web blog](/web.today/cookies) (SPAM OFF 🪺). In the following link, you can find [slides for TPAC work meeting](https://docs.google.com/presentation/d/1RWEEt3eO7hfQF5jkm3GdpkCEeR6yBWmbnlg_uaGkwwE/edit#slide=id.g153ec38b891_0_5) that describe various approaches that have been discussed, including cookie partitioning (such as CHIPS or other methods) and third-party cookie blocking. These slides present complex scenarios that can potentially pose challenges for the solutions.

As stated in the proposal repository, _"The tentative overall plan is to block cross-site cookies and add support for partitioned cookies via opt-in."_. For the most up-to-date information on this topic, please refer to the [following link](https://github.com/privacycg/storage-partitioning#cookies). 

### Cookies Having Independent Partitioned State (CHIPS)

As mentioned previously, Chrome has proposed 'Cookies Having Independent Partitioned State' (CHIPS) as a mechanism to mitigate the potential issues arising from more aggressive measures like third-party cookie blocking, which can disrupt certain webpages. Some articles of DevChrome explaining it ([link](https://developer.chrome.com/docs/privacy-sandbox/chips/)) ([link 2](https://developer.chrome.com/blog/working-with-the-industry-to-evolve-chips/)). There is also a repository of the proposal that explains the idea ([link to CHIPS repo](https://github.com/privacycg/CHIPS)). The Chrome definition is _"Cookies Having Independent Partitioned State (CHIPS) is a Privacy Sandbox proposal that will allow developers to opt a cookie into "partitioned" storage, with separate cookie jars per top-level site."_


![client-side-storage-partitioning](/incoming/storage.partitioning/chips.svg)


Similar to the CHIPS proposal, other browser vendors such as Brave have implemented ephemeral partitioned cookies as a means to prevent website disruptions. In essence, this approach allows the use of partitioned third-party cookies for a limited duration, typically ranging from 30 seconds to 1 minute.



# Iframes 

Iframes present a considerable challenge in the storage dilemma due to their embedded-page nature, enabling complex scenarios such as a page embedding a cross-origin frame that, in turn, embeds the top-level page (A->B->A). For other complex scenarios check the slides for TPAC meeting that I linked before. In the following image you can see how the iframe storage partitioning works.


![client-side-storage-partitioning](/incoming/storage.partitioning/client-side-storage-partitioning.svg)

# Storage access API

To address the deprecation of third-party cookies and mitigate the potential disruptions to webpage functionality, various proposals have emerged. One such proposal that is being implemented by browser vendors is the Storage Access API ([link to proposal](https://privacycg.github.io/storage-access/))([link to the GitHub repo](https://github.com/privacycg/storage-access)). For instance, in the case of Chrome, they are shipping the feature in [version 115](https://chromestatus.com/feature/5612590694662144). The implementation of this API enables third-party frames to request access to their unpartitioned data. Unpartitioned data refers to all the data of that party within the first-party context, such as localStorage, cookies, and more.

<div class="column" title="Storage Access API">
  <div style="overflow: hidden">
    <div style="float: left;">
        <i>"User Agents (Browsers) sometimes prevent content inside certain iframes from accessing data stored in client-side storage mechanisms like cookies. This can break embedded content which relies on having access to client-side storage. The Storage Access API enables content inside iframes to request and be granted access to their client-side storage, so that embedded content which relies on having access to client-side storage can work in such User Agents"</i>. Take a look <a href="https://privacycg.github.io/storage-access/">(link to standard)</a>. 
    </div>
  </div>
</div>

![storage-standard-example](/incoming/storage.partitioning/storage-standard-example.svg)


In the case of WebKit, as [John Wilanger](https://github.com/johnwilander) explains in an [API issue](https://github.com/privacycg/storage-access/issues/44), granting the Storage Access to an iframe is considered as user interaction with the first-party site. Therefore, if you regularly visit a page with the iframe, the permission would be automatically renewed based on the user interaction definition. However, if you haven't visited the page within a 30-day period, the iframe would need to request access again. So, there are certain parts of the standard that are still determined by the browser vendor, including the decision of whether a frame will have access to first-party storage ([GitHub issue](https://github.com/privacycg/storage-access/issues/2#issuecomment-939012902)).

In summary, the Storage Access API facilitates the ability for content within iframes to request and obtain access to first-party storage. To achieve this, two new JavaScript functions have been implemented. For checking the Storage Access `hasStorageAccess()` and for requesting it `requestStorageAccess()`. When an iframe requests access to the first-party storage, a popup similar to the following example is displayed:

![storage-access-prompt](/incoming/storage.partitioning/storage-access-prompt.png)


### Permissions-Policy

The permissions-policy is an attribute of iframes that defines the types of features that can be used within the embedded frame. In this manner, the new model introduces a new value called 'storage-access' which enables the iframe to request access to the first-party storage.


# (IMO) My thoughts

In my opinion, although the deprecation of third-party cookies is a significant step, I hold a different sentiment regarding this topic. In certain aspects, the proposed model could still create possibilities for user tracking by major companies through the exploitation of the Storage Access API, primarily due to the centralized nature of the web ecosystem. My other significant concern pertains to first-party websites. Many first-party sites are not fully aware of all the third-party content they include, making it challenging for them to determine which third-party iframes should have access to first-party storage and which of them not. Moreover, the adoption of this specification in real-world scenarios may be slow, as we have observed in other cases, such as, Content-Security-Policies (CSP) or Subresource-Integrity (SRI).

If you have any recommendation/mistake/feedback, feel free to reach me [twitter](https://twitter.com/alberto_fdr) :)

## References:

-   _Recommended:_ [CHIPS (Cookies Having Independent Partitioned State) proposal repository](https://github.com/privacycg/CHIPS)
-   _Recommended:_ [Client-Side Storage Partitioning proposal repository](https://github.com/privacycg/storage-partitioning)
-   _Recommended:_ [Storage Access API proposal repository](https://github.com/privacycg/storage-access)
-   [Google Privacy Sandbox Team Timeline](https://privacysandbox.com/intl/es_es/open-web/#the-privacy-sandbox-timeline)
-   [Firefox Total Cookie Protection by-default article](https://blog.mozilla.org/en/mozilla/firefox-rolls-out-total-cookie-protection-by-default-to-all-users-worldwide/)
