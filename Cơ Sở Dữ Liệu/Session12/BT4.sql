CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    order_date DATE NOT NULL
);

-- 2 Tạo bảng order_warnings để lưu các cảnh báo về đơn hàng nếu giá trị vượt quá ngưỡng --
CREATE TABLE order_warnings  (
    warning_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    warning_message VARCHAR(255) NOT NULL
);


INSERT INTO orders (customer_name, product, quantity, price, order_date) VALUES
('Alice', 'Laptop', 2, 1500.00, '2023-01-10'),
('Bob', 'Smartphone', 5, 800.00, '2023-02-15'),
('Carol', 'Laptop', 1, 1500.00, '2023-03-05'),
('Alice', 'Keyboard', 3, 100.00, '2023-01-20'),
('Dave', 'Monitor', NULL, 300.00, '2023-04-10');

-- 3  Tạo trigger AFTER INSERT để kiểm tra tổng giá trị của đơn hàng (quantity * price): --
DELIMITER //
CREATE TRIGGER after_insert_orders
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.quantity * NEW.price > 5000 THEN
        INSERT INTO order_warnings (order_id, warning_message)
        VALUES (NEW.order_id, 'Total value exceeds limit');
    END IF;
END;
//
DELIMITER ;

-- 4 Thực hiện thao tác INSERT: --

-- Thêm đơn hàng mới: ('Mark', 'Monitor', 2, 3000.00, '2023-08-01') --

-- Thêm đơn hàng mới: ('Paul', 'Mouse', 1, 50.00, '2023-08-02') -- 
INSERT INTO orders (customer_name, product, quantity, price, order_date)
VALUES ('Mark', 'Monitor', 2, 3000.00, '2023-08-01');

INSERT INTO orders (customer_name, product, quantity, price, order_date)
VALUES ('Paul', 'Mouse', 1, 50.00, '2023-08-02');










