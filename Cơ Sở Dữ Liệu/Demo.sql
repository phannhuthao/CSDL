-- Bảng Customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255)
);

-- Bảng Products
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

-- Bảng Employees
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    birthday DATE,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    revenue DECIMAL(10,2) DEFAULT 0
);

-- Bảng Orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    employee_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Bảng OrderDetails
CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


-- 3.1 Thêm cột email vào bảng Customers
ALTER TABLE Customers ADD COLUMN email VARCHAR(100) NOT NULL UNIQUE;


-- 3.2 ALTER TABLE Employees DROP COLUMN birthday;
ALTER TABLE Employees DROP COLUMN birthday;



-- 4 Chèn dữ liệu mẫu

-- Chèn dữ liệu vào bảng Customers
INSERT INTO Customers (customer_name, phone, email, address) VALUES
('Nguyen Van A', '0987654321', 'nguyenvana@example.com', 'Hanoi'),
('Tran Thi B', '0912345678', 'tranthib@example.com', 'Ho Chi Minh'),
('Le Van C', '0968456321', 'levanc@example.com', 'Da Nang'),
('Pham Minh D', '0978561234', 'phamminhd@example.com', 'Can Tho'),
('Bui Thu E', '0932123456', 'buithue@example.com', 'Hai Phong');

-- Chèn dữ liệu vào bảng Products
INSERT INTO Products (product_name, price, quantity, category) VALUES
('Laptop Dell', 1200.50, 10, 'Laptop'),
('iPhone 13', 999.99, 15, 'Smartphone'),
('Samsung Galaxy S22', 899.99, 20, 'Smartphone'),
('Tablet iPad', 600.00, 5, 'Tablet'),
('AirPods Pro', 250.00, 30, 'Accessories');

-- Chèn dữ liệu vào bảng Employees
INSERT INTO Employees (employee_name, position, salary) VALUES
('Nguyen Van A', 'Sales Manager', 15000000),
('Tran Thi B', 'Sales Assistant', 12000000),
('Le Van C', 'Sales Representative', 10000000),
('Pham Minh D', 'Account Manager', 14000000),
('Bui Thu E', 'Customer Support', 9000000);

-- Chèn dữ liệu vào bảng Orders
INSERT INTO Orders (customer_id, employee_id, total_amount) VALUES
(1, 1, 2199.98),
(2, 2, 999.99),
(3, 3, 899.99),
(4, 4, 1200.50),
(5, 5, 250.00);

-- Chèn dữ liệu vào bảng OrderDetails
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1200.50),
(1, 2, 1, 999.99),
(2, 2, 1, 999.99),
(3, 3, 1, 899.99),
(4, 1, 1, 1200.50),
(5, 5, 1, 250.00);

-- 5.1 Lấy danh sách tất cả khách hàng
SELECT customer_id, customer_name, email, phone, address FROM Customers;

-- 5.2  Cập nhật sản phẩm có 
UPDATE Products SET product_name = 'Laptop Dell XPS', price = 99.99 WHERE product_id = 1;

-- 5.3 Lấy thông tin những đơn đặt hàng
SELECT o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date 
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id;

-- 6.1 Đếm số lượng đơn hàng của mỗi khách hàng
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 6.2 Thống kê tổng doanh thu của từng nhân viên trong năm hiện tại
SELECT e.employee_id, e.employee_name, SUM(o.total_amount) AS total_revenue
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY e.employee_id, e.employee_name;

-- 6.3 Thống kê những sản phẩm có số lượng đặt hàng lớn hơn 100 trong tháng hiện tại
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_quantity
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY p.product_id, p.product_name
HAVING total_quantity > 100
ORDER BY total_quantity DESC;


