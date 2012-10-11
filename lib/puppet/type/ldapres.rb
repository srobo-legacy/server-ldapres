Puppet::Type.newtype(:ldapres) do
  @doc = "Insert here: documentation."
	ensurable

	newparam(:dn, :namevar => true) do
    desc "The DN of the ldapres we're working on"
  end

  newproperty(:objectclass)  do
    desc "Object class of DN being manipulated"
  end

  newparam(:binddn) do
    desc "DN to bind to the LDAP server with"
  end

  newparam(:bindpw) do
    desc "Password to bind to the LDAP server with"
  end

  newparam(:ldapserverhost) do
    desc "Hostname of ldap server to connect to"
    defaultto 'localhost'
  end

  newparam(:ldapserverport) do
    desc "Port number of ldap server we're connecting to"
    defaultto '389'
  end
end
