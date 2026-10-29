
-- EXPERIMENT 7: Database Normalization
-- Database: RetailSalesDB

CREATE DATABASE IF NOT EXISTS RetailSalesDB;
USE RetailSalesDB;

-- 1. Create denormalized table
DROP TABLE IF EXISTS Transaction_Details;
DROP TABLE IF EXISTS Transaction_Header_3NF;
DROP TABLE IF EXISTS Transaction_Header;
DROP TABLE IF EXISTS Item_Catalog;
DROP TABLE IF EXISTS Buyer;
DROP TABLE IF EXISTS Agent;
DROP TABLE IF EXISTS Retail_Sales;

CREATE TABLE Retail_Sales (
    transaction_id INT,
    transaction_date DATE,
    buyer_id INT,
    buyer_name VARCHAR(50),
    agent_id INT,
    agent_name VARCHAR(50),
    item_id INT,
    item_name VARCHAR(50),
    qty INT
);

INSERT INTO Retail_Sales VALUES
(6001, '2026-03-10', 30, 'Priya', 903, 'Vikram', 401, 'Keyboard', 2),
(6001, '2026-03-10', 30, 'Priya', 903, 'Vikram', 402, 'Mouse', 1),
(6002, '2026-03-11', 40, 'Arjun', 904, 'Pooja', 401, 'Keyboard', 1),
(6002, '2026-03-11', 40, 'Arjun', 904, 'Pooja', 403, 'Monitor', 2),
(6003, '2026-03-12', 30, 'Priya', 903, 'Vikram', 402, 'Mouse', 3),
(6003, '2026-03-12', 30, 'Priya', 903, 'Vikram', 404, 'Webcam', 1);

-- Display denormalized data
SELECT * FROM Retail_Sales;

-- 2. First Normal Form (1NF)
-- Every attribute contains atomic values.
SELECT transaction_id, transaction_date, buyer_id, buyer_name,
       agent_id, agent_name, item_id, item_name, qty
FROM Retail_Sales
ORDER BY transaction_id, item_id;

-- 3. Second Normal Form (2NF)
-- Separate transaction header, item catalog and transaction details.

CREATE TABLE Transaction_Header AS
SELECT DISTINCT transaction_id, transaction_date, buyer_id,
       buyer_name, agent_id, agent_name
FROM Retail_Sales;

CREATE TABLE Item_Catalog AS
SELECT DISTINCT item_id, item_name
FROM Retail_Sales;

CREATE TABLE Transaction_Details AS
SELECT transaction_id, item_id, qty
FROM Retail_Sales;

SELECT * FROM Transaction_Header ORDER BY transaction_id;
SELECT * FROM Item_Catalog ORDER BY item_id;
SELECT * FROM Transaction_Details
ORDER BY transaction_id, item_id;

-- 4. Third Normal Form (3NF)
-- Remove transitive dependencies by separating buyers and agents.

CREATE TABLE Buyer AS
SELECT DISTINCT buyer_id, buyer_name
FROM Transaction_Header;

CREATE TABLE Agent AS
SELECT DISTINCT agent_id, agent_name
FROM Transaction_Header;

CREATE TABLE Transaction_Header_3NF AS
SELECT transaction_id, transaction_date, buyer_id, agent_id
FROM Transaction_Header;

SELECT * FROM Buyer ORDER BY buyer_id;
SELECT * FROM Agent ORDER BY agent_id;
SELECT * FROM Transaction_Header_3NF ORDER BY transaction_id;

-- 5. BCNF verification
-- Check the decomposed relations.

SELECT buyer_id, buyer_name FROM Buyer;
SELECT agent_id, agent_name FROM Agent;
SELECT item_id, item_name FROM Item_Catalog;

SELECT transaction_id, transaction_date, buyer_id, agent_id
FROM Transaction_Header_3NF;

SELECT transaction_id, item_id, qty
FROM Transaction_Details;

-- 6. Verify lossless reconstruction
-- Each transaction has one header and each item has one catalog record.

SELECT
    (SELECT COUNT(*) FROM Retail_Sales) AS original_row_count,
    (
        SELECT COUNT(*)
        FROM Transaction_Header_3NF H
        JOIN Buyer B
            ON H.buyer_id = B.buyer_id
        JOIN Agent A
            ON H.agent_id = A.agent_id
        JOIN Transaction_Details D
            ON H.transaction_id = D.transaction_id
        JOIN Item_Catalog I
            ON D.item_id = I.item_id
    ) AS reconstructed_row_count;

-- 7. Verify dependency preservation
-- Each determinant should map to one distinct attribute value.

SELECT buyer_id,
       COUNT(DISTINCT buyer_name) AS assigned_names
FROM Buyer
GROUP BY buyer_id;

SELECT agent_id,
       COUNT(DISTINCT agent_name) AS assigned_names
FROM Agent
GROUP BY agent_id;

SELECT item_id,
       COUNT(DISTINCT item_name) AS assigned_names
FROM Item_Catalog
GROUP BY item_id;
