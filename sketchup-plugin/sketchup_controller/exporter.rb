# frozen_string_literal: true

module SketchUpController
  module Exporter
    def self.export_model(params)
      model = Sketchup.active_model
      format = (params['format'] || 'obj').to_s.downcase
      path = params['path']

      unless path && !path.strip.empty?
        # Default to user's Desktop with timestamp
        ext = format == 'png' ? 'png' : format
        desktop_dir = File.expand_path('~/Desktop')
        path = File.join(desktop_dir, "sketchup_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.#{ext}")
      end

      # Ensure parent directory exists
      FileUtils.mkdir_p(File.dirname(path))

      if format == 'png' || format == 'jpg' || format == 'jpeg'
        # High quality viewport render
        view = model.active_view
        w = (params['width'] || 1920).to_i
        h = (params['height'] || 1080).to_i
        antialias = params.fetch('antialias', true)
        transparent = params.fetch('transparent', true)

        options = {
          filename: path,
          width: w,
          height: h,
          antialias: antialias,
          transparent: transparent
        }
        success = view.write_image(options)
        return {
          status: success ? 'success' : 'failed',
          format: format,
          path: path,
          dimensions: "#{w}x#{h}"
        }
      end

      # 3D Model export
      # SketchUp supports standard exporters: .obj, .dae, .stl, .dwg, etc.
      success = model.export(path)

      {
        status: success ? 'success' : 'failed',
        format: format,
        path: path,
        file_exists: File.exist?(path),
        file_size_bytes: File.exist?(path) ? File.size(path) : 0
      }
    rescue => e
      { status: 'error', message: e.message }
    end

    def self.set_camera_view(view_name)
      model = Sketchup.active_model
      view = model.active_view
      camera = view.camera

      bounds = model.bounds
      center = bounds.center
      diag = bounds.diagonal
      diag = 100.m if diag == 0

      model.start_operation('Set Camera View', true)
      case view_name.to_s.downcase
      when 'iso'
        eye = center + Geom::Vector3d.new(diag, -diag, diag)
        camera.set(eye, center, Geom::Vector3d.new(0, 0, 1))
      when 'top'
        eye = center + Geom::Vector3d.new(0, 0, diag * 1.5)
        camera.set(eye, center, Geom::Vector3d.new(0, 1, 0))
      when 'front'
        eye = center + Geom::Vector3d.new(0, -diag * 1.5, 0)
        camera.set(eye, center, Geom::Vector3d.new(0, 0, 1))
      when 'right'
        eye = center + Geom::Vector3d.new(diag * 1.5, 0, 0)
        camera.set(eye, center, Geom::Vector3d.new(0, 0, 1))
      when 'left'
        eye = center + Geom::Vector3d.new(-diag * 1.5, 0, 0)
        camera.set(eye, center, Geom::Vector3d.new(0, 0, 1))
      end
      view.zoom_extents
      model.commit_operation

      { status: 'success', current_view: view_name }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: e.message }
    end
  end
end
