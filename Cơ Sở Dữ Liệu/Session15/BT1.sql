-- Tạo bảng Departments (Phòng ban)
CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL,
    location VARCHAR(255)
);

-- Tạo bảng Employees (Nhân viên)
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    dob DATE,
    department_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Tạo bảng Projects (Dự án)
CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE
);

-- Tạo bảng Timesheets (Chấm công)
CREATE TABLE Timesheets (
    timesheet_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    date DATE NOT NULL,
    hours_worked INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Tạo bảng WorkReports (Báo cáo công việc)
CREATE TABLE WorkReports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    project_id INT,
    report_date DATE NOT NULL,
    description TEXT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- Chèn dữ liệu mẫu
INSERT INTO Departments (department_name, location) VALUES
('IT', 'Hanoi'),
('HR', 'Ho Chi Minh');

INSERT INTO Employees (name, dob, department_id, salary) VALUES
('Nguyen Van A', '1990-05-10', 1, 15000000),
('Tran Thi B', '1995-08-20', 2, 12000000);

INSERT INTO Projects (project_name, start_date, end_date) VALUES
('ERP System', '2024-01-01', '2024-12-31'),
('Mobile App', '2024-02-01', '2024-09-30');

INSERT INTO Timesheets (employee_id, date, hours_worked) VALUES
(1, '2024-02-10', 8),
(2, '2024-02-10', 7);

INSERT INTO WorkReports (employee_id, project_id, report_date, description) VALUES
(1, 1, '2024-02-10', 'Completed module A'),
(2, 2, '2024-02-11', 'Fixed UI issues');

-- Cập nhật thông tin dự án
UPDATE Projects SET end_date = '2025-12-31' WHERE project_id = 1;

-- Xóa thông tin một nhân viên
DELETE FROM Employees WHERE employee_id = 2;

-- Câu 5.1: Lấy danh sách tất cả khách hàng
SELECT customer_id, customer_name, email, phone_number, address FROM Customers;

-- Câu 5.2: Sửa thông tin sản phẩm có product_id = 1
UPDATE Products SET product_name = 'Laptop Dell XPS', price = 99.99 WHERE product_id = 1;

-- Câu 5.3: Lấy thông tin những đơn đặt hàng
SELECT o.order_id, c.customer_name, e.name AS employee_name, o.total_amount, o.order_date 
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id;

-- Câu 6.1: Đếm số lượng đơn hàng của mỗi khách hàng
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Câu 6.2: Thống kê tổng doanh thu của từng nhân viên trong năm hiện tại
SELECT e.employee_id, e.name AS employee_name, SUM(o.total_amount) AS revenue
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY e.employee_id, e.name;

-- Câu 6.3: Thống kê những sản phẩm có số lượng đặt hàng lớn hơn 100 trong tháng hiện tại
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_quantity
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE MONTH(o.order_date) = MONTH(CURDATE())
AND YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY p.product_id, p.product_name
HAVING total_quantity > 100
ORDER BY total_quantity DESC;

-- Câu 7.1: Lấy danh sách khách hàng chưa từng đặt hàng
SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Câu 7.2: Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT product_id, product_name, price
FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- Câu 7.3: Tìm những khách hàng có mức chi tiêu cao nhất
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING total_spent = (SELECT MAX(total_spent) FROM (
    SELECT customer_id, SUM(total_amount) AS total_spent FROM Orders GROUP BY customer_id
) AS spending_table);

-- Câu 8.1: Tạo view hiển thị thông tin đơn hàng
CREATE VIEW view_order_list AS
SELECT o.order_id, c.customer_name, e.name AS employee_name, o.total_amount, o.order_date 
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;

-- Câu 8.2: Tạo view hiển thị chi tiết đơn hàng
CREATE VIEW view_order_detail_product AS
SELECT od.order_detail_id, p.product_name, od.quantity, od.price_at_purchase
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;
