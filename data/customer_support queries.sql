DROP TABLE IF EXISTS support_tickets;  

CREATE TABLE support_tickets (
    ticket_id VARCHAR(100) PRIMARY KEY,
	customer_name VARCHAR(200),
	customer_email VARCHAR(200),
	customer_age INT,
	customer_gender VARCHAR(20),
	product_purchased VARCHAR(100),
	date_of_purchase TIMESTAMP,
	ticket_type VARCHAR(100),
	ticket_subject VARCHAR(100),
	ticket_description TEXT,
	ticket_status VARCHAR(50),
	resolution TEXT,
	ticket_priority VARCHAR(50),
	ticket_channel VARCHAR(50),
	first_response_time VARCHAR(50),
	time_to_resolution VARCHAR(50),
	customer_satisfaction_rating FLOAT
);	

SELECT COUNT(*)
FROM support_tickets;


SELECT ticket_priority, COUNT(*)
FROM support_tickets
GROUP BY ticket_priority;

SELECT AVG(customer_satisfaction_rating)
FROM support_tickets;


-- Add SLA column
ALTER TABLE support_tickets
ADD COLUMN sla_breach INT;

-- Fill SLA column:
UPDATE support_tickets
SET sla_breach = 0;

-- fill SLA based on actual resolution time
-- time_to_resolution column has vaues like '2 days 5 hours'
-- so check for days


UPDATE support_tickets
SET sla_breach = 1
WHERE (ticket_priority = 'Critical' AND time_to_resolution LIKE '%day%')
OR
(ticket_priority = 'High' AND time_to_resolution LIKE '%3day%' OR time_to_resolution LIKE '%4day%' OR time_to_resolution LIKE '%5day%' OR time_to_resolution Like '%day%')
OR
(ticket_priority = 'Medium' AND time_to_resolution LIKE '%5day%')
OR
(ticket_status IN ('Open', 'pending Customer Response') AND ticket_priority in ('Critical', 'High'));

--check total
SELECT COUNT(*) AS total_breach
FROM support_tickets
WHERE sla_breach = 1;	

SELECT ticket_priority, time_to_resolution, sla_breach
FROM support_tickets
LIMIT 10;

