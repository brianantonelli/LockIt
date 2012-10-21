-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.47


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema lockit
--

CREATE DATABASE IF NOT EXISTS lockit;
USE lockit;

--
-- Definition of table `lockit`.`command_queue`
--

DROP TABLE IF EXISTS `lockit`.`command_queue`;
CREATE TABLE  `lockit`.`command_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `device_token` varchar(64) NOT NULL,
  `command` enum('Lock','Unlock','GetState') NOT NULL,
  `time_received` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `time_processed` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `response_code` enum('200','404','500') DEFAULT NULL,
  `response_payload` varchar(256) DEFAULT NULL,
  `status` enum('sent','received','completed','error') NOT NULL DEFAULT 'sent',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=859 DEFAULT CHARSET=utf8;


--
-- Definition of table `lockit`.`users`
--

DROP TABLE IF EXISTS `lockit`.`users`;
CREATE TABLE  `lockit`.`users` (
  `udid` varchar(40) NOT NULL,
  `device_token` varchar(64) NOT NULL,
  `ip_address` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`udid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
