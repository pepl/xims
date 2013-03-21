PROMPT Extending ci_sessions
ALTER TABLE CI_SESSIONS ADD auth_module VARCHAR2(50);
UPDATE CI_SESSIONS SET auth_module = 'dummy_value';
ALTER TABLE CI_SESSIONS MODIFY auth_module NOT NULL
/
