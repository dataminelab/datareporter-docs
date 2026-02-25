---
title: Getting Started
description: Getting started with Redash is easy and takes only a few minutes - connect a data source, write a query, add a visualization, create a dashboard and invite your colleagues!
section: user-guide
category: getting-started
order: 1
toc: true
keywords:
  - Add Data Source
  - datasource
  - datasources
  - adding datasource
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/Yn3_QDk2qQM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## 1. Add A Data Source

The first thing you'll want to do is connect a data source ([see supported data sources](/docs/data-sources/setup/supported-data-sources/)). You can open the Data Sources management page by clicking the Settings icon:

![](/docs/images/settings_icon.png)

> **Note:** If you’re using the Hosted Redash service and your data source is behind a firewall, you need to **allow access from the IP address `52.71.84.157`** in your database firewall/Security Groups.

> **Note:** We recommend using a user with **read-only permissions**, if possible.

![](/docs/images/gitbook/add-data-source.gif)

## 2. Write A Query

Once you've connected a data source, it's time to write a query: **click on "Create" in the navigation bar, and then choose "Query"**. See the [“Writing Queries” page](/docs/user-guide/querying/writing-queries/) for detailed instructions on how to write queries.

![](/docs/images/gifs/queries/add_new_query.gif)

## 3. Add Visualizations

By default, your query results (data) will appear in a simple table. Visualizations are much better to help you digest complex information, so let's visualize your data. DataReporter supports [multiple types of
visualizations](/docs/user-guide/visualizations/visualization-types/) so you should find one that suits your needs.

Click the “New Visualization” button just above the results to select the perfect visualization for your needs. You can view more detailed instructions [here](/docs/user-guide/visualizations/visualizations-how-to/).

![](/docs/images/gifs/visualization/new_viz.gif)

## 4. Create A Dashboard

You can combine visualizations and text into thematic & powerful dashboards. Add a new dashboard by clicking on "Create" in the navigation bar, and then choose "Dashboard". Dashboards are visible for your team members or they can be shared publicly. For more details, [click here](/docs/user-guide/dashboards/dashboard-editing/).

![](/docs/images/gifs/dashboards/dashboards.gif)

## 5. Invite Colleagues

DataReporter is better together.

Admins, to start enjoying the collaborative nature of DataReporter you'll want to invite your team!

Users can view team member's queries for inspiration (or debugging 😉), fork them to create similar queries of their own, view & create dashboards, and share insights with others via Email, Slack, Mattermost or HipChat.

Users can only be invited by admins - to invite a new user go to `Settings`>`Users` and hit `New User`:

![](/docs/images/gitbook/add-user.png)

Then, fill in their name and email. They'll get an invite via email and be required to set up a DataReporter account.

To add a user to an existing group, go to `Setting`>`Groups`, select the group and add users by typing their name:

![](/docs/images/gitbook/view-only-groups.png)
