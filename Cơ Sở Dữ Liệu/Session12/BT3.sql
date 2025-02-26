CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    order_date DATE NOT NULL
);

-- 2 Tạo bảng deleted_orders để lưu thông tin các đơn hàng đã bị xóa --
CREATE TABLE deleted_orders  (
    delete_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    order_date DATE NOT NULL,
    delete_at DATETIME NOT NULL
);


INSERT INTO orders (customer_name, product, quantity, price, order_date) VALUES
('Alice', 'Laptop', 2, 1500.00, '2023-01-10'),
('Bob', 'Smartphone', 5, 800.00, '2023-02-15'),
('Carol', 'Laptop', 1, 1500.00, '2023-03-05'),
('Alice', 'Keyboard', 3, 100.00, '2023-01-20'),
('Dave', 'Monitor', NULL, 300.00, '2023-04-10');

-- 3 Tạo trigger AFTER DELETE để lưu thông tin các đơn hàng bị xóa vào bảng deleted_orders -- 
DELIMITER //
CREATE TRIGGER after_delete_orders
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO deleted_orders (order_id, customer_name, product, order_date, delete_at)
    VALUES (OLD.order_id, OLD.customer_name, OLD.product, OLD.order_date, NOW());
END;
//
DELIMITER ;

-- 4  Thực hiện thao tác DELETE: --

-- Xóa đơn hàng có order_id = 4 --

-- Xóa đơn hàng có order_id = 5 -- 
DELETE FROM orders WHERE order_id = 4;
DELETE FROM orders WHERE order_id = 5;

-- 5 Hiển thị lại bảng deleted_orders để xem thông tin đơn hàng bị xóa -- 
SELECT * FROM deleted_orders;






