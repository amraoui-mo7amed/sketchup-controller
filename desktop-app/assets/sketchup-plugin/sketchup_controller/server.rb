# frozen_string_literal: true
require 'socket'
require 'json'
require 'fileutils'

module SketchUpController
  class Server
    PORT = 9876
    HOST = '127.0.0.1'

    attr_reader :running

    def initialize
      @server = nil
      @timer_id = nil
      @running = false
    end

    def start
      return if @running

      begin
        @server = TCPServer.new(HOST, PORT)
        @running = true
        puts "[SketchUp Controller] Bridge Server started on http://#{HOST}:#{PORT}"

        # Poll for incoming requests without blocking the SketchUp UI
        @timer_id = UI.start_timer(0.05, true) do
          process_incoming_requests
        end
      rescue Errno::EADDRINUSE
        puts "[SketchUp Controller] Port #{PORT} is already in use."
      rescue => e
        puts "[SketchUp Controller] Server start error: #{e.message}"
      end
    end

    def stop
      return unless @running

      UI.stop_timer(@timer_id) if @timer_id
      @server.close if @server && !@server.closed?
      @running = false
      puts "[SketchUp Controller] Bridge Server stopped."
    end

    def restart
      stop
      start
    end

    private

    def process_incoming_requests
      return unless @server && !@server.closed?

      loop do
        # Check if a client is waiting to connect (timeout = 0 means non-blocking)
        ready = IO.select([@server], nil, nil, 0)
        break unless ready

        client = @server.accept_nonblock rescue nil
        break unless client

        handle_client(client)
      end
    rescue Errno::EAGAIN, Errno::EWOULDBLOCK
      # No more incoming connections this tick
    rescue => e
      puts "[SketchUp Controller] Accept error: #{e.message}"
    end

    def handle_client(client)
      request_line = client.gets
      return client.close unless request_line

      method, full_path, _proto = request_line.strip.split(/\s+/)
      path = full_path ? full_path.split('?').first : '/'

      # Read headers
      headers = {}
      while (line = client.gets) && line.strip != ''
        key, val = line.split(':', 2)
        headers[key.strip.downcase] = val.strip if key && val
      end

      # Handle CORS preflight
      if method == 'OPTIONS'
        send_cors_response(client)
        return client.close
      end

      # Read JSON body if present
      body_data = {}
      content_length = headers['content-length'].to_i
      if content_length > 0
        raw_body = client.read(content_length)
        begin
          body_data = JSON.parse(raw_body)
        rescue => e
          body_data = { 'raw' => raw_body }
        end
      end

      # Dispatch route
      response_data = dispatch(method, path, body_data)
      send_json_response(client, response_data)
    rescue => e
      send_json_response(client, { status: 'error', message: e.message }, 500)
    ensure
      client.close rescue nil
    end

    def dispatch(method, path, body)
      case path
      when '/api/status'
        get_status

      when '/api/design/box'
        Geometry.create_box(body)

      when '/api/design/room'
        Geometry.create_room(body)

      when '/api/design/cylinder'
        Geometry.create_cylinder(body)

      when '/api/design/stairs'
        Geometry.create_stairs(body)

      when '/api/design/clear'
        Geometry.clear_entities

      when '/api/export'
        Exporter.export_model(body)

      when '/api/camera'
        view = body['view'] || 'iso'
        Exporter.set_camera_view(view)

      when '/api/eval'
        execute_ruby_eval(body['code'])

      else
        { status: 'error', message: "Route not found: #{method} #{path}" }
      end
    end

    def get_status
      model = Sketchup.active_model
      return { status: 'idle', message: 'No active model open' } unless model

      unit_names = ['Inches', 'Feet', 'Millimeters', 'Centimeters', 'Meters']
      unit_id = model.options['UnitsOptions']['LengthUnit'] rescue 0
      unit_name = unit_names[unit_id] || 'Unknown'

      entities = model.active_entities
      {
        status: 'online',
        app_version: Sketchup.version,
        model_name: model.title.empty? ? 'Untitled' : model.title,
        model_path: model.path,
        units: unit_name,
        counts: {
          entities: entities.count,
          faces: entities.grep(Sketchup::Face).count,
          edges: entities.grep(Sketchup::Edge).count,
          groups: entities.grep(Sketchup::Group).count,
          components: entities.grep(Sketchup::ComponentInstance).count,
          scenes: model.pages.count,
          layers: model.layers.count
        },
        bounds: {
          width_m: model.bounds.width.to_m.round(3),
          height_m: model.bounds.height.to_m.round(3),
          depth_m: model.bounds.depth.to_m.round(3)
        }
      }
    rescue => e
      { status: 'error', message: e.message }
    end

    def execute_ruby_eval(code)
      return { status: 'error', message: 'No code provided' } unless code && !code.strip.empty?

      model = Sketchup.active_model
      model.start_operation('Remote Eval Script', true)
      result = eval(code)
      model.commit_operation

      { status: 'success', result: result.to_s }
    rescue => e
      Sketchup.active_model.abort_operation if Sketchup.active_model
      { status: 'error', message: e.message, backtrace: e.backtrace.first(5) }
    end

    def send_cors_response(client)
      client.print "HTTP/1.1 204 No Content\r\n"
      client.print "Access-Control-Allow-Origin: *\r\n"
      client.print "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
      client.print "Access-Control-Allow-Headers: Content-Type, Authorization\r\n"
      client.print "Connection: close\r\n\r\n"
    end

    def send_json_response(client, data, status_code = 200)
      body = data.to_json
      status_text = status_code == 200 ? 'OK' : 'Internal Server Error'

      client.print "HTTP/1.1 #{status_code} #{status_text}\r\n"
      client.print "Content-Type: application/json; charset=utf-8\r\n"
      client.print "Content-Length: #{body.bytesize}\r\n"
      client.print "Access-Control-Allow-Origin: *\r\n"
      client.print "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
      client.print "Access-Control-Allow-Headers: Content-Type, Authorization\r\n"
      client.print "Connection: close\r\n\r\n"
      client.print body
    end
  end
end
