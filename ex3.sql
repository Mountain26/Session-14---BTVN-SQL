-- 1. tạo cơ sở dữ liệu
create database company_payroll;
use company_payroll;

-- 2. tạo bảng company_funds
create table company_funds (
    fund_id int primary key auto_increment,
    balance decimal(15,2) not null
);

-- 3. tạo bảng employees
create table employees (
    emp_id int primary key auto_increment,
    emp_name varchar(50) not null,
    salary decimal(10,2) not null
);

-- 4. tạo bảng payroll
create table payroll (
    payroll_id int primary key auto_increment,
    emp_id int,
    salary decimal(10,2) not null,
    pay_date date not null,
    foreign key (emp_id) references employees(emp_id)
);

-- 5. thêm dữ liệu mẫu
insert into company_funds (balance) values (50000.00);

insert into employees (emp_name, salary) values
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);

-- 6. stored procedure trả lương nhân viên
delimiter $$

create procedure pay_salary(
    in p_emp_id int
)
begin
    declare emp_salary decimal(10,2);
    declare fund_balance decimal(15,2);
    declare bank_status int;

    -- nếu có lỗi sql thì rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- lấy lương nhân viên
    select salary
    into emp_salary
    from employees
    where emp_id = p_emp_id
    for update;

    -- lấy số dư quỹ công ty
    select balance
    into fund_balance
    from company_funds
    where fund_id = 1
    for update;

    -- kiểm tra quỹ có đủ tiền
    if fund_balance < emp_salary then
        rollback;
    else
        -- trừ tiền quỹ
        update company_funds
        set balance = balance - emp_salary
        where fund_id = 1;

        -- ghi bảng lương
        insert into payroll (emp_id, salary, pay_date)
        values (p_emp_id, emp_salary, curdate());

        -- trạng thái hệ thống ngân hàng
        set bank_status = 1;

        if bank_status = 0 then
            rollback;
        else
            commit;
        end if;
    end if;
end$$

delimiter ;

-- 7. gọi stored procedure
call pay_salary(1);

select * from company_funds;
select * from payroll;
