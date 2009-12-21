-- Include 'COPY' privilege in existing grants which used 'MODIFY' pseudo privilege
UPDATE CI_OBJECT_PRIVS_GRANTED SET privilege_mask = 112415259 WHERE privilege_mask = 1124151063