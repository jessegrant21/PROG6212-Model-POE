CREATE DATABASE RaceDayDB;

USE RaceDayDB;

CREATE TABLE [User] (
UserID        INT IDENTITY(1,1)   NOT NULL,
FullName      NVARCHAR(100)       NOT NULL,
Email         NVARCHAR(150)       NOT NULL,
PasswordHash  NVARCHAR(255)       NOT NULL,
Role          NVARCHAR(20)        NOT NULL,
CONSTRAINT PK_User       PRIMARY KEY (UserID),
CONSTRAINT UQ_User_Email UNIQUE (Email),
CONSTRAINT CK_User_Role  CHECK (Role IN ('Organiser', 'Participant'))
);

CREATE TABLE Venue (
VenueID      INT IDENTITY(1,1) NOT NULL,
VenueName    NVARCHAR(150)     NOT NULL,
AddressLine  NVARCHAR(200)     NULL,
City         NVARCHAR(100)     NOT NULL,
Province     NVARCHAR(50)      NOT NULL,
CONSTRAINT PK_Venue PRIMARY KEY (VenueID)
);

CREATE TABLE Event (
EventID      INT IDENTITY(1,1)  NOT NULL,
OrganiserID  INT                NOT NULL,
VenueID      INT                NOT NULL,
EventName    NVARCHAR(150)      NOT NULL,
EventType    NVARCHAR(10)       NOT NULL,
EventDate    DATE               NOT NULL,
StartTime    TIME               NOT NULL,
CONSTRAINT PK_Event PRIMARY KEY (EventID),
CONSTRAINT FK_Event_Organiser FOREIGN KEY (OrganiserID) REFERENCES [User](UserID),
CONSTRAINT FK_Event_Venue     FOREIGN KEY (VenueID)     REFERENCES Venue(VenueID),
CONSTRAINT CK_Event_Type      CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);

CREATE TABLE Category (
CategoryID       INT IDENTITY(1,1) NOT NULL,
EventID          INT               NOT NULL,
CategoryName     NVARCHAR(100)     NOT NULL,
DistanceKM       DECIMAL(5,2)      NULL,
EntryFee         DECIMAL(8,2)      NOT NULL DEFAULT 0,
CONSTRAINT PK_Category PRIMARY KEY (CategoryID),
CONSTRAINT FK_Category_Event FOREIGN KEY (EventID) REFERENCES Event(EventID),
);

CREATE TABLE Enrolment (
EnrolmentID    INT IDENTITY(1,1) NOT NULL,
ParticipantID  INT               NOT NULL,
CategoryID     INT               NOT NULL,
BibNumber      NVARCHAR(10)      NULL,
PaymentStatus  NVARCHAR(20)      NOT NULL DEFAULT 'Pending',
CONSTRAINT PK_Enrolment PRIMARY KEY (EnrolmentID),
CONSTRAINT FK_Enrolment_Participant FOREIGN KEY (ParticipantID) REFERENCES [User](UserID),
CONSTRAINT FK_Enrolment_Category    FOREIGN KEY (CategoryID)    REFERENCES Category(CategoryID),
CONSTRAINT CK_Enrolment_PaymentStatus CHECK (PaymentStatus IN ('Pending', 'Paid', 'Refunded')),
);

CREATE TABLE Result (
ResultID          INT IDENTITY(1,1) NOT NULL,
EnrolmentID       INT               NOT NULL,
CapturedByID      INT               NOT NULL,
FinishTime        TIME              NULL,
OverallPosition   INT               NULL,
CONSTRAINT PK_Result PRIMARY KEY (ResultID),
CONSTRAINT FK_Result_Enrolment  FOREIGN KEY (EnrolmentID)  REFERENCES Enrolment(EnrolmentID),
CONSTRAINT FK_Result_CapturedBy FOREIGN KEY (CapturedByID) REFERENCES [User](UserID),
);

CREATE TABLE WeatherSnapshot (
WeatherID     INT IDENTITY(1,1) NOT NULL,
EventID       INT               NOT NULL,
ForecastDate  DATE              NOT NULL,
TemperatureC  DECIMAL(4,1)      NULL,
WindSpeedKMH  DECIMAL(5,1)      NULL,
Conditions    NVARCHAR(100)     NULL,
CONSTRAINT PK_WeatherSnapshot PRIMARY KEY (WeatherID),
CONSTRAINT FK_Weather_Event FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE
);

INSERT INTO [User] (FullName, Email, PasswordHash, Role) VALUES
('Sarah Naidoo', 'sarah.naidoo@raceday.co.za', '$2b$12$exampleHashValue001', 'Organiser'), 
('Michael van der Merwe', 'michael.vdm@raceday.co.za', '$2b$12$exampleHashValue002', 'Organiser'), 
('Thabo Mokoena', 'thabo.mokoena@example.com', '$2b$12$exampleHashValue003', 'Participant'), 
('Emma Botha', 'emma.botha@example.com', '$2b$12$exampleHashValue004', 'Participant'), 
('Sipho Dlamini', 'sipho.dlamini@example.com', '$2b$12$exampleHashValue005', 'Participant'),
('Lindiwe Khumalo', 'lindiwe.khumalo@example.com', '$2b$12$exampleHashValue006', 'Participant'); 

INSERT INTO Venue (VenueName, AddressLine, City, Province) VALUES
('Pietermaritzburg City Hall', '333 Church Street', 'Pietermaritzburg', 'KwaZulu-Natal'), 
('Grand Parade', 'Darling Street', 'Cape Town', 'Western Cape'), 
('FNB Stadium', 'Nasrec Road', 'Johannesburg', 'Gauteng'); 

INSERT INTO Event (OrganiserID, VenueID, EventName, EventType, EventDate, StartTime) VALUES
(1, 1, 'Comrades Marathon 2027', 'Run', '2027-06-13', '05:30:00'),   
(2, 2, 'Cape Town Cycle Tour 2027', 'Cycle', '2027-03-08', '06:00:00'), 
(1, 3, 'Soweto Marathon 2025', 'Run', '2025-11-02', '06:00:00');    

INSERT INTO Category (EventID, CategoryName, DistanceKM, EntryFee) VALUES
(1, 'Senior Men', 87.70, 950.00),
(1, 'Senior Women', 87.70, 950.00),
(1, 'Veteran 40+', 87.70, 950.00), 
(2, '109km Individual', 109.00, 650.00),
(2, '42km Mini Tour', 42.00, 450.00),
(2, 'Under 20', NULL, 300.00), 
(3, '10km Fun Run', 10.00, 150.00),
(3, 'Half Marathon 21km', 21.10, 250.00),
(3, 'Full Marathon 42km', 42.20, 350.00); 

INSERT INTO Enrolment (ParticipantID, CategoryID, BibNumber, PaymentStatus) VALUES
(3, 1, 'C1001', 'Paid'),  
(4, 2, 'C2001', 'Paid'),
(5, 4, 'T3001', 'Paid'),
(6, 5, 'T4001', 'Pending'),
(3, 8, 'S5001', 'Paid'),    
(4, 7, 'S6001', 'Paid');   

INSERT INTO Result (EnrolmentID, CapturedByID, FinishTime, OverallPosition) VALUES
(5, 1, '01:45:30', 120), 
(6, 1, '00:52:10', 300);

INSERT INTO WeatherSnapshot (EventID, ForecastDate, TemperatureC, WindSpeedKMH, Conditions) VALUES
(1, '2027-06-10', 14.5, 12.0, 'Partly cloudy'), 
(2, '2027-03-05', 22.0, 25.0, 'Windy, south-easter expected'),
(3, '2025-10-30', 19.0, 8.0, 'Clear skies');          

SELECT 'User'AS TableName, COUNT(*) AS NumRows FROM [User]
UNION ALL SELECT 'Venue', COUNT(*) FROM Venue
UNION ALL SELECT 'Event', COUNT(*) FROM Event
UNION ALL SELECT 'Category', COUNT(*) FROM Category
UNION ALL SELECT 'Enrolment', COUNT(*) FROM Enrolment
UNION ALL SELECT 'Result', COUNT(*) FROM Result
UNION ALL SELECT 'WeatherSnapshot', COUNT(*) FROM WeatherSnapshot;

USE RaceDayDB;
GO
SELECT * FROM [User];
SELECT * FROM Venue;
SELECT * FROM Event;
SELECT * FROM Category;
SELECT * FROM Enrolment;
SELECT * FROM Result;
SELECT * FROM WeatherSnapshot;