CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    order_date DATE NOT NULL
);

INSERT INTO orders (customer_name, product, quantity, price, order_date) VALUES
('Alice', 'Laptop', 2, 1500.00, '2023-01-10'),
('Bob', 'Smartphone', 5, 800.00, '2023-02-15'),
('Carol', 'Laptop', 1, 1500.00, '2023-03-05'),
('Alice', 'Keyboard', 3, 100.00, '2023-01-20'),
('Dave', 'Monitor', NULL, 300.00, '2023-04-10');

-- 2 Tạo một trigger BEFORE INSERT trên bảng orders để kiểm tra:

- Nếu quantity là NULL hoặc nhỏ hơn 1, tự động gán giá trị là 1.

- Nếu order_date không được cung cấp (NULL), tự động gán là ngày hiện tại (CURDATE()). -- 

DELIMITER //
CREATE TRIGGER before_insert_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Kiểm tra quantity
    IF NEW.quantity IS NULL OR NEW.quantity < 1 THEN
        SET NEW.quantity = 1;
    END IF;
    
    -- Kiểm tra order_date
    IF NEW.order_date IS NULL THEN
        SET NEW.order_date = CURDATE();
    END IF;
END;
//
DELIMITER ;

-- 3 Sau khi tạo trigger, chèn 2 bản ghi vào bảng orders để kiểm chứng: --

-- Bản ghi 1: ('Anna', 'Tablet', NULL, 400.00, NULL) --

-- Bản ghi 2: ('John', 'Mouse', -3, 50.00, '2023-05-01') --

INSERT INTO orders (customer_name, product, quantity, price, order_date) VALUES
('Anna', 'Tablet', NULL, 400.00, NULL),
('John', 'Mouse', -3, 50.00, '2023-05-01');

-- 4 Xóa trigger vừa tạo --
DROP TRIGGER IF EXITS BEFORE before_insert_orders