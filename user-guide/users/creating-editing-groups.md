---
title: Group Management
section: user-guide
category: users
---

Users of DataReporter can be members of one or more groups. Each new user is added to the `Default` group automatically. Members of `Admin` can create new groups, add and remove members from groups, and disable users from accessing DataReporter entirely. Each group can be connected to specific data sources. Read more about group permissions [here](/docs/user-guide/users/permissions-groups).

## Creating & Editing Groups

Only members of `Admin` can edit or create groups. Go to `Settings > Groups` and hit **New Group**. Type a name for your new group and the continue.

![](/docs/images/gitbook/group_settings.png)

Add users to your new group by typing their names:

![](/docs/images/gitbook/view_only_group.png)

You can edit details for a group by clicking its name on the groups list in the settings panel. There you can change its name, add or remove users, or associate it with different data sources.

> **Info:** The `Default` and `Admin` groups can't be deleted.

## Making Admins

You can make any user an admin. Just add that user to the `Admin` group. Admins are able to modify data sources, change groups and permissions, disable users, and add further admins. To withdraw admin permissions from a user just remove them from `Admin` group by following the instructions above.

## Disabling Users

Admins can add a user to the `Disabled` group from the `Settings` screen. Find the user on the `Users` tab and click the `Disable` button on the right.

![](/docs/images/gitbook/disable-user.png)

Disabled users cannot login to DataReporter. You can re-enable a disabled user by finding them on the `Disabled` tab.

> **Info:** The `Disabled` tab does not appear unless you have at least one disabled user.
