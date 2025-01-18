### 11/22/24
New and working alert system.
- Saves collapse of system and message.
- Right click to hide system for rest of session (per Lua load).
- Shows items in changeLog per mod.
#

### 11/22/24 #2
- Shifted UI for collapsed alert over a bit.
- Added message-header to translatable text.
#

### 11/24/24
- Fixes edge case with update logs.
#

### 12/20/24
- Fix edge case with alert display.
#

### 12/23/24
- Fixed issues with B41/B42 not able to mutually read change logs.
- Moved changelog's placement into `common`.
#

### 12/23/24 hotfix #1
- Fixed issue with hiding the system.
#

#### 12/30/24
- Fixed issue with un-collapsing sometimes not respecting the dropMessage's status.
#

<!-- ALERT_CONFIG
link1 = Chuck's Kofi = https://steamcommunity.com/linkfilter/?u=https://ko-fi.com/chuckleberryfinn,
link2 = Workshop = https://steamcommunity.com/id/Chuckleberry_Finn/myworkshopfiles/?appid=108600,
link3 = Github = https://steamcommunity.com/linkfilter/?u=https://github.com/Chuckleberry-Finn,
-->


### 1/18/25 - Remaster for B42 ###
Remastered the UI to be more streamlined based on feedback:
- No longer separate mod-alert and drop message.
- The first alert will remain a message about supporting modding, the rest will be customizable alerts per mod.
- The alert symbol will be marked red when new alerts are found, to be cleared as they are read-through.
- Subsequent reloads will mark all alerts as old.
- Added more UI to allow for scrolling forward/back along the alerts list.

The system has been remastered into a true API - so that any mod-author can make use of it:
- As before only requires mod-author to include a ChangeLog.txt (Now expected in /common/ for B42+, as before /media/ for B41-)
- Alerts support programmable buttons by the mod's respective author.
- Well known sites are color-coded and override a provided title with a logo.
See: ChangeLog.txt entry: ALERT_CONFIG for an example.
#