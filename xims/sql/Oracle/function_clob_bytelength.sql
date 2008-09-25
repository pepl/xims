-- Copyright (c) 2002-2008 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id: function_now.sql 1443 2006-03-26 21:33:14Z pepl $
CREATE OR REPLACE
FUNCTION CLOB_BYTELENGTH
( clob_in IN CLOB
) RETURN NUMBER IS
    temp_lob BLOB;
    byte_length NUMBER;
    char_length NUMBER;
    dest_offset NUMBER;
    src_offset NUMBER;
    lang_context NUMBER;
    warn varchar2(1000);
BEGIN
    dest_offset := 1;
    src_offset := 1;
    lang_context := 0;
    char_length := dbms_lob.getlength( clob_in );

    IF clob_in IS NULL OR char_length = 0 THEN
        dbms_output.put_line('Warning: 0 byte input, setting length to 0');
        byte_length := 0;
    ELSE
        dbms_lob.createtemporary(temp_lob, TRUE, dbms_lob.CALL);
        dbms_lob.converttoblob(temp_lob,
                               clob_in,
                               DBMS_LOB.LOBMAXSIZE,
                               dest_offset,
                               src_offset,
                               0,
                               lang_context,
                               warn);
        byte_length := dbms_lob.getlength(temp_lob);
        dbms_lob.freetemporary(temp_lob);
    END IF;
    RETURN byte_length;
END CLOB_BYTELENGTH;
/

