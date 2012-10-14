Puppet::Type.newtype(:ldapres) do
  @doc = "Insert here: documentation."
	ensurable

	newparam(:dn, :namevar => true) do
    desc "The DN of the ldapres we're working on"
  end

  newproperty(:objectclass, :array_matching => :all)  do
    desc "Object class of DN being manipulated"
  end

  newproperty(:cn, :array_matching => :all)  do
    desc "Common name of LDAP resource"
  end

  newproperty(:sn, :array_matching => :all)  do
    desc "Surname of inetOrgPerson"
  end

  newproperty(:uid, :array_matching => :all) do
    desc "Username of inetOrgPerson"
  end

  newproperty(:mail, :array_matching => :all) do
    desc "Email address of inetOrgPerson"
  end

  newproperty(:loginshell, :array_matching => :all) do
    desc "Login shell path of posixAccount"
  end

  newproperty(:uidnumber, :array_matching => :all) do
    desc "UID of posixAccount"
  end

  newproperty(:gidnumber, :array_matching => :all) do
    desc "Primary group ID of posixAccount"
  end

  newproperty(:homedirectory, :array_matching => :all) do
    desc "Home directory of a posixAccount"
  end

  newproperty(:userpassword, :array_matching => :all) do
    desc "Password record of various account objects"
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
