-- liquibase formatted sql

-- changeset aayushjain:04

INSERT INTO AUDIT_DTLS_CICD_TESTING4 (BATCH_ID, APPLICATION_NAME, SUBJECT_AREA_NAME, INTERFACE_NAME, TASK_NAME, TASK_TYPE)
VALUES ('3', 'liquibase', 'integration', 'snowflake', 'intgration', 'normal');