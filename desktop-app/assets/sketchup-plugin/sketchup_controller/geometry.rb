# frozen_string_literal: true

module SketchUpController
  module Geometry
    def self.create_box(params)
      model = Sketchup.active_model
      entities = model.active_entities

      w = (params['width'] || params['w'] || 4.0).to_f.m
      d = (params['depth'] || params['d'] || 4.0).to_f.m
      h = (params['height'] || params['h'] || 3.0).to_f.m

      model.start_operation('Create Parametric Box', true)
      group = entities.add_group
      group.name = "Box #{Time.now.strftime('%H:%M:%S')}"
      pts = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(w, 0, 0),
        Geom::Point3d.new(w, d, 0),
        Geom::Point3d.new(0, d, 0)
      ]
      face = group.entities.add_face(pts)
      face.pushpull(-h)
      model.commit_operation

      { status: 'success', type: 'box', dimensions: { width_m: w.to_m, depth_m: d.to_m, height_m: h.to_m } }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: e.message }
    end

    def self.create_room(params)
      model = Sketchup.active_model
      entities = model.active_entities

      w = (params['width'] || 6.0).to_f.m
      d = (params['depth'] || 5.0).to_f.m
      h = (params['height'] || 3.0).to_f.m
      t = (params['wall_thickness'] || 0.20).to_f.m
      door_w = (params['door_width'] || 0.90).to_f.m
      door_h = (params['door_height'] || 2.10).to_f.m
      has_floor = params.fetch('has_floor', true)

      model.start_operation('Create Parametric Room', true)
      room_group = entities.add_group
      room_group.name = "Room #{Time.now.strftime('%H:%M:%S')}"
      gentities = room_group.entities

      # 1. Floor slab
      if has_floor
        floor_pts = [
          Geom::Point3d.new(0, 0, 0),
          Geom::Point3d.new(w, 0, 0),
          Geom::Point3d.new(w, d, 0),
          Geom::Point3d.new(0, d, 0)
        ]
        floor_face = gentities.add_face(floor_pts)
        floor_face.pushpull(0.15.m) # standard 15cm floor slab
      end

      # 2. Outer foundation face
      outer_pts = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(w, 0, 0),
        Geom::Point3d.new(w, d, 0),
        Geom::Point3d.new(0, d, 0)
      ]
      outer_face = gentities.add_face(outer_pts)

      # 3. Inner cutout for walls
      inner_pts = [
        Geom::Point3d.new(t, t, 0),
        Geom::Point3d.new(w - t, t, 0),
        Geom::Point3d.new(w - t, d - t, 0),
        Geom::Point3d.new(t, d - t, 0)
      ]
      inner_face = gentities.add_face(inner_pts)
      inner_face.erase! if inner_face && inner_face.valid?

      # Find remaining wall profile face and extrude upward
      wall_face = gentities.grep(Sketchup::Face).find { |f| f != floor_face && f.normal.z.abs > 0.9 }
      if wall_face
        wall_face.pushpull(-h)
      end

      # 4. Optional Door Opening in front wall (centered)
      if door_w > 0 && door_h > 0 && w > (door_w + 1.0.m)
        door_x_start = (w - door_w) / 2.0
        door_pts = [
          Geom::Point3d.new(door_x_start, 0, 0),
          Geom::Point3d.new(door_x_start + door_w, 0, 0),
          Geom::Point3d.new(door_x_start + door_w, 0, door_h),
          Geom::Point3d.new(door_x_start, 0, door_h)
        ]
        door_face = gentities.add_face(door_pts)
        door_face.pushpull(t) if door_face && door_face.valid?
      end

      model.commit_operation
      { status: 'success', type: 'room', dimensions: { width_m: w.to_m, depth_m: d.to_m, height_m: h.to_m, wall_thickness_m: t.to_m } }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: e.message }
    end

    def self.create_cylinder(params)
      model = Sketchup.active_model
      entities = model.active_entities

      r = (params['radius'] || 1.0).to_f.m
      h = (params['height'] || 2.5).to_f.m
      segs = (params['segments'] || 24).to_i

      model.start_operation('Create Cylinder', true)
      group = entities.add_group
      group.name = "Column #{Time.now.strftime('%H:%M:%S')}"
      gentities = group.entities

      circle = gentities.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), r, segs)
      face = gentities.add_face(circle)
      face.pushpull(-h)
      model.commit_operation

      { status: 'success', type: 'cylinder', radius_m: r.to_m, height_m: h.to_m }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: e.message }
    end

    def self.clear_entities
      model = Sketchup.active_model
      model.start_operation('Clear All Entities', true)
      model.active_entities.clear!
      model.commit_operation
      { status: 'success', message: 'Cleared active entities' }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: e.message }
    end
  end
end
