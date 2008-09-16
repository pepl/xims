-- Copyright (c) 2002-2008 The XIMS Project.
-- See the file "LICENSE" for information and conditions for use, reproduction,
-- and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
-- $Id: function_now.sql 1443 2006-03-26 21:33:14Z pepl $
CREATE OR REPLACE FUNCTION CLOB_BYTELENGTH
( clob_in IN CLOB
) RETURN NUMBER IS
    temp_lob BLOB;
    byte_length NUMBER;
    dest_offset integer;
    src_offset integer;
    lang_context integer;
    warn varchar2(1000);
BEGIN
    dest_offset := 1;
    src_offset := 1;
    lang_context := 0;
    
    IF clob_in IS NULL THEN
        byte_length := 0;
    ELSE
        dbms_lob.createtemporary(temp_lob, TRUE, dbms_lob.CALL);
        dbms_lob.converttoblob(temp_lob,
                               clob_in,
                               dbms_lob.getlength( clob_in ),
                               dest_offset,
                               src_offset,
                               0,
                               lang_context,
                               warn);
        byte_length := dbms_lob.getlength(temp_lob);
        --DBMS_LOB.LOBMAXSIZE
        
        -- Temporary LOB handle has to be explicitly freed to avoid 
        -- wrong length calculations at dbms_lob.getlength( clob_in )
        -- during calls inside the same transactions
        -- Result would be ORA-21560 
        -- Not sure about performance penalty
        dbms_lob.freetemporary(temp_lob);

    END IF;
   
    RETURN byte_length;
END CLOB_BYTELENGTH;
/