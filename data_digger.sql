-- ============================================================
-- DATA DIGGER - E-COMMERCE STORE MYSQL PROJECT
-- ============================================================

DROP DATABASE IF EXISTS data_digger;
CREATE DATABASE data_digger;
USE data_digger;

-- ============================================================
-- 1. CUSTOMERS TABLE
-- ============================================================

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Address VARCHAR(255)
);

INSERT INTO Customers (CustomerID, Name, Email, Address) VALUES
(1, 'Alice', 'alice@gmail.com', 'Surat, Gujarat'),
(2, 'Rahul', 'rahul@gmail.com', 'Ahmedabad, Gujarat'),
(3, 'Priya', 'priya@gmail.com', 'Vadodara, Gujarat'),
(4, 'John', 'john@gmail.com', 'Mumbai, Maharashtra'),
(5, 'Neha', 'neha@gmail.com', 'Rajkot, Gujarat');

-- Retrieve all customer details
SELECT * FROM Customers;

-- Update a customer's address
UPDATE Customers
SET Address = 'Pune, Maharashtra'
WHERE CustomerID = 2;

-- Delete a customer using CustomerID
-- Customer 5 has no orders, so this does not violate the foreign key.
DELETE FROM Customers
WHERE CustomerID = 5;

-- Display all customers whose name is Alice
SELECT *
FROM Customers
WHERE Name = 'Alice';


-- ============================================================
-- 2. ORDERS TABLE
-- ============================================================

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(101, 1, CURRENT_DATE, 2499.00),
(102, 2, DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY), 1599.00),
(103, 3, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), 3499.00),
(104, 4, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), 999.00),
(105, 1, DATE_SUB(CURRENT_DATE, INTERVAL 40 DAY), 4999.00);

-- Retrieve all orders made by a specific customer
SELECT *
FROM Orders
WHERE CustomerID = 1;

-- Update an order's total amount
UPDATE Orders
SET TotalAmount = 2699.00
WHERE OrderID = 101;

-- Delete an order using OrderID
-- Order 105 has no OrderDetails, so it can be deleted safely.
DELETE FROM Orders
WHERE OrderID = 105;

-- Retrieve orders placed in the last 30 days
SELECT *
FROM Orders
WHERE OrderDate >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);

-- Highest, lowest and average order amount
SELECT
    MAX(TotalAmount) AS Highest_Order_Amount,
    MIN(TotalAmount) AS Lowest_Order_Amount,
    AVG(TotalAmount) AS Average_Order_Amount
FROM Orders;


-- ============================================================
-- 3. PRODUCTS TABLE
-- ============================================================

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL
);

INSERT INTO Products (ProductID, ProductName, Price, Stock) VALUES
(1, 'Wireless Headphones', 1499.00, 25),
(2, 'Smart Watch', 1999.00, 15),
(3, 'Keyboard', 799.00, 30),
(4, 'Gaming Mouse', 599.00, 20),
(5, 'USB-C Charger', 699.00, 0),
(6, 'Laptop Stand', 1299.00, 10);

-- Retrieve all products sorted by price in descending order
SELECT *
FROM Products
ORDER BY Price DESC;

-- Update the price of a specific product
UPDATE Products
SET Price = 849.00
WHERE ProductID = 3;

-- Delete a product if it is out of stock
DELETE FROM Products
WHERE Stock = 0;

-- Retrieve products whose price is between 500 and 2000
SELECT *
FROM Products
WHERE Price BETWEEN 500 AND 2000;

-- Most expensive product
SELECT *
FROM Products
WHERE Price = (SELECT MAX(Price) FROM Products);

-- Cheapest product
SELECT *
FROM Products
WHERE Price = (SELECT MIN(Price) FROM Products);


-- ============================================================
-- 4. ORDER DETAILS TABLE
-- ============================================================

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_orderdetails_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT fk_orderdetails_product
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO OrderDetails
(OrderDetailID, OrderID, ProductID, Quantity, SubTotal) VALUES
(1, 101, 1, 1, 1499.00),
(2, 101, 3, 1, 849.00),
(3, 102, 2, 1, 1999.00),
(4, 103, 4, 2, 1198.00),
(5, 104, 6, 1, 1299.00);

-- Retrieve all order details for a specific order
SELECT *
FROM OrderDetails
WHERE OrderID = 101;

-- Calculate total revenue generated from all orders
SELECT SUM(SubTotal) AS Total_Revenue
FROM OrderDetails;

-- Retrieve the top 3 most ordered products
SELECT
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS Total_Quantity_Ordered
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Total_Quantity_Ordered DESC
LIMIT 3;

-- Count how many times a specific product has been sold
SELECT
    p.ProductID,
    p.ProductName,
    COUNT(od.OrderDetailID) AS Times_Sold
FROM Products p
LEFT JOIN OrderDetails od
    ON p.ProductID = od.ProductID
WHERE p.ProductID = 1
GROUP BY p.ProductID, p.ProductName;


-- ============================================================
-- FINAL CHECKS
-- ============================================================

-- Show all remaining customers
SELECT * FROM Customers;

-- Show all orders
SELECT * FROM Orders;

-- Show all products
SELECT * FROM Products;

-- Show all order details
SELECT * FROM OrderDetails;
