class User < ActiveRecord::Base

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :presence => true
  validates :role, :presence => true
  validates :institution, :presence => true

  def admin?
    return false if role.nil?
    role.include?("admin")
  end

  def reviewer?
    return false if role.nil?
    role.include?("reviewer")
  end

  def editor?
    return false if role.nil?
    role.include?("editor")
  end

  def administrative?
    return false if role.nil?
    admin? || editor? || reviewer?
  end

end
