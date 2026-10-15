-- EXPERIMENT 5
-- Views, view updatability, and a recursive CTE for employee reporting chains.
USE CompanyDB;

-- PREREQUISITE FROM THE SOURCE DOCUMENT:
-- The PDF says Employee has a manager_id column referencing Employee(emp_id),
-- but it does not show the ALTER TABLE statement or the manager assignment data.
-- If manager_id does not yet exist, run these two statements ONCE by uncommenting them:
-- ALTER TABLE Employee ADD COLUMN manager_id INT NULL;
-- ALTER TABLE Employee
--   ADD CONSTRAINT fk_employee_manager
--   FOREIGN KEY (manager_id) REFERENCES Employee(emp_id);
-- Populate manager_id values separately to create actual reporting relationships.

-- QUERY 1: DEPARTMENT SALARY SUMMARY VIEW
-- Save grouped salary statistics as a reusable virtual table.
CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary,
    SUM(e.salary) AS total_salary
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Inspect the department summary view.
SELECT *
FROM department_salary_summary;

-- QUERY 2: EMPLOYEE HIERARCHY VIEW
-- Show each employee and the name of their immediate manager (if assigned).
-- Requires Employee.manager_id to exist.
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.manager_id,
    m.emp_name AS manager_name,
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
LEFT JOIN Employee m ON e.manager_id = m.emp_id;

-- Inspect the employee/manager pairs.
SELECT *
FROM employee_hierarchy;

-- QUERY 3: TEST VIEW UPDATABILITY
-- The source document expects this joined-view update to fail. View updatability
-- depends on the database's rules and the exact view definition; test it in your MySQL version.
UPDATE employee_hierarchy
SET salary = salary + 1000
WHERE emp_id = 6;

-- Verify the base-table salary after testing the update.
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 6;

-- This grouped view contains GROUP BY and aggregate expressions and is not directly updatable.
-- The source document includes this as a test expected to fail.
UPDATE department_salary_summary
SET average_salary = average_salary + 1000
WHERE dept_id = 1;

-- QUERY 4: RECURSIVE CTE — REPORTING CHAIN
-- Start from rows with no manager and recursively append their direct reports.
-- Useful chains require meaningful manager_id values to have been populated first.
WITH RECURSIVE reporting_chain AS (
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        1 AS level,
        CAST(e.emp_name AS CHAR(500)) AS reporting_path
    FROM Employee e
    WHERE e.manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1,
        CONCAT(rc.reporting_path, ' -> ', e.emp_name)
    FROM Employee e
    JOIN reporting_chain rc ON e.manager_id = rc.emp_id
)
SELECT emp_id, emp_name, manager_id, level, reporting_path
FROM reporting_chain
ORDER BY reporting_path;
