/*********************************************************************/
/*                     MIS 686 Semester Team Project                 */
/*                        Team Voltaire SQL SCRIPT                   */
/*********************************************************************/

/* 
This Script deletes the SunnyServicesDBO Databasae if it exists
It then recreates creates the SunnyServicesDBO Database, populates it with tables 
*/

/*********************************************************************/
/*       !!!!  EXECUTE THIS SCRIPT TO CREATE THE DATABASE    !!!!    */
/*********************************************************************/

-- Set Context to Master
	USE MASTER; 
	GO	

	IF Exists (SELECT * FROM Master.dbo.sysdatabases WHERE NAME = 'SunnyServicesDBO')
	DROP DATABASE SunnyServicesDBO;

-- Create Company Database           
	CREATE DATABASE SunnyServicesDBO;	
	GO

-- CREATE TABLES IN THE SunnyServicesDBO DATABASE
	USE SunnyServicesDBO;

-- Create the ORGANIZATIONS table
/* schema: ORGANIZATIONS (OrganizationID, AK: Organization, OrgAddress, OrgPhoneNumber) 	
				unique not null Organization 	
				not null OrgAddress, OrgPhoneNumber
*/

	CREATE TABLE tblOrganizations
	(
	OrganizationID      int          IDENTITY(300001, 1)    PRIMARY KEY,
	Organization        varchar(50)  unique not null                   ,
	OrgAddress          varchar(100)        not null                   ,
	OrgPhoneNumber      varchar(20)         not null
	);

-- Create the VENDORS table
/* schema: VENDORS (VendorID, AK: Vendor) 	
				foreign key VendorID references ORGANIZATIONS 
				unique not null Vendor
*/

	CREATE TABLE tblVendors
	(
	VendorID    int         PRIMARY KEY  REFERENCES tblOrganizations,
	Vendor      varchar(25) unique not null                               
	);

-- Create the ROLES table
/* schema: ROLES (RoleID, JobTitle, DatabaseAccess) 	
				not null JobTItle, DatabaseAccess 
*/

	CREATE TABLE tblRoles
	(
	RoleID         int          IDENTITY(1, 1)   PRIMARY KEY,
	JobTitle       varchar(25)  not null                    ,
	DatabaseAccess varchar(25)  not null
	);

-- Create the PEOPLE table
/* schema: PEOPLE (PersonID, FirstName, LastName, HomeAddress, ZipCode, PhoneNumber, OrganizationID)
				foreign key OrganizationID references ORGANIZATIONS 
				not null FirstName, LastName, HomeAddress, ZipCode, PhoneNumber
*/

	CREATE TABLE tblPeople
	(
	PersonID       int          IDENTITY(100001, 1) PRIMARY KEY,
	FirstName      varchar(20)  not null                       , 
	LastName       varchar(20)  not null                       ,
	HomeAddress    varchar(100) not null                       ,
	ZipCode        varchar(10)  not null                       ,
	PhoneNumber    varchar(15)  not null                       ,
	OrganizationID int          REFERENCES tblOrganizations
	);
    
-- Create an index for the LastName and FirstName columns of tblPeople

	CREATE INDEX ndx_tblPeople_LastName ON tblPeople (FirstName,LastName);
    
-- Create an index for the PhoneNumber column of tblPeople

	CREATE INDEX ndx_tblPeople_PhoneNumber ON tblPeople (PhoneNumber);

-- Create the EMPLOYEES table
/* schema: EMPLOYEES (EmployeeID, HireDate, RoleID, ManagerID) 	
		foreign key EmployeeID references PEOPLE  	
		foreign key RoleID references ROLES 	
		foreign key ManagerID references EMPLOYEES 
		not null RoleID, HireDate
*/

	CREATE TABLE tblEmployees
	(
	EmployeeID int 	PRIMARY KEY REFERENCES tblPeople	,
	HireDate   date not null							,
	RoleID     int  not null	REFERENCES tblRoles     ,
	ManagerID  int				REFERENCES tblEmployees
	);

-- Create the CUSTOMERS table
/* schema: CUSTOMERS (CustomerID, CustomerType, PaymentMethod) 	
				foreign key CustomerID references PEOPLE 
*/

	CREATE TABLE tblCustomers
	(
	CustomerID    int			PRIMARY KEY REFERENCES tblPeople,
	CustomerType  varchar(50)                                   ,
	PaymentMethod varchar(50)
	);

-- Create the REQUESTS table
/* schema: REQUESTS (RequestID, ShortDescription, RequestDate, CustomerID) 	
				foreign key CustomerID references CUSTOMERS 	
				not null CustomerID, RequestDate
*/

	CREATE TABLE tblRequests
	(
	RequestID        int           IDENTITY(200001,1)   PRIMARY KEY             ,
	ShortDescription varchar(128)                                               ,
	RequestDate      date          not null                                     ,
	CustomerID       int           not null             REFERENCES tblCustomers
	);

-- Create the WORKORDERS table
/* schema: WORKORDERS (WorkOrderID, RequestID, ScheduledDateTime, CompletedDateTime, LocationAddress) 
			foreign key RequestID references REQUESTS 	
			not null RequestID
*/

	CREATE TABLE tblWorkOrders
	(
	WorkOrderID			int         IDENTITY(200001, 1) PRIMARY KEY           ,
	RequestID			int         not null            REFERENCES tblRequests,
	ScheduledDateTime   date                                              ,
	CompletedDateTime	date											  ,
	LocationAddress		varchar(128)
	);

--Create the EMPLOYEEWORKORDERS
/* schema: EMPLOYEEWORKORDERS (WorkOrderID, EmployeeID, Responsibility)
				Foreign key WorkOrderID references WORKORDERS
				Foreign key EmployeeID references EMPLOYEES
				Not null Responsibility
*/

	CREATE TABLE tblEmployeeWorkOrders
	(
	WorkOrderID     int REFERENCES tblWorkOrders        ,
	EmployeeID      int REFERENCES tblEmployees         ,
	Responsibility  varchar(100) not null               ,
		            PRIMARY KEY(WorkOrderID, EmployeeID)
	);

-- Create the INVOICES table
/* schema: INVOICES (InvoiceID, WorkOrderID, CustomerID, LaborCost, DiscountPercentage, CreatedDate, DueDate) 
				foreign key WorkOrderID references WORKORDERS 	
				foreign key CustomerID references CUSTOMERS 	
				not null WorkOrderID, CustomerID, CreatedDate, DueDate
*/
	CREATE TABLE tblInvoices
	(
	InvoiceID          int           IDENTITY(200001, 1) PRIMARY KEY             ,
	WorkOrderID        int           not null            REFERENCES tblWorkOrders,
	CustomerID         int           not null            REFERENCES tblCustomers ,
	LaborCost          decimal(7,2)                                              ,
	DiscountPercentage decimal(2,2)  default 0                                   ,
	CreatedDate		   date		   	 not null							         ,
	DueDate			   date          not null								     ,
	);

-- Create the PARTSCATALOG table
/* schema: PARTSCATALOG (PartsCatalogID, AK: (PartNumber, VendorID), Category, Manufacturer, UnitCost, QuantityAvailable, LeadTime) 	
				foreign key VendorID references VENDORS 
				unique (PartNumber, VendorID) 
				not null PartNumber, VendorID, Category, Manufacturer, UnitCost, QuantityAvailable, LeadTime 
*/

	CREATE TABLE tblPartsCatalog
	(
	PartsCatalogID     int          IDENTITY(500001, 1) PRIMARY KEY          ,
	PartNumber         varchar(20)  not null                                 ,
	VendorID           int          not null            REFERENCES tblVendors,
	Category           varchar(20)  not null                                 ,
	Manufacturer       varchar(50)  not null                                 ,
	UnitCost           decimal(7,2) not null                                 ,
	QuantityAvailable  int          not null            default 0            ,
	LeadTime           int          not null                                 ,
		               unique (PartNumber, VendorID)
	);
    
-- Create on index of the PartNumber column of tblPartsCatalog

	CREATE INDEX ndx_PartNumber_PartsCatalog ON tblPartsCatalog (PartNumber);

-- Create the PARTORDERS table
/* schema: PARTORDERS (PartOrderID, PartsCatalogID, WorkOrderID, UnitPricePaid, OrderQuantity, OrderDateTime, AK: TrackingNumber) 	
				foreign key WorkOrderID references WORKORDERS
				foreign key PartsCatalogID references PARTSCATALOG 	
				not null PartsCatalogID, UnitPricePaid, OrderQuantity, OrderDateTime, TrackingNumber
				unique TrackingNumber
*/

	CREATE TABLE tblPartOrders
	(
	PartOrderID      int           IDENTITY(500001, 1) PRIMARY KEY               , 
	PartsCatalogID   int           not null            REFERENCES tblPartsCatalog,
	WorkOrderID		 int				               REFERENCES tblWorkOrders  ,
	UnitPricePaid    decimal(7, 2) not null                                      ,
	OrderQuantity    int           not null                                      ,
	OrderDateTime    datetime      not null                                      ,
	TrackingNumber   int           not null            unique                    
	);


-- Create the PARTSINSTOCK table
/* schema: PARTSINSTOCK (PartsInStockID, AK:(SKUNumber, PartOrderID), StockQuantity, ListPrice) 	
				foreign key PartOrderID references PartOrders
				not null StockQuantity, ListPrice, PartOrderID, SKUNumber
				Unique (SKUNumber, PartOrderID)
*/
	CREATE TABLE tblPartsInStock
	(
	PartsInStockID   int          IDENTITY(400001, 1) PRIMARY KEY             ,
	SKUNumber        varchar(20)  not null 			                          ,
	PartOrderID      int          not null            REFERENCES tblPartOrders,
	StockQuantity    int          not null            default  0              ,
	ListPrice        decimal(7,2) not null
		             Unique (SKUNumber, PartOrderID)
	);


-- Create the INVOICEPARTS table
/* schema: INVOICEPARTS (InvoicePartID, PartsInStockID, PartOrderID, InvoiceID, Quantity, SalesPrice) 
				foreign key PartsInStockID references PARTSINSTOCK
				foreign key PartOrderID references PARTORDERS
				foreign key InvoiceID references INVOICES 		
				not null InvoiceID, Quantity, SalesPrice
*/

	CREATE TABLE tblInvoiceParts
	(
	InvoicePartID   int          IDENTITY(400001, 1) PRIMARY KEY               ,
	PartsInStockID  int                              REFERENCES tblPartsInStock,
	PartOrderID		int		                         REFERENCES tblPartOrders  ,
	InvoiceID       int          not null            REFERENCES tblInvoices    ,
	Quantity        int          not null                                      ,
	SalesPrice		decimal(7,2) not null                                      ,
		            CHECK (PartOrderID is not null OR PartsInStockID is not null)
	);


-- Insert data into the ORGANIZATIONS table
--schema: ORGANIZATION (Organization, OrgAddress,OrgPhoneNumber)
	INSERT INTO tblOrganizations Values
	
	('Alpine Home Air Product','629 Alpine Way #1206, Escondido, CA 92029','7607472404'),
	('Marcone Supply','340 Race St, Downtown, San Jose','4085726299'),
	('Reliable Parts','1310 N Kraemer Blvd, Anaheim, CA 92806','6572950334'),
	('Sears Holdings Corp','3333 Beverly Road. Hoffman Estates, IL 60179','2035130881'),
	('UCSD','9500 Gilman Drive, La Jolla, CA 92093-0021','8585342230'),
	('Andesign Lab','847 W 16th St, Newport Beach, CA 92663','9497918952'),
	('Mobile Kangaroo','17752 Sky Park Cir Suite 120, Irvine, CA 92614','9494044272'),
	('Bencotto Italian Kitchen','750 W Fir St #103, San Diego, CA 92101','6194504786'),
	('Scripps Clinic Mission Valley','7565 Mission Valley Rd','6192452790'),
	('Peet''s Coffee','7910 Girard Ave unit b, La Jolla, CA 92037','8584563819'),
	('CarMax','7766 Balboa Ave, San Diego, CA 92111','8587126486'),
	('Math Department, SDSU','5500 Campanile Drive, San Diego, CA 92182','6195946191'),
	('SoCal Carpentry','1202 Knoxville St, San Diego, CA 92110','8589458640'),
	('United States Postal Service','6401 El Cajon Blvd, San Diego, CA 92115','8002758777'),
	('AT&T Store','1060 University Suite A-107, San Diego, CA 92103','6192949596');

-- Insert data into the VENDORS table
--schema: VENDORS (Vendor)
	INSERT INTO tblVendors Values
	(300001,'Alpine'),
	(300002,'Marcone'),
	(300003,'Reliable'),
	(300004,'Sears');

-- Insert data into the ROLES table
--schema: Roles (JobTitle, DatabaseAccess)
	INSERT INTO tblRoles Values
	('CEO', 'full'),
	('Office manager', 'full'),
	('Office lead', 'full'),
	('Part manager', 'full'),
	('Technicican', 'read only');

-- Insert data into the PEOPLE table
--schema: PEOPLE (FirstName, LastName, HomeAddress, ZipCode, PhoneNumber, OrganizationID)
	INSERT INTO tblPeople Values
	('Scott', 'Goldberg', '4185 50th St, San Diego, CA 92105', 92105, '(858) 841-2090', null),
	('Carolyn', 'Martinez', '4262 48th St, San Diego, CA 92115', 92115, '(562) 760-5791', null),
	('Gabriela', 'Robinett', '3064 K St, San Diego, CA 92102', 92102, '(562) 546-8542', null),
	('Aaron', 'Liu', '2934 Newton Ave, San Diego, CA 92113', 92113, '(415) 694-3315', null),
	('Nancy', 'Petris', '4548 Felton St, San Diego, CA 92116', 92116, '(562) 373-4841', 300001),
	('David', 'Tobin', '44826 Winding Ln, Fremont, CA 94539', 94539, '(415) 494-1744', 300002),
	('Timothy', 'Klaiber', '252 Russell Ln La Jolla, CA 92093', 92093, '(858) 760-5370', null),
	('Michael', 'Murillo', '258 S Siena St, San Diego, CA 92114', 92114, '(415) 772-7751', 300003),
	('Namrata', 'Waghwasay', '804 Island Pine Ct, Hayward, CA 94544', 94544, '(562) 318-4786', 300004),
	('Katie', 'Fernandez', '2129 Market St, San Diego, CA 92102', 92102, '(858) 821-5456', 300005),
	('Lucas', 'Minto', '385 San Leon, Irvine, CA 92606', 92606, '(415) 241-2880', 300006),
	('John', 'Doe', '13 Rainstar, Irvine, CA 92614', 92614, '(415) 318-3547', 300007),
	('Ming', 'Huang', '1171 Via Argentina, Vista, CA 92081', 92081, '(858) 418-7834', 300008),
	('Kasey', 'Johnson', '710 Dado St, San Jose, CA 95131', 95131, '(415) 912-7707', null),
	('Suzuki', 'Nara', '13230 Pageant Ave, San Diego, CA 92129', 92129, '(858) 447-7741', 300009),
	('Junjie', 'Xu', '9180 La Jolla, CA 92037', 92037, '(858) 806-5201', 300010),
	('Lourdes', 'Wheeler', '3621 Braxton Common, Fremont, CA 94537', 94537, '(562) 627-7410', 300011),
	('Sabine', 'Doxtader', '8412 Cleta St, Downey, CA 90241', 90241, '(858) 410-5681', 300012),
	('Faramarz', 'Aslani', '1528 Van Dyke Ave, San Francisco, CA 94124', 94124, '(415) 843-0416', 300013),
	('Jaden', 'Nguyen', '1766 Petal Dr, San Diego, CA 92114', 92114, '(858) 852-2930', 300014),
	('Nicholas', 'Piggee', '1713 Taraval St, San Francisco, CA 94116', 94116, '(562) 632-4849', 300015);

-- Insert data into the EMPLOYEES table
--schema: EMPLOYEES (EmployeeID, HireDate, RoleID, ManagerID)
	INSERT INTO tblEmployees Values
	(100001, '2012-10-04', 1, null),
	(100002, '2012-10-04', 2, 100001),
	(100003, '2014-03-21', 3, 100002),
	(100004, '2014-05-14', 4, 100001),
	(100007, '2015-01-01', 5, 100004),
	(100014, '2017-04-01', 5, 100004);

-- Insert data into the CUSTOMERS table
--schema: CUSTOMERS (CustomerID, CustomerType, PaymentMethod)
	INSERT INTO tblCustomers Values
	(100005, 'Individual', 'Cash'),
	(100006, 'Institution', 'Check or Money Order'),
	(100008, 'Institution', 'Check or Money Order'),
	(100009, 'Individual', 'Credit Card'),
	(100010, 'Institution', 'Credit Card'),
	(100011, 'Institution', 'Check or Money Order'),
	(100012, 'Individual', 'Check or Money Order'),
	(100013, 'Individual', 'Credit Card'),
	(100015, 'Individual', 'Credit Card'),
	(100016, 'Institution', 'Check or Money Order'),
	(100017, 'Individual', 'Cash'),
	(100018, 'Individual', 'Check or Money Order'),
	(100019, 'Institution', 'Cash'),
	(100020, 'Individual', 'Credit Card'),
	(100021, 'Individual', 'Financing options - Loan');

-- Insert data into the REQUESTS table
--schema: REQUESTS (ShortDescription,RequestDate, CustomerID)
	INSERT INTO tblRequests Values
	('1 Spark ignitor', '2020-01-10', 100005),
	('2 Spark ignitors', '2020-01-29', 100008),
	('1 Spark ignitor', '2020-01-30', 100008),
	('1 Furnace inducer fan', '2020-03-03', 100020),
	('2 rollout switch & 1 door safety switch', '2020-03-20', 100011),
	('1 AC Unit', '2020-04-06', 100016),
	('1 AC Unit', '2020-04-23', 100010),
	('1 Grommet & 1 door safety switch', '2020-05-10', 100017),
	('2 Limit switches', '2020-05-27', 100018),
	('1 Limit switches', '2020-06-13', 100009),
	('1 Grommet', '2020-06-30', 100019),
	('2 Grommets', '2020-07-02', 100019),
	('2 Capacitors', '2020-08-03', 100012),
	('3 Capacitors & 1 Coil', '2020-08-05', 100012),
	('1 AC Unit & 2 Capacitors', '2020-09-06', 100006),
	('2 Pistons', '2020-09-23', 100015),
	('1 Spark ignitor', '2020-10-10', 100013),
	('2 Pistons', '2020-10-14', 100013),
	('1 Flame sensor', '2020-11-13', 100021),
	('1 Ignitor & 1 Flame sensor', '2020-11-15', 100021);

-- Insert data into the WORKORDER table
--schema: WORKORDER (RequestID, ScheduleDateTime,CompletedDateTime,LocationAddress)
	INSERT INTO tblWorkOrders Values
	(200001,'2020-01-17','2020-01-18','4548 Felton St, San Diego, CA 92116'),
	(200003,'2020-02-04','2020-02-05','258 S Siena St, San Diego, CA 92114'),
	(200004,'2020-03-08','2020-03-09','1766 Petal Dr, San Diego, CA 92114'),
	(200005,'2020-03-25','2020-03-26','385 San Leon, Irvine, CA 92606'),
	(200006,'2020-04-11','2020-04-12','9180 La Jolla, CA 92037'),
	(200007,'2020-04-28','2020-04-29','2129 Market St, San Diego, CA 92102'),
	(200008,'2020-05-15','2020-05-16','3621 Braxton Common, Fremont, CA 94537'),
	(200009,'2020-06-01','2020-06-02','8412 Cleta St, Downey, CA 90241'),
	(200010,'2020-06-18','2020-06-19','804 Island Pine Ct, Hayward, CA 94544'),
	(200012,'2020-07-07','2020-07-08','1528 Van Dyke Ave, San Francisco, CA 94124'),
	(200014,'2020-08-10','2020-08-11','13 Rainstar, Irvine, CA 92614'),
	(200015,'2020-09-11','2020-09-12','44826 Winding Ln, Fremont, CA 94539'),
	(200016,'2020-09-28','2020-09-29','13230 Pageant Ave, San Diego, CA 92129'),
	(200018,'2020-10-19','2020-10-20','1171 Via Argentina, Vista, CA 92081'),
	(200020,'2020-11-20','2020-11-21','1713 Taraval St, San Francisco, CA 94116');

-- Insert data into the EMPLOYEEWORKORDERS table
--schema: EMPLOYEEWORKORDERS (WorkOrderID, EmployeeID, Responsibility)
	INSERT INTO tblEmployeeWorkOrders Values
	(200001,100003,'Office lead'),
	(200001,100007,'Technicican'),
	(200002,100003,'Office lead'),
	(200002,100007,'Technicican'),
	(200003,100003,'Office lead'),
	(200003,100007,'Technicican'),
	(200004,100003,'Office lead'),
	(200004,100014,'Technicican'),
	(200005,100003,'Office lead'),
	(200005,100014,'Technicican'),
	(200006,100003,'Office lead'),
	(200006,100007,'Technicican'),
	(200007,100003,'Office lead'),
	(200007,100014,'Technicican'),
	(200008,100003,'Office lead'),
	(200008,100007,'Technicican'),
	(200009,100003,'Office lead'),
	(200009,100014,'Technicican'),
	(200010,100003,'Office lead'),
	(200010,100014,'Technicican'),
	(200011,100003,'Office lead'),
	(200011,100007,'Technicican'),
	(200012,100003,'Office lead'),
	(200012,100007,'Technicican'),
	(200013,100003,'Office lead'),
	(200013,100014,'Technicican'),
	(200014,100003,'Office lead'),
	(200014,100014,'Technicican'),
	(200015,100003,'Office lead'),
	(200015,100014,'Technicican');

-- Insert data into the INVOICES table
--schema: INVOICES (WorkOrderID, CustomerID, LaborCost, DiscountPercentage, CreatedDate, DueDate)
	INSERT INTO tblInvoices Values
	(200001, 100005, 20, 0, '2020-01-13', '2020-02-12'),
	(200002, 100008, 20, 0, '2020-01-31', '2020-03-01'),
	(200003, 100020, 10, 0, '2020-03-04', '2020-04-03'),
	(200004, 100011, 25, 0, '2020-03-23', '2020-04-22'),
	(200005, 100016, 200, 0.05, '2020-04-06', '2020-05-06'),
	(200006, 100010, 200, 0.05, '2020-04-24', '2020-05-24'),
	(200007, 100017, 10, 0, '2020-05-11', '2020-06-10'),
	(200008, 100018, 30, 0, '2020-05-28', '2020-06-27'),
	(200009, 100009, 15, 0, '2020-06-15', '2020-07-15'),
	(200010, 100019, 10, 0, '2020-07-03', '2020-08-02'),
	(200011, 100012, 25, 0, '2020-08-07', '2020-09-06'),
	(200012, 100006, 210, 0.05, '2020-09-08', '2020-10-08'),
	(200013, 100015, 10, 0, '2020-09-24', '2020-10-24'),
	(200014, 100013, 10, 0, '2020-10-15', '2020-11-14'),
	(200015, 100021, 25, 0, '2020-11-17', '2020-12-17');

-- Insert data into the PARTSCATALOG table
--schema: PARTSCATALOG (PartNumber, VendorID, Category, Manufacturer, UnitCost, QuantityAvailable, LeadTime)
	INSERT INTO tblPartsCatalog Values
	('Q313U3000',300001,'Pilots','Honeywell',42,17,5),
	('Q335C1023',300001,'Pilots','Honeywell',39,22,5),
	('Q347A1004',300001,'Ignitors','Honeywell',28.15,18,5),
	('0230K00001',300001,'Ignitors','Goodman',56.5,22,5),
	('S87B1008',300001,'Controls','Honeywell',210.5,24,5),
	('S87B1016',300001,'Controls','Honeywell',187.99,17,5),
	('S87B1024',300001,'Controls','Honeywell',215,8,5),
	('S87B1065',300001,'Controls','Honeywell',205,12,5),
	('Q3200U1004',300001,'MISC','Honeywell',28,17,5),
	('S8610U3009',300001,'Controls','Honeywell',116.25,4,5),
	('Q345U1005',300001,'Pilots','Honeywell',46.35,8,5),
	('Q348U1009',300001,'Pilots','Honeywell',61.5,23,5),
	('L4029E1250',300001,'Limits','Honeywell',72,12,5),
	('L4029E1227',300001,'Limits','Honeywell',98.99,8,5),
	('GMES800403AN',300001,'Furnaces','Goodman',648,20,5),
	('GMES800603AN',300001,'Furnaces','Goodman',730,20,5),
	('GMES800604BN',300001,'Furnaces','Goodman',750,20,5),
	('GMES800804BN',300001,'Furnaces','Goodman',810,20,5),
	('GMES801005CN',300001,'Furnaces','Goodman',850,20,5),
	('GSX130481',300001,'AC Units','Goodman',1058,4,5),
	('GSX140361',300001,'AC Units','Goodman',1302,4,5),
	('GSZ140241',300001,'AC Units','Goodman',1445,4,5),
	('GSZ140301',300001,'AC Units','Goodman',1620,4,5),
	('GSZ140361',300001,'AC Units','Goodman',1770,4,5),
	('GSX140601',300001,'AC Units','Goodman',1820,4,5),
	('HH18HA449',300002,'Switches','Carrier',30.1,100,3),
	('HK06WC069',300002,'Switches','Carrier',59.8,100,3),
	('HK06WC090',300002,'Switches','Carrier',71.6,100,3),
	('C6456513',300002,'Switches','Amana',44.95,100,3),
	('42-24196-84',300002,'Switches','Carrier',72.9,100,3),
	('P322398',300002,'Pilots','Williams',79.8,100,3),
	('HH19ZH195',300002,'Switches','Carrier',36.99,100,3),
	('HH19ZA145',300002,'Switches','Carrier',38.16,100,3),
	('LA11AA005',300002,'MISC','Carrier',32.7,100,3),
	('HC21ZE118',300002,'Motor Kits','Carrier',153.32,10,3),
	('318984753',300002,'Motor Kits','Frigidaire',206.45,5,3),
	('LH33ZG001',300002,'Ignitors','Carrier',72.1,100,3),
	('326100401',300002,'MISC','Carrier',12.5,120,3),
	('LH680534',300002,'Sensors','Carrier',27.35,120,3),
	('0130F00010',300002,'Sensors','Goodman',22.5,120,3),
	('SEN1114',300002,'Sensors','Trane',19.95,120,3),
	('98M87',300002,'Sensors','Goodman',17.9,120,3),
	('P271100',300002,'Sensors','Williams',60.9,120,3),
	('S36453B001',300002,'Sensors','Armstrong',16.8,120,3),
	('R38492B001',300002,'Sensors','Amana',22.5,120,3),
	('HC21ZE121',300002,'Motors','Carrier',135.8,16,3),
	('HR54ZA003',300002,'Switches','Carrier',15.25,120,3),
	('HR54ZA006',300002,'Switches','Carrier',15.9,120,3),
	('PG9A42JTL20',300002,'Controls','Goodman',98.68,120,3),
	('PG9A41JTL20',300002,'Controls','Goodman',96.68,120,3),
	('ICM282A',300002,'Controls','Carrier',236.8,5,3),
	('HK61EA006',300002,'Controls','Carrier',103.15,5,3),
	('325878-751',300002,'Controls','Carrier',378,7,3),
	('47-22827-83',300002,'Controls','Carrier',499,12,3),
	('62-24084-82',300002,'Controls','Carrier',272.15,12,3),
	('HT01BD242',300003,'Transformers','Carrier',79.99,2,1),
	('B1370108',300003,'Switches','Goodman',8.3,64,1),
	('B1370154',300003,'Switches','Amana',11.95,72,1),
	('EF19ZG235',300003,'Coils','Carrier',49.99,8,1),
	('D90-290Q',300003,'MISC','Carrier',9.95,44,1),
	('B1370133',300003,'Switches','Amana',31.99,62,1),
	('C6456508',300003,'Switches','Amana',52.99,12,1),
	('B1370150',300003,'Switches','Goodman',30.8,6,1),
	('C6456513',300003,'Switches','Goodman',44.95,51,1),
	('ORM5488BF',300003,'Motors','Packard',262.7,2,1),
	('FE1026SC',300003,'Motors','Century',148,3,1),
	('B4059000S',300003,'Motors','Goodman',234,2,1),
	('HH19ZH195',300003,'Switches','Carrier',49.5,22,1),
	('HH19ZA145',300003,'Switches','Carrier',42.5,64,1),
	('B1401018S',300003,'Ignitors','Goodman',51.99,37,1),
	('IG1121',300003,'Ignitors','Packard',38.99,12,1),
	('ICM280',300003,'Controls','Goodman',154,3,1),
	('ICM281',300003,'Controls','Goodman',144.81,2,1),
	('ICM275',300003,'Controls','Goodman',114.95,4,1),
	('50XZ042300',300003,'Furnaces','Carrier',1495,4,1),
	('50XZ030300',300003,'Furnaces','Carrier',1150,4,1),
	('50XZ017300',300003,'Furnaces','Carrier',1050,4,1),
	('36C03-333',300003,'Valves','White-Rogers',242.3,4,1),
	('B1282628S',300003,'Valves','Amana',111.48,5,1),
	('1370911S',300003,'Valves','Amana',30.1,72,1),
	('0130F00010',300003,'Sensors','Goodman',24.99,72,1),
	('S36453B001',300003,'Sensors','Armstrong',20.35,8,1),
	('R38492B001',300003,'Sensors','Amana',25.88,64,1),
	('50XZ400178',300003,'Coils','Carrier',350,2,1),
	('B1809913S',300003,'Controls','Amana',246.99,3,1),
	('PCBBF112S',300003,'Controls','Amana',172.83,2,1),
	('DFBK01',300003,'Controls','Amana',117.1,3,1),
	('RF000129',300003,'Controls','Amana',178.8,2,1),
	('PCBBF109S',300003,'Controls','Goodman',165,5,1),
	('ICM282A',300003,'Controls','Carrier',249.99,7,1),
	('325878-751',300003,'Controls','Carrier',392.5,4,1),
	('47-22827-83',300003,'Controls','Carrier',497.6,6,1),
	('62-24084-82',300003,'Controls','Carrier',270.8,12,1),
	('HK61EA006',300003,'Controls','Carrier',132,5,1),
	('TRCFD405',300003,'Capacitors','OEM',37.99,52,1),
	('CR75X370',300003,'Capacitors','OEM',12.99,74,1),
	('CR15X370',300003,'Capacitors','OEM',14.99,68,1),
	('CAP125000370RPS',300003,'Capacitors','Goodman',11.85,41,1),
	('GSX130481',300003,'AC Units','Goodman',1730,1,1),
	('EA36YD149',300004,'Valves','Carrier',74.99,120,5),
	('HT01BD242',300004,'Transformers','Carrier',74.5,120,5),
	('HK06WC061',300004,'Switches','Carrier',52.4,120,5),
	('EF19ZG235',300004,'Coils','Carrier',42,120,5),
	('B1370133',300004,'Switches','Amana',32.1,120,5),
	('B1370150',300004,'Switches','Goodman',34.99,120,5),
	('HY07MP311',300004,'MISC','Carrier',34.8,120,5),
	('HY07MP034',300004,'MISC','Carrier',28.5,120,5),
	('EA52PH038',300004,'MISC','Carrier',4.99,120,5),
	('48GS500230',300004,'MISC','Carrier',28.5,120,5),
	('B4059000S',300004,'Motors','Goodman',198.99,10,5),
	('48CE400021',300004,'MISC','Carrier',17.2,120,5),
	('HT32BH282',300004,'MISC','Carrier',86.2,120,5),
	('50XZ042300',300004,'Furnaces','Carrier',1275,30,5),
	('50XZ030300',300004,'Furnaces','Carrier',985,30,5),
	('50XZ017300',300004,'Furnaces','Carrier',815,30,5),
	('KA56DS001',300004,'MISC','Carrier',0.5,120,5),
	('EC39EZ067',300004,'Valves','Carrier',74.5,120,5),
	('GMES800403AN',300004,'Furnaces','Goodman',627,30,5),
	('GMES800603AN',300004,'Furnaces','Goodman',650,30,5),
	('GMES800604BN',300004,'Furnaces','Goodman',689,30,5),
	('GMES800804BN',300004,'Furnaces','Goodman',770,30,5),
	('GMES801005CN',300004,'Furnaces','Goodman',805,35,5),
	('50XZ400178',300004,'Coils','Carrier',342.75,10,5),
	('50XZ400244',300004,'Coils','Carrier',274.5,10,5),
	('ZPS51K4E-PFV-830',300004,'Motors','Carrier',196.5,10,5),
	('HK61EA006',300004,'Controls','Carrier',99,120,5),
	('325878-751',300004,'Controls','Carrier',350,10,5),
	('47-22827-83',300004,'Controls','Carrier',458.5,10,5),
	('62-24084-82',300004,'Controls','Carrier',250.15,10,5),
	('GSX130481',300004,'AC Units','Goodman',1150,20,5),
	('GSX140361',300004,'AC Units','Goodman',1350,20,5),
	('GSZ140241',300004,'AC Units','Goodman',1500,20,5),
	('GSZ140301',300004,'AC Units','Goodman',1650,20,5),
	('GSX140601',300004,'AC Units','Goodman',1850,20,5),
	('GSZ140361',300004,'AC Units','Goodman',1920,20,5);


-- Insert data into the PARTORDER table
--schema: PARTORDER (PartsCatalogID, WorkOrderID,unitPricePaid,OrderQuantity, OrderDateTime, TrackingNumber)
	INSERT INTO tblPartOrders Values
	(500004,null,56.53,5,'5/16/2020  4:35:12',4312847),
	(500020,null,1058,2,'4/10/2020  12:35:00',5783457),
	(500023,null,1620,2,'4/6/2020  3:30:00',5634576),
	(500024,null,1770,2,'3/19/2020  11:15:12',7686781),
	(500026,null,30.1,1,'11/20/2020  11:30:45',3453462),
	(500027,null,59.8,1,'11/16/2020  6:34:11',2456456),
	(500033,null,38.16,1,'6/21/2020  4:15:15',9023458),
	(500034,null,32.7,4,'6/21/2020  4:15:15',2451201),
	(500037,null,72.1,1,'10/24/2020  11:15:12',1435221),
	(500038,null,12.5,1,'5/25/2020  4:35:12',9320575),
	(500039,null,27.35,2,'12/1/2020  10:37:00',5241345),
	(500040,null,22.5,2,'5/27/2020  4:35:12',4236458),
	(500048,null,15.9,2,'2/22/2020  2:35:45',7674657),
	(500057,null,8.3,4,'8/12/2020  3:00:12',8965242),
	(500059,null,49.99,2,'9/1/2020  4:15:35',1670924),
	(500063,null,30.8,2,'9/2/2020  10:15:30',6474567),
	(500029,null,44.95,2,'6/1/2020  4:35:12',4352345),
	(500032,null,36.99,10,'6/2/2020  10:10:14',5345665),
	(500033,null,38.16,12,'9/15/2020  5:02:00',8126785),
	(500070,null,51.99,2,'9/12/2020  2:12:00',1962313),
	(500040,null,22.5,4,'7/5/2020  12:35:12',1063456),
	(500044,null,16.8,6,'10/6/2020  12:15:00',1960325),
	(500024,null,1770,2,'10/8/2020  1:35:10',2139950),
	(500024,null,1770,2,'10/12/2020  11:37:10',5902046),
	(500116,null,0.5,18,'12/13/2020  6:35:00',1298624);


-- Insert data into the PARTINSTOCK table
--schema: PARTINSTOCK (PartsOrderID, StockQuantity, ListPrice)
	INSERT INTO tblPartsInStock Values
	('0230K00001',500001,5,60),
	('GSX130481',500002,2,1200),
	('GSZ140301',500003,2,1800),
	('GSZ140361',500004,2,2000),
	('HH18HA449',500005,1,35),
	('HK06WC069',500006,1,65),
	('HH19ZA145',500007,1,42),
	('LA11AA005',500008,4,42),
	('LH33ZG001',500009,1,80),
	('326100401',500010,1,15),
	('LH680534',500011,2,32),
	('0130F00010',500012,2,32),
	('HR54ZA006',500013,2,20),
	('B1370108',500014,4,15),
	('EF19ZG235',500015,2,60),
	('B1370150',500016,2,35),
	('C6456513',500017,2,50),
	('HH19ZH195',500018,10,55),
	('HH19ZA145',500019,12,50),
	('B1401018S',500020,2,55),
	('0130F00010',500021,4,30),
	('S36453B001',500022,6,25),
	('GSZ140361',500023,2,1800),
	('GSZ140361',500024,2,1800),
	('KA56DS001',500025,18,1);


-- Insert data into the INVOICEPARTS table
--schema: INVOICEPARTS (PartsInStockID, PartOrderID, InvoiceID, Quantity, SalesPrice)
	INSERT INTO tblInvoiceParts Values
	(400001,500001,200001,1,60),
	(400001,500001,200002,1,60),
	(400012,500012,200003,1,32),
	(400005,500005,200004,2,35),
	(400013,500013,200004,1,20),
	(400002,500002,200005,1,1200),
	(400003,500003,200006,1,1800),
	(400025,500025,200007,1,1),
	(400013,500013,200007,1,20),
	(400018,500018,200008,2,55),
	(400019,500019,200009,1,50),
	(400025,500025,200010,2,1),
	(400024,500024,200011,1,1800),
	(400003,500003,200012,1,1800),
	(400020,500020,200015,1,55),
	(400022,500022,200015,1,25);

--Displays Tables
	SELECT * FROM tblOrganizations
	SELECT * FROM tblVendors
	SELECT * FROM tblRoles
	SELECT * FROM tblPeople
	SELECT * FROM tblEmployees
	SELECT * FROM tblCustomers
	SELECT * FROM tblRequests
	SELECT * FROM tblWorkOrders
	SELECT * FROM tblEmployeeWorkOrders
	SELECT * FROM tblInvoices
	SELECT * FROM tblPartsCatalog
	SELECT * FROM tblPartOrders
	SELECT * FROM tblPartsInStock
	SELECT * FROM tblInvoiceParts

/*********************************************************************/
/*          !!!! END OF CODE TO CREATE THE DATABASE !!!!             */ 
/*********************************************************************/


/*********************************************************************/
/*							BUSINESS QUESTIONS					     */
/*********************************************************************/

---------------------------
--  BUSINESS QUESTION 1  --
---------------------------

-- Q1. Ref BR5. What date will the most recent order for part 0230K00001 arrive? 
--     Show: PartNumber, OrderDateTime as OrderDate, LeadTime, OrderDateTime plus leadTime As Delivery Date

SELECT TOP 1 PartNumber,    Convert(Date, OrderDateTime) as OrderDate, LeadTime, 
           Convert(date,DATEADD(DAY, LeadTime, OrderDateTime)) as [Delivery Date]
FROM       tblPartOrders    po
JOIN       tblPartsCatalog  pc ON po.PartsCatalogID = pc.PartsCatalogID
WHERE      PartNumber =    '0230K00001'
ORDER BY   OrderDateTime    Desc ;

---------------------------
--  BUSINESS QUESTION 2  --
---------------------------

-- Q2. Ref BR1. Katie Fernandez complained that the employee who completed her last work order did a bad job. What is the name of the employee?
--     Show: FirstName, LastName, EmployeeID
SELECT FirstName, LastName, EmployeeID
FROM   tblEmployees e
JOIN   tblPeople    p ON e.EmployeeID = p.PersonID
WHERE  EmployeeID   = (SELECT EmployeeID 
					   FROM tblEmployeeWorkOrders
					   WHERE Responsibility = 'Technicican'
					   AND WorkOrderID = ( SELECT TOP 1 w.WorkOrderID 
										   FROM tblPeople p
										   LEFT JOIN tblCustomers c on p.PersonID = c.CustomerID
									       LEFT JOIN tblRequests r ON c.CustomerID = r.CustomerID
										   LEFT JOIN tblWorkOrders w ON r.RequestID = w.RequestID
										   WHERE p.FirstName = 'Katie'
										   AND p.LastName = 'Fernandez'
										   ORDER BY CompletedDateTime DESC));

---------------------------
--  BUSINESS QUESTION 3  --
---------------------------

-- Q3. Ref BR3. Which employee is working on a work order? What is his/her responsibility?Where and when did the work order complete? How many work orders this year? 
--     Show: EmployeeID, EmployeeName, WorkOrderID, Responsibility, LocationAddress, CompletedDateTime, and total number of work orders this year. Display in ascending order by EmployeeID
SELECT w.WorkOrderID,      e.EmployeeID,      CONCAT(FirstName,' ', LastName) AS 'Employee Name', 
       ew.Responsibility,  w.LocationAddress, w.CompletedDateTime, (SELECT COUNT(WorkOrderID)  
																    FROM   tblWorkOrders 
																    WHERE  YEAR(CompletedDateTime) = 2020) AS TotalWorkOrders
FROM   	 tblPeople            	 p
JOIN     tblEmployees          	 e  ON p.PersonID     = e.EmployeeID
JOIN     tblEmployeeWorkOrders   ew ON ew.EmployeeID  = e.EmployeeID
JOIN     tblWorkOrders        	 w  ON ew.WorkOrderID = w.WorkOrderID
WHERE    YEAR(CompletedDateTime) = 2020
ORDER BY w.WorkOrderID;

---------------------------
--  BUSINESS QUESTION 4  --
---------------------------

-- Q4. Ref BR2. When the office leads issue invoices to customers, they’d like to know how much discount is given to a specific customer? What type is the customer? What payment method the customer uses?
--     Show: InvoiceID, CustomerID, CustomerType, PaymentMethod, DiscountPercentage, the time between the customer making the request and the scheduled date to complete the work order. 
--           Display in ascending order by CustomerID.
SELECT   i.InvoiceID,   c. CustomerID,  c. CustomerType,     c.PaymentMethod, i.DiscountPercentage, 
         DATEDIFF(day,  r.RequestDate,  w.ScheduledDateTime) AS DateDiff
FROM     tblInvoices    i
JOIN     tblCustomers   c ON i.CustomerID  =  c.CustomerID
JOIN     tblWorkOrders  w ON w.WorkOrderID =  i.WorkOrderID
JOIN     tblRequests    r ON r.RequestID   =  w.RequestID
ORDER BY c.CustomerID   ;

---------------------------
--  BUSINESS QUESTION 5  --
---------------------------

-- Q5. Ref BR1. List the technician who worked on each request that required an AC Unit installation.
--     Show: RequestID, ShortDescription, LastName plus FirstName as Name
SELECT r.RequestID, ShortDescription, CONCAT(LastName, ', ', FirstName) AS Name
FROM   tblRequests           r
JOIN   tblWorkOrders         w ON w.RequestID   = r.RequestID
JOIN   tblEmployeeWorkOrders o ON o.WorkOrderID = w.WorkOrderID
JOIN   tblEmployees          e ON e.EmployeeID  = o.EmployeeID
JOIN   tblPeople             p ON p.PersonID    = e.EmployeeID
WHERE  RoleID = 5 AND ShortDescription LIKE '%AC Unit%';

---------------------------
--  BUSINESS QUESTION 6  --
---------------------------

-- Q6. Ref BR5. What was the total cost of AC units we purchased from vendors in the month of october?
--     Show: the month of OrderDateTime as Month, sum of UnitPricePaid *  OrderQuantity as OrderTotal
SELECT   MONTH(OrderDateTime) as Month, SUM(UnitPricePaid*OrderQuantity) as OrderTotal
FROM     tblPartOrders   o
JOIN     tblPartsCatalog c ON c.PartsCatalogID = o.PartsCatalogID
WHERE    category = 'AC Units'
GROUP BY MONTH(OrderDateTime)
HAVING   MONTH(OrderDateTime) = 10;

---------------------------
--  BUSINESS QUESTION 7  --
---------------------------

-- Q7. Ref BR4. Pull out all the invoices on WorkOrders completed in May 2020.
--     Show: InvoiceID, CustomerID, Organization and it’s ID (if any affiliations), Customer’s full name and contact phone number, Short Description of the work done, Labor cost and discount (if any), 
--           Information on the parts used (StockID, PartNumber, ListPrice, Quantity used), Cost of Labor, Parts, and the Total cost charged to the customer.
SELECT i.InvoiceID         , i.CustomerID       , pp.OrganizationID   , org.Organization, 
       pp.FirstName        , pp.LastName        , pp.PhoneNumber    AS 'Contact Number'    , 
	   rq.ShortDescription , i.LaborCost        , i.DiscountPercentage, p.PartsInStockID, 
	   pc.PartNumber       , p.SalesPrice       , p.Quantity, i.LaborCost * (1 - i.DiscountPercentage) AS 'LaborTotal', 
	   p.SalesPrice * p.Quantity AS 'PartsTotal', i.LaborCost * (1 - i.DiscountPercentage) + p.SalesPrice * p.Quantity AS InvoiceTotal
FROM   tblInvoices      i
JOIN   tblInvoiceParts  p   ON i.InvoiceID       = p.InvoiceID
JOIN   tblPartOrders    po  ON p.PartOrderID     = po.PartOrderID
JOIN   tblPartsCatalog  pc  ON po.PartsCatalogID = pc.PartsCatalogID
JOIN   tblCustomers     cu  ON i.CustomerID      = cu.CustomerID
JOIN   tblPeople        pp  ON i.CustomerID      = pp.PersonID
JOIN   tblOrganizations org ON pp.OrganizationID = org.OrganizationID
JOIN   tblWorkOrders    wo  ON i.WorkOrderID     = wo.WorkOrderID
JOIN   tblRequests      rq  ON wo.RequestID      = rq.RequestID
WHERE  i.DueDate between '2020-04-30' and '2020-05-31';

---------------------------
--  BUSINESS QUESTION 8  --
---------------------------

GO

-- Q8. Ref BR2. Create a VIEW showing all Parts arriving to the office within a week from the current date.
--     Show: PartOrderID, Vendor, WorkOrderID (if the part was ordered in association with a specific WorkOrder), PartNumber, OrderQuantity, TrackingNumber, Order Placement date, Expected Arrival Date. 
CREATE VIEW vw_PartsArrival AS
SELECT      po.PartOrderID, v.Vendor, po.WorkOrderID, pc.PartNumber, po.OrderQuantity, po.TrackingNumber, 
            po.OrderDateTime, (po.OrderDateTime + pc.LeadTime) AS ExpectedArrivalDate
FROM        tblPartOrders   po
LEFT JOIN   tblPartsCatalog pc ON po.PartsCatalogID = pc.PartsCatalogID
JOIN        tblVendors      v  ON pc.VendorID       = v.VendorID
WHERE       (po.OrderDateTime + pc.LeadTime) >= GETDATE()
AND         (po.OrderDateTime + pc.LeadTime) <= (GETDATE() + 7);

GO
---------------------------
--  BUSINESS QUESTION 9  --
---------------------------

-- Q9. Ref BR1. Assume a customer is calling you asking about an AC unit installation that their organization commissioned with SunnyServices at one of their properties some time earlier this year. 
--              They are unable to find the Invoice that they need for a tax write-off.
--     Show: InvoiceID, WorkSite Address, Short Description, Completion date, Total Invoice amount charged, as well as the Contact Person full name and 
--           Organization to verify the identity of the person calling based on their phone number: (415) 494-1744.
SELECT p.FirstName       , p.LastName          , o.Organization   , rq.ShortDescription, 
       wo.LocationAddress, wo.CompletedDateTime, i.InvoiceID,
       i.LaborCost * (1 - i.DiscountPercentage) + inp.SalesPrice * inp.Quantity AS InvoiceTotal
FROM   tblRequests      rq
JOIN   tblWorkOrders    wo  ON wo.RequestID     = rq.RequestID
JOIN   tblCustomers     c   ON rq.CustomerID    = c.CustomerID
JOIN   tblPeople        p   ON c.CustomerID     = p.PersonID
JOIN   tblInvoices      i   ON i.WorkOrderID    = wo.WorkOrderID
JOIN   tblInvoiceParts  inp ON inp.InvoiceID    = i.InvoiceID
JOIN   tblOrganizations o   ON p.OrganizationID = o.OrganizationID
WHERE  p.PhoneNumber = '(415) 494-1744';

---------------------------
--  BUSINESS QUESTION 10 --
---------------------------

-- Q10. Ref BR2.  List the CustomerID,  full name (First Name & Last Name), total quantity ordered for the customer(s) who ordered the most parts last year.
-- Show: CustomerID, Last Name and First Name of Customer(s), List the total quantity of parts each customer ordered last year in descending order to find
--       out which customers ordered the most parts.

SELECT DISTINCT TOP 1 WITH TIES c.CustomerID, p.FirstName, p.LastName, TotalQuantity 
FROM   tblPeople  p
JOIN   tblCustomers    c   ON p.personID   = c.CustomerID 
JOIN   tblInvoices     i   ON i.CustomerID = i.CustomerID
JOIN   tblInvoiceParts inp ON inp.InvoiceID = i.InvoiceID
JOIN (SELECT i2.CustomerID, SUM(Quantity) TotalQuantity
	  FROM tblInvoices     i2
	  JOIN tblInvoiceParts inp2 ON i2.InvoiceID = inp2.InvoiceID
	  GROUP BY CustomerID
	  )                TQ  ON TQ.CustomerID = c.CustomerID
WHERE i.CreatedDate > DATEADD(year,-1,GETDATE( ))
ORDER BY TotalQuantity DESC;

