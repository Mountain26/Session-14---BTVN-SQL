-- 1. tạo cơ sở dữ liệu
create database social_network;
use social_network;

-- 2. tạo bảng users
create table users (
    user_id int primary key auto_increment,
    username varchar(50) not null,
    posts_count int default 0
);

-- 3. tạo bảng posts
create table posts (
    post_id int primary key auto_increment,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

-- 4. thêm dữ liệu mẫu
insert into users (username) values
('nguyen_an'),
('tran_ba');

-- 5. giao dịch thành công
start transaction;

-- thêm bài viết cho user_id = 1 
insert into posts (user_id, content)
values (1, 'bài viết đầu tiên của người dùng 1');

-- cập nhật số lượng bài viết
update users
set posts_count = posts_count + 1
where user_id = 1;

commit;

select * from users;
select * from posts;

-- 6. giao dịch lỗi 
start transaction;

-- cố ý dùng user_id không tồn tại 
insert into posts (user_id, content)
values (999, 'bài viết lỗi để test rollback');

-- câu lệnh dưới sẽ không được commit
update users
set posts_count = posts_count + 1
where user_id = 10;

rollback;

select * from users;
select * from posts;
