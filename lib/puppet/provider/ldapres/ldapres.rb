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
        # Stash a copy/reference/whatever to the values
        @resattrs = entry.attrs
        @resvals = entry.to_hash
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

    if defined?(@resvals) then
      # Everything should have an objectClass,
      objclass = @resvals['objectClass'][0]
      expected = @resource[:objectclass]
      # Does it match what puppet expects?
      if objclass != expected then
        raise Puppet::Error, "LDAP resource " + @resource[:dn] + " has objectclass '" + objclass + "', but we expected class '" + expected + "'. Cowardly refusing to delete existing data."
      end
    end

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

  def create
    getconnected
    themod = LDAP::Mod.new(LDAP::LDAP_MOD_ADD, "objectClass", [@resource[:objectclass]])
    begin
      @conn.add(@resource[:dn], [themod])
    rescue LDAP::ResultError
      err = @conn.err2string(@conn.err)
      unconnect
      raise Puppet::Error, "Couldn't create LDAP resource with dn " + @resource[:dn] + " because '" + err + "'"
    end
    unconnect
  end

  mk_resource_methods
end
