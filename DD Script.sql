DROP DATABASE IF EXISTS sleepme;
CREATE DATABASE sleepme;
USE sleepme;


--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `login` varchar(45) NOT NULL UNIQUE,
  `password` varchar(64) NOT NULL COMMENT 'password hash',
  `role` set('user','consultant','admin') NOT NULL DEFAULT 'user',
  `email` varchar(120) NOT NULL UNIQUE,
  `is_active` bit NOT NULL DEFAULT 1
);


--
-- Table structure for table `profiles`
--

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `user_id` bigint unsigned NOT NULL UNIQUE,
  `name` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `phone` bigint unsigned DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `gender` char(1) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `info` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `from_user_id` bigint unsigned NOT NULL,
  `to_user_id` bigint unsigned NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_messages_from_user_id` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_messages_to_user_id` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`)
);


--
-- Table structure for table `children`
--

DROP TABLE IF EXISTS `children`;
CREATE TABLE `children` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `parent_id` bigint unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `birthday` date NOT NULL,
  CONSTRAINT `fk_children_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
);


--
-- Table structure for table `journals`
--

DROP TABLE IF EXISTS `journals`;
CREATE TABLE `journals` (
  `child_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `sleep_data` json NOT NULL,
  `comment` text,
  PRIMARY KEY (`child_id`,`date`),
  CONSTRAINT `fk_journals_child_id` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT='Children sleep journals';


--
-- Table structure for table `child_consultant`
--

DROP TABLE IF EXISTS `child_consultant`;
CREATE TABLE `child_consultant` (
  `cons_id` bigint unsigned NOT NULL,
  `child_id` bigint unsigned NOT NULL,
  `status` enum('requested','approved','unset','declined') NOT NULL DEFAULT 'requested',
  `requested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cons_id`,`child_id`),
  CONSTRAINT `fk_child_consultant_child_id` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_child_consultant_cons_id` FOREIGN KEY (`cons_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT='Children connected with consultants';


--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
CREATE TABLE `tasks` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `cons_id` bigint unsigned NOT NULL COMMENT 'consultant',
  `child_id` bigint unsigned NOT NULL,
  `content` text NOT NULL,
  `status` enum('unread','read','in progress','completed') NOT NULL DEFAULT 'unread',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `tasks_uid_child_id_idx` (`cons_id`,`child_id`) USING BTREE,
  CONSTRAINT `fk_tasks_child_id` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_tasks_cons_id` FOREIGN KEY (`cons_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
);


--
-- Table structure for table `offers`
--

DROP TABLE IF EXISTS `offers`;
CREATE TABLE `offers` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `cons_id` bigint unsigned NOT NULL COMMENT 'consultant',
  `name` varchar(150) NOT NULL,
  `description` text,
  `price` decimal(7,2) unsigned NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expire_at` datetime DEFAULT NULL,
  `is_instant` bit NOT NULL DEFAULT 0 COMMENT 'instant confirmation flag',
  KEY `idx_offers_price` (`price`) USING BTREE,
  CONSTRAINT `fk_offers_cons_id` FOREIGN KEY (`cons_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL COMMENT 'customer',
  `offer_id` bigint unsigned NOT NULL,
  `discount` float DEFAULT NULL,
  `amount` decimal(7,2) unsigned NOT NULL DEFAULT '0.00',
  `status` enum('pending','confirmed','paid','complete','processing','canceled') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expire_at` datetime DEFAULT (NOW() + interval 3 day),
  CONSTRAINT `fk_orders_offer_id` FOREIGN KEY (`offer_id`) REFERENCES `offers` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE
);


--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `amount` decimal(7,2) NOT NULL DEFAULT '0.00',
  `status` enum('pending','paid','error','processing','canceled','refund') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `payment_info` json DEFAULT NULL,
  CONSTRAINT `fk_payments_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
);


--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL COMMENT 'author',
  `content` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `likes_count` int unsigned NOT NULL DEFAULT '0' COMMENT 'Updates by trigger `tr_likes_count`',
  CONSTRAINT `fk_media_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
);


--
-- Table structure for table `likes`
--

DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` (
  `user_id` bigint unsigned NOT NULL,
  `media_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`media_id`),
  CONSTRAINT `fk_likes_media_id` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_likes_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
);


--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `media_id` bigint unsigned NOT NULL,
  `content` text NOT NULL,
  `parent_id` bigint unsigned DEFAULT NULL,
  `level` smallint unsigned NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_comments_media_id` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comments_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comments_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
);


--
-- Table structure for table `comments_tree`
--

DROP TABLE IF EXISTS `comments_tree`;
CREATE TABLE `comments_tree` (
  `ancestor_id` bigint unsigned NOT NULL DEFAULT 0,
  `descendant_id` bigint unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`ancestor_id`,`descendant_id`),
  CONSTRAINT `fk_comments_tree_ancestor_id` FOREIGN KEY (`ancestor_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comments_tree_descendant_id` FOREIGN KEY (`descendant_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Table structure for table `saves`
--

DROP TABLE IF EXISTS `saves`;
CREATE TABLE `saves` (
  `user_id` bigint unsigned NOT NULL,
  `media_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`media_id`),
  CONSTRAINT `fk_saves_media_id` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_saves_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
CREATE TABLE `subscriptions` (
  `user_id` bigint unsigned NOT NULL,
  `cons_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`cons_id`),
  CONSTRAINT `fk_subscriptions_cons_id` FOREIGN KEY (`cons_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_subscriptions_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);


--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `id` bigint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `cons_id` bigint unsigned NOT NULL,
  `rating` tinyint NOT NULL,
  `content` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `ukey_feedback_cons_user` (`user_id`, `cons_id`),
  CONSTRAINT `fk_feedback_cons_id` FOREIGN KEY (`cons_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_feedback_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
);




