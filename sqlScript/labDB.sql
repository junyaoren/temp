########################
# 1. Create 系统管理员 table
########################


CREATE TABLE systemAdministrator
(
  # 用户ID
  userID varchar(10), # varchar 
  # 用户名
  userName VARCHAR(32) NOT NULL,
  # 登录密码
  userPassword VARCHAR(32) NOT NULL,
  # 主键
  PRIMARY KEY (userID)
) ENGINE=InnoDB;

########################
# 2. Create 服务员信息 table
########################

CREATE TABLE waiter
(
  # 工号
  waiterID varchar(10), #varchar
  # 姓名
  waiterName VARCHAR(32),
  # 出生日期
  waiterBirthday DATE NOT NULL,
  # 身份证
  waiterIDCard VARCHAR(18) NOT NULL UNIQUE,
  # 系统登录密码
  waiterPassword VARCHAR(32) NOT NULL,
  # 入职日期
  waiterJoinDate DATE NOT NULL,
  # 手机
  waiterPhoneNumber VARCHAR(20) UNIQUE,
  # 备注
  remarks VARCHAR(32),
  # 主键
  PRIMARY KEY (waiterID)
) ENGINE=InnoDB;

########################
# 3. Create 会员信息 table
########################
CREATE TABLE VIPLevel
(
  # 会员等级（主码）
  level smallint,  # smallint  LV 1-10
  # 享受折扣
  discount decimal(10,2) unsigned,
  # 等级对应消费金额
  totalAmount bigint, # bigint
  # 备注
  remarks VARCHAR(32),
  # 主键
  PRIMARY KEY (level)
) ENGINE=InnoDB;

########################
# 4. Create 房间类型与价格 table
########################
CREATE TABLE roomTypeAndPrice
(
  # 房间类型（主码）
  roomType VARCHAR(60),
  # 价格
  price INT UNSIGNED NOT NULL,
  
  `desc` VARCHAR(100),
  url varchar(40),
  # 主键
  PRIMARY KEY (roomType)

) ENGINE=InnoDB;

########################
# 5. Create 顾客信息 table
########################

CREATE TABLE customers
(
  # 顾客身份证
  customerIDCard VARCHAR(18),
  # 性别
  customerGender CHAR(4) check (customerGender ='男' or customerGender='女'),  # 限制 男或女  
  # 姓名
  customerName VARCHAR(16) NOT NULL,  
  # 出生日期
  customerBirthday DATE, 
  # 会员等级
  customerVIPLevel smallint, # 改成 smallint 
  # 手机号码
  customerPhoneNumber VARCHAR(30) , 
  # 消费金额
  totalAmount INT UNSIGNED,  
  # 备注
  remarks VARCHAR(32),  
  # 主键
  PRIMARY KEY (customerIDCard),
  # 外键
  FOREIGN KEY (customerVIPLevel) REFERENCES VIPLevel(level)

) ENGINE=InnoDB;

  
########################
# 6. Create 房间信息 table
########################
CREATE TABLE room
(
  # 房间号（主码）
  roomNumber CHAR(6),
  # 房间类型
  roomType VARCHAR(60) NOT NULL,
  # 状态
  roomStatus CHAR(6) check (roomStatus='空' or roomStatus='非空'), # 空/非空 
  # 备注
  remarks VARCHAR(32),
  # 主键
  PRIMARY KEY (roomNumber),
  # 外键
  FOREIGN KEY (roomType) REFERENCES roomTypeAndPrice(roomType)
  
) ENGINE=InnoDB;


########################
# 7. Create 订单信息 table
# 已预订，已入住，已退房/已完成
# 三种订单都在里面
########################

CREATE TABLE orders
(
  # 订单号
  orderNumber CHAR(32) NOT NULL  , 
  # 订单状态
  orderStatus CHAR(18) check (value in ('预订中','已入住','已退房')) ,
  # 客户身份证
  customerIDCard CHAR(18),
  # 入住房间号
  roomNumber CHAR(6) NOT NULL,
  # 入住时间
  checkInTime DATE NOT NULL,
  # 离店时间
  checkOutTime DATE NOT NULL,
  # 需付金额(由于可能续费，不能作为外键)
  totalMoney INT UNSIGNED NOT NULL,
  # 服务员工号
  waiterID VARCHAR(10) NOT NULL,
  # 备注
  remarks VARCHAR(32),
  orderTime DATE NOT NULL,
  # 主键
  PRIMARY KEY (orderNumber),
  # 外键
  FOREIGN KEY (customerIDCard) REFERENCES customers(customerIDCard),

  FOREIGN KEY (roomNumber) REFERENCES room(roomNumber),

  FOREIGN KEY (waiterID) REFERENCES waiter(waiterID)

) ENGINE=InnoDB;

########################
# 8. Create 订单跟踪信息 table
# 时间为NULL表示订单没到当前状态
########################

CREATE TABLE orderTracking
(
  # 订单号
  orderNumber CHAR(32),
  # 预定时间（订单表中一旦有预定订单加入，那么本表新增一条记录，本字段不可能为空）
  orderTime DATE NOT NULL,
  # 实际入住时间
  checkInTime DATE,
  # 实际退房时间
  checkOutTime DATE,
  # 备注
  remarks VARCHAR(32),
  # 主键
  PRIMARY KEY (orderNumber),
  # 同时作为外键
  FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber)

) ENGINE=InnoDB;

########################
# 9. Create 续费延长 table
# 客户需要续费延长时，直接更新订单表中的日期以及金额
# 由于订单状态未变，跟踪表中无法体现该订单续费了，所以增加此续费表
########################
  
CREATE TABLE timeExtension    
(
  # 操作记录号
  operatingID INT UNSIGNED AUTO_INCREMENT,
  # 操作的订单号(是记录中的订单号，外码，参照订单表)
  orderNumber CHAR(32),
  # 住房原到期日期
  oldExpiryDate DATE NOT NULL,
  # 住房新到期日期
  newExpiryDate DATE NOT NULL,
  # 需要添加的金额
  addedMoney INT UNSIGNED NOT NULL,
  # 主键
  PRIMARY KEY (operatingID),
  # 外键
  FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber)

) ENGINE=InnoDB;



###### 视图 

# 创建收入视图
create view incomeView
as
# 选择退房时间，总金额，订单数量
select checkOutTime co, sum(totalMoney) tot, count(*) num from orders 
where orders.orderNumber
in (
select ordertracking.orderNumber from ordertracking
    where ordertracking.checkOutTime is not null
)
group by co ;


# 创建客户折扣视图
create view customerVipLevelInfo
as
# 选择客户以及对应的VIP等级
select 
    customers.*, viplevel.discount
from
    customers, viplevel
where
    customers.customerVIPLevel = viplevel.level ;

 
# 创建房间信息视图
CREATE VIEW roomInfo
AS
select 
    room.*, rp.price, rp.`desc`,
    rp.url
FROM
    room, roomtypeandprice rp
WHERE
    room.roomType = rp.roomType ;


# 创建续费订单视图
CREATE VIEW timeExtensionOrdersView
AS
# 选择订单号，顾客名，手机号码，房间号，入住时间，旧的到期时间，新的到期时间以及增加的金额
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


# 创建订单视图
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

-- ----------------------------
-- Triggers structure for table customers
-- ----------------------------
DROP TRIGGER IF EXISTS `insertCustomerLevelTrigger`;
delimiter ;;
# 创建客户折扣触发器
CREATE TRIGGER `insertCustomerLevelTrigger` BEFORE INSERT ON `customers` FOR EACH ROW begin 
# 消费金额<200 VIP等级为1
        if new.totalAmount<200
          then 
          set new.customerVIPLevel =1 ;
# 200<消费金额<500 VIP等级为2          
        elseif  new.totalAmount<500
          then 
          set new.customerVIPLevel =2 ;
# 500<消费金额<1000 VIP等级为3         
        elseif new.totalAmount<1000
          then 
          set new.customerVIPLevel =3 ;
# 1000<消费金额<2000 VIP等级为4
        elseif new.totalAmount<2000
          then 
          set new.customerVIPLevel =4 ;
# 2000<消费金额<3000 VIP等级为5        
        elseif new.totalAmount<3000
          then 
          set new.customerVIPLevel =5 ;
# 3000<消费金额<5000 VIP等级为6          
        elseif new.totalAmount<5000
          then 
          set new.customerVIPLevel =6 ;
          end if;
      end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table customers
-- ----------------------------
DROP TRIGGER IF EXISTS `updateCustomerLevelTrigger`;
delimiter ;;
# 创建客户消费金额更新后的触发器
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

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
DROP TRIGGER IF EXISTS `insertAddMoneyToOrdersTrigger`;
delimiter ;;
# 创建更新的顾客消费总金额的触发器
CREATE TRIGGER `insertAddMoneyToOrdersTrigger` BEFORE INSERT ON `orders` FOR EACH ROW begin 
        UPDATE customers set totalAmount=totalAmount+new.totalMoney where customerIDCard=new.customerIDCard ;
      end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
# 创建插入订单后对订单信息进行更新的触发器
DROP TRIGGER IF EXISTS `insertOrderStatusToTrackingTrigger`;
delimiter ;;
CREATE TRIGGER `insertOrderStatusToTrackingTrigger` AFTER INSERT ON `orders` FOR EACH ROW begin 
        if new.orderStatus='预定中'
          then
          INSERT INTO ordertracking VALUES ( new.orderNumber, new.orderTime , NULL, NULL, NULL);
        elseif new.orderStatus='已入住'
          then
          INSERT INTO ordertracking VALUES ( new.orderNumber, new.orderTime , NULL, NULL, NULL);
          update orderTracking set checkInTime=new.checkInTime ,orderTime=new.checkInTime where orderNumber=new.orderNumber ;
        elseif new.orderStatus='已退房' 
          then
          INSERT INTO ordertracking VALUES ( new.orderNumber, new.orderTime , NULL, NULL, NULL);
          update orderTracking set checkInTime=new.checkInTime ,orderTime=new.checkInTime,checkOutTime=new.checkOutTime where orderNumber=new.orderNumber ;
        end if ;
      end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
DROP TRIGGER IF EXISTS `insertRoomStatusByOrdersTrigger`;
delimiter ;;
# 创建插入订单后对房间状态进行更新的触发器
CREATE TRIGGER `insertRoomStatusByOrdersTrigger` AFTER INSERT ON `orders` FOR EACH ROW begin 
        if new.orderStatus='已入住'
          then
          update room  set roomStatus='非空' where roomNumber=new.roomNumber ;
        elseif new.orderStatus='已退房'
          then 
          update room  set roomStatus='空' where roomNumber=new.roomNumber ;
        end if ;
      end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
DROP TRIGGER IF EXISTS `updateOrderStatustoTrackingTrigger`;
delimiter ;;
# 创建对订单完整性进行控制的触发器
CREATE TRIGGER `updateOrderStatustoTrackingTrigger` BEFORE UPDATE ON `orders` FOR EACH ROW begin 
        
        if new.orderStatus='已入住'
          then
          update orderTracking set checkInTime=new.checkInTime  where orderNumber=new.orderNumber ;
        elseif new.orderStatus='已退房'
          then 
          update orderTracking set checkOutTime=new.checkOutTime where orderNumber=new.orderNumber ;
        end if ;
      end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table orders
-- ----------------------------
# 创建对房间完整性进行控制的触发器
DROP TRIGGER IF EXISTS `updateRoomStatusByOrdersTrigger`;
delimiter ;;
CREATE TRIGGER `updateRoomStatusByOrdersTrigger` BEFORE UPDATE ON `orders` FOR EACH ROW begin 
        if new.orderStatus='已入住'
          then
          update room  set roomStatus='非空' where roomNumber=new.roomNumber ;
        elseif new.orderStatus='已退房'
          then 
          update room  set roomStatus='空' where roomNumber=new.roomNumber ;
        end if ;
      end
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table timeextension
-- ----------------------------
# 创建对续费订单总金额进行更新的触发器
DROP TRIGGER IF EXISTS `insertMoneyToTimeExtensionTrigger`;
delimiter ;;
CREATE TRIGGER `insertMoneyToTimeExtensionTrigger` BEFORE INSERT ON `timeextension` FOR EACH ROW begin 
        
        UPDATE orders set totalMoney=totalMoney+new.addedMoney where  orderNumber=new.orderNumber ;
        UPDATE customers set totalAmount=totalAmount+new.addedMoney  WHERE customerIDCard = (select customerIDCard from orders where new.orderNumber=orderNumber) ;
      end
;;
delimiter ;


# 建立的索引 

# 创建room 中roomtype和roomstatus 的混合索引
create index indexRoomTypeStatus on room (roomType, roomStatus);
# 创建系统管理员id和password的混合索引
create index indexSystemAdminIDPassword on systemadministrator (userID, userPassword);
# 创建宾馆管理员id和password的混合索引
create index indexWaiterIDPassword on waiter (waiterID, waiterPassword);
# 创建customers中姓名的索引
create index indexCustomerName on customers (customerName);
# 创建customers中手机号的索引
create index indexCustomerPhoneNumber on customers (customerPhoneNumber);
# 创建customers中VIP等级的索引
create index indexCustomerVIPLevel on customers (customerVIPLevel);
# 创建orders中orderNumber和orderStatus 的混合索引 
create index indexOrderStatusNumber on orders (orderNumber, orderStatus);
# 创建roomtypeandprice中roomType和price的混合索引
create index indexRoomTypePrice on roomtypeandprice (roomType, price);



# 插入服务员
INSERT INTO `waiter` VALUES ('member', 'Junyao Ren', '1993-01-01', 'W30826200001012232', 'member', '2018-01-01', '214-987-2131', 'ewe');
INSERT INTO `waiter` VALUES ('jren', 'Junyao Ren', '1993-01-01', 'W30826200001012234', '1234', '2018-01-01', '214-914-5466', 'ewe');
INSERT INTO `waiter` VALUES ('xgui', 'Xiang Gui', '1998-10-22', 'W30723199810226011', '3342', '2017-12-06', '214-914-3242', 'ppp');
INSERT INTO `waiter` VALUES ('mli', 'Minghao Li', '1992-12-28', 'W40122199707014848', '1234', '2018-01-04', '214-914-8987', NULL);
INSERT INTO `waiter` VALUES ('ngreen', 'Nicole Green', '1978-12-21', 'W42623199807263812', '1234', '2017-12-05', '214-345-1579', NULL);
INSERT INTO `waiter` VALUES ('pcohen', 'Philip Cohen', '1982-01-03', 'W23123124124124123', '1234', '2018-01-17', '214-924-1579', '1232null');
INSERT INTO `waiter` VALUES ('jdoe', 'John Doe', '1992-01-01', 'W30899199201011234', '1234', '2018-01-01', '214-323-1579', 'qwe');


# 插入VIP等级以及对应的折扣和消费金额
INSERT INTO `viplevel` VALUES (1, 0.99, 200, NULL);
INSERT INTO `viplevel` VALUES (2, 0.98, 500, NULL);
INSERT INTO `viplevel` VALUES (3, 0.97, 1000, NULL);
INSERT INTO `viplevel` VALUES (4, 0.96, 2000, NULL);
INSERT INTO `viplevel` VALUES (5, 0.95, 3000, NULL);
INSERT INTO `viplevel` VALUES (6, 0.94, 5000, NULL);


# 插入系统管理员
INSERT INTO `systemadministrator` VALUES ('admin', 'Junyao Ren', 'admin');


#插入房间详细信息
INSERT INTO `roomtypeandprice` VALUES ('Real-time PCR Machine', 120, 'Real time PCR Detection System, iQ5 Biorad | DNA o cDNA', '/images/RTPCR.jpg');
INSERT INTO `roomtypeandprice` VALUES ('NanoDrop', 188, 'Thermo Scientific Spectophotometer NanoDrop', '/images/ND.jpg');
INSERT INTO `roomtypeandprice` VALUES ('Fluorescent Microscope', 178, 'Upright Microscopes Leica DM4 B & DM6 B | DFC7000T Camera', '/images/FM.jpg');
INSERT INTO `roomtypeandprice` VALUES ('FPLC', 258, 'ÄKTA Pure 25M and 25L with Fraction Collectors | ÄKTA Flux 6', '/images/FPLC.jpg');
INSERT INTO `roomtypeandprice` VALUES ('Ultra-Centrifuge', 450, 'Analytical Ultracentrifuge Beckman Coulter Proteomelab', '/images/UC.jpg');


#插入房间编号类型和状态信息
INSERT INTO `room` VALUES ('000001', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000002', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000003', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000004', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000005', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000006', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000007', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000008', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000009', 'Fluorescent Microscope', '非空', NULL);
INSERT INTO `room` VALUES ('000010', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000011', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000012', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000013', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000014', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000015', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000016', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000017', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000018', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000019', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000020', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000021', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000022', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000023', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000024', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000025', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000026', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000027', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000028', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000029', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000030', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000031', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000032', 'NanoDrop', '非空', NULL);
INSERT INTO `room` VALUES ('000033', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000034', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000035', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000036', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000037', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000038', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000039', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000040', 'Ultra-Centrifuge', '非空', NULL);
INSERT INTO `room` VALUES ('000041', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000042', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000043', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000044', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000045', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000046', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000047', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000048', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000049', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000050', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000051', 'Ultra-Centrifuge', '非空', NULL);
INSERT INTO `room` VALUES ('000052', 'Ultra-Centrifuge', '非空', NULL);
INSERT INTO `room` VALUES ('000053', 'NanoDrop', '非空', NULL);
INSERT INTO `room` VALUES ('000054', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000055', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000056', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000057', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000058', 'Real-time PCR Machine', '非空', NULL);
INSERT INTO `room` VALUES ('000059', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000060', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000061', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000062', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000063', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000064', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000065', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000066', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000067', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000068', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000069', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000070', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000071', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000072', 'Real-time PCR Machine', '非空', NULL);
INSERT INTO `room` VALUES ('000073', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000074', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000075', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000076', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000077', 'NanoDrop', '非空', NULL);
INSERT INTO `room` VALUES ('000078', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000079', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000080', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000081', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000082', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000083', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000084', 'NanoDrop', '非空', NULL);
INSERT INTO `room` VALUES ('000085', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000086', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('000087', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000088', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000089', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000090', 'Ultra-Centrifuge', '非空', NULL);
INSERT INTO `room` VALUES ('000091', 'FPLC', '非空', NULL);
INSERT INTO `room` VALUES ('000092', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000093', 'Real-time PCR Machine', '非空', NULL);
INSERT INTO `room` VALUES ('000094', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000095', 'FPLC', '空', NULL);
INSERT INTO `room` VALUES ('000096', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000097', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('000098', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000099', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('000100', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000101', 'NanoDrop', '空', NULL);
INSERT INTO `room` VALUES ('000102', 'Fluorescent Microscope', '空', NULL);
INSERT INTO `room` VALUES ('001188', 'Ultra-Centrifuge', '空', NULL);
INSERT INTO `room` VALUES ('012341', 'Real-time PCR Machine', '空', NULL);
INSERT INTO `room` VALUES ('100000', 'Real-time PCR Machine', '空', '');
INSERT INTO `room` VALUES ('123422', 'Real-time PCR Machine', '空', '');


# 创建用户 
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



