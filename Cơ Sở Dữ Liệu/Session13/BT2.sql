CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products (product_name, price, stock) VALUES
('Laptop Dell', 1500.00, 10),
('iPhone 13', 1200.00, 8),
('Samsung TV', 800.00, 5),
('AirPods Pro', 250.00, 20),
('MacBook Air', 1300.00, 7);

-- 2 Viết một Stored Procedure trong MySQL để xử lý đặt hàng --
-- Tham số đầu vào của Stored Procedure: --
-- p_product_id (INT) - ID của sản phẩm cần đặt hàng.--

-- p_quantity (INT) - Số lượng sản phẩm cần mua.

-- Logic thực hiện trong Stored Procedure:
-- Kiểm tra số lượng tồn kho (stock) của sản phẩm trong bảng products.
-- Nếu số lượng trong kho không đủ (stock < p_quantity), rollback (ROLLBACK).
-- Nếu đủ hàng, thực hiện các thao tác sau:

-- Tạo đơn hàng mới trong bảng orders.

-- Giảm số lượng tồn kho (stock - p_quantity) trong bảng products.

--  Commit transaction (COMMIT) để lưu thay đổi. --

DELIMITER //

CREATE PROCEDURE place_order(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_total_price DECIMAL(10,2);

    -- Lấy thông tin sản phẩm
    SELECT stock, price INTO v_stock, v_price 
    FROM products 
    WHERE product_id = p_product_id;

    -- Kiểm tra nếu số lượng tồn kho không đủ
    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Số lượng tồn kho không đủ!';
    ELSE
        SET v_total_price = v_price * p_quantity;

        START TRANSACTION;

        -- Tạo đơn hàng mới
        INSERT INTO orders (product_id, quantity, total_price) 
        VALUES (p_product_id, p_quantity, v_total_price);

        -- Giảm số lượng tồn kho
        UPDATE products 
        SET stock = stock - p_quantity 
        WHERE product_id = p_product_id;

        COMMIT;
    END IF;
END;

//
DELIMITER ;

CALL place_order(1, 3);
