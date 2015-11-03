-- Check if a given host is up by performing a ping -c 1 call.
CREATE OR REPLACE FUNCTION _CDBG_Check_Host(hostname TEXT)
  RETURNS BOOLEAN
AS $$
  import os

  response = os.system("ping -c 1 " + hostname)

  return False if response else True
$$ LANGUAGE plpythonu VOLATILE;

-- Returns current pwd
CREATE OR REPLACE FUNCTION _CDBG_PWD()
  RETURNS TEXT
AS $$
  import os

  return os.getcwd()
$$ LANGUAGE plpythonu VOLATILE;
