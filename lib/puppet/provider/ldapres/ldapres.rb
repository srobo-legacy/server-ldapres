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
    begin
      # Search for any object with the given DN.
      @conn.search(@resource[:dn], LDAP::LDAP_SCOPE_BASE, '(objectclass=*)') do |entry|
        # It exists, success
        itexists = true
      end
    rescue LDAP::ResultError
      # If object wasn't found, then that's an expected result, it's absent.
      if @conn.err != 32 then
        # All other errors are proper failures.
        err = @conn.err2string(@conn.err)
        unconnect
        raise Puppet::Error, "Couldn't search for LDAP resource with dn " + @resource[:dn] + " because '" + err + "'"
      end
    end
    unconnect
    return itexists
  end

  def destroy
    getconnected
    begin
      @conn.delete(@resource[:dn])
    rescue LDAP::ResultError
      err = @conn.err2string(@conn.err)
      unconnect
      raise Puppet::Error, "Couldn't delete LDAP resource with dn " + @resource[:dn] + " because '" + err + "'"
    end
    unconnect
    return true
  end
end
