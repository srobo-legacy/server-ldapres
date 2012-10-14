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

  def create_mod_array(input)
    modarray = []
    input.each do |key, value|
      key = key.to_s
      if (key == "objectclass") then
        key = "objectClass"
      end

      mod = LDAP::Mod.new(LDAP::LDAP_MOD_REPLACE, key, value)
      modarray = modarray << mod
    end
    return modarray
  end

  # Add ldap modifications that delete certain attributes and put them into
  # the modarray array. The attributes deleted are those that exist (i.e., are
  # in @resvals, but are not in the array of values being set, refhash.
  def del_missing_properties(modarray, refhash)
    @resvals.each do |key, value|
      if key == "dn" or key == "objectClass" then
        next
      end
      if ! refhash.keys.include?(key) then
        mod = LDAP::Mod.new(LDAP::LDAP_MOD_DELETE, key, value)
        modarray = modarray << mod
      end
    end
    return modarray
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
        @resvals.each do |key, value|
          key = key.to_sym
          if key == :objectClass then
            key = :objectclass
          end
          @property_hash[key] = value
        end
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

  def create
    @needscreating = true
  end

  mk_resource_methods

  def flush
    if @resource[:ensure] == :absent then
      return
    end

    # This is the point at which we take all of the properties we contain,
    # and flush them into the actual ldap record.
    changed = false
    @property_hash.each do |key, value|
      if key == :objectclass then
        key = :objectClass # don't ask
      end

      key = key.to_s

      if @resvals.member? key then
        if ! @resvals[key].include?(value) then
          changed = true
        end
      else
        changed = true
      end
    end

    # If we changed something, produce a modification to apply
    if changed or @needscreating == true then
      getconnected
      # Apply it

      if @needscreating == true then
        # Fetch any specified properties out of the parameter array.
        # These don't make it into @property_hash for some unknown reason.
        toconvert = {}
        parameters = @resource.parameters
        parameters.each do |key, value|
          if value.is_a?(Puppet::Property) and key != :ensure then
            toconvert[key.to_s] = value.should
          end
        end
        modarray = create_mod_array(toconvert)

        begin
          @conn.add(@resource[:dn], modarray)
        rescue LDAP::ResultError
          err = @conn.err2string(@conn.err)
          unconnect
          raise Puppet::Error, "Couldn't create LDAP resource with dn " + @resource[:dn] + " because '" + err + "'"
        end
      else
        modarray = create_mod_array(@property_hash)
        begin
          @conn.modify(@resource[:dn], modarray)
        rescue LDAP::ResultError
          err = @conn.err2string(@conn.err)
          unconnect
          raise Puppet::Error, "Couldn't modify LDAP resource with dn " + @resource[:dn] + " because '" + err + "'"
        end
      end

      unconnect
    end

  end
end
