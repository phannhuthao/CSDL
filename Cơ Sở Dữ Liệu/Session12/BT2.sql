CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    order_date DATE NOT NULL
);

-- 2 Tiến hành tạo bảng price_changes: --
CREATE TABLE price_changes (
    change_id INT AUTO_INCREMENT PRIMARY KEY,
    product VARCHAR(100) NOT NULL,
    old_price DECIMAL(10,2) NOT NULL,
    new_price DECIMAL(10,2) NOT NULL
);


INSERT INTO orders (customer_name, product, quantity, price, order_date) VALUES
('Alice', 'Laptop', 2, 1500.00, '2023-01-10'),
('Bob', 'Smartphone', 5, 800.00, '2023-02-15'),
('Carol', 'Laptop', 1, 1500.00, '2023-03-05'),
('Alice', 'Keyboard', 3, 100.00, '2023-01-20'),
('Dave', 'Monitor', NULL, 300.00, '2023-04-10');


-- 3 Tạo một trigger AFTER UPDATE để ghi lại giá cũ và giá mới khi giá sản phẩm thay đổi vào bảng price_changes. --
DELIMITER //
CREATE TRIGGER after_update_orders
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Chỉ ghi lại nếu giá thay đổi
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_changes (product, old_price, new_price)
        VALUES (OLD.product, OLD.price, NEW.price);
    END IF;
END;
//
DELIMITER ;

-- 4 Thực hiện thao tác UPDATE: --

-- Cập nhật giá của sản phẩm 'Laptop'  thành 1400.00. --

- Cập nhật giá của sản phẩm 'Smartphone' thành 800.00  --
UPDATE orders SET price = 1400.00 WHERE product = 'Laptop';
UPDATE orders SET price = 800.00 WHERE product = 'Smartphone';

-- 5 Kiểm tra lại dữ liệu trong bảng price_changes --
DROP TRIGGER IF EXISTS after_update_orders;
