# frozen_string_literal: true
require 'sketchup.rb'
require 'extensions.rb'

module SketchUpController
  PLUGIN_DIR = File.dirname(__FILE__) unless defined?(PLUGIN_DIR)
  PLUGIN_ROOT = File.join(PLUGIN_DIR, 'sketchup_controller')

  # Load the core loader directly to ensure immediate startup
  begin
    require_relative 'sketchup_controller/loader'
  rescue => e
    puts "[SketchUp Controller] Direct load error: #{e.message}"
  end

  extension = SketchupExtension.new('SketchUp Controller Bridge', File.join(PLUGIN_ROOT, 'loader'))
  extension.description = 'REST & Socket Bridge for Desktop UI & MCP AI Automation'
  extension.version     = '1.0.0'
  extension.creator     = 'Antigravity'
  extension.copyright   = '2026'

  Sketchup.register_extension(extension, true)
end
