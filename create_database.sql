DROP DATABASE IF EXISTS bidi_db;
CREATE DATABASE bidi_db;
USE bidi_db;

CREATE TABLE Location (
    LID INT PRIMARY KEY AUTO_INCREMENT,
    Address VARCHAR(255) NOT NULL,
    Country VARCHAR(100) NOT NULL DEFAULT 'Finland',
    CONSTRAINT chk_location_country
        CHECK (Country IN ('Finland', 'Sweden', 'Norway', 'Denmark', 'Estonia'))
);

CREATE TABLE Customer (
    CID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(150) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    LID INT NOT NULL,
    
    CONSTRAINT fk_customer_location
        FOREIGN KEY (LID) REFERENCES Location(LID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
        
    CONSTRAINT chk_customer_email
        CHECK (Email LIKE '%@%.__%')
);

CREATE TABLE Project (
    PrID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Budget DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    Status VARCHAR(20) NOT NULL DEFAULT 'Planned',
    Priority VARCHAR(20) NOT NULL DEFAULT 'Medium',
    startDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    deadline DATE NOT NULL,
    CID INT NOT NULL,

    CONSTRAINT fk_project_customer
        FOREIGN KEY (CID) REFERENCES Customer(CID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_project_budget
        CHECK (Budget >= 0),

    CONSTRAINT chk_project_dates
        CHECK (deadline >= startDate),

    CONSTRAINT chk_project_status
        CHECK (Status IN ('Planned', 'Active', 'Completed')),

    CONSTRAINT chk_project_priority
        CHECK (Priority IN ('Low', 'Medium', 'High'))
);


CREATE TABLE Department (
    DepID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE,
    LID INT NOT NULL,
    CONSTRAINT fk_department_location
        FOREIGN KEY (LID) REFERENCES Location(LID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY AUTO_INCREMENT,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Name VARCHAR(150) NOT NULL,
    HireDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    DepID INT NOT NULL,
    
    CONSTRAINT fk_employee_department
        FOREIGN KEY (DepID) REFERENCES Department(DepID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_employee_email
        CHECK (Email LIKE '%@%.__%')
);

CREATE TABLE RoleTable (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE UserGroupTable (
    GrID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE
);



CREATE TABLE Works (
    PrID INT NOT NULL,
    EmpID INT NOT NULL,
    started DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (PrID, EmpID),
    CONSTRAINT fk_works_project
        FOREIGN KEY (PrID) REFERENCES Project(PrID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_works_employee
        FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE HasRole (
    EmpID INT NOT NULL,
    RoleID INT NOT NULL,
    Description VARCHAR(255) DEFAULT 'Assigned role',
    PRIMARY KEY (EmpID, RoleID),
    CONSTRAINT fk_hasrole_employee
        FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_hasrole_role
        FOREIGN KEY (RoleID) REFERENCES RoleTable(RoleID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE PartOf (
    EmpID INT NOT NULL,
    GrID INT NOT NULL,
    PRIMARY KEY (EmpID, GrID),
    CONSTRAINT fk_partof_employee
        FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_partof_group
        FOREIGN KEY (GrID) REFERENCES UserGroupTable(GrID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



CREATE TABLE ProjectAudit (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    PrID INT,
    ProjectName VARCHAR(150),
    ActionType VARCHAR(30) NOT NULL,
    OldBudget DECIMAL(12,2),
    NewBudget DECIMAL(12,2),
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20),
    ChangedBy VARCHAR(100),
    ActionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);