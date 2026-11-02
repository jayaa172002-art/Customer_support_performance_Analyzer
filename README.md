# 03 — Customer Support Performance Analyzer | Customer Experience

> **Business Question:** What is driving support workload, which issues take longest to resolve, and where could a support team improve?

I wanted to follow the real analytics path: messy data -> cleaning -> analysis -> insight -> recommendation. That's what this project is.

### 1. The Raw Problem
I started with a support ticket dataset of 8,469 tickets. It had ticket ID, created date, category, priority, channel, product, status, resolution time, CSAT - everything a real support team would have.

But it was messy:
- `customer_satisfaction_rating` had 0s instead of NULL, so AVG was showing 0.97 instead of actual 2.99
- Text columns had mixed cases (High, HIGH, high)
- Dates and resolution times were inconsistent

### 2. What I Did

**Python Cleaning (data/cleaned_support.csv)**
I wrote `scripts/cleaning.py` to:
- Standardize labels (priority, status, channel, category)
- Fix dates and parse resolution time
- Replace 0 CSAT with proper imputation. This fixed the AVG from 0.97 to 2.99
- Final output: 8469 rows x 17 columns, perfectly balanced - High 2085, Critical 2129, Medium 2192, Low 2063

**SQL - The KPIs (sql/customer_support_queries.sql)**
I did all calculations in PostgreSQL to keep it real:
- Total Tickets = 8469
- Avg Resolution = 7.74 hours
- Avg CSAT = 2.99
- SLA Breach: I defined breach as any ticket where Status is Open or Pending Customer Response AND Priority is Critical or High.
  Because if a high priority ticket is still open, it's already breaching.
```sql
ALTER TABLE support_tickets ADD COLUMN sla_breach INT;
UPDATE support_tickets SET sla_breach = 0;
UPDATE support_tickets SET sla_breach = 1 
WHERE ticket_status IN ('Open','Pending Customer Response') 
AND ticket_priority IN ('Critical','High');
-- Result: 1396 breached = 16.48%
-- High: 704, Critical: 692, Low/Medium: 0

## 3. Power BI- Support Command Center
Built a 3-page interactive dashboard Customer_Support_CSAT_Performance_Dashboard.pbix with date slicer (01-01-2020 to 30-12-2021), ticket_priority
and ticket_channel filters.
Page 1 Overview: Total Tickets 8469, SLA Breach % 16.48%, Total Breached 1396, SLA_Breach by Priority, SLA_Breach by Products (Canon EOS,
Philips Hue Lights highest).
Page 2 Workload and Resolution: Avg Resolution 7.74, Avg CSAT 2.99, Ticket Workload Status donut (Pending 34.02% - 2881, Open 33.29% - 2819,
Closed 32.7% - 2769), Priority vs Resolution Time.
Page 3 CSAT & Performance: CSAT Trend Over Time (Is Satisfaction Dropping?), Workload vs Effort Matrix, Channel Load as Team Proxy (Email 2136,
Phone 2100, Social 2127, Chat 2106)

## Answers to the Brief's Questions
Which issue types create the most workload?
Refund + Cancellation requests = 3,445 tickets = 40.6% of total workload. They dominate.

Which high-volume issues also have long resolution times?
High Priority tickets take 8.20 hours avg vs Medium 7.36 hours. Refund/Cancellation avg 8.11h resolution + 704 SLA breaches.

Does priority actually correlate with faster resolution?
No. This is the biggest finding. High Priority has the LONGEST resolution (8.20h). Priority is not driving faster resolution - routing is broken.
That's the "Routing Issue Found" in my dashboard.

## Key Insight & Recommendations (Based on MY data)From my dashboard
 - High Priority tickets have longest Avg Resolution (8.20h) vs Medium (7.3h). Refund + Cancellation = 3,445 tickets (40.6% workload) + 8.1h Resolution + 704 SLA Breaches.

## Recommendation 1: Automate the top 40%
Build a Self-Serve Refund Eligibility Checker on the website/app and a detailed KB article for Cancellation queries.
 Most Refund tickets are "where is my refund?" which can be answered by an order status check.

Recommendation 2: Fix Priority Routing
Auto-route all High and Critical priority tickets to senior agents, not the general queue.
Currently they go to same pool, so they take longer.

## Recommendation 3: Product-Specific Fix
Canon EOS, Philips Hue Lights, Fitbit Charge have highest SLA breach (40+ each).
 Need a product-specific FAQ and QA check for these.

## Recommendation 4: Reduce Pending Time
34% tickets are Pending Customer Response. Add proactive auto-reminders and close loop after 48 hours to reduce workload.

**Quantified Impact:**
If we automate just 30% of Refund tickets (∼1,030 tickets), we save ∼8,350 hours/year, reduce SLA Breach from 16.48% to ∼11%
and improve CSAT from 2.99 to ∼3.2.5.
**Tech Stack:**
Python (Pandas), PostgreSQL (pgAdmin), Power BI
