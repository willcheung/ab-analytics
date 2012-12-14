class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :registerable,:timeoutable, :validatable, :recoverable and :omniauthable
  devise :rememberable, :trackable#,:ldap_authenticatable
  
  # before_save :get_ldap_email, :get_ldap_name

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :password, :remember_me, :email
  
  def get_ldap_email 
    self.email = Devise::LdapAdapter.get_ldap_param(self.username,"mail") 
  end
  
  def get_ldap_name 
    self.name = Devise::LdapAdapter.get_ldap_param(self.username,"cn") 
  end
  
  def self.authenticate_old(username, password)
    LDAP::Conn.new(host='ldap-vip.domain.com', port=LDAP::LDAP_PORT)
    conn.bind(dn='uid=,ou=people,dc=domain,dc=net',password='',method=LDAP::LDAP_AUTH_SIMPLE)
    conn.search(base_dn='uid=wcheung,ou=people,dc=domain,dc=net',scope=1,filter='(&(objectClass=person)(|(givenName=Will)(mail=wcheung*)))')
  end
end
