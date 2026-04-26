USE bidi_db;

-- Location
INSERT INTO Location (Address, Country) VALUES
('Helsinki Office, Mannerheimintie 10', 'Finland'),
('Lahti Office, Vesijarvenkatu 25', 'Finland'),
('Tampere Office, Hameenkatu 15', 'Finland');

-- Customer
INSERT INTO Customer (Name, Email, LID) VALUES
('MediCare Oy', 'contact@medicare.fi', 1),
('HealthTech Nordic', 'info@healthtech.fi', 2),
('Wellness Systems', 'support@wellness.fi', 3);

-- Department
INSERT INTO Department (Name, LID) VALUES
('HR', 1),
('Software', 1),
('Data', 2),
('ICT', 3),
('Customer Support', 2);

-- Employee
INSERT INTO Employee (Email, Name, HireDate, DepID) VALUES
('anna@bidi.fi', 'Anna Korhonen', '2024-08-01', 2),
('mikko@bidi.fi', 'Mikko Laine', '2024-09-15', 3),
('sara@bidi.fi', 'Sara Niemi', '2025-01-10', 4),
('pekka@bidi.fi', 'Pekka Virtanen', '2024-11-20', 5),
('liisa@bidi.fi', 'Liisa Salonen', '2023-06-05', 1);

-- RoleTable
INSERT INTO RoleTable (Name) VALUES
('Developer'),
('Data Analyst'),
('Project Manager'),
('System Admin'),
('Support Specialist');

-- UserGroupTable
INSERT INTO UserGroupTable (Name) VALUES
('Internal Users'),
('Project Leads'),
('External Support Team');

-- Project
INSERT INTO Project (Name, Budget, Status, Priority, startDate, deadline, CID) VALUES
('Patient Portal', 120000.00, 'Active', 'High', '2026-01-10', '2026-08-30', 1),
('EHR Analytics', 85000.00, 'Active', 'Medium', '2026-02-01', '2026-10-15', 2),
('Remote Care Platform', 150000.00, 'Planned', 'High', '2026-03-01', '2026-12-20', 3);

-- Works
INSERT INTO Works (PrID, EmpID, started) VALUES
(1, 1, '2026-01-15'),
(1, 2, '2026-01-20'),
(2, 2, '2026-02-05'),
(2, 3, '2026-02-10'),
(3, 1, '2026-03-10'),
(3, 4, '2026-03-15');

-- HasRole
INSERT INTO HasRole (EmpID, RoleID, Description) VALUES
(1, 1, 'Frontend and backend development'),
(2, 2, 'Analytics and reporting'),
(3, 4, 'Infrastructure administration'),
(4, 5, 'Customer issue handling'),
(5, 3, 'HR coordination and project oversight');

-- PartOf
INSERT INTO PartOf (EmpID, GrID) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 1),
(3, 2),
(4, 3),
(5, 2);