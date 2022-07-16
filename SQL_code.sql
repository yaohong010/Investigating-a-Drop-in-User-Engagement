/*Check Tables*/
SELECT * 
FROM tutorial.yammer_emails
LIMIT 5

SELECT *
FROM tutorial.yammer_events
LIMIT 5

SELECT *
FROM tutorial.yammer_users
LIMIT 5

/*See what events are categorized as engagement*/
SELECT DISTINCT event_type, event_name
FROM tutorial.yammer_events
ORDER BY event_type, event_name

/*See what's the difference in engagement between months*/
with cte as (
SELECT 
  EXTRACT('month' FROM occurred_at) as month, 
  Count(event_name) as event_count
FROM tutorial.yammer_events
GROUP BY month
)
SELECT *, 
(event_count - LAG(event_count) OVER (ORDER BY month ASC)) as diff
FROM cte



/*count the number of occurrences of each ‘engagement’ event month over month*/
/*Get the change in event_count*/
with two as (
with one as (
SELECT 
  event_name,
  CONCAT(EXTRACT('month' FROM occurred_at), '-', EXTRACT('year' FROM occurred_at)) AS month_year, 
  COUNT(event_name) AS event_count
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY event_name, month_year
)
SELECT *,
  CASE 
    WHEN month_year = '5-2014' THEN 0
    WHEN month_year != '5-2014' THEN (event_count - LAG(event_count) OVER (ORDER BY event_name ASC, month_year ASC))
    ELSE NULL 
  END AS abs_change
FROM one
)
SELECT *
FROM two
WHERE month_year = '8-2014' and abs_change < 0
ORDER BY abs_change


/*to see if the drop was due to a drop in users or a drop in the number of engagements/user*/
-- SELECT
--   EXTRACT('month' FROM occurred_at) as month, 
--   COUNT(DISTINCT user_id) as num_users
-- FROM tutorial.yammer_events
-- WHERE event_type = 'engagement'
-- GROUP BY month;

SELECT 
  EXTRACT('month' FROM occurred_at) as month,
  COUNT(event_name) as num_event,
  COUNT(DISTINCT user_id) as num_users,
  COUNT(event_name)/COUNT(DISTINCT user_id) as events_per_user
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY month;



/*Consider divide users into groups according to device type. Check which group of these users drop.*/
with two as (
with one as (
SELECT 
  device,
  EXTRACT('month' FROM occurred_at) as month,
  COUNT(DISTINCT user_id) as num_users
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY device, month
)
SELECT *, 
  (num_users - LAG(num_users) OVER (PARTITION BY device ORDER BY month)) as diff
FROM one
)
SELECT *
FROM two
WHERE month = 8 and diff < 0
ORDER BY diff ASC


/*Check users' interaction with email service*/
/*Which action drops significantly*/
with one as (
SELECT 
  action, 
  EXTRACT('month' FROM occurred_at) as month, 
  count(action) as num_action
FROM tutorial.yammer_emails
GROUP BY action, month
ORDER BY action, month
)
SELECT *, 
  (num_action - LAG(num_action) OVER (PARTITION BY action)) as diff_num_action
FROM one 



/*Investigate CLR for each device over month*/
/*user_id and date as super key*/
with cte2 as (

with cte as (

with email as (
SELECT 
  user_id, 
  CONCAT(EXTRACT('day' FROM occurred_at), '-', EXTRACT('month' FROM occurred_at), '-', EXTRACT('year' FROM occurred_at)) as date, 
  EXTRACT('month' FROM occurred_at) as month, 
  action
FROM tutorial.yammer_emails
), 
events as (
SELECT 
  DISTINCT user_id, 
  CONCAT(EXTRACT('day' FROM occurred_at), '-', EXTRACT('month' FROM occurred_at), '-', EXTRACT('year' FROM occurred_at)) as date, 
  EXTRACT('month' FROM occurred_at) as month, 
  device
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
)
SELECT
  events.device,
  email.month, 
  COUNT(email.action) as CLR_count
FROM email
LEFT JOIN events ON email.user_id = events.user_id AND email.date = events.date
WHERE email.action = 'email_clickthrough'
GROUP BY events.device, email.month
ORDER BY events.device, email.month

)
SELECT
  *,
  (clr_count - LAG(clr_count) OVER (PARTITION BY device)) as diff_clr
FROM cte

)
SELECT *
FROM cte2
WHERE month = 8
ORDER BY diff_clr




/*See which email category accounts for the drop*/
/*sent_weekly_digest is the one that not contributing much to CLTR*/
with one as (
SELECT 
  *,
  EXTRACT('month' from occurred_at) as month,
  CASE WHEN (LEAD(action, 1) OVER (PARTITION BY user_id ORDER BY occurred_at ASC)) = 'email_open' THEN 1 ELSE 0 END AS opened_email,
  CASE WHEN (LEAD(action, 2) OVER (PARTITION BY user_id ORDER BY occurred_at ASC)) = 'email_clickthrough' THEN 1 ELSE 0 END AS clicked_email
FROM
  tutorial.yammer_emails
)
SELECT 
  action,
  month,
  count(action),
  sum(opened_email) as num_open,
  sum(clicked_email) as num_clicked
FROM
  one
WHERE action in ('sent_weekly_digest','sent_reengagement_email')
GROUP BY
  action,
  month
ORDER BY
  action,
  month;




  /*click through rate change by location*/
-- with cte2 as (

-- with cte as (

-- with email as (
-- SELECT 
--   user_id, 
--   CONCAT(EXTRACT('day' FROM occurred_at), '-', EXTRACT('month' FROM occurred_at), '-', EXTRACT('year' FROM occurred_at)) as date, 
--   EXTRACT('month' FROM occurred_at) as month, 
--   action
-- FROM tutorial.yammer_emails
-- ), 
-- events as (
-- SELECT 
--   DISTINCT user_id, 
--   CONCAT(EXTRACT('day' FROM occurred_at), '-', EXTRACT('month' FROM occurred_at), '-', EXTRACT('year' FROM occurred_at)) as date, 
--   EXTRACT('month' FROM occurred_at) as month, 
--   location
-- FROM tutorial.yammer_events
-- WHERE event_type = 'engagement'
-- )
-- SELECT
--   events.location,
--   email.month, 
--   COUNT(email.action) as CLR_count
-- FROM email
-- LEFT JOIN events ON email.user_id = events.user_id AND email.date = events.date
-- WHERE email.action = 'email_clickthrough'
-- GROUP BY events.location, email.month
-- ORDER BY events.location, email.month

-- )
-- SELECT
--   *,
--   (clr_count - LAG(clr_count) OVER (PARTITION BY location)) as diff_clr
-- FROM cte

-- )
-- SELECT *
-- FROM cte2
-- WHERE month = 8
-- ORDER BY diff_clr