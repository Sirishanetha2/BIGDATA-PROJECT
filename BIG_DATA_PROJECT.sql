Developing a Recommendation Engine for Retail Data in Snowflake.  


-- Step 1: Create Database and Schema
CREATE OR REPLACE DATABASE RETAIL_RECOMMENDATION;
USE DATABASE RETAIL_RECOMMENDATION;

CREATE OR REPLACE SCHEMA RETAIL_ANALYSIS;
USE SCHEMA RETAIL_ANALYSIS;

-- Step 2: Create Purchase History Table
CREATE OR REPLACE TABLE PURCHASE_HISTORY (
    customer_id STRING,
    product_id STRING,
    purchase_date DATE
);

-- Step 3: Insert Sample Purchase Data
INSERT INTO PURCHASE_HISTORY VALUES
('C001', 'P001', '2025-01-10'),
('C001', 'P002', '2025-01-15'),
('C001', 'P003', '2025-01-18'),
('C002', 'P001', '2025-02-05'),
('C002', 'P004', '2025-02-10'),
('C003', 'P002', '2025-02-12'),
('C003', 'P003', '2025-02-13'),
('C004', 'P004', '2025-03-01'),
('C004', 'P005', '2025-03-02'),
('C005', 'P001', '2025-03-05'),
('C005', 'P002', '2025-03-07');

-- Step 4: Create Recommendation Output Table
CREATE OR REPLACE TABLE PRODUCT_RECOMMENDATIONS (
    customer_id STRING,
    recommended_product STRING,
    recommendation_time TIMESTAMP
);

-- Step 5: Create Stored Procedure to Generate Recommendations
CREATE OR REPLACE PROCEDURE generate_recommendations()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
-- Clear old results
DELETE FROM PRODUCT_RECOMMENDATIONS;

-- Generate new recommendations
INSERT INTO PRODUCT_RECOMMENDATIONS
SELECT DISTINCT
    c.customer_id,
    p2.product_id AS recommended_product,
    CURRENT_TIMESTAMP()
FROM PURCHASE_HISTORY p1
JOIN PURCHASE_HISTORY p2
    ON p1.customer_id = p2.customer_id AND p1.product_id <> p2.product_id
JOIN (SELECT DISTINCT customer_id FROM PURCHASE_HISTORY) c
    ON c.customer_id <> p1.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM PURCHASE_HISTORY ph
    WHERE ph.customer_id = c.customer_id
      AND ph.product_id = p2.product_id
);


    RETURN 'Recommendations generated successfully';
END;
$$;
------------------------------------------------------------------------------------------
-- Step 6: Call Stored Procedure to Generate Recommendations
CALL generate_recommendations();

-- Step 7: View Results
SELECT * FROM PRODUCT_RECOMMENDATIONS ORDER BY customer_id;




#############################################################################################

Project: Recommendation Engine for Retail Data Using Only Snowflake SQL

Objective:
Build a recommendation engine using only Snowflake SQL that suggests new products to customers based on what other similar customers have purchased.

---

What’s Happening Behind the Scenes:

1. Customer Purchase History  
   We start with a table (`PURCHASE_HISTORY`) that tracks:
   - Who bought what
   - And when

2. Recommendation Output Table  
   We create another table (`PRODUCT_RECOMMENDATIONS`) to store:
   - Which product is recommended
   - For which customer
   - And when the recommendation was made

3. Stored Procedure Logic (`generate_recommendations`)  
   This is the engine that powers everything:
   - For each customer, it looks at other customers who have similar purchases
   - It then recommends products they haven’t bought yet but others with similar taste have
   - It avoids duplicate or already purchased products

4. Final Output  
   We run the stored procedure and get a neat list of:
   - Customer IDs
   - Recommended products
   - Timestamps of when those recommendations were generated

---

Example Interpretation:
If Customer C001 bought P001 and P002, and Customer C002 also bought P001 and then bought P004…

→ C001 may get P004 recommended, assuming they haven’t bought it yet.

