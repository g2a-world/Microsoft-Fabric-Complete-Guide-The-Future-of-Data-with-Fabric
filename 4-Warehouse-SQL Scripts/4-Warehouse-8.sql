-- ******* Performance *********

-- Validate table auto-created statistics
select
    object_name(s.object_id) AS [object_name],
    c.name AS [column_name],
    s.name AS [stats_name],
    s.stats_id,
    STATS_DATE(s.object_id, s.stats_id) AS [stats_update_date], 
    s.auto_created,
    s.user_created,
    s.stats_generation_method_desc 
FROM sys.stats AS s -- automatically generated by the engine to improve query plans
INNER JOIN sys.objects AS o 
ON o.object_id = s.object_id 
INNER JOIN sys.stats_columns AS sc 
ON s.object_id = sc.object_id 
AND s.stats_id = sc.stats_id 
INNER JOIN sys.columns AS c 
ON sc.object_id = c.object_id 
AND c.column_id = sc.column_id
WHERE o.type = 'U' -- Only check for stats on user-tables
    AND s.auto_created = 1
    AND o.name = 'instacart_orders'
ORDER BY object_name, column_name;

-- obtain details on automatically generated histogram statistic
DBCC SHOW_STATISTICS ('instacart_orders', '_WA_Sys_00000008_5FB337D6');




-- ******* Monitoring *********

-- find all sessions that are currently active
SELECT * FROM sys.dm_exec_sessions;

-- relationship between connections and sessions
SELECT connections.connection_id,
 connections.connect_time,
 sessions.session_id, sessions.login_name, sessions.login_time, sessions.status
FROM sys.dm_exec_connections AS connections
INNER JOIN sys.dm_exec_sessions AS sessions ON connections.session_id=sessions.session_id;

-- user who are executing long-running querie
SELECT r.request_id, r.session_id, r.start_time, r.total_elapsed_time, s.login_name
FROM sys.dm_exec_requests as r
INNER JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
WHERE r.status = 'running'
ORDER BY r.total_elapsed_time DESC;

-- kill connection using session_idd
KILL '<??>'

