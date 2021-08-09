# M-Track
## Application Concept
**M-Track** is a multi-functional package tracking application, which allows users to track parcel delivering information completely within one single app, regardless the carriers or package types, or different users.

In addition to the basic tracking functionality, it adds real-time tracking, in-app sharing, and carriers rating. This app also works for deliverers for easier and smooth communication with customers.<br/>

There are already multiple types of parcel tracking apps in the marketplace. However, most of them focus on the tracking only. What we want is, M-Track can become users’ assistant more than tracking. Sharing your tracking easily, contact with your customers smoothly, and see how other users rate carriers, and help u do a better choice next time. We also allow you try our tracking functions without login first, just to make sure you feel satisfied with our app first then become our users.
### Key functions
- Parcel real-time tracking with live-updated map
For each tracking, the information will be shown with the map showing real-
time location.
- In-app tracking information sharing
In the login state, the user can directly establish a conversation with another to easily share the tracking details.
- Tracking systems for receivers and deliverers
Not only the receivers but also the deliverers can use the same tracking system, making tracking details consistent and convenient for communication among the three parties.
- Service rating systems 
  - Carrier rating
  - Delivery rating
  - User evaluation display

A convenient and efficient rating system can be used bidirectionally. For example, receivers can rate the deliverers, carriers and drivers; also, deliverers can rate other users. The rating results will be available for all the users, making the service quality transparent.
- Tracking speed statistics
Would you like to know how long it takes for each tracking to arrive? Here it is. The tracking speed (duration) statistics give you a more intuitive view of the completion efficiency of different orders, and the overall one is available to all users, allowing you to make better choices.
- Data synchronization
Each tracking details can be saved to each account and synchronize among multiple devices. You don’t need to worry about losing data when changing devices.
- Linking with e-shops
No need to switch the apps on background to copy and paste the tracking numbers. Link with the current popular e-commerce shops like eBay, Amazon, to synchronize your order information and start tracking seamlessly.

## Interface desing & storyboard mockups
### Human interface guidelines
The app full storyboards are listed here. All designs are in line with the Apple Human Interface Guidelines (HIG). App icon, color scheme, and the typography it uses will be mentioned in the following part.
- Launching: we provide a launch screen with a head photo, the app name, and different accessing methods including sign-in/up or try without login. It clearly gives users the first impression that what the app is and how it can be used. It also always keep the same orientation whatever people are in the portrait or landscape.

- Navigation: bottom tab bar clarifies the peer function sections and make users easier to switch between them. Current section is highlighted to prompt users where they are.

- Authentication: we have functions which no need user sign in first, which corresponds to the rule “Delay sign-in as long as possible”. We try to make user try our app first, and then make a decision to create an account.
We also provide “Sign in with Apple” as one of the sign-in option, trying to give user a simple and secure way to sign in.

- Data entry: we provide the convenience for users to enter the carrier. It will be auto suggested once tracking number is put or some letters are put.

- Gestures: standard gestures are provided. When deleting one chat, users swipe left the chat from the list and delete button will be shown.

- Adaptivity and layout: Auto layout is applied for M-Track, and each element will have constraint with others, to make sure it can be suitable for different screen sizes. Safe area is also applied to fit the guide. Margins are kept around it.

- Color: M-Track use a set of color scheme which makes sure the color match looks great both in individual and combination, and suitable with light and dark modes.

  - Other colors for special used:

    #FD003A: used for highlight points and notifications dot.

- Dark mode: to correspond with iOS 13, dark mode is also designed for our app. As background changed to dark, the color used is to ensure the users can see the contents still clearly with the same brightness. Two screens are given to show the example dark mode in the mockup.

- Terminology: in the app, as the guide mentioned, we provide short but accurate text hint or description to make users feel comfortable. Language which might sound patronizing is avoided.

- Typography: M-Track uses standard fonts provided by Apple, which is SF pro text with regular and semibold types.

- App icon: the app icon uses the truck to show the fast parcel delivery. the color matches with the theme colors and corresponds to what the guideline mentions. Here provides an App store version.

- Tables: M-Track has several lists which uses tables views. We use the customized table styles but also following the guides using the plain design and keep every row aligned.

## App mockup and hierarchy


## Scope & limitations
Due to function feasibility, some indicated before are unable to be implemented.

Therefore, scope is provided here to clarify the functions that must be completed before the app is released.

Minimum viable product:

|                                                                                         Parcel tracking                                                                                        |                   Chat board                  |                                   Rating system                                  |             Account management            |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:---------------------------------------------:|:--------------------------------------------------------------------------------:|:-----------------------------------------:|
|     1. Create parcel tracking with tracking numbers and carriers     1.1 Suggested carrier list is shown after tracking numbers entered     1.2 Allow users to manually enter carrier          |     1. Add contacts by email address          |     1. Rate carrier     1.1 Give star rating     1.2 Write comment to carrier    |     1. Sign up with email and password    |
|     2. Edit tracking details i.e. tracking numbers and carriers are able to change                                                                                                             |     2. Chat with contact by text              |     2. Check carrier rating list                                                 |     2. Sign in with email and password    |
|     3. Show tracking details with locations in the map                                                                                                                                         |     3. Share tracking details with contact    |     3. Show carrier rating details with carrier name, user rating details        |     3. Sign in with Apple                 |
|                                                                                                                                                                                                |                                               |                                                                                  |     4. Sign in with Google                |
