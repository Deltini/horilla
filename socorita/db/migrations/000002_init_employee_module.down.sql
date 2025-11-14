-- Drop employee module tables in reverse order

-- Remove the foreign key from departments table
ALTER TABLE departments DROP CONSTRAINT IF EXISTS fk_departments_manager;

DROP TABLE IF EXISTS employee_tags;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS employee_notes;
DROP TABLE IF EXISTS emergency_contacts;
DROP TABLE IF EXISTS employee_bank_details;
DROP TABLE IF EXISTS employee_work_info;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS users;
