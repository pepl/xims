-- Update existing grants which used 'MODIFY' pseudo privilege and version 0.9 value of 'COPY'
UPDATE CI_OBJECT_PRIVS_GRANTED SET privilege_mask = 1124167447 WHERE privilege_mask = 1124152599;
-- Update wrong values resulting from a typo in the update script 0.7_0.8
UPDATE CI_OBJECT_PRIVS_GRANTED SET privilege_mask = 1124167447 WHERE privilege_mask = 112415259;
-- be sure not to overlook old grants before COPY has been introduced
UPDATE CI_OBJECT_PRIVS_GRANTED SET privilege_mask = 1124167447 WHERE privilege_mask = 1124151063;
-- update existing MODIFY,PUBLISH grants to include COPY
UPDATE CI_OBJECT_PRIVS_GRANTED SET privilege_mask = 1124167455 WHERE privilege_mask = 1124151071;
-- update existing MODIFY (0.9),PUBLISH grants to include COPY
UPDATE CI_OBJECT_PRIVS_GRANTED SET privilege_mask = 1124167455 WHERE privilege_mask = 1124152607;
