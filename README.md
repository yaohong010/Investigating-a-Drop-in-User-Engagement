# Investigating-a-Drop-in-User-Engagement
In this case study, I managed to investigate a drop in user engagement in Yammer. (The Case Study is provided by Mode, and you can find it [here](https://mode.com/sql-tutorial/a-drop-in-user-engagement/)

## Problem

Yammer is a social network for communicating with coworkers. Individuals share documents, updates, and ideas by posting them in groups. Yammer is free to use indefinitely, but companies must pay license fees if they want access to administrative controls, including integration with user management systems like ActiveDirectory.

Yammer noticed a drop in Weekly Active Users, “the number of users who logged at least one engagement event during the week starting on that date”. Engagement is defined as having made some types of server call by interacting with the product (shown in the data as events of type “engagement”.)

My goal is to find out what causes the decrease in weekly active users shown in the [plot](https://app.mode.com/modeanalytics/reports/cbb8c291ee96/runs/7925c979521e/viz1/cfcdb6b78885) below:




## Plan

I first brainstorm some potential causes for the drop in engagement:

-
-
-

## Data

There are four tables in total.

### Table1 Users:

This table includes one row per user, with descriptive information about that user's account.



### Table2 Events:

This table includes one row per event, where an event is an action that a user has taken on Yammer. These events include login events, messaging events, search events, events logged as users progress through a signup funnel, events around received emails.



### Table3 

This table contains events specific to the sending of emails. It is similar in structure to the events table above.



### Table 4

The last table is a lookup table that is used to create rolling time periods. 



## Analysis


## Conclusion


## Recommendation


## Further Analysis

