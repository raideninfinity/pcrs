/*
Navicat MySQL Data Transfer

Source Server         : raiden
Source Server Version : 50720
Source Host           : localhost:3306
Source Database       : pcrs_production

Target Server Type    : MYSQL
Target Server Version : 50720
File Encoding         : 65001

Date: 2017-12-18 09:49:03
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for admins
-- ----------------------------
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `password` varchar(32) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES ('1', 'Admin', '0a290b7b649f452b30901aa273e16a87', '2017-12-15 19:51:16', '2017-12-15 19:51:16');

-- ----------------------------
-- Table structure for admin_ips
-- ----------------------------
DROP TABLE IF EXISTS `admin_ips`;
CREATE TABLE `admin_ips` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of admin_ips
-- ----------------------------
INSERT INTO `admin_ips` VALUES ('1', '127.0.0.1', '2017-12-15 19:51:16', '2017-12-15 19:51:16');

-- ----------------------------
-- Table structure for admin_logs
-- ----------------------------
DROP TABLE IF EXISTS `admin_logs`;
CREATE TABLE `admin_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `admin_id` bigint(20) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `action_name` varchar(255) NOT NULL,
  `action_details` varchar(10000) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_logs_on_admin_id` (`admin_id`),
  CONSTRAINT `fk_rails_ee859ba416` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of admin_logs
-- ----------------------------

-- ----------------------------
-- Table structure for ar_internal_metadata
-- ----------------------------
DROP TABLE IF EXISTS `ar_internal_metadata`;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of ar_internal_metadata
-- ----------------------------
INSERT INTO `ar_internal_metadata` VALUES ('environment', 'production', '2017-12-15 19:51:16', '2017-12-15 19:51:16');

-- ----------------------------
-- Table structure for prepaid_codes
-- ----------------------------
DROP TABLE IF EXISTS `prepaid_codes`;
CREATE TABLE `prepaid_codes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `pin` varchar(255) DEFAULT NULL,
  `prepaid_type_id` bigint(20) NOT NULL,
  `admin_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_prepaid_codes_on_admin_id` (`admin_id`),
  KEY `index_prepaid_codes_on_prepaid_type_id` (`prepaid_type_id`),
  CONSTRAINT `fk_rails_049e86c8db` FOREIGN KEY (`prepaid_type_id`) REFERENCES `prepaid_types` (`id`),
  CONSTRAINT `fk_rails_867bdb6b4e` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of prepaid_codes
-- ----------------------------

-- ----------------------------
-- Table structure for prepaid_purchases
-- ----------------------------
DROP TABLE IF EXISTS `prepaid_purchases`;
CREATE TABLE `prepaid_purchases` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `prepaid_code_id` bigint(20) NOT NULL,
  `purchase_price` decimal(10,2) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_prepaid_purchases_on_prepaid_code_id` (`prepaid_code_id`),
  KEY `index_prepaid_purchases_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_269e125d96` FOREIGN KEY (`prepaid_code_id`) REFERENCES `prepaid_codes` (`id`),
  CONSTRAINT `fk_rails_e2e2fd42fe` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of prepaid_purchases
-- ----------------------------

-- ----------------------------
-- Table structure for prepaid_types
-- ----------------------------
DROP TABLE IF EXISTS `prepaid_types`;
CREATE TABLE `prepaid_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `image_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of prepaid_types
-- ----------------------------

-- ----------------------------
-- Table structure for reload_requests
-- ----------------------------
DROP TABLE IF EXISTS `reload_requests`;
CREATE TABLE `reload_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `transaction_type` varchar(255) NOT NULL,
  `comments` varchar(1000) DEFAULT NULL,
  `approved` varchar(16) NOT NULL,
  `admin_id` bigint(20) DEFAULT NULL,
  `approve_comments` varchar(1000) DEFAULT NULL,
  `approve_time` datetime DEFAULT NULL,
  `approve_credits` decimal(10,0) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reload_requests_on_admin_id` (`admin_id`),
  KEY `index_reload_requests_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_9559a5338a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_c874285117` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of reload_requests
-- ----------------------------

-- ----------------------------
-- Table structure for schema_migrations
-- ----------------------------
DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of schema_migrations
-- ----------------------------
INSERT INTO `schema_migrations` VALUES ('20171031120427');
INSERT INTO `schema_migrations` VALUES ('20171031120449');
INSERT INTO `schema_migrations` VALUES ('20171031120509');
INSERT INTO `schema_migrations` VALUES ('20171031120726');
INSERT INTO `schema_migrations` VALUES ('20171031120738');
INSERT INTO `schema_migrations` VALUES ('20171031120753');
INSERT INTO `schema_migrations` VALUES ('20171031120805');
INSERT INTO `schema_migrations` VALUES ('20171031120818');
INSERT INTO `schema_migrations` VALUES ('20171031120828');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `password` varchar(32) NOT NULL,
  `dob` date NOT NULL,
  `email` varchar(255) NOT NULL,
  `credits` decimal(10,0) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of users
-- ----------------------------

-- ----------------------------
-- Table structure for user_logs
-- ----------------------------
DROP TABLE IF EXISTS `user_logs`;
CREATE TABLE `user_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `action_name` varchar(255) NOT NULL,
  `action_details` varchar(10000) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_logs_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_903088cca6` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user_logs
-- ----------------------------
