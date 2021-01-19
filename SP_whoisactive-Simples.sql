SELECT     QP.query_plan, r.start_time [Start Time],r.session_ID [SPID],
            DB_NAME(r.database_id) [Database],
            SUBSTRING(t.text,(r.statement_start_offset/2)+1,
            CASE WHEN statement_end_offset=-1 OR statement_end_offset=0
            THEN (DATALENGTH(t.Text)-r.statement_start_offset/2)+1
            ELSE (r.statement_end_offset-r.statement_start_offset)/2+1
            END) [Executing Statment],
            r.Status,command,wait_type,wait_time,wait_resource,
            last_wait_type, t.text as Text, r.reads, r.writes,s.host_name, s.program_name, s.client_interface_name
FROM        sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY  sys.dm_exec_query_plan(r.plan_handle) AS QP
WHERE       r.session_id != @@SPID -- don't show this query
AND         r.session_id > 50 -- don't show system queries
ORDER BY    r.start_time
