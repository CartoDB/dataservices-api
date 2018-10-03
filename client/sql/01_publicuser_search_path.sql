-- Make sure publicuser has a sane search path although it can not execute
ALTER USER publicuser SET search_path = "$user",cartodb,public,cdb_dataservices_client;
