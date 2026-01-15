-- 1. tạo cơ sở dữ liệu
create database shop;
use shop;

-- 2. tạo bảng products
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    stock INT NOT NULL
);

-- 3. tạo bảng orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- 4. thêm dữ liệu mẫu vào products
INSERT INTO products (product_name, price, stock) VALUES
('Laptop Dell', 1500.00, 10),
('iPhone 13', 1200.00, 8),
('Samsung TV', 800.00, 5),
('AirPods Pro', 250.00, 20),
('MacBook Air', 1300.00, 7);

-- 5. tạo stored procedure xử lý đặt hàng
delimiter $$

create procedure place_order(
    in p_product_id int,
    in p_quantity int
)
begin
    declare current_stock int;
    declare product_price decimal(10,2);
    declare total decimal(10,2);

    -- nếu có lỗi thì rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- lấy tồn kho và giá sản phẩm
    select stock, price
    into current_stock, product_price
    from products
    where product_id = p_product_id
    for update;

    -- kiểm tra tồn kho
    if current_stock < p_quantity then
        rollback;
    else
        -- tính tổng tiền
        set total = product_price * p_quantity;

        -- thêm đơn hàng
        insert into orders (product_id, quantity, total_price)
        values (p_product_id, p_quantity, total);

        -- giảm tồn kho
        update products
        set stock = stock - p_quantity
        where product_id = p_product_id;

        commit;
    end if;
end$$

delimiter ;

-- 6. gọi stored procedure 
call place_order(1, 2);

select * from products;
select * from orders;
