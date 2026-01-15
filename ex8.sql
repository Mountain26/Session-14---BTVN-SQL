use social_network;

-- 1. thêm cột comments_count vào posts (nếu chưa có)
alter table posts
add column comments_count int default 0;

-- 2. tạo bảng comments
create table comments (
    comment_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);

-- 3. stored procedure đăng bình luận 
delimiter $$

create procedure sp_post_comment(
    in p_post_id int,
    in p_user_id int,
    in p_content text
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- bước 1: thêm bình luận
    insert into comments (post_id, user_id, content)
    values (p_post_id, p_user_id, p_content);

    -- tạo savepoint sau khi insert comment
    savepoint after_insert;

    -- bước 2: cập nhật số lượng comment
    -- (dùng post_id để update, nếu post_id sai sẽ gây lỗi)
    update posts
    set comments_count = comments_count + 1
    where post_id = p_post_id;

    -- nếu update không ảnh hưởng dòng nào thì rollback partial
    if row_count() = 0 then
        rollback to after_insert;
        commit;
    else
        commit;
    end if;
end$$

delimiter ;

-- 4. test
-- trường hợp 1: đăng bình luận thành công
call sp_post_comment(1, 1, 'bình luận đầu tiên');

-- trường hợp 2: gây lỗi update (post_id không tồn tại)
call sp_post_comment(999, 1, 'bình luận lỗi để test savepoint');

select * from posts;
select * from comments;
