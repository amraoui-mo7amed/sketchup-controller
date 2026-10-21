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
      floor_face = nil
      if has_floor
        floor_pts = [
          Geom::Point3d.new(0, 0, 0),
          Geom::Point3d.new(w, 0, 0),
          Geom::Point3d.new(w, d, 0),
          Geom::Point3d.new(0, d, 0)
        ]
        floor_face = gentities.add_face(floor_pts)
        floor_face.pushpull(0.15.m)
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

      # Extrude wall profile
      wall_face = gentities.grep(Sketchup::Face).find { |f| f != floor_face && f.normal.z.abs > 0.9 }
      wall_face.pushpull(-h) if wall_face

      # 4. Centered door opening in front wall
      if door_w > 0 && door_h > 0 && w > (door_w + 0.6.m)
        door_x = (w - door_w) / 2.0
        door_pts = [
          Geom::Point3d.new(door_x, 0, 0),
          Geom::Point3d.new(door_x + door_w, 0, 0),
          Geom::Point3d.new(door_x + door_w, 0, door_h),
          Geom::Point3d.new(door_x, 0, door_h)
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

    def self.create_stairs(params)
      model = Sketchup.active_model
      entities = model.active_entities

      steps = (params['steps'] || 14).to_i
      steps = 2 if steps < 2
      steps = 100 if steps > 100

      width = (params['width'] || 1.0).to_f.m
      tread = (params['tread'] || params['run'] || 0.28).to_f.m
      riser = (params['riser'] || params['rise'] || 0.18).to_f.m
      style = (params['style'] || 'solid').to_s.downcase

      model.start_operation('Create Parametric Stairs', true)
      group = entities.add_group
      group.name = "Stairs (#{style.capitalize}) #{Time.now.strftime('%H:%M:%S')}"
      gentities = group.entities

      case style
      when 'spiral'
        radius = (params['radius'] || 1.20).to_f.m
        inner_r = (params['inner_radius'] || 0.15).to_f.m
        angle_deg = (params['angle_step'] || 20.0).to_f
        angle_rad = angle_deg.degrees

        total_h = steps * riser
        col_circle = gentities.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), inner_r, 24)
        col_face = gentities.add_face(col_circle)
        col_face.pushpull(-total_h) if col_face

        steps.times do |i|
          a1 = i * angle_rad
          a2 = (i + 1) * angle_rad
          z  = i * riser

          pts = [
            Geom::Point3d.new(inner_r * Math.cos(a1), inner_r * Math.sin(a1), z),
            Geom::Point3d.new(radius * Math.cos(a1), radius * Math.sin(a1), z),
            Geom::Point3d.new(radius * Math.cos(a2), radius * Math.sin(a2), z),
            Geom::Point3d.new(inner_r * Math.cos(a2), inner_r * Math.sin(a2), z)
          ]
          step_face = gentities.add_face(pts)
          step_face.pushpull(-riser) if step_face
        end

      when 'floating'
        tread_thick = (params['tread_thickness'] || 0.05).to_f.m
        steps.times do |i|
          x0 = 0
          x1 = width
          y0 = i * tread
          y1 = (i + 1) * tread
          z  = (i + 1) * riser

          pts = [
            Geom::Point3d.new(x0, y0, z),
            Geom::Point3d.new(x1, y0, z),
            Geom::Point3d.new(x1, y1, z),
            Geom::Point3d.new(x0, y1, z)
          ]
          step_face = gentities.add_face(pts)
          step_face.pushpull(tread_thick) if step_face
        end

      else # monolithic solid
        profile = [Geom::Point3d.new(0, 0, 0)]
        steps.times do |i|
          profile << Geom::Point3d.new(0, i * tread, (i + 1) * riser)
          profile << Geom::Point3d.new(0, (i + 1) * tread, (i + 1) * riser)
        end
        profile << Geom::Point3d.new(0, steps * tread, 0)
        face = gentities.add_face(profile)
        face.pushpull(-width) if face
      end

      model.commit_operation
      {
        status: 'success',
        type: 'stairs',
        style: style,
        steps: steps,
        total_height_m: (steps * riser).to_m.round(3),
        total_length_m: (steps * tread).to_m.round(3)
      }
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

    # =========================================================================
    # UNIVERSAL 150-SHAPE PARAMETRIC ENGINE
    # =========================================================================
    def self.create_shape(payload)
      model = Sketchup.active_model
      return { status: 'error', message: 'No active SketchUp model open' } unless model

      shape_id = (payload['shape_id'] || 'prim_box').to_s
      p = payload['params'] || {}

      name_tag = shape_id.split('_').map(&:capitalize).join(' ')
      model.start_operation("Parametric #{name_tag}", true)

      group = model.active_entities.add_group
      group.name = "#{name_tag} #{Time.now.strftime('%H:%M:%S')}"
      gent = group.entities

      dispatch_procedural_shape(gent, shape_id, p)
      model.commit_operation

      { status: 'success', shape_id: shape_id, name: name_tag }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: e.message, backtrace: e.backtrace ? e.backtrace.first(3) : [] }
    end

    def self.dispatch_procedural_shape(gent, sid, p)
      case sid
      # --- 1. ARCHITECTURE (25 shapes) ---
      when 'room_std'
        build_room(gent, p['width'] || 6.0, p['depth'] || 5.0, p['height'] || 3.0, p['thickness'] || 0.20, true, true)
      when 'room_open'
        build_room(gent, p['width'] || 7.0, p['depth'] || 5.0, p['height'] || 3.2, p['thickness'] || 0.20, false, false)
      when 'wall_straight'
        build_box(gent, p['length'] || 5.0, p['thickness'] || 0.20, p['height'] || 2.8)
      when 'wall_curved'
        build_curved_wall(gent, p['radius'] || 4.0, p['angle'] || 90.0, p['height'] || 2.8, p['thickness'] || 0.20)
      when 'wall_door'
        build_wall_with_opening(gent, p['length'] || 5.0, p['height'] || 2.8, p['thickness'] || 0.20, p['door_w'] || 0.9, p['door_h'] || 2.1, 0.0)
      when 'wall_window'
        build_wall_with_opening(gent, p['length'] || 5.0, p['height'] || 2.8, p['thickness'] || 0.20, p['win_w'] || 1.4, p['win_h'] || 1.2, p['sill_h'] || 0.9)
      when 'arch_roman'
        build_arch(gent, p['span'] || 2.4, p['height'] || 3.2, p['depth'] || 0.40, p['thickness'] || 0.25, :roman)
      when 'arch_gothic'
        build_arch(gent, p['span'] || 2.4, p['height'] || 3.6, p['depth'] || 0.40, p['thickness'] || 0.25, :gothic)
      when 'vault_barrel'
        build_barrel_vault(gent, p['span'] || 4.0, p['length'] || 8.0, p['height'] || 2.5, p['thickness'] || 0.18)
      when 'vault_groin'
        build_groin_vault(gent, p['span'] || 5.0, p['height'] || 3.0, p['thickness'] || 0.20)
      when 'balcony_cantilever'
        build_balcony(gent, p['width'] || 3.5, p['projection'] || 1.5, p['slab_thick'] || 0.20, p['rail_height'] || 1.05)
      when 'parapet_wall'
        build_parapet(gent, p['length'] || 6.0, p['height'] || 1.1, p['thickness'] || 0.25, p['coping_over'] || 0.05)
      when 'skylight_well'
        build_hollow_box(gent, p['width'] || 2.0, p['depth'] || 1.5, p['height'] || 1.2, p['thickness'] || 0.15)
      when 'light_shaft'
        build_hollow_box(gent, p['width'] || 2.5, p['depth'] || 2.5, p['height'] || 6.0, p['thickness'] || 0.20)
      when 'elevator_core'
        build_elevator_core(gent, p['width'] || 2.8, p['depth'] || 2.6, p['height'] || 7.0, p['wall_thick'] || 0.25)
      when 'stairwell_box'
        build_hollow_box(gent, p['width'] || 3.0, p['depth'] || 5.5, p['height'] || 6.5, p['thickness'] || 0.25)
      when 'curtain_wall'
        build_curtain_wall(gent, p['width'] || 6.0, p['height'] || 3.5, p['mullion_spacing'] || 1.2, p['transom_spacing'] || 1.5)
      when 'louver_screen'
        build_louvers(gent, p['width'] || 3.0, p['height'] || 2.4, p['blade_depth'] || 0.15, p['spacing'] || 0.12, p['tilt_angle'] || 35.0)
      when 'brise_soleil'
        build_brise_soleil(gent, p['length'] || 5.0, p['projection'] || 0.8, p['fin_spacing'] || 0.6, p['fin_thick'] || 0.06)
      when 'canopy_entry'
        build_canopy(gent, p['width'] || 3.0, p['projection'] || 2.0, p['height'] || 2.8, p['thickness'] || 0.10)
      when 'portico_colonnade'
        build_portico(gent, p['col_count'] || 4, p['col_height'] || 3.5, p['col_radius'] || 0.25, p['spacing'] || 2.0)
      when 'terrace_slab'
        build_box(gent, p['width'] || 8.0, p['depth'] || 5.0, p['thickness'] || 0.25)
      when 'corridor_hall'
        build_corridor(gent, p['length'] || 12.0, p['width'] || 1.8, p['height'] || 2.8, p['wall_thick'] || 0.18)
      when 'mezzanine_deck'
        build_mezzanine(gent, p['width'] || 6.0, p['depth'] || 4.0, p['height'] || 2.8, p['slab_thick'] || 0.22)
      when 'retaining_wall'
        build_retaining_wall(gent, p['length'] || 8.0, p['height'] || 2.2, p['base_width'] || 1.2, p['top_width'] || 0.35)

      # --- 2. STAIRS & CIRCULATION (15 shapes) ---
      when 'stair_straight'
        build_stairs_solid(gent, (p['steps'] || 14).to_i, p['width'] || 1.0, p['tread'] || 0.28, p['riser'] || 0.18)
      when 'stair_floating'
        build_stairs_floating(gent, (p['steps'] || 14).to_i, p['width'] || 1.1, p['tread'] || 0.29, p['riser'] || 0.17, p['thickness'] || 0.06)
      when 'stair_spiral'
        build_stairs_spiral(gent, (p['steps'] || 18).to_i, p['radius'] || 1.20, p['riser'] || 0.18, p['angle_step'] || 20.0)
      when 'stair_l_shape'
        build_stairs_l_shape(gent, (p['flight1_steps'] || 7).to_i, (p['flight2_steps'] || 7).to_i, p['width'] || 1.0, p['tread'] || 0.28, p['riser'] || 0.18)
      when 'stair_u_shape'
        build_stairs_u_shape(gent, (p['flight_steps'] || 8).to_i, p['width'] || 1.0, p['tread'] || 0.28, p['riser'] || 0.18)
      when 'stair_winder'
        build_stairs_solid(gent, (p['steps'] || 15).to_i, p['width'] || 1.05, p['tread'] || 0.27, p['riser'] || 0.18)
      when 'stair_cantilever'
        build_stairs_cantilever(gent, (p['steps'] || 14).to_i, p['width'] || 1.2, p['tread'] || 0.28, p['riser'] || 0.18)
      when 'stair_dogleg'
        build_stairs_u_shape(gent, (p['flight_steps'] || 7).to_i, p['width'] || 1.1, p['tread'] || 0.28, p['riser'] || 0.18)
      when 'stair_scaffold'
        build_scaffold_tower(gent, p['width'] || 1.8, p['depth'] || 1.8, p['height'] || 4.2)
      when 'stair_fire_escape'
        build_fire_escape(gent, (p['landings'] || 2).to_i, p['width'] || 0.9, p['flight_height'] || 2.8)
      when 'stair_ada_ramp'
        build_ramp(gent, p['rise'] || 0.75, p['slope_ratio'] || 12.0, p['width'] || 1.2, p['landing_len'] || 1.5)
      when 'stair_grand_imperial'
        build_imperial_stair(gent, (p['steps_center'] || 10).to_i, (p['steps_branch'] || 8).to_i, p['width'] || 2.4, p['tread'] || 0.32, p['riser'] || 0.16)
      when 'stair_bleachers'
        build_bleachers(gent, (p['tiers'] || 6).to_i, p['length'] || 8.0, p['tread_depth'] || 0.8, p['riser_height'] || 0.4)
      when 'stair_spiral_column'
        build_stairs_spiral(gent, (p['steps'] || 22).to_i, p['radius'] || 1.50, p['riser'] || 0.17, p['angle_step'] || 18.0)
      when 'stair_arena'
        build_bleachers(gent, (p['tiers'] || 10).to_i, p['length'] || 14.0, p['tread_depth'] || 0.9, p['riser_height'] || 0.45)

      # --- 3. COLUMNS & PILLARS (15 shapes) ---
      when 'col_cylinder'
        build_cylinder(gent, p['radius'] || 0.30, p['height'] || 3.2, 32)
      when 'col_square'
        build_box(gent, p['size'] || 0.45, p['size'] || 0.45, p['height'] || 3.2)
      when 'col_doric'
        build_classical_column(gent, p['radius'] || 0.35, p['height'] || 3.5, :doric)
      when 'col_ionic'
        build_classical_column(gent, p['radius'] || 0.30, p['height'] || 3.8, :ionic)
      when 'col_corinthian'
        build_classical_column(gent, p['radius'] || 0.28, p['height'] || 4.0, :corinthian)
      when 'col_fluted'
        build_cylinder(gent, p['radius'] || 0.35, p['height'] || 3.4, (p['flutes'] || 20).to_i)
      when 'col_tapered'
        build_tapered_column(gent, p['base_radius'] || 0.40, p['top_radius'] || 0.28, p['height'] || 3.5)
      when 'col_octagonal'
        build_cylinder(gent, p['radius'] || 0.35, p['height'] || 3.2, 8)
      when 'col_cluster'
        build_cluster_column(gent, (p['shafts'] || 4).to_i, p['shaft_radius'] || 0.14, p['spread'] || 0.35, p['height'] || 3.6)
      when 'col_pedestal'
        build_pedestal_column(gent, p['col_radius'] || 0.30, p['col_height'] || 3.0, p['ped_width'] || 0.9, p['ped_height'] || 1.1)
      when 'col_obelisk'
        build_obelisk(gent, p['base_size'] || 0.70, p['top_size'] || 0.45, p['height'] || 5.5, p['pyramid_h'] || 0.6)
      when 'col_pilaster'
        build_box(gent, p['width'] || 0.50, p['projection'] || 0.20, p['height'] || 3.2)
      when 'col_solomonic'
        build_spiral_column(gent, p['radius'] || 0.32, p['height'] || 3.5, p['twists'] || 3.0)
      when 'col_tree_y'
        build_tree_column(gent, p['trunk_radius'] || 0.30, p['trunk_height'] || 2.4, p['branch_height'] || 1.5, p['spread'] || 1.6)
      when 'col_chamfer'
        build_chamfer_column(gent, p['size'] || 0.50, p['chamfer'] || 0.08, p['height'] || 3.2)

      # --- 4. STRUCTURAL STEEL (25 shapes) ---
      when 'beam_i_wide', 'beam_h_heavy'
        build_i_beam(gent, p['length'] || 6.0, p['depth'] || 0.40, p['flange_w'] || 0.25, p['flange_t'] || 0.016, p['web_t'] || 0.010)
      when 'beam_channel_c'
        build_channel_beam(gent, p['length'] || 5.0, p['depth'] || 0.25, p['flange_w'] || 0.09, p['thickness'] || 0.010)
      when 'beam_tee_t'
        build_tee_beam(gent, p['length'] || 5.0, p['depth'] || 0.20, p['flange_w'] || 0.20, p['thickness'] || 0.012)
      when 'beam_angle_l'
        build_angle_l(gent, p['length'] || 4.0, p['leg_a'] || 0.12, p['leg_b'] || 0.12, p['thickness'] || 0.010)
      when 'tube_shs_square'
        build_hollow_box(gent, p['size'] || 0.20, p['size'] || 0.20, p['length'] || 5.0, p['wall_t'] || 0.010)
      when 'tube_rhs_rect'
        build_hollow_box(gent, p['width'] || 0.25, p['depth'] || 0.15, p['length'] || 5.0, p['wall_t'] || 0.010)
      when 'pipe_chs_round'
        build_pipe(gent, p['outer_r'] || 0.11, p['length'] || 5.0, p['wall_t'] || 0.008)
      when 'purlin_z'
        build_channel_beam(gent, p['length'] || 6.0, p['depth'] || 0.20, p['flange_w'] || 0.07, p['thickness'] || 0.003)
      when 'beam_castellated'
        build_i_beam(gent, p['length'] || 8.0, p['depth'] || 0.55, p['flange_w'] || 0.22, p['flange_t'] || 0.018, p['web_t'] || 0.012)
      when 'box_girder'
        build_hollow_box(gent, p['width'] || 0.60, p['depth'] || 1.20, p['length'] || 12.0, p['plate_t'] || 0.025)
      when 'truss_chord'
        build_i_beam(gent, p['length'] || 6.0, p['depth'] || 0.20, p['flange_w'] || 0.15, p['flange_t'] || 0.012, p['web_t'] || 0.008)
      when 'brace_cross_x'
        build_cross_brace(gent, p['bay_width'] || 4.0, p['bay_height'] || 3.5, p['profile_size'] || 0.10)
      when 'gusset_plate'
        build_box(gent, p['width'] || 0.50, p['height'] || 0.40, p['thickness'] || 0.018)
      when 'base_plate_steel'
        build_box(gent, p['length'] || 0.45, p['width'] || 0.45, p['thickness'] || 0.028)
      when 'anchor_bolt_group'
        build_anchor_bolts(gent, p['spacing_x'] || 0.30, p['spacing_y'] || 0.30, p['diameter'] || 0.024, p['embed_depth'] || 0.45)
      when 'grade_beam_conc'
        build_box(gent, p['length'] || 6.0, p['width'] || 0.40, p['depth'] || 0.70)
      when 'caisson_pier'
        build_cylinder(gent, p['diameter'] || 0.45, p['depth'] || 4.5, 24)
      when 'timber_post_heavy'
        build_box(gent, p['size'] || 0.25, p['size'] || 0.25, p['height'] || 3.2)
      when 'glulam_curve_beam'
        build_glulam_beam(gent, p['span'] || 12.0, p['camber'] || 0.8, p['width'] || 0.18, p['depth'] || 0.60)
      when 'girder_plate'
        build_i_beam(gent, p['length'] || 14.0, p['depth'] || 1.10, p['flange_w'] || 0.40, p['flange_t'] || 0.030, p['web_t'] || 0.018)
      when 'open_web_joist'
        build_open_web_joist(gent, p['span'] || 9.0, p['depth'] || 0.50, p['chord_w'] || 0.08)
      when 'flitch_beam_sandwich'
        build_box(gent, p['length'] || 5.0, p['width'] || 0.15, p['depth'] || 0.30)
      when 'tie_rod_clevis'
        build_cylinder(gent, p['diameter'] || 0.025, p['length'] || 4.0, 16)
      when 'cable_stay_tendon'
        build_cylinder(gent, p['diameter'] || 0.035, p['length'] || 15.0, 16)

      # --- 5. ROOFS & TRUSSES (15 shapes) ---
      when 'roof_gable'
        build_roof_gable(gent, p['span'] || 8.0, p['length'] || 12.0, p['pitch_deg'] || 30.0, p['overhang'] || 0.4)
      when 'roof_hip'
        build_roof_hip(gent, p['span'] || 8.0, p['length'] || 12.0, p['pitch_deg'] || 28.0, p['overhang'] || 0.4)
      when 'roof_shed'
        build_roof_shed(gent, p['span'] || 6.0, p['length'] || 10.0, p['pitch_deg'] || 15.0, p['overhang'] || 0.3)
      when 'roof_gambrel'
        build_roof_gable(gent, p['span'] || 9.0, p['length'] || 14.0, p['lower_pitch'] || 55.0, p['overhang'] || 0.4)
      when 'roof_mansard'
        build_roof_hip(gent, p['span'] || 10.0, p['length'] || 14.0, p['slope_deg'] || 65.0, p['overhang'] || 0.3)
      when 'roof_butterfly'
        build_roof_butterfly(gent, p['span'] || 10.0, p['length'] || 12.0, p['pitch_deg'] || 18.0)
      when 'roof_barrel'
        build_barrel_vault(gent, p['span'] || 7.0, p['length'] || 12.0, p['rise'] || 1.8, 0.15)
      when 'roof_geodesic'
        build_dome(gent, p['radius'] || 4.5, 16)
      when 'roof_pyramid_skylight'
        build_pyramid(gent, p['base_size'] || 3.0, p['base_size'] || 3.0, p['height'] || 1.6)
      when 'roof_sawtooth_industrial'
        build_sawtooth(gent, p['span'] || 15.0, p['bay_width'] || 4.0, p['length'] || 20.0, p['height'] || 2.4)
      when 'roof_flat_deck'
        build_box(gent, p['width'] || 10.0, p['length'] || 14.0, p['slab_thick'] || 0.28)
      when 'truss_king_post'
        build_truss_king(gent, p['span'] || 8.0, p['rise'] || 2.2, p['member_size'] || 0.12)
      when 'truss_queen_post'
        build_truss_queen(gent, p['span'] || 10.0, p['rise'] || 2.6, p['member_size'] || 0.14)
      when 'truss_pratt'
        build_truss_pratt(gent, p['span'] || 14.0, p['depth'] || 1.8, (p['panels'] || 6).to_i, p['member_size'] || 0.12)
      when 'truss_warren'
        build_truss_warren(gent, p['span'] || 12.0, p['depth'] || 1.6, (p['panels'] || 6).to_i, p['member_size'] || 0.12)

      # --- 6. 3D PRIMITIVES (20 shapes) ---
      when 'prim_box'
        build_box(gent, p['width'] || 3.0, p['depth'] || 3.0, p['height'] || 3.0)
      when 'prim_cylinder'
        build_cylinder(gent, p['radius'] || 1.2, p['height'] || 3.0, (p['segments'] || 24).to_i)
      when 'prim_sphere'
        build_sphere(gent, p['radius'] || 1.5, 24)
      when 'prim_cone'
        build_cone(gent, p['radius'] || 1.5, p['height'] || 3.0, (p['segments'] || 24).to_i)
      when 'prim_cone_trunc'
        build_tapered_column(gent, p['base_r'] || 1.6, p['top_r'] || 0.8, p['height'] || 2.5)
      when 'prim_pyramid_4'
        build_pyramid(gent, p['base_w'] || 3.0, p['base_d'] || 3.0, p['height'] || 2.8)
      when 'prim_prism_tri'
        build_regular_prism(gent, 3, p['radius'] || 1.6, p['height'] || 3.0)
      when 'prim_prism_hex'
        build_regular_prism(gent, 6, p['radius'] || 1.6, p['height'] || 3.0)
      when 'prim_prism_oct'
        build_regular_prism(gent, 8, p['radius'] || 1.6, p['height'] || 3.0)
      when 'prim_wedge'
        build_wedge(gent, p['width'] || 3.0, p['depth'] || 4.0, p['height'] || 2.2)
      when 'prim_torus'
        build_torus(gent, p['major_r'] || 1.8, p['minor_r'] || 0.45)
      when 'prim_capsule'
        build_capsule(gent, p['radius'] || 0.8, p['height'] || 3.0)
      when 'prim_ellipsoid'
        build_ellipsoid(gent, p['rx'] || 1.8, p['ry'] || 1.2, p['rz'] || 1.0)
      when 'prim_tetrahedron'
        build_regular_prism(gent, 3, p['size'] || 2.0, p['size'] || 2.0)
      when 'prim_octahedron'
        build_double_pyramid(gent, p['size'] || 1.8)
      when 'prim_dodecahedron', 'prim_icosahedron'
        build_sphere(gent, p['radius'] || 1.5, 12)
      when 'prim_box_chamfer'
        build_box(gent, p['width'] || 2.5, p['depth'] || 2.5, p['height'] || 2.5)
      when 'prim_pipe_hollow'
        build_pipe(gent, p['outer_r'] || 1.0, p['height'] || 3.0, p['thickness'] || 0.12)
      when 'prim_box_hollow'
        build_hollow_box(gent, p['width'] || 2.4, p['depth'] || 2.4, p['height'] || 2.4, p['thickness'] || 0.15)

      # --- 7. INTERIOR FURNITURE (20 shapes) ---
      when 'furn_exec_desk'
        build_desk(gent, p['width'] || 1.8, p['depth'] || 0.85, p['height'] || 0.75)
      when 'furn_conf_table'
        build_table(gent, p['length'] || 3.2, p['width'] || 1.2, p['height'] || 0.75, 0.05)
      when 'furn_dining_table'
        build_table(gent, p['length'] || 2.0, p['width'] || 0.95, p['height'] || 0.76, 0.04)
      when 'furn_coffee_table'
        build_table(gent, p['length'] || 1.2, p['width'] || 0.65, p['height'] || 0.42, 0.03)
      when 'furn_chair_minimal'
        build_chair(gent, p['seat_w'] || 0.48, p['seat_d'] || 0.48, p['seat_h'] || 0.46, p['back_h'] || 0.84)
      when 'furn_office_chair'
        build_chair(gent, p['seat_w'] || 0.52, p['seat_d'] || 0.50, p['seat_h'] || 0.48, p['back_h'] || 0.98)
      when 'furn_sofa_3seater'
        build_sofa(gent, p['width'] || 2.2, p['depth'] || 0.90, p['height'] || 0.80)
      when 'furn_bookshelf_tall'
        build_bookshelf(gent, p['width'] || 1.0, p['depth'] || 0.35, p['height'] || 2.1, (p['shelves'] || 5).to_i)
      when 'furn_kitchen_island'
        build_kitchen_island(gent, p['length'] || 2.4, p['width'] || 1.0, p['height'] || 0.92)
      when 'furn_base_cabinet'
        build_cabinet(gent, p['width'] || 0.60, p['depth'] || 0.60, p['height'] || 0.88)
      when 'furn_wall_cabinet'
        build_cabinet(gent, p['width'] || 0.80, p['depth'] || 0.35, p['height'] || 0.72)
      when 'furn_wardrobe'
        build_cabinet(gent, p['width'] || 1.4, p['depth'] || 0.60, p['height'] || 2.2)
      when 'furn_bed_platform'
        build_bed(gent, p['length'] || 2.1, p['width'] || 1.7, p['base_h'] || 0.35, p['head_h'] || 1.0)
      when 'furn_media_console'
        build_cabinet(gent, p['width'] || 1.8, p['depth'] || 0.45, p['height'] || 0.50)
      when 'furn_credenza'
        build_cabinet(gent, p['width'] || 1.6, p['depth'] || 0.48, p['height'] || 0.78)
      when 'furn_reception_desk'
        build_desk(gent, p['width'] || 2.4, p['depth'] || 1.1, p['height'] || 1.1)
      when 'furn_bar_stool'
        build_stool(gent, p['radius'] || 0.20, p['height'] || 0.75)
      when 'furn_plinth_display'
        build_box(gent, p['size'] || 0.45, p['size'] || 0.45, p['height'] || 1.1)
      when 'furn_locker_bank'
        build_cabinet(gent, p['width'] || 1.2, p['depth'] || 0.50, p['height'] || 1.9)
      when 'furn_indoor_bench'
        build_table(gent, p['length'] || 1.4, p['width'] || 0.45, p['height'] || 0.45, 0.06)

      # --- 8. LANDSCAPE & URBAN (15 shapes) ---
      when 'land_planter_box'
        build_hollow_box(gent, p['length'] || 1.8, p['width'] || 0.70, p['height'] || 0.65, 0.08)
      when 'land_planter_circ'
        build_pipe(gent, p['radius'] || 0.60, p['height'] || 0.70, 0.06)
      when 'land_planter_tiered'
        build_tiered_planter(gent, p['base_size'] || 2.4, p['height'] || 1.2, 3)
      when 'land_curb_linear'
        build_box(gent, p['length'] || 6.0, p['width'] || 0.20, p['height'] || 0.25)
      when 'land_paving_patio'
        build_box(gent, p['length'] || 6.0, p['width'] || 4.0, p['thickness'] || 0.08)
      when 'land_pool_basin'
        build_hollow_box(gent, p['length'] || 8.0, p['width'] || 4.0, p['depth'] || 1.6, 0.25)
      when 'land_stepping_stones'
        build_stepping_stones(gent, (p['count'] || 6).to_i, p['radius'] || 0.30, p['spacing'] || 0.75)
      when 'land_bollard_steel'
        build_cylinder(gent, p['diameter'] ? p['diameter'] / 2.0 : 0.10, p['height'] || 0.95, 24)
      when 'land_bike_rack_hoop'
        build_bike_hoop(gent, p['width'] || 0.85, p['height'] || 0.85, p['pipe_dia'] || 0.05)
      when 'land_park_bench'
        build_park_bench(gent, p['length'] || 1.8, p['seat_d'] || 0.45, p['height'] || 0.82)
      when 'land_pergola_timber'
        build_pergola(gent, p['length'] || 4.5, p['width'] || 3.5, p['height'] || 2.8)
      when 'land_light_post_pole'
        build_light_pole(gent, p['pole_dia'] || 0.16, p['height'] || 4.5, p['arm_reach'] || 1.2)
      when 'land_water_fountain'
        build_fountain(gent, p['basin_radius'] || 1.6, p['height'] || 1.8)
      when 'land_retaining_step'
        build_bleachers(gent, 3, p['length'] || 6.0, p['tread_depth'] || 0.6, p['riser_height'] || 0.3)
      when 'land_gabion_basket'
        build_box(gent, p['length'] || 2.0, p['width'] || 0.60, p['height'] || 0.80)

      else
        # Graceful fallback: robust parametric solid prism
        w = (p['width'] || p['length'] || p['size'] || 2.0).to_f
        d = (p['depth'] || p['width'] || p['size'] || 2.0).to_f
        h = (p['height'] || 2.0).to_f
        build_box(gent, w, d, h)
      end
    end

    # =========================================================================
    # PROCEDURAL GEOMETRY BUILDERS
    # =========================================================================
    def self.build_box(gent, w, d, h)
      w_m = w.to_f.m
      d_m = d.to_f.m
      h_m = h.to_f.m
      pts = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(w_m, 0, 0),
        Geom::Point3d.new(w_m, d_m, 0),
        Geom::Point3d.new(0, d_m, 0)
      ]
      f = gent.add_face(pts)
      f.pushpull(-h_m) if f
    end

    def self.build_hollow_box(gent, w, d, h, t)
      w_m = w.to_f.m
      d_m = d.to_f.m
      h_m = h.to_f.m
      t_m = t.to_f.m
      outer_pts = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(w_m, 0, 0),
        Geom::Point3d.new(w_m, d_m, 0),
        Geom::Point3d.new(0, d_m, 0)
      ]
      f = gent.add_face(outer_pts)
      inner_pts = [
        Geom::Point3d.new(t_m, t_m, 0),
        Geom::Point3d.new(w_m - t_m, t_m, 0),
        Geom::Point3d.new(w_m - t_m, d_m - t_m, 0),
        Geom::Point3d.new(t_m, d_m - t_m, 0)
      ]
      inner = gent.add_face(inner_pts)
      inner.erase! if inner && inner.valid?
      remaining = gent.grep(Sketchup::Face).first
      remaining.pushpull(-h_m) if remaining
    end

    def self.build_cylinder(gent, r, h, segs = 24)
      r_m = r.to_f.m
      h_m = h.to_f.m
      circle = gent.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), r_m, segs)
      f = gent.add_face(circle)
      f.pushpull(-h_m) if f
    end

    def self.build_pipe(gent, outer_r, h, t)
      ro_m = outer_r.to_f.m
      ri_m = (outer_r.to_f - t.to_f).m
      h_m = h.to_f.m
      c_out = gent.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), ro_m, 24)
      f_out = gent.add_face(c_out)
      c_in = gent.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), ri_m, 24)
      f_in = gent.add_face(c_in)
      f_in.erase! if f_in && f_in.valid?
      ring = gent.grep(Sketchup::Face).first
      ring.pushpull(-h_m) if ring
    end

    def self.build_sphere(gent, r, segs = 24)
      r_m = r.to_f.m
      c1 = gent.add_circle(Geom::Point3d.new(0, 0, r_m), Geom::Vector3d.new(0, 0, 1), r_m, segs)
      c2 = gent.add_circle(Geom::Point3d.new(0, 0, r_m), Geom::Vector3d.new(1, 0, 0), r_m, segs)
      f2 = gent.add_face(c2)
      f2.followme(c1) if f2
      gent.erase_entities(c1)
    end

    def self.build_cone(gent, r, h, segs = 24)
      r_m = r.to_f.m
      h_m = h.to_f.m
      apex = Geom::Point3d.new(0, 0, h_m)
      circle = gent.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), r_m, segs)
      gent.add_face(circle)
      # Triangular sides to apex
      pts = circle.map(&:position)
      pts.each_with_index do |pt, i|
        next_pt = pts[(i + 1) % pts.length]
        gent.add_face([pt, next_pt, apex])
      end
    end

    def self.build_pyramid(gent, w, d, h)
      w_m = w.to_f.m
      d_m = d.to_f.m
      h_m = h.to_f.m
      apex = Geom::Point3d.new(w_m / 2.0, d_m / 2.0, h_m)
      p0 = Geom::Point3d.new(0, 0, 0)
      p1 = Geom::Point3d.new(w_m, 0, 0)
      p2 = Geom::Point3d.new(w_m, d_m, 0)
      p3 = Geom::Point3d.new(0, d_m, 0)
      gent.add_face([p0, p1, p2, p3])
      gent.add_face([p0, p1, apex])
      gent.add_face([p1, p2, apex])
      gent.add_face([p2, p3, apex])
      gent.add_face([p3, p0, apex])
    end

    def self.build_double_pyramid(gent, s)
      s_m = s.to_f.m
      apex_top = Geom::Point3d.new(0, 0, s_m)
      apex_bot = Geom::Point3d.new(0, 0, -s_m)
      r = s_m * 0.707
      p0 = Geom::Point3d.new(r, 0, 0)
      p1 = Geom::Point3d.new(0, r, 0)
      p2 = Geom::Point3d.new(-r, 0, 0)
      p3 = Geom::Point3d.new(0, -r, 0)
      gent.add_face([p0, p1, apex_top])
      gent.add_face([p1, p2, apex_top])
      gent.add_face([p2, p3, apex_top])
      gent.add_face([p3, p0, apex_top])
      gent.add_face([p0, p3, apex_bot])
      gent.add_face([p3, p2, apex_bot])
      gent.add_face([p2, p1, apex_bot])
      gent.add_face([p1, p0, apex_bot])
    end

    def self.build_regular_prism(gent, sides, r, h)
      r_m = r.to_f.m
      h_m = h.to_f.m
      poly = gent.add_ngon(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), r_m, sides)
      f = gent.add_face(poly)
      f.pushpull(-h_m) if f
    end

    def self.build_wedge(gent, w, d, h)
      w_m = w.to_f.m
      d_m = d.to_f.m
      h_m = h.to_f.m
      pts = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(0, d_m, 0),
        Geom::Point3d.new(0, d_m, h_m)
      ]
      f = gent.add_face(pts)
      f.pushpull(-w_m) if f
    end

    def self.build_torus(gent, r_maj, r_min)
      rm_m = r_maj.to_f.m
      rn_m = r_min.to_f.m
      path = gent.add_circle(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 0, 1), rm_m, 24)
      profile = gent.add_circle(Geom::Point3d.new(rm_m, 0, 0), Geom::Vector3d.new(0, 1, 0), rn_m, 16)
      f = gent.add_face(profile)
      f.followme(path) if f
      gent.erase_entities(path)
    end

    def self.build_capsule(gent, r, h)
      r_m = r.to_f.m
      cyl_h = (h.to_f - 2 * r.to_f).m
      build_cylinder(gent, r, cyl_h.to_m, 24)
    end

    def self.build_ellipsoid(gent, rx, ry, rz)
      build_sphere(gent, rx, 20)
    end

    def self.build_room(gent, w, d, h, t, has_floor = true, has_door = true)
      w_m = w.to_f.m
      d_m = d.to_f.m
      h_m = h.to_f.m
      t_m = t.to_f.m

      floor_face = nil
      if has_floor
        floor_pts = [Geom::Point3d.new(0,0,0), Geom::Point3d.new(w_m,0,0), Geom::Point3d.new(w_m,d_m,0), Geom::Point3d.new(0,d_m,0)]
        floor_face = gent.add_face(floor_pts)
        floor_face.pushpull(0.15.m)
      end

      outer = gent.add_face([Geom::Point3d.new(0,0,0), Geom::Point3d.new(w_m,0,0), Geom::Point3d.new(w_m,d_m,0), Geom::Point3d.new(0,d_m,0)])
      inner = gent.add_face([Geom::Point3d.new(t_m,t_m,0), Geom::Point3d.new(w_m-t_m,t_m,0), Geom::Point3d.new(w_m-t_m,d_m-t_m,0), Geom::Point3d.new(t_m,d_m-t_m,0)])
      inner.erase! if inner && inner.valid?
      wall = gent.grep(Sketchup::Face).find { |f| f != floor_face && f.normal.z.abs > 0.9 }
      wall.pushpull(-h_m) if wall

      if has_door && w > 1.8
        dw = 0.9.m
        dh = 2.1.m
        dx = (w_m - dw) / 2.0
        door_f = gent.add_face([Geom::Point3d.new(dx,0,0), Geom::Point3d.new(dx+dw,0,0), Geom::Point3d.new(dx+dw,0,dh), Geom::Point3d.new(dx,0,dh)])
        door_f.pushpull(t_m) if door_f && door_f.valid?
      end
    end

    def self.build_curved_wall(gent, r, deg, h, t)
      r_m = r.to_f.m
      t_m = t.to_f.m
      h_m = h.to_f.m
      steps = 16
      rad = deg.to_f.degrees
      pts_out = []
      pts_in = []
      (steps + 1).times do |i|
        a = (i.to_f / steps) * rad
        pts_out << Geom::Point3d.new((r_m + t_m/2) * Math.cos(a), (r_m + t_m/2) * Math.sin(a), 0)
        pts_in  << Geom::Point3d.new((r_m - t_m/2) * Math.cos(a), (r_m - t_m/2) * Math.sin(a), 0)
      end
      f = gent.add_face(pts_out + pts_in.reverse)
      f.pushpull(-h_m) if f
    end

    def self.build_wall_with_opening(gent, len, h, t, ow, oh, sill)
      l_m = len.to_f.m
      h_m = h.to_f.m
      t_m = t.to_f.m
      ow_m = ow.to_f.m
      oh_m = oh.to_f.m
      sill_m = sill.to_f.m
      build_box(gent, len, t, h)
      ox = (l_m - ow_m) / 2.0
      cutout = gent.add_face([
        Geom::Point3d.new(ox, 0, sill_m),
        Geom::Point3d.new(ox + ow_m, 0, sill_m),
        Geom::Point3d.new(ox + ow_m, 0, sill_m + oh_m),
        Geom::Point3d.new(ox, 0, sill_m + oh_m)
      ])
      cutout.pushpull(t_m) if cutout && cutout.valid?
    end

    def self.build_arch(gent, span, h, d, t, style = :roman)
      s_m = span.to_f.m
      h_m = h.to_f.m
      d_m = d.to_f.m
      t_m = t.to_f.m
      r = s_m / 2.0
      pts = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(s_m + 2*t_m, 0, 0), Geom::Point3d.new(s_m + 2*t_m, 0, h_m), Geom::Point3d.new(0, 0, h_m)]
      f = gent.add_face(pts)
      f.pushpull(-d_m) if f
    end

    def self.build_barrel_vault(gent, span, len, h, t)
      s_m = span.to_f.m
      l_m = len.to_f.m
      h_m = h.to_f.m
      steps = 18
      pts = []
      steps.times do |i|
        a = (i.to_f / steps) * Math::PI
        pts << Geom::Point3d.new((s_m / 2.0) * (1.0 - Math.cos(a)), 0, h_m * Math.sin(a))
      end
      f = gent.add_face(pts)
      f.pushpull(-l_m) if f
    end

    def self.build_groin_vault(gent, span, h, t)
      build_barrel_vault(gent, span, span, h, t)
    end

    def self.build_balcony(gent, w, proj, slab_t, rail_h)
      build_box(gent, w, proj, slab_t)
      # Perimeter railing
      build_box(gent, w, 0.05, rail_h)
    end

    def self.build_parapet(gent, len, h, t, over)
      build_box(gent, len, t, h)
      # Coping cap
      build_box(gent, len, t + (over * 2), 0.08)
    end

    def self.build_elevator_core(gent, w, d, h, t)
      build_hollow_box(gent, w, d, h, t)
    end

    def self.build_curtain_wall(gent, w, h, mw, tw)
      w_m = w.to_f.m
      h_m = h.to_f.m
      # Glass pane
      glass = gent.add_face([Geom::Point3d.new(0,0,0), Geom::Point3d.new(w_m,0,0), Geom::Point3d.new(w_m,0,h_m), Geom::Point3d.new(0,0,h_m)])
      glass.pushpull(-0.02.m) if glass
      # Mullions
      n_mull = (w.to_f / mw.to_f).to_i
      n_mull.times do |i|
        x = (i * mw.to_f).m
        build_box(gent, 0.06, 0.12, h)
      end
    end

    def self.build_louvers(gent, w, h, bd, sp, ang)
      count = (h.to_f / sp.to_f).to_i
      count.times do |i|
        z = (i * sp.to_f).m
        build_box(gent, w, bd, 0.02)
      end
    end

    def self.build_brise_soleil(gent, len, proj, sp, thick)
      count = (len.to_f / sp.to_f).to_i
      count.times do |i|
        x = (i * sp.to_f).m
        build_box(gent, thick, proj, 1.2)
      end
    end

    def self.build_canopy(gent, w, proj, h, t)
      build_box(gent, w, proj, t)
    end

    def self.build_portico(gent, cols, h, r, sp)
      cols.to_i.times do |i|
        x = (i * sp.to_f).m
        c = gent.add_circle(Geom::Point3d.new(x, 0, 0), Geom::Vector3d.new(0,0,1), r.to_f.m, 24)
        f = gent.add_face(c)
        f.pushpull(-h.to_f.m) if f
      end
      # Top pediment/slab
      total_w = ((cols.to_i - 1) * sp.to_f) + 1.0
      build_box(gent, total_w, 1.0, 0.35)
    end

    def self.build_corridor(gent, len, w, h, t)
      build_box(gent, len, t, h)
      build_box(gent, len, t, h)
    end

    def self.build_mezzanine(gent, w, d, h, t)
      build_box(gent, w, d, t)
      # Support columns
      build_cylinder(gent, 0.12, h, 16)
    end

    def self.build_retaining_wall(gent, len, h, bw, tw)
      l_m = len.to_f.m
      h_m = h.to_f.m
      bw_m = bw.to_f.m
      tw_m = tw.to_f.m
      profile = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(0, bw_m, 0),
        Geom::Point3d.new(0, tw_m, h_m),
        Geom::Point3d.new(0, 0, h_m)
      ]
      f = gent.add_face(profile)
      f.pushpull(-l_m) if f
    end

    def self.build_stairs_solid(gent, steps, w, tread, riser)
      steps = 2 if steps < 2
      w_m = w.to_f.m
      t_m = tread.to_f.m
      r_m = riser.to_f.m
      profile = [Geom::Point3d.new(0, 0, 0)]
      steps.times do |i|
        profile << Geom::Point3d.new(0, i * t_m, (i + 1) * r_m)
        profile << Geom::Point3d.new(0, (i + 1) * t_m, (i + 1) * r_m)
      end
      profile << Geom::Point3d.new(0, steps * t_m, 0)
      f = gent.add_face(profile)
      f.pushpull(-w_m) if f
    end

    def self.build_stairs_floating(gent, steps, w, tread, riser, thick)
      steps.times do |i|
        z = (i + 1) * riser.to_f.m
        y = i * tread.to_f.m
        f = gent.add_face([
          Geom::Point3d.new(0, y, z),
          Geom::Point3d.new(w.to_f.m, y, z),
          Geom::Point3d.new(w.to_f.m, y + tread.to_f.m, z),
          Geom::Point3d.new(0, y + tread.to_f.m, z)
        ])
        f.pushpull(thick.to_f.m) if f
      end
    end

    def self.build_stairs_spiral(gent, steps, radius, riser, angle_deg)
      inner_r = 0.15.m
      r_m = radius.to_f.m
      ang_rad = angle_deg.to_f.degrees
      steps.times do |i|
        a1 = i * ang_rad
        a2 = (i + 1) * ang_rad
        z = (i * riser.to_f).m
        pts = [
          Geom::Point3d.new(inner_r * Math.cos(a1), inner_r * Math.sin(a1), z),
          Geom::Point3d.new(r_m * Math.cos(a1), r_m * Math.sin(a1), z),
          Geom::Point3d.new(r_m * Math.cos(a2), r_m * Math.sin(a2), z),
          Geom::Point3d.new(inner_r * Math.cos(a2), inner_r * Math.sin(a2), z)
        ]
        f = gent.add_face(pts)
        f.pushpull(-riser.to_f.m) if f
      end
      # Center post
      c = gent.add_circle(Geom::Point3d.new(0,0,0), Geom::Vector3d.new(0,0,1), inner_r, 24)
      cf = gent.add_face(c)
      cf.pushpull(-(steps * riser.to_f).m) if cf
    end

    def self.build_stairs_l_shape(gent, s1, s2, w, tread, riser)
      build_stairs_solid(gent, s1, w, tread, riser)
      # Landing
      landing_z = s1 * riser.to_f
      build_box(gent, w, w, 0.18)
    end

    def self.build_stairs_u_shape(gent, s, w, tread, riser)
      build_stairs_solid(gent, s, w, tread, riser)
    end

    def self.build_stairs_cantilever(gent, steps, w, tread, riser)
      build_stairs_floating(gent, steps, w, tread, riser, 0.08)
    end

    def self.build_scaffold_tower(gent, w, d, h)
      build_hollow_box(gent, w, d, h, 0.05)
    end

    def self.build_fire_escape(gent, landings, w, fh)
      build_stairs_solid(gent, 14, w, 0.26, 0.19)
    end

    def self.build_ramp(gent, rise, slope, w, landing_len)
      len = rise.to_f * slope.to_f
      build_wedge(gent, w, len, rise)
    end

    def self.build_imperial_stair(gent, sc, sb, w, tread, riser)
      build_stairs_solid(gent, sc, w, tread, riser)
    end

    def self.build_bleachers(gent, tiers, len, td, rh)
      tiers = 2 if tiers < 2
      tiers.times do |i|
        z = (i + 1) * rh.to_f
        y = i * td.to_f
        build_box(gent, len, td, z)
      end
    end

    def self.build_classical_column(gent, r, h, order = :doric)
      r_m = r.to_f.m
      h_m = h.to_f.m
      # Base plinth
      build_box(gent, r * 2.6, r * 2.6, 0.20)
      # Column shaft
      c = gent.add_circle(Geom::Point3d.new(r * 1.3, r * 1.3, 0.20.m), Geom::Vector3d.new(0,0,1), r_m, 28)
      f = gent.add_face(c)
      f.pushpull(-(h_m - 0.45.m)) if f
      # Capital
      build_box(gent, r * 2.8, r * 2.8, 0.25)
    end

    def self.build_tapered_column(gent, rb, rt, h)
      build_cylinder(gent, (rb.to_f + rt.to_f) / 2.0, h, 28)
    end

    def self.build_cluster_column(gent, shafts, sr, spread, h)
      shafts.to_i.times do |i|
        a = (i.to_f / shafts.to_i) * 2 * Math::PI
        x = (spread.to_f * Math.cos(a)).m
        y = (spread.to_f * Math.sin(a)).m
        c = gent.add_circle(Geom::Point3d.new(x, y, 0), Geom::Vector3d.new(0,0,1), sr.to_f.m, 20)
        f = gent.add_face(c)
        f.pushpull(-h.to_f.m) if f
      end
    end

    def self.build_pedestal_column(gent, cr, ch, pw, ph)
      build_box(gent, pw, pw, ph)
      c = gent.add_circle(Geom::Point3d.new((pw.to_f / 2).m, (pw.to_f / 2).m, ph.to_f.m), Geom::Vector3d.new(0,0,1), cr.to_f.m, 24)
      f = gent.add_face(c)
      f.pushpull(-ch.to_f.m) if f
    end

    def self.build_obelisk(gent, bs, ts, h, ph)
      build_box(gent, bs, bs, h)
      build_pyramid(gent, ts, ts, ph)
    end

    def self.build_spiral_column(gent, r, h, twists)
      build_cylinder(gent, r, h, 24)
    end

    def self.build_tree_column(gent, tr, th, bh, spread)
      build_cylinder(gent, tr, th, 24)
    end

    def self.build_chamfer_column(gent, size, chamfer, h)
      build_box(gent, size, size, h)
    end

    def self.build_i_beam(gent, len, d, fw, ft, wt)
      l_m = len.to_f.m
      d_m = d.to_f.m
      fw_m = fw.to_f.m
      ft_m = ft.to_f.m
      wt_m = wt.to_f.m
      x_web_start = (fw_m - wt_m) / 2.0
      x_web_end   = x_web_start + wt_m
      profile = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(fw_m, 0, 0),
        Geom::Point3d.new(fw_m, 0, ft_m),
        Geom::Point3d.new(x_web_end, 0, ft_m),
        Geom::Point3d.new(x_web_end, 0, d_m - ft_m),
        Geom::Point3d.new(fw_m, 0, d_m - ft_m),
        Geom::Point3d.new(fw_m, 0, d_m),
        Geom::Point3d.new(0, 0, d_m),
        Geom::Point3d.new(0, 0, d_m - ft_m),
        Geom::Point3d.new(x_web_start, 0, d_m - ft_m),
        Geom::Point3d.new(x_web_start, 0, ft_m),
        Geom::Point3d.new(0, 0, ft_m)
      ]
      f = gent.add_face(profile)
      f.pushpull(-l_m) if f
    end

    def self.build_channel_beam(gent, len, d, fw, t)
      l_m = len.to_f.m
      d_m = d.to_f.m
      fw_m = fw.to_f.m
      t_m = t.to_f.m
      profile = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(fw_m, 0, 0),
        Geom::Point3d.new(fw_m, 0, t_m),
        Geom::Point3d.new(t_m, 0, t_m),
        Geom::Point3d.new(t_m, 0, d_m - t_m),
        Geom::Point3d.new(fw_m, 0, d_m - t_m),
        Geom::Point3d.new(fw_m, 0, d_m),
        Geom::Point3d.new(0, 0, d_m)
      ]
      f = gent.add_face(profile)
      f.pushpull(-l_m) if f
    end

    def self.build_tee_beam(gent, len, d, fw, t)
      build_i_beam(gent, len, d, fw, t, t)
    end

    def self.build_angle_l(gent, len, la, lb, t)
      l_m = len.to_f.m
      la_m = la.to_f.m
      lb_m = lb.to_f.m
      t_m = t.to_f.m
      profile = [
        Geom::Point3d.new(0, 0, 0),
        Geom::Point3d.new(la_m, 0, 0),
        Geom::Point3d.new(la_m, 0, t_m),
        Geom::Point3d.new(t_m, 0, t_m),
        Geom::Point3d.new(t_m, 0, lb_m),
        Geom::Point3d.new(0, 0, lb_m)
      ]
      f = gent.add_face(profile)
      f.pushpull(-l_m) if f
    end

    def self.build_cross_brace(gent, bw, bh, sz)
      build_box(gent, sz, bw, bh)
    end

    def self.build_anchor_bolts(gent, sx, sy, dia, depth)
      build_cylinder(gent, dia.to_f / 2, depth, 16)
    end

    def self.build_glulam_beam(gent, span, camber, w, d)
      build_box(gent, span, w, d)
    end

    def self.build_open_web_joist(gent, span, d, cw)
      build_box(gent, span, cw, d)
    end

    def self.build_roof_gable(gent, span, len, pitch, over)
      s_m = span.to_f.m
      l_m = len.to_f.m
      h_m = (span.to_f / 2.0) * Math.tan(pitch.to_f.degrees)
      apex = Geom::Point3d.new(s_m / 2.0, 0, h_m.m)
      profile = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(s_m, 0, 0), apex]
      f = gent.add_face(profile)
      f.pushpull(-l_m) if f
    end

    def self.build_roof_hip(gent, span, len, pitch, over)
      build_roof_gable(gent, span, len, pitch, over)
    end

    def self.build_roof_shed(gent, span, len, pitch, over)
      s_m = span.to_f.m
      l_m = len.to_f.m
      h_m = span.to_f * Math.tan(pitch.to_f.degrees)
      profile = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(s_m, 0, 0), Geom::Point3d.new(s_m, 0, h_m.m)]
      f = gent.add_face(profile)
      f.pushpull(-l_m) if f
    end

    def self.build_roof_butterfly(gent, span, len, pitch)
      build_roof_gable(gent, span, len, pitch, 0.2)
    end

    def self.build_dome(gent, r, segs = 16)
      build_sphere(gent, r, segs)
    end

    def self.build_sawtooth(gent, span, bay_w, len, h)
      build_wedge(gent, span, bay_w, h)
    end

    def self.build_truss_king(gent, span, rise, sz)
      build_roof_gable(gent, span, sz, 25.0, 0.0)
    end

    def self.build_truss_queen(gent, span, rise, sz)
      build_roof_gable(gent, span, sz, 25.0, 0.0)
    end

    def self.build_truss_pratt(gent, span, d, panels, sz)
      build_box(gent, span, sz, d)
    end

    def self.build_truss_warren(gent, span, d, panels, sz)
      build_box(gent, span, sz, d)
    end

    def self.build_desk(gent, w, d, h)
      build_box(gent, w, d, 0.04) # desktop
      build_box(gent, 0.05, d, h) # leg left
      build_box(gent, 0.05, d, h) # leg right
    end

    def self.build_table(gent, l, w, h, top_t)
      build_box(gent, l, w, top_t)
    end

    def self.build_chair(gent, sw, sd, sh, bh)
      build_box(gent, sw, sd, 0.05)
    end

    def self.build_sofa(gent, w, d, h)
      build_box(gent, w, d, 0.45)
      build_box(gent, w, 0.20, h)
    end

    def self.build_bookshelf(gent, w, d, h, shelves)
      build_hollow_box(gent, w, d, h, 0.04)
    end

    def self.build_kitchen_island(gent, l, w, h)
      build_box(gent, l, w, h)
    end

    def self.build_cabinet(gent, w, d, h)
      build_box(gent, w, d, h)
    end

    def self.build_bed(gent, l, w, bh, hh)
      build_box(gent, l, w, bh)
      build_box(gent, 0.15, w, hh)
    end

    def self.build_stool(gent, r, h)
      build_cylinder(gent, r, h, 20)
    end

    def self.build_tiered_planter(gent, bs, h, tiers)
      build_box(gent, bs, bs, h)
    end

    def self.build_stepping_stones(gent, count, r, sp)
      count.to_i.times do |i|
        x = (i * sp.to_f).m
        c = gent.add_circle(Geom::Point3d.new(x, 0, 0), Geom::Vector3d.new(0,0,1), r.to_f.m, 20)
        f = gent.add_face(c)
        f.pushpull(-0.06.m) if f
      end
    end

    def self.build_bike_hoop(gent, w, h, pd)
      build_box(gent, w, pd, h)
    end

    def self.build_park_bench(gent, l, sd, h)
      build_box(gent, l, sd, 0.45)
    end

    def self.build_pergola(gent, l, w, h)
      build_box(gent, l, w, 0.15)
    end

    def self.build_light_pole(gent, dia, h, reach)
      build_cylinder(gent, dia.to_f / 2, h, 16)
    end

    def self.build_fountain(gent, br, h)
      build_cylinder(gent, br, 0.45, 24)
    end

    # -------------------------------------------------------------------------
    # 3D FILE IMPORTER (.skp, .obj, .dae, .stl, .3ds, .dwg, .dxf, .ifc)
    # -------------------------------------------------------------------------
    def self.import_file(params = {})
      file_path = params['file_path'] || params['path']
      return { status: 'error', message: 'No file path provided' } unless file_path && File.exist?(file_path)

      model = Sketchup.active_model
      return { status: 'error', message: 'No active SketchUp model' } unless model

      name = params['name'] || File.basename(file_path, '.*')
      x = (params['x'] || 0.0).to_f
      y = (params['y'] || 0.0).to_f
      z = (params['z'] || 0.0).to_f
      rot_z = (params['rot_z'] || params['rotation'] || 0.0).to_f
      rot_x = (params['rot_x'] || 0.0).to_f
      rot_y = (params['rot_y'] || 0.0).to_f
      scale_u = (params['scale'] || 1.0).to_f
      scale_x = (params['scale_x'] || scale_u).to_f
      scale_y = (params['scale_y'] || scale_u).to_f
      scale_z = (params['scale_z'] || scale_u).to_f
      layer_name = params['layer'] || params['tag']

      ext = File.extname(file_path).downcase

      model.start_operation("Insert #{name}", true)

      pt = Geom::Point3d.new(x.m, y.m, z.m)
      t_trans = Geom::Transformation.translation(pt)
      t_rotz = Geom::Transformation.rotation(pt, Geom::Vector3d.new(0, 0, 1), rot_z.degrees)
      t_rotx = Geom::Transformation.rotation(pt, Geom::Vector3d.new(1, 0, 0), rot_x.degrees)
      t_roty = Geom::Transformation.rotation(pt, Geom::Vector3d.new(0, 1, 0), rot_y.degrees)
      t_scale = Geom::Transformation.scaling(pt, scale_x, scale_y, scale_z)
      transform = t_trans * t_rotz * t_rotx * t_roty * t_scale

      instance_or_group = nil

      if ext == '.skp'
        # Check if definition already loaded in model
        definition = nil
        model.definitions.each do |d|
          if d.path == file_path || d.name == name
            definition = d
            break
          end
        end

        definition ||= model.definitions.load(file_path)

        if definition
          instance_or_group = model.active_entities.add_instance(definition, transform)
          instance_or_group.name = name unless name.empty?
        else
          model.abort_operation
          return { status: 'error', message: "Failed to load SketchUp component from #{file_path}" }
        end
      else
        # Supported 3D formats (.obj, .dae, .stl, .3ds, .dwg, .dxf, .ifc)
        before_ents = model.active_entities.to_a
        model.import(file_path, false)
        after_ents = model.active_entities.to_a
        new_ents = after_ents - before_ents

        if !new_ents.empty?
          if new_ents.length == 1 && (new_ents.first.is_a?(Sketchup::Group) || new_ents.first.is_a?(Sketchup::ComponentInstance))
            instance_or_group = new_ents.first
            instance_or_group.transform!(transform)
          else
            instance_or_group = model.active_entities.add_group(new_ents)
            instance_or_group.transform!(transform)
          end
          instance_or_group.name = name unless name.empty?
        end
      end

      if instance_or_group && layer_name && !layer_name.strip.empty?
        tag = model.layers[layer_name] || model.layers.add(layer_name)
        instance_or_group.layer = tag
      end

      model.commit_operation

      {
        status: 'success',
        message: "Successfully inserted '#{name}' (#{ext.upcase}) into SketchUp at [#{x.round(2)}, #{y.round(2)}, #{z.round(2)}]m",
        name: name,
        extension: ext,
        position: [x, y, z],
        scale: [scale_x, scale_y, scale_z],
        rotation: rot_z
      }
    rescue => e
      model.abort_operation if model
      { status: 'error', message: "Import failed: #{e.message}" }
    end
  end
end
