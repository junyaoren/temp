CREATE TABLE systemAdministrator
(
  userID varchar(10), 
  userName VARCHAR(32) NOT NULL,
  userPassword VARCHAR(32) NOT NULL,
  PRIMARY KEY (userID)
) ENGINE=InnoDB;

CREATE TABLE waiter
(
  waiterID varchar(10),
  waiterName VARCHAR(32),
  waiterBirthday DATE NOT NULL,
  waiterIDCard VARCHAR(18) NOT NULL UNIQUE,
  waiterPassword VARCHAR(32) NOT NULL,
  waiterJoinDate DATE NOT NULL,
  waiterPhoneNumber VARCHAR(20) UNIQUE,
  remarks VARCHAR(32),
  PRIMARY KEY (waiterID)
) ENGINE=InnoDB;

CREATE TABLE VIPLevel
(
  level smallint,
  discount decimal(10,2) unsigned,
  totalAmount bigint, 
  remarks VARCHAR(32),
  PRIMARY KEY (level)
) ENGINE=InnoDB;

CREATE TABLE roomTypeAndPrice
(
  roomType VARCHAR(32),
  price INT UNSIGNED NOT NULL,
  `desc` VARCHAR(100),
  url varchar(40),
  PRIMARY KEY (roomType)
) ENGINE=InnoDB;

CREATE TABLE customers
(
  customerIDCard CHAR(18),
  customerGender CHAR(4) check (customerGender ='male' or customerGender='female'),
  customerName VARCHAR(16) NOT NULL,  
  customerBirthday DATE, 
  customerVIPLevel smallint,
  customerPhoneNumber CHAR(11),
  totalAmount INT UNSIGNED,
  remarks VARCHAR(32),
  PRIMARY KEY (customerIDCard),
  FOREIGN KEY (customerVIPLevel) REFERENCES VIPLevel(level)
) ENGINE=InnoDB;


CREATE TABLE room
(
  roomNumber CHAR(6),
  roomType VARCHAR(32) NOT NULL,
  roomStatus CHAR(6) check (roomStatus='empty' or roomStatus='taken'),
  remarks VARCHAR(32),
  PRIMARY KEY (roomNumber),
  FOREIGN KEY (roomType) REFERENCES roomTypeAndPrice(roomType)
) ENGINE=InnoDB;


CREATE TABLE orders
(
  orderNumber CHAR(32) NOT NULL  , 
  orderStatus CHAR(18) check (value in ('Reserved','In-process','Completed')) ,
  customerIDCard CHAR(18),
  roomNumber CHAR(6) NOT NULL,
  checkInTime DATE NOT NULL,
  checkOutTime DATE NOT NULL,
  totalMoney INT UNSIGNED NOT NULL,
  waiterID VARCHAR(10) NOT NULL,
  remarks VARCHAR(32),
  orderTime DATE NOT NULL,
  PRIMARY KEY (orderNumber),
  FOREIGN KEY (customerIDCard) REFERENCES customers(customerIDCard),
  FOREIGN KEY (roomNumber) REFERENCES room(roomNumber),
  FOREIGN KEY (waiterID) REFERENCES waiter(waiterID)
) ENGINE=InnoDB;

CREATE TABLE orderTracking
(
  orderNumber CHAR(32),
  orderTime DATE NOT NULL,
  checkInTime DATE,
  checkOutTime DATE,
  remarks VARCHAR(32),
  PRIMARY KEY (orderNumber),
  FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber)
) ENGINE=InnoDB;

  
CREATE TABLE timeExtension    
(
  operatingID INT UNSIGNED AUTO_INCREMENT,
  orderNumber CHAR(32),
  oldExpiryDate DATE NOT NULL,
  newExpiryDate DATE NOT NULL,
  addedMoney INT UNSIGNED NOT NULL,
  PRIMARY KEY (operatingID),
  FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber)

) ENGINE=InnoDB;


create view incomeView
as
select checkOutTime co, sum(totalMoney) tot, count(*) num from orders 
where orders.orderNumber
in (
select ordertracking.orderNumber from ordertracking
    where ordertracking.checkOutTime is not null
)
group by co ;


create view customerVipLevelInfo
as
select 
    customers.*, viplevel.discount
from
    customers, viplevel
where
    customers.customerVIPLevel = viplevel.level ;

 
CREATE VIEW roomInfo
AS
select 
    room.*, rp.price, rp.`desc`,
    rp.url
FROM
    room, roomtypeandprice rp
WHERE
    room.roomType = rp.roomType ;


CREATE VIEW timeExtensionOrdersView
AS
SELECT 
    tt.orderNumber,
    ct.customerName,
    ct.customerPhoneNumber,
    od.roomNumber,
    od.checkInTime,
    tt.oldExpiryDate,
    tt.newExpiryDate,
    tt.addedMoney
FROM
    timeextension tt, orders od, customers ct
WHERE
    tt.orderNumber = od.orderNumber
AND
    od.customerIDCard = ct.customerIDCard ;


CREATE VIEW orderviews as
SELECT
    orders.orderNumber,
    orders.orderStatus,
    customers.customerName,
    room.roomNumber,
    room.roomType,
    orders.orderTime,
    orders.checkInTime,
    orders.checkOutTime,
    customers.customerPhoneNumber,
    orders.totalMoney FROM
    orders, room, customers, roomtypeandprice
WHERE
    orders.customerIDCard = customers.customerIDCard
AND
    room.roomType = roomtypeandprice.roomType
AND 
    orders.roomNumber = room.roomNumber
ORDER BY
    orders.orderNumber DESC;



DROP TRIGGER IF EXISTS `insertCustomerLevelTrigger`;
delimiter ;;
CREATE TRIGGER `insertCustomerLevelTrigger` BEFORE INSERT ON `customers` FOR EACH ROW begin 
        if new.totalAmount<200
          then 
          set new.customerVIPLevel =1 ;
        elseif  new.totalAmount<500
          then 
          set new.customerVIPLevel =2 ;
        elseif new.totalAmount<1000
          then 
          set new.customerVIPLevel =3 ;
        elseif new.totalAmount<2000
          then 
          set new.customerVIPLevel =4 ;
        elseif new.totalAmount<3000
          then 
          set new.customerVIPLevel =5 ;
        elseif new.totalAmount<5000
          then 
          set new.customerVIPLevel =6 ;
          end if;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `updateCustomerLevelTrigger`;
delimiter ;;
CREATE TRIGGER `updateCustomerLevelTrigger` BEFORE UPDATE ON `customers` FOR EACH ROW begin 
        if new.totalAmount<200
          then 
          set new.customerVIPLevel =1 ;
          
        elseif  new.totalAmount<500
          then 
          set new.customerVIPLevel =2 ;
          
        elseif new.totalAmount<1000
          then 
          set new.customerVIPLevel =3 ;
        elseif new.totalAmount<2000
          then 
          set new.customerVIPLevel =4 ;
        elseif new.totalAmount<3000
          then 
          set new.customerVIPLevel =5 ;
        elseif new.totalAmount<5000
          then 
          set new.customerVIPLevel =6 ;
          end if;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `insertAddMoneyToOrdersTrigger`;
delimiter ;;
CREATE TRIGGER `insertAddMoneyToOrdersTrigger` BEFORE INSERT ON `orders` FOR EACH ROW begin 
        UPDATE customers set totalAmount=totalAmount+new.totalMoney where customerIDCard=new.customerIDCard ;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `insertOrderStatusToTrackingTrigger`;
delimiter ;;
CREATE TRIGGER `insertOrderStatusToTrackingTrigger` AFTER INSERT ON `orders` FOR EACH ROW begin 
        if new.orderStatus='Reserved'
          then
          INSERT INTO ordertracking VALUES ( new.orderNumber, new.orderTime , NULL, NULL, NULL);
        elseif new.orderStatus='In-process'
          then
          INSERT INTO ordertracking VALUES ( new.orderNumber, new.orderTime , NULL, NULL, NULL);
          update orderTracking set checkInTime=new.checkInTime ,orderTime=new.checkInTime where orderNumber=new.orderNumber ;
        elseif new.orderStatus='Completed' 
          then
          INSERT INTO ordertracking VALUES ( new.orderNumber, new.orderTime , NULL, NULL, NULL);
          update orderTracking set checkInTime=new.checkInTime ,orderTime=new.checkInTime,checkOutTime=new.checkOutTime where orderNumber=new.orderNumber ;
        end if ;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `insertRoomStatusByOrdersTrigger`;
delimiter ;;
CREATE TRIGGER `insertRoomStatusByOrdersTrigger` AFTER INSERT ON `orders` FOR EACH ROW begin 
        if new.orderStatus='In-process'
          then
          update room  set roomStatus='taken' where roomNumber=new.roomNumber ;
        elseif new.orderStatus='Completed'
          then 
          update room  set roomStatus='empty' where roomNumber=new.roomNumber ;
        end if ;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `updateOrderStatustoTrackingTrigger`;
delimiter ;;
CREATE TRIGGER `updateOrderStatustoTrackingTrigger` BEFORE UPDATE ON `orders` FOR EACH ROW begin 
        
        if new.orderStatus='In-process'
          then
          update orderTracking set checkInTime=new.checkInTime  where orderNumber=new.orderNumber ;
        elseif new.orderStatus='Completed'
          then 
          update orderTracking set checkOutTime=new.checkOutTime where orderNumber=new.orderNumber ;
        end if ;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `updateRoomStatusByOrdersTrigger`;
delimiter ;;
CREATE TRIGGER `updateRoomStatusByOrdersTrigger` BEFORE UPDATE ON `orders` FOR EACH ROW begin 
        if new.orderStatus='In-process'
          then
          update room  set roomStatus='taken' where roomNumber=new.roomNumber ;
        elseif new.orderStatus='Completed'
          then 
          update room  set roomStatus='empty' where roomNumber=new.roomNumber ;
        end if ;
      end
;;
delimiter ;


DROP TRIGGER IF EXISTS `insertMoneyToTimeExtensionTrigger`;
delimiter ;;
CREATE TRIGGER `insertMoneyToTimeExtensionTrigger` BEFORE INSERT ON `timeextension` FOR EACH ROW begin 
        
        UPDATE orders set totalMoney=totalMoney+new.addedMoney where  orderNumber=new.orderNumber ;
        UPDATE customers set totalAmount=totalAmount+new.addedMoney  WHERE customerIDCard = (select customerIDCard from orders where new.orderNumber=orderNumber) ;
      end
;;
delimiter ;


create index indexRoomTypeStatus on room (roomType, roomStatus);
create index indexSystemAdminIDPassword on systemadministrator (userID, userPassword);
create index indexWaiterIDPassword on waiter (waiterID, waiterPassword);
create index indexCustomerName on customers (customerName);
create index indexCustomerPhoneNumber on customers (customerPhoneNumber);
create index indexCustomerVIPLevel on customers (customerVIPLevel);
create index indexOrderStatusNumber on orders (orderNumber, orderStatus);
create index indexRoomTypePrice on roomtypeandprice (roomType, price);



INSERT INTO `waiter` VALUES ('member', 'Junyao Ren', '1993-01-01', 'W30826200001012232', 'member', '2018-01-01', '214-987-2131', 'ewe');
INSERT INTO `waiter` VALUES ('jren', 'Junyao Ren', '1993-01-01', 'W30826200001012234', '1234', '2018-01-01', '214-914-5466', 'ewe');
INSERT INTO `waiter` VALUES ('xgui', 'Xiang Gui', '1998-10-22', 'W30723199810226011', '3342', '2017-12-06', '214-914-3242', 'ppp');
INSERT INTO `waiter` VALUES ('mli', 'Minghao Li', '1992-12-28', 'W40122199707014848', '1234', '2018-01-04', '214-914-8987', NULL);
INSERT INTO `waiter` VALUES ('ngreen', 'Nicole Green', '1978-12-21', 'W42623199807263812', '1234', '2017-12-05', '214-345-1579', NULL);
INSERT INTO `waiter` VALUES ('pcohen', 'Philip Cohen', '1982-01-03', 'W23123124124124123', '1234', '2018-01-17', '214-924-1579', '1232null');
INSERT INTO `waiter` VALUES ('jdoe', 'John Doe', '1992-01-01', 'W30899199201011234', '1234', '2018-01-01', '214-323-1579', 'qwe');


INSERT INTO `viplevel` VALUES (1, 0.99, 200, NULL);
INSERT INTO `viplevel` VALUES (2, 0.98, 500, NULL);
INSERT INTO `viplevel` VALUES (3, 0.97, 1000, NULL);
INSERT INTO `viplevel` VALUES (4, 0.96, 2000, NULL);
INSERT INTO `viplevel` VALUES (5, 0.95, 3000, NULL);
INSERT INTO `viplevel` VALUES (6, 0.94, 5000, NULL);


INSERT INTO `systemadministrator` VALUES ('admin', 'Junyao Ren', 'admin');


INSERT INTO `roomtypeandprice` VALUES ('Real-time PCR Machine', 318, 'lab18-20㎡ | size.8m | height 2th-4th | Microscope', '/images/5.jpg');
INSERT INTO `roomtypeandprice` VALUES ('NanoDrop', 188, 'lab12㎡ | size.5m | height 2th-4th | Microscope', '/images/4.jpg');
INSERT INTO `roomtypeandprice` VALUES ('Fluorescent Microscope', 178, 'lab: 18m|1.2m|楼th: 1th | Microscope', '/images/2.jpg');
INSERT INTO `roomtypeandprice` VALUES ('Class-III Tissue Culture Room', 258, 'lab20-25㎡ | 1.2m| height 2th-4th | Microscope', '/images/1.jpg');
INSERT INTO `roomtypeandprice` VALUES ('Ultra-Centrifuge', 450, 'lab: 16-20m|doublesize.5m|height: 2-5th| Microscope', '/images/3.jpg');


INSERT INTO `room` VALUES ('000001', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000002', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000003', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000004', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000005', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000006', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000007', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000008', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000009', 'Fluorescent Microscope', 'taken', NULL);
INSERT INTO `room` VALUES ('000010', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000011', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000012', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000013', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000014', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000015', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000016', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000017', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000018', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000019', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000020', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000021', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000022', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000023', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000024', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000025', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000026', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000027', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000028', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000029', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000030', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000031', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000032', 'NanoDrop', 'taken', NULL);
INSERT INTO `room` VALUES ('000033', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000034', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000035', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000036', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000037', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000038', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000039', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000040', 'Ultra-Centrifuge', 'taken', NULL);
INSERT INTO `room` VALUES ('000041', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000042', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000043', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000044', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000045', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000046', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000047', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000048', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000049', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000050', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000051', 'Ultra-Centrifuge', 'taken', NULL);
INSERT INTO `room` VALUES ('000052', 'Ultra-Centrifuge', 'taken', NULL);
INSERT INTO `room` VALUES ('000053', 'NanoDrop', 'taken', NULL);
INSERT INTO `room` VALUES ('000054', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000055', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000056', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000057', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000058', 'Real-time PCR Machine', 'taken', NULL);
INSERT INTO `room` VALUES ('000059', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000060', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000061', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000062', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000063', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000064', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000065', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000066', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000067', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000068', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000069', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000070', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000071', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000072', 'Real-time PCR Machine', 'taken', NULL);
INSERT INTO `room` VALUES ('000073', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000074', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000075', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000076', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000077', 'NanoDrop', 'taken', NULL);
INSERT INTO `room` VALUES ('000078', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000079', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000080', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000081', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000082', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000083', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000084', 'NanoDrop', 'taken', NULL);
INSERT INTO `room` VALUES ('000085', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000086', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('000087', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000088', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000089', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000090', 'Ultra-Centrifuge', 'taken', NULL);
INSERT INTO `room` VALUES ('000091', 'Class-III Tissue Culture Room', 'taken', NULL);
INSERT INTO `room` VALUES ('000092', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000093', 'Real-time PCR Machine', 'taken', NULL);
INSERT INTO `room` VALUES ('000094', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000095', 'Class-III Tissue Culture Room', 'empty', NULL);
INSERT INTO `room` VALUES ('000096', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000097', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('000098', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000099', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('000100', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000101', 'NanoDrop', 'empty', NULL);
INSERT INTO `room` VALUES ('000102', 'Fluorescent Microscope', 'empty', NULL);
INSERT INTO `room` VALUES ('001188', 'Ultra-Centrifuge', 'empty', NULL);
INSERT INTO `room` VALUES ('012341', 'Real-time PCR Machine', 'empty', NULL);
INSERT INTO `room` VALUES ('100000', 'Real-time PCR Machine', 'empty', '');
INSERT INTO `room` VALUES ('123422', 'Real-time PCR Machine', 'empty', '');


grant all on * to system IDENTIFIED by '1234' ;
  
grant SELECT,INSERT on timeextension to hotel IDENTIFIED by '1234';
grant all on room to hotel  ;
GRANT select ,INSERT on orders to hotel ; 
GRANT select ,INSERT ,UPDATE on ordertracking to hotel ; 
GRANT select,INSERT  on customers to hotel  ;
grant all on roomtypeandprice to hotel ;
GRANT select on viplevel  to hotel  ;
grant select on timeextensionordersview to hotel ;
grant select on orderviews to hotel ;
grant INSERT,UPDATE,SELECT on orders to hotel ;



