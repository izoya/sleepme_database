-- профиль консультанта
create or replace view v_cons_profiles as
select  cons.id, cons.login, cons.email,
		cons_p.name, cons_p.lastname, cons_p.phone, cons_p.birthday, cons_p.gender, cons_p.city, cons_p.info, cons_p.created_at,
		r.rating, r.count as feedback_count,
		o.orders_count,
		m.media_count
from users cons
left join profiles cons_p on cons.id = cons_p.user_id
left join v_cons_rating r on r.cons_id = cons.id
left join v_cons_orders o on o.cons_id = cons.id
left join v_cons_media  m on m.cons_id = cons.id
where cons.`role` = 'consultant' and cons.is_active = 1;

-- список клиентов на сопровождении консультанта
create or replace view v_cons_clients as
select  cons.id, cons.login,
		cc.child_id, ch.name as child_name,
		ch.birthday, fn_child_age(ch.birthday) as `age`,
		ch.parent_id, concat(p.name, ' ', p.lastname) as parent_name, p.city as parent_city
from users cons
join child_consultant cc on (cc.cons_id = cons.id and cc.status = 'approved')
left join children ch on ch.id = cc.child_id
left join profiles p on ch.parent_id = p.user_id
where cons.`role` = 'consultant' and cons.is_active = 1;


-- рейтинг консультантов
create or replace view v_cons_rating as
select cons_id, round(sum(rating) / count(rating), 2) as rating, count(id) as count from feedback group by cons_id;


-- статистика проведённых консультаций
create or replace view v_cons_orders as
select cons.id as cons_id, count(o.id) as orders_count, sum(o.amount) as total
from users cons
join offers off ON off.cons_id = cons.id
join orders o on o.offer_id = off.id
where cons.`role` = 'consultant' and cons.is_active = 1 and (o.status = 'complete' or o.status = 'paid')
group by cons.id;


-- количество опубликованных статей
create or replace view v_cons_media as
select user_id as cons_id, count(id) as media_count from media group by cons_id;
