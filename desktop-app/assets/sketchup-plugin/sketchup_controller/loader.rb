# frozen_string_literal: true

require_relative 'geometry'
require_relative 'exporter'
require_relative 'server'

module SketchUpController
  # Global reference to avoid duplicate servers across reload
  if defined?($sketchup_controller_server) && $sketchup_controller_server
    $sketchup_controller_server.stop
  end

  $sketchup_controller_server = Server.new
  $sketchup_controller_server.start

  # Create UI Menus
  unless file_loaded?(__FILE__)
    menu = UI.menu('Extensions').add_submenu('SketchUp Controller')

    menu.add_item('Server Status') do
      status = $sketchup_controller_server.running ? 'ONLINE (127.0.0.1:9876)' : 'OFFLINE'
      UI.messagebox("SketchUp Controller Bridge Server is #{status}\n\nReady for PySide6 Desktop UI & MCP AI Agent.")
    end

    menu.add_item('Restart Bridge Server') do
      $sketchup_controller_server.restart
      UI.messagebox('Bridge Server restarted on 127.0.0.1:9876')
    end

    menu.add_item('Stop Bridge Server') do
      $sketchup_controller_server.stop
      UI.messagebox('Bridge Server stopped.')
    end

    file_loaded(__FILE__)
  end
end
