-- 1. Crear la base de datos
DROP DATABASE IF EXISTS sales_company;
CREATE DATABASE IF NOT EXISTS sales_company;
USE sales_company;

-- 2. Crear las tablas

DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
  CategoryID INT PRIMARY KEY,
  CategoryName VARCHAR(45)
);

DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
  CountryID INT PRIMARY KEY,
  CountryName VARCHAR(100),
  CountryCode VARCHAR(10)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  CityID INT PRIMARY KEY,
  CityName VARCHAR(45),
  Zipcode VARCHAR(10),
  CountryID INT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  CustomerID INT PRIMARY KEY,
  FirstName VARCHAR(100),
  MiddleInitial CHAR(5),
  LastName VARCHAR(100),
  CityID INT,
  Address VARCHAR(255)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
  EmployeeID INT PRIMARY KEY,
  FirstName VARCHAR(100),
  MiddleInitial CHAR(1),
  LastName VARCHAR(100),
  BirthDate DATETIME,
  Gender CHAR(1),
  CityID INT,
  HireDate DATETIME
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  ProductID INT PRIMARY KEY,
  ProductName VARCHAR(255),
  Price DECIMAL(10,4),
  CategoryID INT,
  Class VARCHAR(50),
  ModifyDate TIME,
  Resistant VARCHAR(50),
  IsAllergic VARCHAR(10),
  VitalityDays INT
);

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  SalesID INT PRIMARY KEY,
  SalesPersonID INT,
  CustomerID INT,
  ProductID INT,
  Quantity INT,
  Discount DECIMAL(4,2),
  TotalPrice DECIMAL(10,2),
  SalesDate DATETIME,
  TransactionNumber VARCHAR(50)
);

-- 3. Crear los datos desde archivos CSV

LOAD DATA INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CategoryID, CategoryName);   


LOAD DATA LOCAL INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/countries.csv'
INTO TABLE countries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CountryID, CountryName, CountryCode);


LOAD DATA LOCAL INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/cities.csv'
INTO TABLE cities
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CityID, CityName, Zipcode, CountryID);

LOAD DATA LOCAL INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerID, FirstName, MiddleInitial, LastName, CityID, Address);

LOAD DATA LOCAL INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(EmployeeID, FirstName, MiddleInitial, LastName, BirthDate, Gender, CityID, HireDate);

LOAD DATA LOCAL INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ProductID, ProductName, Price, CategoryID, Class, ModifyDate, Resistant, IsAllergic, VitalityDays);

LOAD DATA LOCAL INFILE '/Users/dlopez/Documents/Apps/Henry/Proyecto_1/data/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(SalesID, SalesPersonID, CustomerID, ProductID, Quantity, Discount, TotalPrice, SalesDate, TransactionNumber);






