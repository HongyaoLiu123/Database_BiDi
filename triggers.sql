USE bidi_db;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_project_insert$$
DROP TRIGGER IF EXISTS trg_project_update$$
DROP TRIGGER IF EXISTS trg_project_delete$$
DROP TRIGGER IF EXISTS trg_works_insert$$

CREATE TRIGGER trg_project_insert
AFTER INSERT ON Project
FOR EACH ROW
BEGIN
    INSERT INTO ProjectAudit (
        PrID,
        ProjectName,
        ActionType,
        NewBudget,
        NewStatus,
        ChangedBy
    )
    VALUES (
        NEW.PrID,
        NEW.Name,
        'INSERT',
        NEW.Budget,
        NEW.Status,
        CURRENT_USER()
    );
END$$

CREATE TRIGGER trg_project_update
AFTER UPDATE ON Project
FOR EACH ROW
BEGIN
    INSERT INTO ProjectAudit (
        PrID,
        ProjectName,
        ActionType,
        OldBudget,
        NewBudget,
        OldStatus,
        NewStatus,
        ChangedBy
    )
    VALUES (
        NEW.PrID,
        NEW.Name,
        'UPDATE',
        OLD.Budget,
        NEW.Budget,
        OLD.Status,
        NEW.Status,
        CURRENT_USER()
    );
END$$

CREATE TRIGGER trg_project_delete
BEFORE DELETE ON Project
FOR EACH ROW
BEGIN
    INSERT INTO ProjectAudit (
        PrID,
        ProjectName,
        ActionType,
        OldBudget,
        OldStatus,
        ChangedBy
    )
    VALUES (
        OLD.PrID,
        OLD.Name,
        'DELETE',
        OLD.Budget,
        OLD.Status,
        CURRENT_USER()
    );
END$$

CREATE TRIGGER trg_works_insert
BEFORE INSERT ON Works
FOR EACH ROW
BEGIN
    DECLARE project_start_date DATE;

    SELECT startDate
    INTO project_start_date
    FROM Project
    WHERE PrID = NEW.PrID;

    IF NEW.started < project_start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The work start date cannot be earlier than the project start date.';
    END IF;
END$$

DELIMITER ;