# A user of the system, including admins.
#
# <br /> <br /> <br /> <br /> <br />
# You ever notice how the only people, other than us, who call their customers
# "Users" are drug dealers? Is that a coincidence, or is somebody hiding
# something from us, JOSHUA? MAYBE YOU WOULD KNOW?
#
# What a silly and frivolous comment that was.
class User < ActiveRecord::Base
  acts_as_authentic
  has_and_belongs_to_many :skills
  has_many :labs
  has_many :annotations
  has_many :transactions
  has_many :items

  attr_accessor :skill_list
  after_save :update_skills

  # Gets a parameter string which uniquely represents this user.
  def to_param
    username
  end

  # A factory method which will create various types of users.
  def self.factory(type,params)
    type ||= 'User'
    class_name = type

    if defined? class_name.constantize
      return class_name.constantize.new(params)
    else
      User.new(params)
    end

  end

  # Changes the type of tis user. Maybe they got promoted?
  def class_type=(value)
    self[:type] = value
  end

  # Gets which kind of user this is (or is supposed to be, at any rate).
  def class_type
    return self[:type]
  end

  private

  # Update which skills this user has.
  def update_skills
    skills.delete_all
    selected_skills = skill_list.nil? ? [] : skill_list.keys.collect{|id| Skill.find_by_id(id) }
    selected_skills.each {|skill| self.skills << skill }
  end
end
