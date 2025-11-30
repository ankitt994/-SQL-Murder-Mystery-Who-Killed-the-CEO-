/*Who entered the CEO’s Office close to the time of the murder?*/
SELECT kl.employee_id, 
e.name, e.department, 
e.role, kl.room, 
kl.entry_time, 
kl.exit_time
 FROM keycard_logs kl
 INNER JOIN employees e
 ON kl.employee_id = e.employee_id
WHERE kl.room = "CEO Office";

/*Who claimed to be somewhere else but was not?*/
 SELECT
 a.employee_id, 
 a.claimed_location,
 a.claim_time, 
 k.room,
 k.entry_time, 
 k.exit_time
 FROM alibis a
 INNER JOIN keycard_logs k ON a.employee_id = k.employee_id
 WHERE k.room = "CEO Office";
 

 /*Who made or received calls around 20:50–21:00?*/
SELECT 
c.call_id,
c.caller_id, 
caller.name as caller_name,
c.receiver_id,
receiver.name as receiver_name,
DATE_ADD(c.call_time, INTERVAL c.duration_sec SECOND) as call_end_time
FROM calls c
JOIN employees as caller
ON c.caller_id = caller.employee_id
JOIN employees as receiver
ON c.receiver_id = receiver.employee_id
WHERE c.call_time <= '2025-10-15 21:00:00' AND
DATE_ADD(c.call_time, INTERVAL c.duration_sec SECOND) 
>= '2025-10-15 20:00:00';

 /*What evidence was found at the crime scene?*/
WITH room_logs_cte AS (
    SELECT 
        k.employee_id,k.room,k.entry_time,k.exit_time,e.evidence_id,
        e.found_time,
        ROW_NUMBER() OVER (
            PARTITION BY e.room, e.evidence_id
            ORDER BY k.entry_time DESC
	) AS rn
    FROM evidence AS e
    JOIN keycard_logs AS k
        ON e.room = k.room
       AND k.entry_time <= e.found_time)
SELECT 
    r.evidence_id,r.room,r.found_time, r.employee_id, emp.name, r.entry_time,
    r.exit_time
FROM room_logs_cte AS r
JOIN employees AS emp
    ON emp.employee_id = r.employee_id
WHERE r.rn = 1
ORDER BY r.evidence_id;
 
  /*Which suspect’s movements, alibi, and call activity don’t add up?*/
 SELECT DISTINCT
    CONCAT('Name of Killer: ', e.name) AS Killer
FROM employees e
JOIN
    alibis a ON e.employee_id = a.employee_id
JOIN
    keycard_logs l ON e.employee_id = l.employee_id
WHERE
    l.room = 'CEO Office'
    AND a.claimed_location <> l.room
    AND l.entry_time BETWEEN '2025-10-15 20:30:00' AND '2025-10-15 21:30:00';
 
 
 
 
 
 
 
 
