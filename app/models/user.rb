class User < ActiveRecord::Base
  acts_as_authentic
  has_and_belongs_to_many :skills
  has_many :labs
  has_many :annotations
  has_many :transactions
  has_many :items
  has_many :project_assignments
  has_many :projects, :through => :project_assignments

  attr_accessor :skill_list
  after_save :update_skills

  def to_param
    username
  end

  def self.factory(type,params)
    type ||= 'User'
    class_name = type

    if defined? class_name.constantize
      return class_name.constantize.new(params)
    else
      User.new(params)
    end

  end

  def class_type=(value)
    self[:type] = value
  end

  def class_type
    return self[:type]
  end

  private

  def update_skills
    skills.delete_all
    selected_skills = skill_list.nil? ? [] : skill_list.keys.collect{|id| Skill.find_by_id(id) }
    selected_skills.each {|skill| self.skills << skill }
  end
end
