-- 1. tạo cơ sở dữ liệu
create database bank;
use bank;

-- 2. tạo bảng accounts
create table accounts (
    account_id int auto_increment primary key,
    account_name varchar(100) not null,
    balance decimal(10,2) not null check (balance >= 0)
);

-- 3. chèn dữ liệu ban đầu
insert into accounts (account_name, balance) values
('Nguyễn Văn An', 1000.00),
('Trần Thị Bảy', 500.00);

-- 4. tạo stored procedure chuyển tiền
delimiter $$

create procedure transfer_money(
    in from_account int,
    in to_account int,
    in amount decimal(10,2)
)
begin
    declare from_balance decimal(10,2);

    -- xử lý lỗi: nếu có lỗi thì rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- lấy số dư tài khoản gửi
    select balance into from_balance
    from accounts
    where account_id = from_account
    for update;

    -- kiểm tra số dư
    if from_balance >= amount then

        -- trừ tiền tài khoản gửi
        update accounts
        set balance = balance - amount
        where account_id = from_account;

        -- cộng tiền tài khoản nhận
        update accounts
        set balance = balance + amount
        where account_id = to_account;

        commit;
    else
        rollback;
    end if;
end$$

delimiter ;

-- 5. gọi stored procedure
call transfer_money(1, 2, 200.00);
call transfer_money(1, 2, 500.00);

select * from accounts;
