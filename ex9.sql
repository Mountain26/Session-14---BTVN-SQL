use social_network;

-- 1. tạo bảng delete_log
create table delete_log (
    log_id int primary key auto_increment,
    post_id int not null,
    deleted_by int not null,
    deleted_at datetime default current_timestamp
);

-- 2. stored procedure xóa bài viết
delimiter $$

create procedure sp_delete_post(
    in p_post_id int,
    in p_user_id int
)
begin
    declare v_owner_id int;

    -- nếu có lỗi sql thì rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- kiểm tra bài viết tồn tại và đúng chủ sở hữu
    select user_id
    into v_owner_id
    from posts
    where post_id = p_post_id
    for update;

    -- nếu không tồn tại hoặc không phải chủ bài viết
    if v_owner_id is null or v_owner_id <> p_user_id then
        rollback;
    else
        -- xóa likes của bài viết
        delete from likes
        where post_id = p_post_id;

        -- xóa comments của bài viết
        delete from comments
        where post_id = p_post_id;

        -- xóa bài viết
        delete from posts
        where post_id = p_post_id;

        -- cập nhật lại số lượng bài viết của user
        update users
        set posts_count = posts_count - 1
        where user_id = p_user_id;

        -- ghi log xóa bài viết
        insert into delete_log (post_id, deleted_by)
        values (p_post_id, p_user_id);

        commit;
    end if;
end$$

delimiter ;

-- 3. test
-- trường hợp 1: xóa bài viết hợp lệ (đúng chủ bài viết)
call sp_delete_post(1, 1);

-- trường hợp 2: xóa không hợp lệ (không phải chủ bài viết)
call sp_delete_post(1, 2);

select * from posts;
select * from likes;
select * from comments;
select * from users;
select * from delete_log;