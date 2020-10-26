/* скрипты характерных выборок */

-- поиск консультантов из города клиента c сортировкой по рейтингу
set @user_id = 1;
select cp.* from profiles up
	join v_cons_profiles cp using (city)
	where up.user_id = @user_id
	order by cp.rating desc;


-- консультант с максимальным рейтингом
select * from v_cons_profiles
	order by rating desc, rand() limit 1;


-- вывод статей по подписке с сортировкой по новизне
set @user_id = 15;
select m.* from media m
	right join subscriptions s on s.cons_id = m.user_id
	where s.user_id = @user_id
	order by m.created_at desc ;


-- журнал сна ребёнка за выбранный период
set @child_id = 2;
set @start = '2020-10-01';
set @end = '2020-10-31';
select * from journals j
	where child_id = @child_id and (`date` between @start and @end)
	order by `date`;


-- вывод всех комментариев к статье
set @media = 1;
select c.*,	min(ancestor_id) as ancestor_id
	from comments c
	left join comments_tree ct on c.id = ct.descendant_id
	where	c.media_id = @media
	group by id
	order by ancestor_id, created_at, `level`;


-- вывод отдельной ветки комментариев
set @ancestor = 28;
select c.*,	min(ancestor_id) as ancestor_id
	from comments c
	left join comments_tree ct on c.id = ct.descendant_id
	where ct.ancestor_id = @ancestor
	group by id
	order by ancestor_id, created_at, `level`;


-- переписка
set @from_user = 5;
set @to_user = 28;

select * from messages
	where (from_user_id = @from_user and to_user_id = @to_user)
		or (from_user_id = @to_user and to_user_id = @from_user)
	ORDER BY created_at desc;