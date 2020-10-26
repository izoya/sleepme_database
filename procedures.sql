-- Вставка комментария
drop procedure if exists sp_insert_comment;

delimiter //
CREATE procedure sp_insert_comment (
	out `result` VARCHAR(255),
	in media INT,
	in parent INT,
	in author INT,
	in content TEXT
	)
begin
	declare error BIT default 0;
	declare lvl tinyint unsigned default 0;
	declare code, error_str VARCHAR(100);
	declare comment_id BIGINT unsigned;
	declare continue handler for sqlexception
	begin
		set error = 1;
		get stacked diagnostics condition 1
			code = RETURNED_SQLSTATE,
			error_str = MESSAGE_TEXT;
		set `result` = concat('Error occured. ', code, ' ', error_str);
	end;

	start transaction;

		if parent is not null then
			set lvl = (select `level` + 1 from comments where id = parent);
		end if;

		insert into
			comments (user_id, media_id, content, parent_id, `level`)
			values (author, media, 	content, parent, 	lvl);

		set comment_id = last_insert_id();

		insert into
		  comments_tree (ancestor_id, descendant_id)
			select ancestor_id, comment_id
				from comments_tree
				where descendant_id = parent
			union
			select comment_id, comment_id;

	if error = 1 then
		rollback;
	else
		commit;
		set `result` = 'Success';
	end if;
end //
delimiter ;

/* ----- CALL EXAMPLE ----------- */
set @media = 3;
set @parent = null;
set @author = 15;
set @content = 'new comment';

call sp_insert_comment(@res, @media, @parent, @author, @content);
select @res;
/* ---------------- */



-- Создание нового пользователя
drop procedure if exists sp_add_new_user;

delimiter //
CREATE procedure sp_add_new_user (
	out `result` VARCHAR(255),
	in login VARCHAR(45),
	in `password` VARCHAR(64),
	in email VARCHAR(120),
	in name VARCHAR(50),
	in lastname VARCHAR(50)
	)
begin
	declare error BIT default 0;
	declare code, error_str VARCHAR(100);

	declare continue handler for sqlexception
	begin
		set error = 1;
		get stacked diagnostics condition 1
			code = RETURNED_SQLSTATE,
			error_str = MESSAGE_TEXT;
		set `result` = concat('Error occured. ', code, ' ', error_str);
	end;

	start transaction;

		insert into users (login, `password`, email)
			values (login, `password`, email);

		insert into profiles (user_id, name, lastname)
			values (last_insert_id(), name, lastname);

	if error = 1 then
		rollback;
	else
		commit;
		set `result` = 'Success';
	end if;
end //
delimiter ;

/* ----- CALL EXAMPLE ----------- */
call sp_add_new_user(@res, 'myLogin', '2eaea43523dc5fdc98a3ebd70d3bf44e8020066d', 'my.email@me.ru', 'MyName', 'MyLastname');
select @res;
/* ---------------- */



-- Возраст ребёнка в формате 'y-m'
drop function if exists fn_child_age;
delimiter //
create function fn_child_age(birthday date)
returns varchar(6) not deterministic
begin
	declare years, months smallint;
	set months = TIMESTAMPDIFF(month, birthday, now());
	set years = months div 12;
	set months = months - (years * 12);
	return concat(years, '-', months);
end//
delimiter ;

/* ----- SELECT EXAMPLE ----------- */
select name, fn_child_age(birthday) from children;
/* ---------------- */