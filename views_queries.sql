USE bidi_db;

-- =========================
-- 1. View
-- =========================
CREATE OR REPLACE VIEW vw_project_overview AS
SELECT
    p.PrID,
    p.Name AS ProjectName,
    p.Budget,
    p.Status,
    p.Priority,
    p.startDate,
    p.deadline,
    c.CID,
    c.Name AS CustomerName,
    c.Email AS CustomerEmail,
    l.Address AS CustomerAddress,
    l.Country AS CustomerCountry
FROM Project p
JOIN Customer c ON p.CID = c.CID
JOIN Location l ON c.LID = l.LID;

-- =========================
-- 2. Simple SELECT queries
-- =========================

-- Simple SELECT 1
SELECT EmpID, Email, Name, HireDate, DepID
FROM Employee;

-- Simple SELECT 2
SELECT Name, Budget, Status, Priority
FROM Project
WHERE Budget > 100000;

-- =========================
-- 3. JOIN queries (3+ tables)
-- =========================

-- JOIN 1: employee + department + location
SELECT
    e.EmpID,
    e.Name AS EmployeeName,
    d.Name AS DepartmentName,
    l.Address,
    l.Country
FROM Employee e
JOIN Department d ON e.DepID = d.DepID
JOIN Location l ON d.LID = l.LID;

-- JOIN 2: project + customer + location
SELECT
    p.Name AS ProjectName,
    c.Name AS CustomerName,
    l.Address AS CustomerLocation,
    p.Budget,
    p.Status
FROM Project p
JOIN Customer c ON p.CID = c.CID
JOIN Location l ON c.LID = l.LID;

-- JOIN 3: project + works + employee + department
SELECT
    p.Name AS ProjectName,
    e.Name AS EmployeeName,
    d.Name AS DepartmentName,
    w.started
FROM Works w
JOIN Project p ON w.PrID = p.PrID
JOIN Employee e ON w.EmpID = e.EmpID
JOIN Department d ON e.DepID = d.DepID;

-- =========================
-- 4. Aggregation queries
-- =========================

-- Aggregation 1: number of employees per department
SELECT
    d.Name AS DepartmentName,
    COUNT(e.EmpID) AS EmployeeCount
FROM Department d
LEFT JOIN Employee e ON d.DepID = e.DepID
GROUP BY d.DepID, d.Name
HAVING COUNT(e.EmpID) >= 1;

-- Aggregation 2: total budget per customer
SELECT
    c.Name AS CustomerName,
    COUNT(p.PrID) AS NumberOfProjects,
    SUM(p.Budget) AS TotalBudget
FROM Customer c
LEFT JOIN Project p ON c.CID = p.CID
GROUP BY c.CID, c.Name
HAVING SUM(p.Budget) > 50000;

-- =========================
-- 5. INSERT / UPDATE / DELETE examples
-- These examples are also available visually from the Projects page.
-- =========================

-- INSERT example
INSERT INTO RoleTable (Name)
SELECT 'QA Engineer'
WHERE NOT EXISTS (
    SELECT 1 FROM RoleTable WHERE Name = 'QA Engineer'
);

-- UPDATE example
UPDATE Project
SET Budget = 130000.00
WHERE PrID = 1;

-- DELETE example
DELETE FROM PartOf
WHERE EmpID = 4 AND GrID = 3;

-- View usage
SELECT * FROM vw_project_overview;

-- Check audit log created by project triggers
SELECT * FROM ProjectAudit;
