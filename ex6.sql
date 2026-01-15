use social_network;
-- 1. thêm cột likes_count vào bảng posts (nếu chưa có)
alter table posts
add column likes_count int default 0;

-- 2. tạo bảng likes
create table likes (
    like_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id),
    unique key unique_like (post_id, user_id)
);

-- 3. like lần đầu
start transaction;

-- user_id = 1 like post_id = 1
insert into likes (post_id, user_id)
values (1, 1);

-- tăng số lượt like của bài viết
update posts
set likes_count = likes_count + 1
where post_id = 1;

commit;

select * from posts;
select * from likes;

-- 4. like lần thứ hai 
start transaction;

-- cố tình like lại cùng post_id và user_id
insert into likes (post_id, user_id)
values (1, 1);

-- câu lệnh này sẽ không được commit
update posts
set likes_count = likes_count + 1
where post_id = 1;

rollback;

select * from posts;
select * from likes;
