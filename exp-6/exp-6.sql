-- EXPERIMENT 6
-- Stored procedure for department transfer, salary validation, and audit logging.
USE CompanyDB;

-- QUERY 1: SALARY AUDIT TABLE
-- Keeps a record of old/new salary values and the time of the change.
CREATE TABLE IF NOT EXISTS Employee_Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(30)
);

-- QUERY 2: SALARY VALIDATION BEFORE INSERT
-- Reject inserted salary values below 30,000 or above 150,000.
DELIMITER //
CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 30000 OR NEW.salary > 150000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be between 30000 and 150000';
    END IF;
END//
DELIMITER ;

-- SUPPLEMENTAL TRIGGER (the source PDF describes update validation but does not
-- provide a BEFORE UPDATE trigger definition). This implements that stated intent.
DELIMITER //
CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 30000 OR NEW.salary > 150000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be between 30000 and 150000';
    END IF;
END//
DELIMITER ;

-- TEST salary validation separately.
-- This should raise SQLSTATE 45000 if employee 6 exists and the update trigger is installed:
-- UPDATE Employee SET salary = 20000 WHERE emp_id = 6;
-- A valid example from the source document:
-- UPDATE Employee SET salary = 85000 WHERE emp_id = 6;

-- QUERY 3: SALARY AUDIT TRIGGER
-- After an update, write an audit row only if the salary actually changed.
DELIMITER //
CREATE TRIGGER audit_salary_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO Employee_Salary_Audit
            (emp_id, old_salary, new_salary, action)
        VALUES
            (NEW.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATE');
    END IF;
END//
DELIMITER ;

-- The source PDF tests employee 31, but Experiment 3 inserts only employees 1–30.
-- The following test uses employee 6 so a row exists in the Experiment 3 sample data.
UPDATE Employee
SET salary = 51000
WHERE emp_id = 6;

-- Display audit records produced by successful salary updates.
SELECT audit_id, emp_id, old_salary, new_salary, changed_at, action
FROM Employee_Salary_Audit
ORDER BY audit_id;

-- QUERY 4: STORED PROCEDURE — TRANSFER EMPLOYEE
-- Validate employee and department IDs, then transfer within a transaction.
DELIMITER //
CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_emp_count INT DEFAULT 0;
    DECLARE v_dept_count INT DEFAULT 0;
    DECLARE v_old_dept_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_emp_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_emp_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee does not exist';
    END IF;

    SELECT COUNT(*) INTO v_dept_count
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF v_dept_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department does not exist';
    END IF;

    SELECT dept_id INTO v_old_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_old_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee is already in this department';
    END IF;

    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;
END//
DELIMITER ;

-- QUERY 5: TEST A SUCCESSFUL TRANSFER
-- In Experiment 3's data, employee 6 is Ivaan in Engineering (dept 1), and dept 4 is Sales.
-- The source PDF's text says Development -> Sales, which does not match Experiment 3's department names.
CALL transfer_employee(6, 4);

SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.emp_id = 6;

-- QUERY 6: EDGE CASE TESTS — uncomment/run individually to observe expected errors.
-- Invalid employee:
-- CALL transfer_employee(99, 4);
-- Invalid department:
-- CALL transfer_employee(6, 99);
-- Employee already in that department (after the successful transfer above):
-- CALL transfer_employee(6, 4);

-- QUERY 7: AUDIT LOG CHECK
SELECT audit_id, emp_id, old_salary, new_salary, changed_at, action
FROM Employee_Salary_Audit
ORDER BY audit_id;
