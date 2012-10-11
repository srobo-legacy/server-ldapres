class Puppet::Provider::Ldapres < Puppet::Provider
  def initialize(*args)
    puts "I'm covered in bees"
    puts args.inspect
  end
end

Puppet::Type.type(:ldapres).provide :default, :parent => Puppet::Provider::Ldapres do
  desc "Default provider for ldapres resources"

  confine :true => Puppet.features.ldap?
end
