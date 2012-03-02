# EMC Confidential Information, protected under EMC Bilateral Non-Disclosure Agreement.
# Copyright © 2012 EMC Corporation, All Rights Reserved

#require "#{ENV['RAZOR_HOME']}/lib/project_razor.rb"
require "uuid"
require "project_razor/utility"
require "project_razor/logging"

# Common object for all base ProjectRazor objects
# @abstract
class ProjectRazor::Object
  # Mixin our ObjectUtilities
  include(ProjectRazor::Utility)
  include(ProjectRazor::Logging)

  # There variables are required in all ProjectRazor objects
  attr_accessor :uuid # All objects must have a uuid / can be overridden in child object
  attr_accessor :version # All objects must have a version that is incremented on updates
  attr_accessor :classname # Classname will contain a string representation of the end Class / used for dynamically loading back from DB
  attr_accessor :_persist_ctrl # instance ref pointing to ProjectRazor::Persist::Controller of ProjectRazor::Data that created/fetched this object used for update/refresh
  attr_reader   :_collection # Collection/Table symbol for ProjectRazor::Persist::Controller / Must be specified(overridden) in each child class

  # Set default values
  def initialize
    @uuid = create_uuid
    @version = 0
    @classname = self.class.to_s
    @_collection = :object
    @_persist_ctrl = nil
  end


  # Refreshes object from Controller
  def refresh_self
    logger.debug "Refreshing object from persist controller"
    return false if @_persist_ctrl == nil
    new_hash = @_persist_ctrl.object_hash_get_by_uuid(self.to_hash, @_collection)
    self.from_hash(new_hash) unless new_hash == nil
    true
  end

  # Updates object through Controller
  def update_self
    logger.debug "Updating object in persist controller"
    return false if @_persist_ctrl == nil
    @_persist_ctrl.object_hash_update(self.to_hash, @_collection)
    refresh_self
    true
  end

  # Get logger object
  def get_logger
    logger
  end

  private

  # Return a new UUID string
  def create_uuid
    logger.debug "Generate UUID"
    UUID.generate(format = :compact)
  end
end