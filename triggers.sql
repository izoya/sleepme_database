
-- обновление поля likes_count в таблице media
DROP TRIGGER IF EXISTS tr_likes_count;

DELIMITER $$
$$
CREATE TRIGGER `tr_likes_count` AFTER INSERT ON `likes`
FOR EACH ROW
begin
	update media
		set likes_count = (select count(likes.uid) from likes where media_id = new.media_id )
		where id = new.media_id;
end$$
DELIMITER ;