-- 1. tạo cơ sở dữ liệu
create database university;
use university;

-- 2. tạo bảng students
create table students (
    student_id int primary key auto_increment,
    student_name varchar(50)
);

-- 3. tạo bảng courses
create table courses (
    course_id int primary key auto_increment,
    course_name varchar(100),
    available_seats int not null
);

-- 4. tạo bảng enrollments
create table enrollments (
    enrollment_id int primary key auto_increment,
    student_id int,
    course_id int,
    foreign key (student_id) references students(student_id),
    foreign key (course_id) references courses(course_id)
);

-- 5. thêm dữ liệu mẫu
insert into students (student_name) values
('Nguyễn Văn An'),
('Trần Thị Ba');

insert into courses (course_name, available_seats) values
('Lập trình C', 25),
('Cơ sở dữ liệu', 22);

-- 6. stored procedure đăng ký học phần
delimiter $$

create procedure enroll_course(
    in p_student_name varchar(50),
    in p_course_name varchar(100)
)
begin
    declare v_student_id int;
    declare v_course_id int;
    declare v_available_seats int;

    -- nếu có lỗi thì rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- lấy id sinh viên
    select student_id
    into v_student_id
    from students
    where student_name = p_student_name
    for update;

    -- lấy id môn học và số chỗ trống
    select course_id, available_seats
    into v_course_id, v_available_seats
    from courses
    where course_name = p_course_name
    for update;

    -- kiểm tra chỗ trống
    if v_available_seats > 0 then

        -- thêm đăng ký học phần
        insert into enrollments (student_id, course_id)
        values (v_student_id, v_course_id);

        -- giảm số chỗ trống
        update courses
        set available_seats = available_seats - 1
        where course_id = v_course_id;

        commit;
    else
        rollback;
    end if;
end$$

delimiter ;

-- 7. gọi stored procedure
call enroll_course('Phan Văn A', 'Lập trình C');

select * from courses;
select * from enrollments;
