USE bidi_db;


-- Indexing Strategy
-- These indexes improve the performance of common JOIN, filter, and sorting operations used by the SQL queries and the frontend.


-- Customer is frequently joined with Location through LID.
CREATE INDEX idx_customer_lid
ON Customer (LID);

-- Project is frequently joined with Customer through CID.
CREATE INDEX idx_project_cid
ON Project (CID);

-- The frontend filters projects by Status and Priority.
CREATE INDEX idx_project_status_priority
ON Project (Status, Priority);

-- The frontend sorts projects by deadline.
CREATE INDEX idx_project_deadline
ON Project (deadline);

-- Department is frequently joined with Location through LID.
CREATE INDEX idx_department_lid
ON Department (LID);

-- Employee is frequently joined with Department through DepID.
CREATE INDEX idx_employee_depid
ON Employee (DepID);

-- Employee pages can be sorted by HireDate.
CREATE INDEX idx_employee_hiredate
ON Employee (HireDate);

-- Works is frequently joined by EmpID when finding employee assignments.
-- PrID is already the first column of the primary key (PrID, EmpID),
-- so this extra index helps queries that start from EmpID.
CREATE INDEX idx_works_empid
ON Works (EmpID);

-- HasRole is frequently searched by RoleID.
-- EmpID is already the first column of the primary key (EmpID, RoleID).
CREATE INDEX idx_hasrole_roleid
ON HasRole (RoleID);

-- PartOf is frequently searched by GrID.
-- EmpID is already the first column of the primary key (EmpID, GrID).
CREATE INDEX idx_partof_grid
ON PartOf (GrID);
