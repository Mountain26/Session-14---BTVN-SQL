use social_network;

-- 1. thêm cột following_count, followers_count vào users (nếu chưa có)
alter table users
add column following_count int default 0,
add column followers_count int default 0;

-- 2. tạo bảng followers
create table followers (
    follower_id int not null,
    followed_id int not null,
    primary key (follower_id, followed_id),
    foreign key (follower_id) references users(user_id),
    foreign key (followed_id) references users(user_id)
);

-- 3. tạo bảng log lỗi follow
create table follow_log (
    log_id int primary key auto_increment,
    follower_id int,
    followed_id int,
    error_message varchar(255),
    log_time datetime default current_timestamp
);

-- 4. stored procedure follow user
delimiter $$

create procedure sp_follow_user(
    in p_follower_id int,
    in p_followed_id int
)
begin
    declare follower_exists int;
    declare followed_exists int;
    declare already_followed int;

    -- nếu có lỗi sql thì rollback
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;

    -- kiểm tra user tồn tại
    select count(*) into follower_exists
    from users
    where user_id = p_follower_id
    for update;

    select count(*) into followed_exists
    from users
    where user_id = p_followed_id
    for update;

    if follower_exists = 0 or followed_exists = 0 then
        insert into follow_log (follower_id, followed_id, error_message)
        values (p_follower_id, p_followed_id, 'user does not exist');
        rollback;

    -- kiểm tra không tự follow chính mình
    elseif p_follower_id = p_followed_id then
        insert into follow_log (follower_id, followed_id, error_message)
        values (p_follower_id, p_followed_id, 'cannot follow yourself');
        rollback;

    else
        -- kiểm tra đã follow trước đó chưa
        select count(*) into already_followed
        from followers
        where follower_id = p_follower_id
          and followed_id = p_followed_id
        for update;

        if already_followed > 0 then
            insert into follow_log (follower_id, followed_id, error_message)
            values (p_follower_id, p_followed_id, 'already followed');
            rollback;
        else
            -- insert follow
            insert into followers (follower_id, followed_id)
            values (p_follower_id, p_followed_id);

            -- cập nhật số lượng follow
            update users
            set following_count = following_count + 1
            where user_id = p_follower_id;

            update users
            set followers_count = followers_count + 1
            where user_id = p_followed_id;

            commit;
        end if;
    end if;
end$$

delimiter ;

-- 5. test
-- trường hợp 1: follow thành công
call sp_follow_user(1, 2);

-- trường hợp 2: follow lại (rollback)
call sp_follow_user(1, 2);

-- trường hợp 3: tự follow chính mình (rollback)
call sp_follow_user(1, 1);

-- trường hợp 4: user không tồn tại (rollback)
call sp_follow_user(1, 20);

select * from users;
select * from followers;
select * from follow_log;
