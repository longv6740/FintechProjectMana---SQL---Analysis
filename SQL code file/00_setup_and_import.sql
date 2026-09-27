-- =====================================================================
-- 00_setup_and_import.sql
-- Part 1: build the RAW layer (the data exactly as it arrived)
--
-- Rules for this layer:
--   * every column is TEXT, so nothing is converted or lost on import
--   * column order = CSV header order; names = snake_case of the headers
--   * raw is never edited. All fixes happen in the clean schema (Part 2)
--
-- How to run:
--   1. Once, from any other database:  CREATE DATABASE fintech_pm;
--   2. Connect to fintech_pm and run sections 1 and 2.
--   3. Import the CSVs with DBeaver (section 3).
--   4. Run the checks (section 4).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Schemas
-- ---------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS clean;


-- ---------------------------------------------------------------------
-- 2. Raw tables (all TEXT, re-runnable thanks to DROP IF EXISTS)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS raw.departments;
CREATE TABLE raw.departments (
    department_id       TEXT,
    department_name     TEXT,
    head_of_department  TEXT
);

DROP TABLE IF EXISTS raw.projects;
CREATE TABLE raw.projects (
    project_id                 TEXT,
    product_name               TEXT,
    department_id              TEXT,
    project_manager_id         TEXT,
    city                       TEXT,
    project_country_latitude   TEXT,
    project_country_longitude  TEXT,
    planned_start_date         TEXT,
    planned_end_date           TEXT,
    actual_start_date          TEXT,
    actual_end_date            TEXT,
    status                     TEXT,
    planned_budget_eur         TEXT,
    actual_budget_eur          TEXT,
    risk_level                 TEXT,
    completion_pct             TEXT,
    project_country            TEXT
);

DROP TABLE IF EXISTS raw.employees;
CREATE TABLE raw.employees (
    employee_id                 TEXT,
    full_name                   TEXT,
    department_id               TEXT,
    role                        TEXT,
    experience_level            TEXT,
    country                     TEXT,
    city                        TEXT,
    employee_country_latitude   TEXT,
    employee_country_longitude  TEXT,
    hourly_rate                 TEXT   -- EUR per hour
);

DROP TABLE IF EXISTS raw.tasks;
CREATE TABLE raw.tasks (
    task_id        TEXT,
    project_id     TEXT,
    employee_id    TEXT,   -- CSV header: "AssignedTo (EmployeeID)"
    task_name      TEXT,
    planned_hours  TEXT,
    actual_hours   TEXT,
    task_status    TEXT,
    priority       TEXT
);

DROP TABLE IF EXISTS raw.milestones;
CREATE TABLE raw.milestones (
    milestone_id             TEXT,
    project_id               TEXT,
    milestone_name           TEXT,
    planned_completion_date  TEXT,
    actual_completion_date   TEXT,
    status                   TEXT
);


-- ---------------------------------------------------------------------
-- 3. Import (done in DBeaver, not in SQL)
--    Right-click each table > Import Data > CSV
--      * Header: top, delimiter: ","
--      * Mapping: every column must say "existing". DBeaver matches by
--        NAME, so headers like "EmployeeID" must be mapped by hand to
--        employee_id, otherwise DBeaver skips them or creates new columns
--      * Tick "Truncate target table before load"
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- 4. Checks
-- ---------------------------------------------------------------------

-- 4a. Row counts. Expected: 7 / 120 / 72 / 624 / 288
SELECT 'departments' AS table_name, COUNT(*) AS row_count FROM raw.departments
UNION ALL SELECT 'employees',  COUNT(*) FROM raw.employees
UNION ALL SELECT 'projects',   COUNT(*) FROM raw.projects
UNION ALL SELECT 'tasks',      COUNT(*) FROM raw.tasks
UNION ALL SELECT 'milestones', COUNT(*) FROM raw.milestones;

-- 4b. Mapping check: the ID column of every table must be filled.
--     A wrong mapping still gives the right row count, but with NULL columns.
--     Expected: 0 everywhere
SELECT 'departments' AS table_name, COUNT(*) FILTER (WHERE department_id IS NULL) AS null_ids FROM raw.departments
UNION ALL SELECT 'employees',  COUNT(*) FILTER (WHERE employee_id  IS NULL) FROM raw.employees
UNION ALL SELECT 'projects',   COUNT(*) FILTER (WHERE project_id   IS NULL) FROM raw.projects
UNION ALL SELECT 'tasks',      COUNT(*) FILTER (WHERE task_id      IS NULL) FROM raw.tasks
UNION ALL SELECT 'milestones', COUNT(*) FILTER (WHERE milestone_id IS NULL) FROM raw.milestones;
