
# EXPERIMENT - 7: Database Normalization

## AIM

To analyze and determine functional dependencies within a denormalized sales database and normalize it from First Normal Form (1NF) to Third Normal Form (3NF) and Boyce-Codd Normal Form (BCNF). To verify lossless decomposition and dependency preservation using SQL queries.

## OPERATIONS PERFORMED

### 1. Database and Denormalized Table Creation
- Created the `RetailSalesDB` database.
- Created the `Retail_Sales` table containing transaction, buyer, agent, item, and quantity details.
- Inserted six sample sales records.

### 2. Identification of Functional Dependencies
Identified the following functional dependencies:

- `transaction_id → transaction_date, buyer_id, agent_id`
- `buyer_id → buyer_name`
- `agent_id → agent_name`
- `item_id → item_name`
- `(transaction_id, item_id) → qty`

**Candidate Key:** `(transaction_id, item_id)`

### 3. First Normal Form (1NF)
- Verified that all attributes contain atomic values.
- Ensured each row represents a single item in a transaction.
- Displayed the records in sorted order.

### 4. Second Normal Form (2NF)
- Removed partial dependencies by decomposing the original table into:
  - `Transaction_Header`
  - `Item_Catalog`
  - `Transaction_Details`
- Displayed the normalized tables.

### 5. Third Normal Form (3NF)
- Removed transitive dependencies by creating separate tables:
  - `Buyer`
  - `Agent`
  - `Transaction_Header_3NF`
- Displayed the resulting tables.

### 6. Boyce-Codd Normal Form (BCNF)
- Examined the decomposed relations.
- Verified that the determinants of non-trivial functional dependencies are candidate keys or superkeys.

### 7. Lossless Join Verification
- Joined the normalized tables to reconstruct the original sales records.
- Compared the original and reconstructed row counts.

### 8. Dependency Preservation Verification
- Used `COUNT(DISTINCT ...)` queries to verify the functional dependencies between buyer IDs and names, agent IDs and names, and item IDs and names.

## OUTPUT

### 1. Original Denormalized Table

Six records were inserted successfully.

| Transaction ID | Date | Buyer | Agent | Item | Quantity |
|---|---|---|---|---|---:|
| 6001 | 2026-03-10 | Priya | Vikram | Keyboard | 2 |
| 6001 | 2026-03-10 | Priya | Vikram | Mouse | 1 |
| 6002 | 2026-03-11 | Arjun | Pooja | Keyboard | 1 |
| 6002 | 2026-03-11 | Arjun | Pooja | Monitor | 2 |
| 6003 | 2026-03-12 | Priya | Vikram | Mouse | 3 |
| 6003 | 2026-03-12 | Priya | Vikram | Webcam | 1 |

### 2. Normalized Tables

| Table Name | Number of Records |
|---|---:|
| Transaction_Header | 3 |
| Item_Catalog | 4 |
| Transaction_Details | 6 |
| Buyer | 2 |
| Agent | 2 |
| Transaction_Header_3NF | 3 |

### 3. Lossless Join Verification

Expected output:

| original_row_count | reconstructed_row_count |
|---:|---:|
| 6 | 6 |

The matching row counts indicate that all six original records can be reconstructed using the specified joins.

### 4. Dependency Preservation Verification

**Buyer Table**

| buyer_id | assigned_names |
|---:|---:|
| 30 | 1 |
| 40 | 1 |

**Agent Table**

| agent_id | assigned_names |
|---:|---:|
| 903 | 1 |
| 904 | 1 |

**Item Catalog Table**

| item_id | assigned_names |
|---:|---:|
| 401 | 1 |
| 402 | 1 |
| 403 | 1 |
| 404 | 1 |

Each buyer, agent, and item ID maps to exactly one distinct name in its respective table.

## RESULT

The denormalized sales database was decomposed into normalized tables through 3NF, and the resulting relations were examined for BCNF. The lossless join query returned matching row counts, and the dependency verification queries confirmed unique name mappings.

## CONCLUSION

Database normalization reduced redundant data and helped prevent insertion, update, and deletion anomalies. The SQL operations demonstrated the reconstruction of the original dataset and verified the selected functional dependencies.
