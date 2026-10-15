-- =========================================================
-- EXPERIMENT 2
-- Convert the Indian e-commerce ER diagram into relational
-- tables and demonstrate primary keys, foreign keys, NOT NULL,
-- UNIQUE, ON DELETE CASCADE, ON DELETE SET NULL, and
-- referential-integrity violations.
--
-- Database: ecommerce
-- DBMS: MySQL 8.x
--
-- NOTE: This script recreates the tables listed below. If you
-- already have tables with these names in ecommerce, they will
-- be dropped and recreated.
-- =========================================================

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Clothing;
DROP TABLE IF EXISTS Electronics;
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS Seller_Product;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Customer_Phone;
DROP TABLE IF EXISTS Seller;
DROP TABLE IF EXISTS Customer;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. CUSTOMER
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(120) NOT NULL UNIQUE,
    DateOfBirth DATE
);

-- 2. CUSTOMER_PHONE
-- Composite primary key: (CustomerID, Phone)
-- A customer's phone rows are deleted when that customer is deleted.
CREATE TABLE Customer_Phone (
    CustomerID INT NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (CustomerID, Phone),
    CONSTRAINT fk_customer_phone_customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);

-- 3. ADDRESS
CREATE TABLE Address (
    AddressID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    HouseNo VARCHAR(30),
    Street VARCHAR(100) NOT NULL,
    City VARCHAR(60) NOT NULL,
    State VARCHAR(60) NOT NULL,
    Pincode VARCHAR(10) NOT NULL,
    CONSTRAINT fk_address_customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);

-- 4. CATEGORY
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(80) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- 5. PRODUCT
-- CategoryID is nullable so ON DELETE SET NULL can be demonstrated.
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(120) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Brand VARCHAR(80),
    Stock INT NOT NULL DEFAULT 0,
    CategoryID INT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
        ON DELETE SET NULL,
    CONSTRAINT chk_product_price CHECK (Price >= 0),
    CONSTRAINT chk_product_stock CHECK (Stock >= 0)
);

-- 6. SELLER
CREATE TABLE Seller (
    SellerID INT PRIMARY KEY,
    SellerName VARCHAR(100) NOT NULL,
    Email VARCHAR(120) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    GSTIN VARCHAR(20) UNIQUE
);

-- 7. SELLER_PRODUCT (many-to-many relationship)
-- Composite primary key: (SellerID, ProductID)
CREATE TABLE Seller_Product (
    SellerID INT NOT NULL,
    ProductID INT NOT NULL,
    PRIMARY KEY (SellerID, ProductID),
    CONSTRAINT fk_seller_product_seller
        FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
        ON DELETE CASCADE,
    CONSTRAINT fk_seller_product_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE
);

-- 8. ORDERS
-- This FK is intentionally named orders_ibfk_1 to match the
-- constraint name visible in the supplied handwritten output.
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    CustomerID INT NOT NULL,
    CONSTRAINT orders_ibfk_1
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE,
    CONSTRAINT chk_order_total CHECK (TotalAmount >= 0)
);

-- 9. ORDERITEM
-- Composite primary key: (OrderID, ItemNo)
CREATE TABLE OrderItem (
    OrderID INT NOT NULL,
    ItemNo INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ItemNo),
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT chk_orderitem_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_orderitem_price CHECK (UnitPrice >= 0)
);

-- 10. PAYMENT
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    TransactionID VARCHAR(80) NOT NULL UNIQUE,
    PaymentStatus VARCHAR(30) NOT NULL,
    CONSTRAINT fk_payment_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);

-- 11. DELIVERY
CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    DeliveryDate DATE,
    DeliveryStatus VARCHAR(30) NOT NULL,
    TrackingNo VARCHAR(80) UNIQUE,
    CourierName VARCHAR(80),
    CONSTRAINT fk_delivery_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);

-- 12. PRODUCT SPECIALIZATION: ELECTRONICS
CREATE TABLE Electronics (
    ProductID INT PRIMARY KEY,
    Warranty VARCHAR(50),
    CONSTRAINT fk_electronics_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE
);

-- 13. PRODUCT SPECIALIZATION: CLOTHING
CREATE TABLE Clothing (
    ProductID INT PRIMARY KEY,
    Size VARCHAR(20),
    Gender VARCHAR(30),
    Material VARCHAR(50),
    CONSTRAINT fk_clothing_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE
);

-- 14. PRODUCT SPECIALIZATION: BOOKS
CREATE TABLE Books (
    ProductID INT PRIMARY KEY,
    Author VARCHAR(100) NOT NULL,
    Publisher VARCHAR(100),
    CONSTRAINT fk_books_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE
);

-- =========================================================
-- SAMPLE DATA
-- =========================================================

INSERT INTO Customer (CustomerID, CustomerName, Email, DateOfBirth) VALUES
(1, 'Aarav Sharma', 'aarav@example.com', '2004-02-14'),
(2, 'Meera Verma', 'meera@example.com', '2003-08-21');

INSERT INTO Customer_Phone (CustomerID, Phone) VALUES
(1, '9876501234'),
(2, '9908776655');

INSERT INTO Address (AddressID, CustomerID, HouseNo, Street, City, State, Pincode) VALUES
(1, 1, '12A', 'MG Road', 'Lucknow', 'Uttar Pradesh', '226001'),
(2, 2, '44B', 'Park Street', 'Kanpur', 'Uttar Pradesh', '208001');

INSERT INTO Category (CategoryID, CategoryName, Description) VALUES
(1, 'Electronics', 'Electronic devices and accessories'),
(2, 'Clothing', 'Clothing and apparel'),
(3, 'Books', 'Books and study material');

INSERT INTO Product (ProductID, ProductName, Price, Brand, Stock, CategoryID) VALUES
(101, 'Gaming Laptop', 85000.00, 'NovaTech', 12, 1),
(102, 'Cotton Shirt', 799.00, 'Everyday', 50, 2),
(103, 'DBMS', 1200.00, 'Academic Press', 25, 3);

INSERT INTO Seller (SellerID, SellerName, Email, Phone, GSTIN) VALUES
(10, 'Tech Store', 'techstore@example.com', '9123456780', '09ABCDE1234F1Z5'),
(20, 'Campus Books', 'books@example.com', '9234567890', '09BCDEF2345G1Z6');

INSERT INTO Seller_Product (SellerID, ProductID) VALUES
(10, 101),
(10, 102),
(20, 103);

INSERT INTO Orders (OrderID, OrderDate, OrderStatus, TotalAmount, CustomerID) VALUES
(501, '2026-08-09', 'processing', 85000.00, 1),
(502, '2026-08-10', 'shipped', 1200.00, 2);

INSERT INTO OrderItem (OrderID, ItemNo, ProductID, Quantity, UnitPrice) VALUES
(501, 1, 101, 1, 85000.00),
(502, 1, 103, 1, 1200.00);

INSERT INTO Payment (PaymentID, OrderID, PaymentDate, Amount, PaymentMethod, TransactionID, PaymentStatus) VALUES
(701, 501, '2026-08-09', 85000.00, 'UPI', 'TXN-501', 'paid'),
(702, 502, '2026-08-10', 1200.00, 'Card', 'TXN-502', 'paid');

INSERT INTO Delivery (DeliveryID, OrderID, DeliveryDate, DeliveryStatus, TrackingNo, CourierName) VALUES
(801, 501, NULL, 'processing', 'TRK-501', 'QuickShip'),
(802, 502, '2026-08-10', 'shipped', 'TRK-502', 'QuickShip');

INSERT INTO Electronics (ProductID, Warranty) VALUES (101, '2 years');
INSERT INTO Clothing (ProductID, Size, Gender, Material) VALUES (102, 'M', 'Unisex', 'Cotton');
INSERT INTO Books (ProductID, Author, Publisher) VALUES (103, 'Database Faculty', 'Academic Press');

-- =========================================================
-- DEMONSTRATION 1: REFERENTIAL-INTEGRITY VIOLATION
-- Expected to FAIL because CustomerID 999 does not exist.
-- Keep this statement commented during a full-script run.
-- Uncomment and run it separately to see MySQL error 1452.
-- =========================================================

-- INSERT INTO Orders (OrderID, OrderDate, OrderStatus, TotalAmount, CustomerID)
-- VALUES (599, '2026-08-15', 'pending', 500.00, 999);

-- =========================================================
-- DEMONSTRATION 2: ON DELETE SET NULL
-- Deleting Category 1 should NOT delete Product 101.
-- Its CategoryID becomes NULL.
-- =========================================================

DELETE FROM Category
WHERE CategoryID = 1;

SELECT ProductID, ProductName, CategoryID
FROM Product
ORDER BY ProductID;

-- =========================================================
-- DEMONSTRATION 3: ON DELETE CASCADE
-- Deleting Customer 1 removes that customer's Orders and
-- Customer_Phone rows because of ON DELETE CASCADE.
-- Dependent order items, payment and delivery rows are also
-- removed by their own cascading foreign keys.
-- =========================================================

DELETE FROM Customer
WHERE CustomerID = 1;

SELECT * FROM Orders
ORDER BY OrderID;

SELECT * FROM Customer_Phone
ORDER BY CustomerID, Phone;
