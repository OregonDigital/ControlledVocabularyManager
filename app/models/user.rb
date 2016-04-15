class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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

end
