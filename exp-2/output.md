# Experiment 2 — Output

The outputs below show the expected results from the sample data in `exp-2.sql`. Error text can vary slightly by MySQL version and by foreign-key naming, but the cause is the same.

## Output 1 — Referential-integrity violation

Run this statement separately after creating the tables and sample data:

```sql
INSERT INTO Orders (OrderID, OrderDate, OrderStatus, TotalAmount, CustomerID)
VALUES (599, '2026-08-15', 'pending', 500.00, 999);
```

**Expected result:** The insert is rejected because customer `999` does not exist in `Customer`.

```text
ERROR 1452 (23000): Cannot add or update a child row:
a foreign key constraint fails (`ecommerce`.`orders`,
CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`)
REFERENCES `customer` (`CustomerID`) ON DELETE CASCADE)
```

This demonstrates referential integrity: an order cannot reference a nonexistent customer.

## Output 2 — `ON DELETE SET NULL`

The SQL executes:

```sql
DELETE FROM Category WHERE CategoryID = 1;

SELECT ProductID, ProductName, CategoryID
FROM Product
ORDER BY ProductID;
```

Expected result:

| ProductID | ProductName | CategoryID |
|---:|---|---:|
| 101 | Gaming Laptop | `NULL` |
| 102 | Cotton Shirt | 2 |
| 103 | DBMS | 3 |

The category row is deleted, but Product 101 remains. Its `CategoryID` is set to `NULL` because the foreign key uses `ON DELETE SET NULL`.

## Output 3 — `ON DELETE CASCADE`

The SQL executes:

```sql
DELETE FROM Customer WHERE CustomerID = 1;
SELECT * FROM Orders ORDER BY OrderID;
SELECT * FROM Customer_Phone ORDER BY CustomerID, Phone;
```

Expected `Orders` result:

| OrderID | OrderDate | OrderStatus | TotalAmount | CustomerID |
|---:|---|---|---:|---:|
| 502 | 2026-08-10 | shipped | 1200.00 | 2 |

Expected `Customer_Phone` result:

| CustomerID | Phone |
|---:|---|
| 2 | 9908776655 |

The order belonging to Customer 1 and Customer 1's phone record are deleted automatically. Customer 2's records remain. In this implementation, dependent order items, payment records, and delivery records for deleted orders are also removed via their own cascade rules.

## Result

The relational schema is implemented with primary and foreign keys, `NOT NULL`, `UNIQUE`, `ON DELETE SET NULL`, and `ON DELETE CASCADE` constraints. Sample queries demonstrate a foreign-key violation, nullable foreign-key behavior, and cascading deletion.
