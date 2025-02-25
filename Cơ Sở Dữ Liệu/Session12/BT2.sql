CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    order_date DATE NOT NULL
);

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

-- 2 --
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

-- 3 --
UPDATE orders SET price = 1400.00 WHERE product = 'Laptop';
UPDATE orders SET price = 800.00 WHERE product = 'Smartphone';

-- 4 --
DROP TRIGGER IF EXISTS after_update_orders;
