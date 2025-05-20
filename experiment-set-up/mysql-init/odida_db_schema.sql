-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (arm64)
--
-- Host: localhost    Database: dida
-- ------------------------------------------------------
-- Server version	9.2.0

--
-- Table structure for table `healthworker`
--

DROP TABLE IF EXISTS `healthworker`;
CREATE TABLE `healthworker` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `extId` varchar(255) NOT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK_4unn0i6qm7at3wfb9mabd7efa` (`insertBy_uuid`),
  KEY `FK_q6ymupkgx827c4mvbdna11ih0` (`voidBy_uuid`),
  CONSTRAINT `FK_4unn0i6qm7at3wfb9mabd7efa` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_q6ymupkgx827c4mvbdna11ih0` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`)
);


--
-- Table structure for table `privilege`
--

DROP TABLE IF EXISTS `privilege`;
CREATE TABLE `privilege` (
  `uuid` varchar(32) NOT NULL,
  `privilege` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `role` of users, e.g. healthworker.s
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK_7nlqb70wumsn55tgw2ciwcm55` (`insertBy_uuid`),
  KEY `FK_mwjfo2nfaa6y6n4h1ml3nn7t` (`voidBy_uuid`),
  CONSTRAINT `FK_7nlqb70wumsn55tgw2ciwcm55` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_mwjfo2nfaa6y6n4h1ml3nn7t` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`)
);

--
-- Table structure for table `role_privileges` for users, e.g. healthworkers
--

DROP TABLE IF EXISTS `role_privileges`;
CREATE TABLE `role_privileges` (
  `role_uuid` varchar(32) NOT NULL,
  `privilege_uuid` varchar(32) NOT NULL,
  PRIMARY KEY (`role_uuid`,`privilege_uuid`),
  KEY `FK_k6uj268gni011rwaelyhphpq4` (`privilege_uuid`),
  KEY `FK_oil2hfu2pruh4modp2xvfjbdv` (`role_uuid`),
  CONSTRAINT `FK_k6uj268gni011rwaelyhphpq4` FOREIGN KEY (`privilege_uuid`) REFERENCES `privilege` (`uuid`),
  CONSTRAINT `FK_oil2hfu2pruh4modp2xvfjbdv` FOREIGN KEY (`role_uuid`) REFERENCES `role` (`uuid`)
);

--
-- Table structure for table `user` e.g. healthworkers, data manager, statisticians
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `fullName` varchar(255) DEFAULT NULL,
  `lastLoginTime` bigint NOT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `sessionId` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`uuid`)
);

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `user_uuid` varchar(32) NOT NULL,
  `role_uuid` varchar(32) NOT NULL,
  PRIMARY KEY (`user_uuid`,`role_uuid`),
  KEY `FK_ogi6pxfwkc3arlsnkws9639ia` (`role_uuid`),
  KEY `FK_hd67jftidtg8prusvr0kxxgbt` (`user_uuid`),
  CONSTRAINT `FK_hd67jftidtg8prusvr0kxxgbt` FOREIGN KEY (`user_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_ogi6pxfwkc3arlsnkws9639ia` FOREIGN KEY (`role_uuid`) REFERENCES `role` (`uuid`)
);


--
-- Table structure for table `locationhierarchylevel`
--

DROP TABLE IF EXISTS `locationhierarchylevel`;
CREATE TABLE `locationhierarchylevel` (
  `uuid` varchar(255) NOT NULL,
  `keyIdentifier` int NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`uuid`)
);


--
-- Table structure for table `locationhierarchy`
--

DROP TABLE IF EXISTS `locationhierarchy`;
CREATE TABLE `locationhierarchy` (
  `uuid` varchar(32) NOT NULL,
  `extId` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `level_uuid` varchar(255) DEFAULT NULL,
  `parent_uuid` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK_5ijbnxn9wgd9jwf0bdwpold4n` (`level_uuid`),
  KEY `FK_4mukghjss7ns2b4ghc17bffp6` (`parent_uuid`),
  CONSTRAINT `FK_4mukghjss7ns2b4ghc17bffp6` FOREIGN KEY (`parent_uuid`) REFERENCES `locationhierarchy` (`uuid`),
  CONSTRAINT `FK_5ijbnxn9wgd9jwf0bdwpold4n` FOREIGN KEY (`level_uuid`) REFERENCES `locationhierarchylevel` (`uuid`)
);

--
/* location here implies patients' location if community health worker conducts home-visits or 
or location of health facility if patient visits health facility */
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `statusMessage` varchar(255) DEFAULT NULL,
  `accuracy` varchar(255) DEFAULT NULL,
  `altitude` varchar(255) DEFAULT NULL,
  `extId` varchar(255) NOT NULL,
  `latitude` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `locationName` varchar(255) DEFAULT NULL,
  `locationType` varchar(255) DEFAULT NULL,
  `geom` geometry NOT NULL SRID 4326,
   SPATIAL KEY `geom` (`geom`),
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  `collectedBy_uuid` varchar(32) NOT NULL,
  `locationLevel_uuid` varchar(32) DEFAULT NULL, 
  PRIMARY KEY (`uuid`),
  KEY `FK_mt7414ncr774l3epfon25xohp` (`insertBy_uuid`),
  KEY `FK_pwyht4sxqqlrg5olbxorkfx0b` (`voidBy_uuid`),
  KEY `FK_ofpekiq0ackmeqjk0n5qcw83k` (`collectedBy_uuid`),
  KEY `FK_7fu06f62tglhmuaqcid1uvw21` (`locationLevel_uuid`),
  CONSTRAINT `FK_7fu06f62tglhmuaqcid1uvw21` FOREIGN KEY (`locationLevel_uuid`) REFERENCES `locationhierarchy` (`uuid`),
  CONSTRAINT `FK_mt7414ncr774l3epfon25xohp` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_ofpekiq0ackmeqjk0n5qcw83k` FOREIGN KEY (`collectedBy_uuid`) REFERENCES `healthworker` (`uuid`),
  CONSTRAINT `FK_pwyht4sxqqlrg5olbxorkfx0b` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`)
);


--
-- Table structure for table `visit` 
--
/* patient visit to a health facility or community health worker conducts home-visits:  
Multiple visits are allowed */

DROP TABLE IF EXISTS `visit`;
CREATE TABLE `visit` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `statusMessage` varchar(255) DEFAULT NULL,
  `extId` varchar(255) DEFAULT NULL,
  `realVisit` varchar(255) DEFAULT NULL,
  `visitDate` date NOT NULL,
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  `collectedBy_uuid` varchar(32) NOT NULL,
  `visitLocation_uuid` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK_2b3v1h5vfinonhcidlvi1lolk` (`insertBy_uuid`),
  KEY `FK_8a73httb4ws8uw1b6dxltua8v` (`voidBy_uuid`),
  KEY `FK_d6bfe68crb9vxvd14bywkncdu` (`collectedBy_uuid`),
  KEY `FK_o5bf4vxr786ck323yuw9iskvo` (`visitLocation_uuid`),
  CONSTRAINT `FK_2b3v1h5vfinonhcidlvi1lolk` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_8a73httb4ws8uw1b6dxltua8v` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_d6bfe68crb9vxvd14bywkncdu` FOREIGN KEY (`collectedBy_uuid`) REFERENCES `healthworker` (`uuid`),
  CONSTRAINT `FK_o5bf4vxr786ck323yuw9iskvo` FOREIGN KEY (`visitLocation_uuid`) REFERENCES `location` (`uuid`)
);

--
-- Table structure for table `individual` patients' demographic data
--

DROP TABLE IF EXISTS `individual`;
CREATE TABLE `individual` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `statusMessage` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `dobAspect` varchar(255) DEFAULT NULL,
  `extId` varchar(255) DEFAULT NULL, 
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `religion` varchar(255) DEFAULT NULL,
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  `collectedBy_uuid` varchar(32) NOT NULL,
  `father_uuid` varchar(32) DEFAULT NULL,
  `mother_uuid` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK_n5gwh9dvp8mlquilrsj9t1wap` (`insertBy_uuid`),
  KEY `FK_lr5dxsynctf16jcbo1upu0uou` (`voidBy_uuid`),
  KEY `FK_tn93ul9f2de2j9ncd30bxpkth` (`collectedBy_uuid`),
  KEY `FK_b99vn3sdu2n74va47bk6dh812` (`father_uuid`),
  KEY `FK_77kakvsx9ekfuokmxl3kettph` (`mother_uuid`),
  CONSTRAINT `FK_77kakvsx9ekfuokmxl3kettph` FOREIGN KEY (`mother_uuid`) REFERENCES `individual` (`uuid`),
  CONSTRAINT `FK_b99vn3sdu2n74va47bk6dh812` FOREIGN KEY (`father_uuid`) REFERENCES `individual` (`uuid`),
  CONSTRAINT `FK_lr5dxsynctf16jcbo1upu0uou` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_n5gwh9dvp8mlquilrsj9t1wap` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_tn93ul9f2de2j9ncd30bxpkth` FOREIGN KEY (`collectedBy_uuid`) REFERENCES `healthworker` (`uuid`)
) ;

--
/*Table structure for table `residency` of patients and to capture the migration-in and
migration-out of patients'location. 
- This will be useful for downstream analysis of infectious disease transmission/surveillance and control 
esp public health researchers */
--

DROP TABLE IF EXISTS `residency`;
CREATE TABLE `residency` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `statusMessage` varchar(255) DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `endType` varchar(255) DEFAULT NULL,
  `startDate` date NOT NULL,
  `startType` varchar(255) DEFAULT NULL,
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  `collectedBy_uuid` varchar(32) NOT NULL,
  `individual_uuid` varchar(32) DEFAULT NULL,
  `location_uuid` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK_8dtybp6i3toxc7jsfxs4r8bao` (`insertBy_uuid`),
  KEY `FK_htorj6kj80r9vehuiakgkkq3b` (`voidBy_uuid`),
  KEY `FK_bgbytde1d5wmaprsvur3tj0ov` (`collectedBy_uuid`),
  KEY `FK_5mcm09mtsoaiw51jj485xrq5u` (`individual_uuid`),
  KEY `FK_n4gwr8bo1vomyktppn0465ep7` (`location_uuid`),
  CONSTRAINT `FK_5mcm09mtsoaiw51jj485xrq5u` FOREIGN KEY (`individual_uuid`) REFERENCES `individual` (`uuid`),
  CONSTRAINT `FK_8dtybp6i3toxc7jsfxs4r8bao` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_bgbytde1d5wmaprsvur3tj0ov` FOREIGN KEY (`collectedBy_uuid`) REFERENCES `healthworker` (`uuid`),
  CONSTRAINT `FK_htorj6kj80r9vehuiakgkkq3b` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_n4gwr8bo1vomyktppn0465ep7` FOREIGN KEY (`location_uuid`) REFERENCES `location` (`uuid`)
);

--
-- Table structure for table `biosampledata and test results` for patients
--

DROP TABLE IF EXISTS `biosampledata`;
CREATE TABLE `biosampledata` (
  `uuid` varchar(32) NOT NULL,
  `deleted` tinyint(1) NOT NULL,
  `insertDate` date DEFAULT NULL,
  `voidDate` datetime DEFAULT NULL,
  `voidReason` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `statusMessage` varchar(255) DEFAULT NULL,
  `sampleId` varchar(255) DEFAULT NULL,
  `sampleCollectionDate` date DEFAULT NULL,
  `prepKitRef` varchar(255) DEFAULT NULL,
  `testPanelName` varchar(255) DEFAULT NULL,
  `testPanelSN` varchar(255) DEFAULT NULL,
  `heaterId` varchar(255) DEFAULT NULL,
  `panelValid` varchar(255) DEFAULT NULL,
  `controlColour` varchar(255) DEFAULT NULL,
  `controlSample` varchar(255) DEFAULT NULL,
  `controlInternal` varchar(255) DEFAULT NULL,
  `sarscov2` varchar(255) DEFAULT NULL,
  `fluA` varchar(255) DEFAULT NULL,
  `fluB` varchar(255) DEFAULT NULL,
  `rsv` varchar(255) DEFAULT NULL,
  `rhinovirus` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `mode` varchar(255) DEFAULT NULL,
  `totalElapsedTime` date DEFAULT NULL,
  `lysisTime` varchar(255) DEFAULT NULL,
  `washTime` varchar(255) DEFAULT NULL,
  `dryTime` varchar(255) DEFAULT NULL,
  `eluteTime` varchar(255) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `flag` varchar(255) DEFAULT NULL,
  `prepKitExpired` varchar(255) DEFAULT NULL,
  `testPanelExpired` varchar(255) DEFAULT NULL,
  `incubation` varchar(255) DEFAULT NULL,
  `imageCaptured` varchar(255) DEFAULT NULL,
  `insertBy_uuid` varchar(32) DEFAULT NULL,
  `voidBy_uuid` varchar(32) DEFAULT NULL,
  `collectedBy_uuid` varchar(32) NOT NULL,
  `individual_uuid` varchar(32) DEFAULT NULL, /*sample ID*/
  PRIMARY KEY (`uuid`),
  KEY `FK_isrqvkv0p6gwv0j50any3t0d9` (`insertBy_uuid`),
  KEY `FK_ojqtytomny7glq6w0aiig0kba` (`voidBy_uuid`),
  KEY `FK_97h827d4s2r6829xlk8pe9gdr` (`collectedBy_uuid`),
  KEY `FK_ps6xdnxi8u7wyxbg28akwnrd0` (`individual_uuid`),
  CONSTRAINT `FK_97h827d4s2r6829xlk8pe9gdr` FOREIGN KEY (`collectedBy_uuid`) REFERENCES `healthworker` (`uuid`),
  CONSTRAINT `FK_isrqvkv0p6gwv0j50any3t0d9` FOREIGN KEY (`insertBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_ojqtytomny7glq6w0aiig0kba` FOREIGN KEY (`voidBy_uuid`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FK_ps6xdnxi8u7wyxbg28akwnrd0` FOREIGN KEY (`individual_uuid`) REFERENCES `individual` (`uuid`)
);

