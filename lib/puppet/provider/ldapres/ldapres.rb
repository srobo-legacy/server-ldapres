Puppet::Type.type(:ldapres).provide :default do
  desc "Default provider for ldapres resources"

  confine :true => Puppet.features.ldap?

  def getconnected
    @conn = LDAP::Conn.new(host=@resource[:ldapserverhost],
                           port=Integer(@resource[:ldapserverport]))
    @conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @conn.bind(dn=@resource[:binddn], password=@resource[:bindpw],
               method=LDAP::LDAP_AUTH_SIMPLE)
  end

  def unconnect
    @conn.unbind
  end

  def exists?
    getconnected
    itexists = false
    @conn.search(@resource[:dn], LDAP::LDAP_SCOPE_BASE, '(objectclass=*)') do |entry|
      itexists = true
    end
    unconnect
    return itexists
  end

end
