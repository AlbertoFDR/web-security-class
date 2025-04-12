---
title: "You Shall Not Get Access 🧙🏻‍♂️: Browser Permissions"
---

<div class="balloon_l">
  <div class="faceicon"><img src="../icon/otter_says.png" alt="faceicon" ></div>
  <p class="says">
  Let's take Google Meet as an example. When you try to join a very (cough cough) important (cough cough) work meeting, and the browser pops up a prompt requesting access to your camera and microphone... How do these browser permissions work? How many other permissions are out there? 
  </p>
</div>


![asking](/browser/browser.permissions/asking-micro.svg)

# Browser Permissions


<div class="column" title="Permission vs Feature">
  <div style="overflow: hidden">
    <div style="float: left;">
        Permission is the key or gateway to accessing and requesting certain features. For example, if a webpage has 'camera' permission, it means the page can either request access to the camera or use it directly if previously granted. This type of permission, which requires the user to explicitly grant access through a popup, is categorized as 'powerful', which we will explain later.
    </div>
  </div>
</div>


Nowadays, many permissions exist—it’s not just the camera or microphone. There isn’t an official list of all the permissions supported by browsers or [standarized](https://github.com/w3c/permissions-registry/issues/22), so I created what I believe is the most comprehensive permissions list ([link](https://albertofdr.github.io/browser-permissions-tool/)). My list isn’t perfect, and not all the characteristics of the permissions may be accurate, but I believe it’s more useful than relying on the [standard list](https://github.com/w3c/webappsec-permissions-policy/blob/main/features.md) or checking the [Chromium code list](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/third_party/blink/renderer/core/permissions_policy/permissions_policy_features.json5). Alternatively, if you're curious about which websites you have permissions granted on, you can check out: `about://settings/content/siteDetails?site=https://albertofdr.github.io/` (links to `about:` doesn't work for security reasons, so you need to copy&paste). 

| Example of Permissions| 
|-----------|

| | | | | 
|----------|----------|----------|----------|
| accelerometer   | camera   | clipboard-read   | clipboard-write | 
| display-capture   |  fullscreen  |   geolocation	   | gyroscope  | 
| idle-detection |  local-fonts	  |  microphone	   | notifications | 



It’s important to note that some permissions are special. For example, the permission to download a file from a website differs from typical permissions like camera access. This occurs when the browser encounters a content type that is not the usual formats, such as HTML or standard resources. Currently, there are two key characteristics of permissions. The first is whether it’s a powerful permission, and the second is whether it’s policy-controlled. I've included examples of different permissions and their characteristics based on the [Permissions Registry deprecated W3C Standard](https://w3c.github.io/permissions-registry/), but let’s now dive into both of these in more detail.



| Permission  | Powerful? | Policy-controlled?  | Default allowlist  |
|----------|----------|----------|----------|
| camera   | ✅   |   ✅  |  `self`  |
| geolocation   | ✅   |    ✅ |  `self`  |
| gamepad   | ❌   |  ✅ | `*`  |
| notifications   | ✅   |   ❌  |  N/A  |
| push   | ✅   |   ❌  |  N/A |


## Powerful Permission

A powerful permission simply means that the specific feature requires explicit consent from the user. If the permission has not been granted before, a prompt will appear, and the user will need to accept it.  A common example of this is the `camera` and `microphone` popup that appears on meeting websites. In other examples, such as with `serial` or `usb` permissions, the user must select the device, which means these can also be categorized as powerful. An example of the javascript code to check the status (**not** for asking/prompting the user) of the permission would be:

```javascript 
async function checkPermission(permission){
  let result = await navigator.permissions.query({'name': permission});
  console.log(result['state'])
}

checkPermission('camera');
```

## Policy-controlled Permission

Now, what does it mean for a permission to be policy-controlled? It means that the permission can either be delegated or not, and as a result, there is also a default allowlist in place. Let’s use the camera permission as an example. The camera permission is both powerful and policy-controlled. Its allowlist is set to `self`. Let’s break this down:

Because camera is a powerful permission, if a website wants to use it, it must prompt the user for consent, which the user needs to accept. On the other hand, the `self` allowlist means that only the top-level document (the main page) can access this permission. As a result, if there’s an iframe, such as one from `meet.example.org`, it will not be able to use the camera permission. In contrast, as it was previously some years ago, a default allowlist of `*` would allow the iframe to access the permission without an explicit delegation.

<div class="column" title="How to check if the context can access the permission">
  <div style="overflow: hidden">
    <div style="float: left;">
      To check if a context, such as an iframe from <code>meet.example.org</code>, is able to access a permission, we can use: <code>document.featurePolicy.allowedFeatures()</code>. There are also other functions available, so open the browser console and see what the browser suggests. Additionally, in the future, these functions may be moved under <code>document.permissionsPolicy</code>.
    </div>
  </div>
</div>

That being said, you might wonder how an iframe could access the camera. The delegation of permissions fall into one of the following categories ([chromium source code](https://source.chromium.org/chromium/chromium/src/+/main:components/permissions/permission_util.cc;l=41)): 

1. Undelegated (e.g., `notification` and `push`).

> Permissions from the main frame are not delegated to child frames. An undelegated permission will only be granted to a child frame if the child frame's origin was previously granted access to the permission when in a main frame.

2. Double-keyed (e.g., `storage-access`).

> Permission access is a function of both the requesting and embedding origins.

3. Delegated (e.g., `camera` and `microphone`).

> Permissions from the main frame are delegated to child frames. This is the default delegation mode for permissions. If a main frame was granted a permission that is delegated, its child frames will inherit that permission if allowed by the permissions policy.

In this two last categories of delegation is where the `allow` attribute of the iframe comes into play. Continuing with the example the iframe would be created like: 

`<iframe src='//meet.example.org' allow='camera'></iframe>`. 

This may not be a good practice, so make sure to keep reading until the *Good practices* section. 

<div class="column" title="Iframe needs to re-prompt for permission?">
  <div style="overflow: hidden">
    <div style="float: left;">
      Let’s take an example: You visit the website <code>bubu.com</code>, which requests access to your camera, and you allow it. Later, an iframe from <code>meet.example.org</code> is included with the <code>allow='camera'</code> attribute. At this point, would the iframe be allowed to access the camera without re-prompting? <b>YES!</b>.
    </div>
  </div>
</div>


Now that we’ve learned about the allow attribute and how permission delegation works, let’s look at the syntax. Without going into technical details just yet (we’ll cover that later in the blog), the value for a permission can be `'none'`, `'self'`, `'src'`, an origin (`https://albertofdr.github.io/`), or `*`. When the permission delegated doesn't have an explicit directive (e.g., `'self'`), the allowlist defaults to the iframe's `'src'` attribute. I'll revisit this point when discussing the Permissions-Policy Standard later. You might be wondering how to delegate multiple permissions. This can be done by separating them with the `;` character. A complete example would be: 

`allow="camera; geolocation 'self' https://tracker.com; display-capture 'none'"`. 

To help you understand how the directives work, I’ve created the following table.

|  albertofdr.github.io  |  albertofdr.github.io |  permission.site (Iframe) |   
|----------|----------|----------|

|  Camera Access/Prompt | Iframe Allow Delegation  |  Camera Access/Prompt  |
|----------|----------|----------|
|  ✅   | no allow  |    ❌  [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20) | 
|  ✅   | `allow` |    ❌  [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20) |
|  ✅   | `allow=''` |    ❌  [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D''%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20) | 
|  ✅   | `allow=camera`  |   ✅   [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D'camera'%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20) |
|  ✅   | `allow="camera 'self'"`  |   ❌   [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D%22camera%20'self'%22%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20) |
|  ✅   | `allow='camera https://permission.site/'`  |   ✅   [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D%22camera%20https%3A%2F%2Fpermission.site%2F%22%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20)  |
|  ✅   | `allow="camera 'https://permission.site/'"`  |   ❌   [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D%22camera%20'https%3A%2F%2Fpermission.site%2F'%22%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20)  |
|  ✅   | `allow='camera *'`  |   ✅    [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D%22camera%20*%22%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20)  |
|  ✅   | `allow="camera '*'"`  |   ❌    [link](https://albertofdr.github.io/dummy-pages/testing-pages/live-editor.html?html=%3Ciframe%20src%3D'%2F%2Fpermission.site'%20allow%3D%22camera%20'*'%22%20height%3D800%20width%3D800%3E%3C%2Fiframe%3E%20)  |


At this point, we’ve covered permissions and how they can be delegated to other contexts. Now, you might be wondering how a developer can completely restrict the use of a permission if it’s not needed. This is where the Permissions-Policy **response header** (formerly known as Feature-Policy) comes into play.

<div class="column" title="Permissions Policy header vs Feature Policy header">
  <div style="overflow: hidden">
    <div style="float: left;">
    The Permissions-Policy header was formerly known as the Feature-Policy header. The main difference between them is the syntax, so it’s important to be cautious. Many websites still use the old Feature-Policy syntax in the Permissions-Policy header, which will not work.
    </div>
  </div>
</div>

![pp-header](/browser/browser.permissions/pp-header.svg)

In simple terms, the Permissions-Policy header allows developers to opt-out of or restrict the use and delegation of permissions. At this moment, only supported by Chromium-based browsers and deployed in around 27% of the websites ([chrome status](https://chromestatus.com/metrics/feature/timeline/popularity/3850)). Continuing with the camera example, setting the camera permission to `*` does not override the default allowlist of `'self'`. As a result, the permission will not be delegated unless the allow attribute is explicitly used. An example of a Permissions-Policy header would be: 

`Permissions-Policy: camera=(), microphone=()`

This header would disallow the use of both the `camera` and `microphone` in ANY CONTEXT. Just like before, let’s take a look at this new table.

|   albertofdr.github.io |  albertofdr.github.io |  albertofdr.github.io |  permission.site (Iframe) |  
|----------|----------|----------|----------|

| Permissions Policy Header  | Access/Prompt | Iframe Allow Delegation  | Access/Prompt  |
|----------|----------|----------|----------|
| No Header    | ✅   | not delegate  |    ❌  |
| No Header    | ✅   | delegate   |   ✅  |
| `camera=()`    |  ❌  | delegate   |     ❌ |
| `camera='self'`    |  ✅  | delegate   |     ❌ |
| `camera=('self' permission.site)`    |  ✅  | delegate   |     ✅ |
| `camera=*`    |  ✅  | not delegate   |    ❌  |
| `camera=*`    |  ✅  | delegate   |   ✅   |


Now that we understand how the Permissions-Policy header works for the top-level document, let’s explore how the Permissions-Policy header in iframes affects the usage.




|   WEBSITE TLD |  WEBSITE TLD | WEBSITE TLD |  permission.site (Iframe) |  permission.site (Iframe) |
|----------|----------|----------|----------|----------|

| Permissions Policy Header  | Access/Prompt | Iframe Allow Delegation  | Permissions-Policy Header  | Access/Prompt  |
|----------|----------|----------|----------|----------|
| No Header    | ✅   | not delegate  |  No Header  |  ❌  |
| No Header    | ✅   | not delegate  |  `camera=*`  |  ❌  |
| No Header    | ✅   | delegate   |  No Header  |  ✅  |
| No Header    | ✅   | delegate  |  `camera=()`  |  ❌  |
| `camera=()`    |  ❌  | delegate   |  No Header  |   ❌ |
| `camera=self`    |  ✅  | delegate   |  No Header  |   ❌ |
| `camera=*`    |  ✅  | delegate   |  No Header  |   ✅ |
| `camera=*`    |  ✅  | delegate   |  `camera=()`  |  ❌  |
| `camera=*`    |  ✅  | delegate   |  `camera=self`  |  ✅  |


As an exercise for the reader, I will add a few headers and allow attributes. The goal is to determine whether the permission can be used or is blocked in different contexts. Remember for the exercise that the default allowlist of `camera` is `self`.


<style>
  details {
    margin: 1em 0;
    padding: 1em;
    border: 1px solid #ddd;
    border-radius: 8px;
    background-color: #f9f9f9;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    position: relative; /* Needed for positioning the bar inside */
    transition: all 0.3s ease-in-out;
  }
  
  summary {
    font-size: 1.1em;
    font-weight: bold;
    cursor: pointer;
    color: #007BFF;
  }
  
  summary:hover {
    text-decoration: underline;
  }
  
  details[open] summary {
    color: #0056b3;
  }
  
  .close-bar-browser-permissions {
    position: absolute;
    top: 0;
    right: 0;
    height: 100%; /* Full height of the details */
    width: 15px; /* Adjust width to your preference */
    background-color:   #ff9b85 ; /* Red for the bar */
    color: white;
    font-size: 0.8em;
    font-weight: bold;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    border-radius: 0 8px 8px 0; /* Rounded corners on the right side */
    transition: background-color 0.2s;
    writing-mode: vertical-rl; /* Vertical text orientation */
    text-align: center;
  }
  
  .close-bar-browser-permissions:hover {
    background-color: #f44336; /* Darker red on hover */
  }

  .centered-text-browser-permissions {
  text-align: center; /* Center the text */
  margin-top: 1em; /* Add some space above */
  font-style: italic; /* Optional: make it italic for emphasis */
  color: #555; /* Optional: light gray for subtlety */
}
</style>

<details id="details-section">
  <summary>Click to see a few simple scenarios to try out as exercises.</summary>
  
| Exercise 1 | 
|-------------|

> Does the website have access to the camera?

`Permissions-Policy: camera=()`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. The header blocks the use of the permission.
</div>

| Exercise 2 | 
|-------------|

> Does the website have access to the camera?

`Permissions-Policy: camera=(),`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
Yes. The trailing comma breaks the header, rendering it ineffective, as if it wasn’t defined.
</div>

| Exercise 3 | 
|-------------|

> Does the website have access to the camera?

`Permissions-Policy: camera='none'`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
Yes. The header uses 'none' with quotes, but directives should not be enclosed in quotes.
</div>

| Exercise 4 | 
|-------------|

> Does the website have access to the camera?

`Permissions-Policy: camera=none`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. The header correctly blocks access to the camera.
</div>

| Exercise 5 | 
|-------------|

> Does the website have access to the camera?

`Permissions-Policy: camera=(none)`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. The header prevents the camera from being used.
</div>

| Exercise 6 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://meet.bubu.com/`.

`Permissions-Policy: camera=(https://meet.bubu.com/)`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. Since the URL is not enclosed in double quotes, the origin is not recognized as origin directive.
</div>

| Exercise 7 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=('https://meet.bubu.com/')`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
Yes. Using single quotes breaks the parsing, invalidating the header entirely.
</div>

| Exercise 8 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=("https://meet.bubu.com/")`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. The header is valid and restricts access to only the origin <code>meet.bubu.com</code>.
</div>

| Exercise 9 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=(), microphone=(https://meet.bubu.com/)`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. While the microphone policy doesn’t apply correctly as before, it doesn’t affect the camera policy, which remains functional.
</div>

| Exercise 10 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=(), microphone=('https://meet.bubu.com/')`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
Yes. Single quotes break the parsing, causing the browser to discard the header entirely.
</div>

| Exercise 11 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=(), microphone=("https://meet.bubu.com/")`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. Both policies are correctly configured and work as expected.
</div>

| Exercise 12 | 
|-------------|

> Does the iframe have permission to access the camera?

`<iframe src='https://permission.site' allow="camera"></iframe>`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
Yes. With no header restrictions, and delegation defaulting to 'src', <code>permission.site</code> will have access to the camera if no redirects to different origin occur.
</div>

| Exercise 13 | 
|-------------|

> Does the iframe have permission to access the camera?

`Permissions-Policy: camera=(*)`
`<iframe src='https://permission.site'></iframe>`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. The header can only opt-out or restrict permissions; it cannot grant delegation on its own.
</div>

| Exercise 14 | 
|-------------|

> Does the iframe have permission to access the camera?

`Permissions-Policy: camera=self`
`<iframe src='https://permission.site' allow="camera"></iframe>`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. The header is properly configured to restrict access to the self context.
</div>

| Exercise 15 | 
|-------------|

> Does the iframe have permission to access the camera? In this case `storage-access` default allowlist is `*`.

`<iframe src='https://permission.site' allow="storage-access 'none';"></iframe>`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. Access is explicitly disabled in the delegation.
</div>

| Extra | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=none`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
No. You might think that <code>none</code> gets interpreted and the policy is applied, but the truth is that <code>none</code> is invalid. However, since there are no other policies, it behaves like <code>camera=()</code>.
</div>

| Extra 2 | 
|-------------|

> Does the website have access to the camera? The website origin is `https://bubu.com/`.

`Permissions-Policy: camera=(none *)`

<div style="filter: blur(10px); cursor: pointer;" onclick="this.style.filter='none'; this.style.cursor='default';">
Yes. Again <code>none</code> is invalid and <code>*</code> is applied.
</div>

<div class="centered-text-browser-permissions">
I bet you got at least one wrong!. 
</div>

  <div class="close-bar-browser-permissions" onclick="document.getElementById('details-section').removeAttribute('open');">
    Close
  </div>
  
</details>

<div class="column" title="Permissions-Policy Header 'Self' directive mandatory for delegation">
  <div style="overflow: hidden">
    <div style="float: left;">
        At this point (06-02-2025), <i>Self</i> directive is mandatory if we want to delegate permission to other iframes (<a href="https://github.com/w3c/webappsec-permissions-policy/issues/480">Github Spec Issue</a>).
    </div>
  </div>
</div>

With this first section, we now have a solid overview of how permissions work in today’s web ecosystem. Let’s dive into the standards that govern and explain this.


# Permissions W3C Standards

As of early 2025, two primary standards explain this: the [Permissions Standard](https://www.w3.org/TR/permissions/) and the [Permissions-Policy Standard](https://www.w3.org/TR/permissions-policy/). Additionally, individual standards must specify whether a permission is powerful or policy-controlled. There is also a [Permission Registry standard](https://w3c.github.io/permissions-registry/), but it has been [deprecated](https://github.com/w3c/permissions-registry/issues/22). Significant changes to both standards can be expected in the coming months and years. Furthermore, some corner cases and core aspects of these standards remain in discussion among major browser vendors and developers.

## [Permissions Standard](https://www.w3.org/TR/permissions/)

In simple terms, the Permissions Standard defines powerful permissions --- or, as described in the specification:

> This specification defines common infrastructure that other specifications can use to interact with browser permissions. These permissions represent a user's choice to allow or deny access to "powerful features" of the platform. For developers, the specification standardizes an API to query the permission state of a powerful feature, and be notified if a permission to use a powerful feature changes state.

For a detailed explanation of what 'powerful' means, refer to [this issue (link)](https://github.com/w3c/permissions/issues/451). Additionally, it’s worth noting that the standard defines the `navigator.permissions.query` function. This is the function used to check if a permission has been `granted`, can be `prompt` or is `denied`.


## [Permissions Policy Standard (formerly Feature Policy)](https://www.w3.org/TR/permissions-policy/)

The Permissions-Policy standard is a bit more complex and can be somewhat confusing to understand. I’ll do my best to explain it clearly. This standard defines the Permissions-Policy header and the delegation using the allow attribute including the definition of default allowlist. Additionally, any individual standard that defines a policy-controlled feature with the corresponding default allowlist should reference this one. 

> This specification defines a mechanism that allows developers to selectively enable and disable use of various browser features and APIs.

Starting with the structured header: this means that a misplaced comma (`camera=(),`) or any unexpected element can break the browser's serialization, causing it to remove the header. The consequence of this is that the website would function as if the header was never defined. For each permission, separated by a comma (`camera=(), microphone=()`), the header defines a set of directives, either individually (`camera=self`) or in groups (`camera=(self "https://bubu.com/")`), such as `self`, `*`, or a specific origin ([standard section](https://www.w3.org/TR/permissions-policy/#structured-header-serialization)). For the allow attribute, permissions should be separated by a semicolon `;` and, apart from `self` and `*`, you can also use `none` and `src`. Moreover, the standard also defines how the default allowlist works, specifying that the default allowlist for any permission can only be `self` or `*` ([with `none` being considered as an option](https://github.com/w3c/webappsec-permissions-policy/issues/513)). This spec also defines how to check if a permission is allowed in your context. This is done using the `document.permissionsPolicy.*` (e.g., `document.permissionsPolicy.allowedFeatures()`) functions. As of January 2025, the functions are still part of the old Feature-Policy object, such as `document.featurePolicy.allowedFeatures()`. In this specification, the delegation using the `allow` tag is also included, and one important thing to note is the following:

> The allowlist for the features named in the attribute may be empty; in that case, the default value for the allowlist is 'src', which represents the origin of the URL in the iframe’s src attribute.




## Individual Permissions Standard [(Ex: Media Capture and Streams)](https://www.w3.org/TR/mediacapture-streams/)

Each individual specification related to a feature may refer to either the Permissions Standard or the Permissions-Policy Standard, depending on the feature's characteristics. It typically also defines a permission associated with that feature. If the feature is policy-controlled, the specification should define the default allowlist ([standard example](https://www.w3.org/TR/mediacapture-streams/#permissions-policy-integration)). Sometimes, because the term 'powerful' is relatively new, some standards may instead say something like 'the user needs to grant the permission'.


<div class="column" title="Reading Standards and Specifications">
  <div style="overflow: hidden">
    <div style="float: left;">
      If you want to learn more, give the spec a try. While you might not fully understand how the standards are written at first, it’s worth exploring.
    </div>
  </div>
</div>


# Permission Common Misconceptions

### 1. Permissions-Policy only defines the Permissions-Policy Header

Some people may think that the Permissions-Policy standard only defines the header. This is completely incorrect. The standard actually defines the entire policy and delegation ecosystem, including delegation, as we’ve seen. In my opinion, this is a great starting point and should be pushed forward.

### 2. All Defined Permissions are Powerful and Policy controlled

As the Permissions standard and Permission Registry standard states:

> Not every policy-controlled feature is powerful features. For example, "web-share" is a policy-controlled feature that is not classified as a powerful feature because it doesn't require express permission to be used. However, with very few exceptions, most powerful features are also policy-controlled features. For example, "geolocation" is both a policy-controlled feature and a powerful feature, as it requires express permission to be used. Please refer to the Permissions specification for guidance on how to specify a powerful feature.

One of the things that browser vendors and those working on the standard should do is define a comprehensive list of permissions. This way, developers wouldn’t need to rely on [my list](https://albertofdr.github.io/browser-permissions-tool/index.html) and would have a clear understanding of the characteristics of each permission. It would also allow for defining permissions in the header and disabling those that developers know are not being used.


### 3. Policy Declaration when iframe A includes iframe B

![iframe-inside-iframe](/browser/browser.permissions/pp-iframe-inside-iframe.svg)

One of the biggest sources of confusion for website developers is what happens to the policy declared by the header when an iframe contains another iframe. Developers often believe they can define a policy that affects nested iframes. However, this would violate one of the core principles of the web: the Same-Origin Policy (SOP). In other words, once a permission is delegated to a different context, that context can do whatever it wants with the permission. So, in the example, if the permission is delegated to Iframe A, Iframe A could then delegate it to Iframe B. There is no header or mechanism that a website developer can use to prevent this second delegation. This is one of the reasons developers should be cautious about which contexts or iframes they delegate permissions to.

### 4. Misleading prompt text when Permission requested from an iframe 

![prompt-from-iframe](/browser/browser.permissions/prompt-from-iframe.svg)

Developers may assume that when an iframe, like `meet.example.org`, is included in `albertofdr.github.io` and attempts to access a permission, the prompt would say something like: '`meet.example.org` wants to access the permission'. However, this is not the case. The prompt will actually say: '`albertofdr.github.io` wants to access the permission.'

### 5. What happens when a new iframe want the already granted permission

A typical developer might assume that when a new iframe is created, the previously granted permissions would not be accessible. However, this is not the case. Once a permission has been granted—whether now or 30 days ago (depends on the browser)—any iframe (with the appropriate delegation, if needed) will have access to that permission.

### 6. Dynamically Delegating Permissions

Some people might think that changing the allow attribute of an iframe would immediately affect the delegated permissions, but this is not true. Delegation cannot be set dynamically. In other words, once the document context of the iframe is created, changing the delegation requires two steps: first, update the allow attribute, and second, reload the iframe's context (e.g., `window.location.reload()`). Now, I’ll present different cases to clarify this. Let’s take an example of a website including an iframe.

<style>
/* Styling the menu */
.menu-browser-permissions {
  display: flex;
  justify-content: center;
  margin-bottom: 1em;
}

.menu-browser-permissions button {
  margin: 0 5px;
  padding: 0.5em 1em;
  font-size: 1em;
  cursor: pointer;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: #f9f9f9;
  transition: background-color 0.2s ease;
}

.menu-browser-permissions button:hover {
  background-color: #e0e0e0;
}

.menu-browser-permissions button.active {
  background-color: #f52d1f;
  color: white;
}

.table-container-browser-permissions {
  display: none;
}

.table-container-browser-permissions.active {
  display: block;
  margin: 0 auto;
  text-align: center;
}
</style>

<div class="menu-browser-permissions">
  <button onclick="showTable(1)" id="btn-1-browser-permissions" class="active">Case 1</button>
  <button onclick="showTable(2)" id="btn-2-browser-permissions">Case 2</button>
  <button onclick="showTable(3)" id="btn-3-browser-permissions">Case 3</button>
  <button onclick="showTable(4)" id="btn-4-browser-permissions">Case 4</button>
  <button onclick="showTable(5)" id="btn-5-browser-permissions">Case 5</button>
  <button onclick="showTable(6)" id="btn-6-browser-permissions">Case 6</button>
  <button onclick="showTable(7)" id="btn-7-browser-permissions">Case 7</button>
  <button onclick="showTable(8)" id="btn-8-browser-permissions">Case 8</button>
  <button onclick="showTable(9)" id="btn-9-browser-permissions">Case 9</button>
</div>

<div id="table-1-browser-permissions" class="table-container-browser-permissions active">

|  | 
|-----------|
| declare allow `allow="camera *"`| 
| declare src `src="abc.org"`| 
| `abc.org` camera allowed ✅| 
| `abc.org` --> *REDIRECT* --> `xyz.org` | 
| `xyz.org` camera allowed ✅| 

</div>

<div id="table-2-browser-permissions" class="table-container-browser-permissions">


|  | 
|-----------|
| declare allow `allow="camera"`| 
| declare src `src="abc.org"`| 
| `abc.org` camera allowed ✅| 
| `abc.org` --> *REDIRECT* --> `xyz.org` | 
| `abc.org` camera denied ❌| 

</div>


<div id="table-3-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| `abc.org` camera denied ❌| 

</div>

<div id="table-4-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| `abc.org` camera denied ❌| 
| `abc.org` --> *REDIRECT* --> `xyz.org` | 
| `xyz.org` camera allowed ✅| 

</div>
<div id="table-5-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| `abc.org` camera denied ❌| 
| `abc.org` uses `window.location.reload()` | 
| `abc.org` camera allowed ✅| 

</div>
<div id="table-6-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| declare src `src="abc.org#bubu"`| 
| `abc.org` camera denied ❌| 
| *Explanation: Fragment is not reloading the document context.* |

</div>
<div id="table-7-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| declare src `src="abc.org"`| 
| `abc.org` camera allowed ✅| 
| *Explanation: Setting `src` produces a reload.* |

</div>
<div id="table-8-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| declare src `src="abc.org/bubu/profile"`| 
| `abc.org` camera allowed ✅| 
| *Explanation: Setting path produces a new context.* |

</div>
<div id="table-9-browser-permissions" class="table-container-browser-permissions">

|  | 
|-----------|
| declare src `src="abc.org"`| 
| `abc.org` camera denied ❌| 
| declare allow `allow="camera *"`| 
| declare src `src="abc.org/?user=13"`| 
| `abc.org` camera allowed ✅| 

</div>

<script>
function showTable(index) {
  // Hide all tables
  document.querySelectorAll('.table-container-browser-permissions').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.menu-browser-permissions button').forEach(el => el.classList.remove('active'));
  
  // Show the selected table
  document.getElementById(`table-${index}-browser-permissions`).classList.add('active');
  document.getElementById(`btn-${index}-browser-permissions`).classList.add('active');
}
</script>


### 7. Permissions-Policy Header vs Feature Policy Header

The main difference, aside from the name, lies in the syntax used in the header. Furthermore, in Permissions-Policy header `none` token is invalid. Take a look at these two examples:

> Feature-Policy: camera 'self'; geolocation 'none'

> Permissions-Policy: camera='self', geolocation=()

If you’re curious, when both headers are declared for the same permission, the Permissions-Policy directive takes precedence. However, if a permission directive is only present in the Feature-Policy header, it will still work and apply the policy. Remember that still only applies to Chromium-based browsers.

# HTML \<permission\> tag (PEPC)


![newasking](/browser/browser.permissions/new-asking.svg)


In mid-2024, Google folks introduced the `<permission>` HTML tag ([blog](https://developer.chrome.com/blog/permission-element-origin-trial)). The two major changes in their [proposal](https://github.com/WICG/PEPC/tree/main) are, first, a visual change that blurs the entire screen instead of using a traditional prompt, and second, the introduction of a button-like element to request permissions

`<permission type="camera microphone"></permission>`. 

If you’re interested, feel free to check out their [demo](https://permission.site/pepc.html) or the [explainer](https://github.com/WICG/PEPC/tree/main).


# Good practices

In the following lines, I’ll share a few pieces of advice, but keep in mind that these may not apply to every case and are not foolproof. Starting with the Permissions-Policy header, since there are currently [no permission groups](https://github.com/w3c/webappsec-permissions-policy/issues/481) and each permission must be disabled manually, a good starting point would be the following setup. The goal is to **disable all types of powerful browser features that are not commonly used** and are only required by specific categories of websites. However, I recommend reviewing [my list](https://albertofdr.github.io/browser-permissions-tool/index.html) and keeping in mind that this may change in the future as new permissions are introduced.

> camera=(), captured-surface-control=(), clipboard-read=(), display-capture=(), geolocation=(), idle-detection=(), local-fonts=(), microphone=(), midi=(), nfc=(), screen-wake-lock=(), system-wake-lock=(), usb=(), window-management=(), xr-spatial-tracking=()

If it’s not strictly necessary, I always recommend avoiding changes to the header or adding third-party widgets, as you are ultimately responsible for what third parties do with your users' data. Another important point to address is permission delegation. Similar to header directives, both website developers and third-party widget developers should avoid delegating permissions. Doing so increases the attack surface and the risk of vulnerabilities, such as permission hijacking.

Let’s consider a real-world example: a support chat widget that facilitates communication between clients and company representatives to address queries. Each company using such a widget would include it with the same origin, modifying, for instance, a parameter like id to identify the specific company. Based on this id and the plugins installed in the chat widget, **only the necessary permission delegations should be used**. Third-party companies should avoid using a generic template that delegates all potentially required permissions. (*If you're curious about these kinds of cases and want to learn more, you will have to wait and see if my academic paper gets accepted soon* 💀).


# Thoughts on Security Risks


At this point, I’d like to mention two types of attacks that came to mind after watching a [Google presentation by the great researcher jkokatsu (shhnjk)](https://docs.google.com/presentation/d/1r-IoO4zATUt4X2KyND16EoDiho5q56KdjqqfR5U7XaY/edit?resourcekey=0-ybts583CqEUxeJsUUXYpmA) or this [academic paper (*Studying the Privacy Issues of the Incorrect Use of the Feature Policy*)]() by [Beliz Kaleli](https://www.linkedin.com/in/belizkaleli/). The first case involves a website that uses powerful permissions, such as access to the camera and microphone. Let’s take `meet.bubu.com` as an example.

![htmli](/browser/browser.permissions/htmli.svg)

Imagine that the website has a robust Content-Security-Policy but lacks a Permissions-Policy. In this case, the bug discovered and explained in the following section to bypass `self` directives not only applies but could make the situation even worse. The CSP header, which lacks directives for including other documents (e.g., `frame-src`), effectively prevents any XSS scripting attacks or CSS exfiltration. At this point, client-side attacks would be significantly reduced. Now, let’s say you find an HTML injection on the page, whether stored or reflected. On its own, this would be a vulnerability without much impact due to existing mitigations. However, the point I want to emphasize here is how HTML injection could be escalated into a permission hijacking attack. Why? Because the permissions have already been granted, and you could potentially delegate access to the `camera`, `microphone`, and `display-capture` to an attacker’s page. This attack would allow the attacker to make use of features from their page. Furthermore, while videoconferencing websites often provide an option to turn off the camera or microphone, this does not revoke the permission. As a result, the attacker could still listen in on or view people who are theoretically muted. Even in cases where the permission has not been granted before, you can attempt to trick the user due to the misleading prompt explained earlier.

![chain](/browser/browser.permissions/supplychain.svg)

The second type of attack I have in mind involves widgets with delegated permissions. Let’s imagine a very common widget from `bubuchat.com` that is embedded on thousands of pages, used by thousands of users every day. This widget, for certain functionalities, has delegated access to important permissions, such as `display-capture`. If an attacker is able to exploit this company and alter the widget, they would gain the ability to modify the code that has access to the permissions. In cases where the permission has not been granted yet, the attacker would only need to request the permission, because, as explained earlier, the prompt would display the website's name, not the widget’s.


# Local-Scheme Document Strikes Again

As a final point, I'd like to mention a bypass I discovered due to a specification issue, which affects all Chromium-based browsers. Some of this, along with many other findings, may be published, if I'm lucky, in an academic paper.

In simple terms, there is a way to delegate a permission to a third party, even when the Permissions-Policy header restricts that permission to `self` (e.g., `camera=self`). You might be wondering, how is this possible?



|  | meet.com  |  Local-Scheme document (data: URI) |  | attacker.com |   
|----------|----------|----------|----------|----------|


|  | Permissions-Policy Header | Camera Access/Prompt | Allow Delegation  |  Camera Access/Prompt  |
|----------|----------|----------|----------|----------|
| Expected | `camera=self` | ✅   | delegate (`allow=camera`)  |    ❌  |
| Real | `camera=self` | ✅   | delegate (`allow=camera`)  |    ✅🐛  |


As shown in the table and title, the key lies in using a local-scheme document. These documents, defined in the [standard](https://fetch.spec.whatwg.org/#local-scheme), inherit headers in cases like Content-Security-Policy to prevent bypasses ([CSP Standard](https://w3c.github.io/webappsec-csp/#security-inherit-csp)). Currently, however, this does not happen with Permissions-Policy, allowing us to use this technique to bypass the 'self' restriction. This issue has been reported in the standard but remains unresolved, as you can see here:


- [Reported issue in Permissions-Policy W3C Standard.](https://github.com/w3c/webappsec-permissions-policy/issues/552)
- [Reported issue in HTML Standard issue.](https://github.com/whatwg/html/issues/10461)

# Last thoughts

As a simple conclusion, I'd like to write a few lines about the complexity of these mechanisms for developers. For example, implementing the Permissions Policy header can be error-prone—something as small as a misplaced comma can invalidate the entire header. This approach simplifies parsing on the browser side, and I'm not saying it's a bad thing, but developers should have tools—like [my own for generating the Permissions-Policy header](https://albertofdr.github.io/browser-permissions-tool/generator.html)—to help them effectively use these important security mechanisms.

## Thanks for reading

Part of this research was conducted in collaboration with the excellent researcher, [Jannis](https://jannisbush.github.io/).
If you have any recommendation/mistake/feedback, feel free to reach me [twitter](https://twitter.com/alberto_fdr) :)

## References:

-   [Browser Permission List.](https://albertofdr.github.io/browser-permissions-tool/index.html)
-   [Permissions-Policy Header generator.](https://albertofdr.github.io/browser-permissions-tool/generator.html)
-   _Recommended:_  [Smarter Defaults by Paying Attention. ericlaw.](https://textslashplain.com/2022/02/15/smarter-defaults-by-paying-attention/)
-   _Recommended:_ [Browser Basics: User Gestures. ericlaw. ](https://textslashplain.com/2020/05/18/browser-basics-user-gestures/)
-   [Permissions-Policy Standard](https://www.w3.org/TR/permissions-policy/)
-   [Permissions Standard](https://www.w3.org/TR/permissions/)
-   [Permissions Registry Standard](https://w3c.github.io/permissions-registry/)

## Other articles of the blog:

-   [Everything you ever wanted to know about Web Tracking (but were afraid to ask).](https://albertofdr.github.io/web-security-class/advanced/web.tracking)
-   [Web-to-App Communication.](https://albertofdr.github.io/web-security-class/browser/web.to.app)
-   [Storage Partitioning 📂: From each according to his ability, to each according to his needs.](https://albertofdr.github.io/web-security-class/incoming/storage.partitioning)
