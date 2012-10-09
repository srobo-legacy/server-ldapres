Puppet::Type.type(:ldapres).provide :default  do
  desc "Default provider for ldapres resources"

  confine :true => Puppet.features.ldap?
end
