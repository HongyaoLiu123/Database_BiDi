USE bidi_db;

-- Remove old users/roles if needed
DROP ROLE IF EXISTS project_manager_role;
DROP ROLE IF EXISTS customer_support_role;

DROP USER IF EXISTS 'pm_user'@'localhost';
DROP USER IF EXISTS 'support_user'@'localhost';

-- =========================
-- 1. Create roles
-- =========================
CREATE ROLE project_manager_role;
CREATE ROLE customer_support_role;

-- =========================
-- 2. Grant privileges to roles
-- =========================

-- Project manager: can manage projects and work assignments.
GRANT SELECT, INSERT, UPDATE, DELETE
ON bidi_db.Project TO project_manager_role;

GRANT SELECT, INSERT, UPDATE, DELETE
ON bidi_db.Works TO project_manager_role;

GRANT SELECT
ON bidi_db.Customer TO project_manager_role;

GRANT SELECT
ON bidi_db.Employee TO project_manager_role;

GRANT SELECT
ON bidi_db.Department TO project_manager_role;

GRANT SELECT
ON bidi_db.Location TO project_manager_role;

GRANT SELECT, INSERT
ON bidi_db.ProjectAudit TO project_manager_role;

GRANT SELECT
ON bidi_db.vw_project_overview TO project_manager_role;

GRANT SELECT, INSERT
ON bidi_db.RoleTable TO project_manager_role;

GRANT SELECT, DELETE
ON bidi_db.PartOf TO project_manager_role;

-- Customer support: can read customer and project information, but cannot modify projects.
GRANT SELECT
ON bidi_db.Customer TO customer_support_role;

GRANT SELECT
ON bidi_db.Project TO customer_support_role;

GRANT SELECT
ON bidi_db.Location TO customer_support_role;

GRANT SELECT
ON bidi_db.Employee TO customer_support_role;

GRANT SELECT
ON bidi_db.Department TO customer_support_role;

GRANT SELECT
ON bidi_db.Works TO customer_support_role;

GRANT SELECT
ON bidi_db.vw_project_overview TO customer_support_role;

GRANT SELECT
ON bidi_db.ProjectAudit TO customer_support_role;

-- =========================
-- 3. Create users
-- =========================
CREATE USER 'pm_user'@'localhost' IDENTIFIED BY 'PmUser123!';
CREATE USER 'support_user'@'localhost' IDENTIFIED BY 'Support123!';

-- =========================
-- 4. Assign roles
-- =========================
GRANT project_manager_role TO 'pm_user'@'localhost';
GRANT customer_support_role TO 'support_user'@'localhost';

SET DEFAULT ROLE project_manager_role TO 'pm_user'@'localhost';
SET DEFAULT ROLE customer_support_role TO 'support_user'@'localhost';
