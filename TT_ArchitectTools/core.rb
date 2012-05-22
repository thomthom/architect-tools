#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

module TT::Plugins::ArchitectTools
  
  
  ### MODULE VARIABLES ### -----------------------------------------------------
  
  # Preference
  @settings = TT::Settings.new( PLUGIN_ID )
  @settings.set_default( :gb_filter, '5003,5014,5081' ) # 5001,5003,5014,5041,5080,5081,5082
  @settings.set_default( :gb_low_pt, 'Lowest Point Above' )
  @settings.set_default( :gb_epsilon, 100.mm )
  @settings.set_default( :gb_group,   'No' )
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    # Commands
    cmd = UI::Command.new( 'Generate Buildings' ) { self.generate_buildings }
    cmd.small_icon = File.join( PATH_ICONS, 'GenerateBuildings_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'GenerateBuildings_24.png' )
    cmd.status_bar_text = 'Generate Buildings from CAD plan.'
    cmd.tooltip = 'Generate Buildings'
    cmd_generate_buildings = cmd
    
    cmd = UI::Command.new( 'Merge Solid Buildings' ) { self.merge_solid_buildings }
    cmd.small_icon = File.join( PATH_ICONS, 'MergeSolidBuildings_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'MergeSolidBuildings_24.png' )
    cmd.tooltip = 'Merge Solid Buildings'
    cmd_merge_solid_buildings = cmd
    
    cmd = UI::Command.new( 'Fill Solid Holes' ) { self.fill_solid_holes }
    cmd.small_icon = File.join( PATH_ICONS, 'FillSolidHoles_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'FillSolidHoles_24.png' )
    cmd.tooltip = 'Fill Solid Holes'
    cmd_fill_solid_holes = cmd
    
    cmd = UI::Command.new( 'Select Non-Solids' ) { self.select_non_solids }
    cmd.small_icon = File.join( PATH_ICONS, 'SelectNonSolids_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'SelectNonSolids_24.png' )
    cmd.tooltip = 'Select Non-Solids'
    cmd_select_non_solids = cmd
    
    cmd = UI::Command.new( 'Make 2:1 Road Profile' ) { self.make_road_profile }
    cmd.small_icon = File.join( PATH_ICONS, 'RoadProfile_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'RoadProfile_24.png' )
    cmd.tooltip = 'Make 2:1 Road Profile'
    cmd_make_road_profile = cmd
    
    cmd = UI::Command.new( 'Move to Z' ) { self.move_to_z }
    cmd.small_icon = File.join( PATH_ICONS, 'MoveToZ_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'MoveToZ_24.png' )
    cmd.status_bar_text = 'Moves all selected vertices to the given Z height.'
    cmd.tooltip = 'Move to Z'
    cmd_move_to_z = cmd
    
    cmd = UI::Command.new( 'Contour Tool' ) { self.contour_tool }
    cmd.small_icon = File.join( PATH_ICONS, 'ContourTool_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'ContourTool_24.png' )
    cmd.tooltip = 'Contour Tool'
    cmd_contour_tool = cmd
        
    cmd = UI::Command.new( 'Extrude Up' ) { self.extrude_up }
    cmd.small_icon = File.join( PATH_ICONS, 'ExtrudeUp_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'ExtrudeUp_24.png' )
    cmd.tooltip = 'Extrude Up'
    cmd_extrude_up = cmd
    
    cmd = UI::Command.new( 'Project Down Tool' ) { self.project_tool }
    cmd.small_icon = File.join( PATH_ICONS, 'ProjectDown_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'ProjectDown_24.png' )
    cmd.tooltip = 'Project Down Tool'
    cmd_project_tool = cmd
    
    cmd = UI::Command.new( 'Magnet Tool' ) { self.magnet_tool }
    cmd.small_icon = File.join( PATH_ICONS, 'MagnetTool_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'MagnetTool_24.png' )
    cmd.tooltip = 'Magnet Tool'
    cmd_magnet_tool = cmd
    
    cmd = UI::Command.new( 'Move to Plane' ) { self.plane_tool }
    cmd.small_icon = File.join( PATH_ICONS, 'ProjectToPlane_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'ProjectToPlane_24.png' )
    cmd.tooltip = 'Move to Plane'
    cmd_plane_tool = cmd
    
    cmd = UI::Command.new( 'Flatten Selection' ) { self.flatten_selection }
    cmd.small_icon = File.join( PATH_ICONS, 'Flatten_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'Flatten_24.png' )
    cmd.tooltip = 'Flatten Selection'
    cmd_flatten_selection = cmd
    
    cmd = UI::Command.new( 'Crop Selection to Boundary' ) { self.crop_selection }
    cmd.small_icon = File.join( PATH_ICONS, 'CropToBoundary_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'CropToBoundary_24.png' )
    cmd.tooltip = 'Crop Selection to Boundary'
    cmd_crop_selection = cmd
    
    cmd = UI::Command.new( 'Edge Grid Divide' ) { self.grid_divide_ui }
    cmd.small_icon = File.join( PATH_ICONS, 'EdgeGridDivide_16.png' )
    cmd.large_icon = File.join( PATH_ICONS, 'EdgeGridDivide_24.png' )
    cmd.tooltip = 'Edge Grid Divide'
    cmd_grid_divide_ui = cmd
    
    # Menus
    m = TT.menu( 'Plugins' ).add_submenu( PLUGIN_NAME )
    m.add_item( cmd_generate_buildings )
    m.add_item( cmd_merge_solid_buildings )
    m.add_separator
    m.add_item( cmd_fill_solid_holes )
    m.add_item( cmd_select_non_solids )
    m.add_separator
    m.add_item( cmd_make_road_profile )
    m.add_item( cmd_move_to_z )
    m.add_separator
    m.add_item( cmd_contour_tool )
    m.add_item( cmd_extrude_up )
    m.add_separator
    m.add_item( cmd_project_tool )
    m.add_item( cmd_magnet_tool )
    m.add_item( cmd_plane_tool )
    m.add_separator
    m.add_item( cmd_flatten_selection )
    m.add_item( cmd_crop_selection )
    m.add_separator
    m.add_item( cmd_grid_divide_ui )
    
    # Toolbar
    toolbar = UI::Toolbar.new( PLUGIN_NAME )
    toolbar.add_item( cmd_generate_buildings )
    toolbar.add_item( cmd_merge_solid_buildings )
    toolbar.add_separator
    toolbar.add_item( cmd_fill_solid_holes )
    toolbar.add_item( cmd_select_non_solids )
    toolbar.add_separator
    toolbar.add_item( cmd_make_road_profile )
    toolbar.add_item( cmd_move_to_z )
    toolbar.add_separator
    toolbar.add_item( cmd_contour_tool )
    toolbar.add_item( cmd_extrude_up )
    toolbar.add_separator
    toolbar.add_item( cmd_project_tool )
    toolbar.add_item( cmd_magnet_tool )
    toolbar.add_item( cmd_plane_tool )
    toolbar.add_separator
    toolbar.add_item( cmd_flatten_selection )
    toolbar.add_item( cmd_crop_selection )
    toolbar.add_separator
    toolbar.add_item( cmd_grid_divide_ui )
    if toolbar.get_last_state == TB_VISIBLE
      toolbar.restore
      UI.start_timer( 0.1, false ) { toolbar.restore } # SU bug 2902434
    end
  end
  
  
  ### MAIN SCRIPT ### ----------------------------------------------------------
  
  # @since 2.0.0
  def self.plane_tool
    Sketchup.active_model.select_tool( PlaneTool.new )
  end
  
  # @since 2.0.0
  class PlaneTool
    
    # @since 2.0.0
    def initialize
      @mouse_surface = []
      @mouse_edges = []
      @mouse_triangles = []
      @mouse_segments = []
      
      # Array of faces representing the surface.
      @surface = []
      # Array of bordering edges in surface - allowed to pick from.
      @edges = []
      # Array of triangle pointsets - for GL_TRIANGLE.
      @triangles = []
      # Array of selected edges - for GL_LINES.
      @segments = []
      
      @picked_edges = []
    end
    
    # @since 2.0.0
    def activate
      update_UI()
    end
    
    # @since 2.0.0
    def deactivate( view )
      view.invalidate
    end
    
    # @since 2.0.0
    def resume( view )
      update_UI()
      view.invalidate
    end
    
    # @since 2.0.0
    def onMouseMove( flags, x, y, view )
      ph = view.pick_helper
      ph.do_pick( x, y )
      
      #picked = ph.best_picked
      if @surface.empty?
        picked = ph.picked_face
      else
        picked = ph.picked_edge || ph.picked_face
      end
      tr = get_pickhelper_transformation( ph, picked )
      
      if picked.is_a?( Sketchup::Face )
        if @surface.include?( picked )
          #Sketchup.status_text = 'Pick face plane...'
          @mouse_segments.clear
          @mouse_segments = picked.edges.map { |e|
            e.vertices.map { |v| v.position.transform( tr ) }
          }.flatten
        else
          @mouse_surface.clear
          @mouse_edges.clear
          @mouse_triangles.clear
          #Sketchup.status_text = 'Pick surface...'
          @mouse_surface = get_surface( picked )
          @mouse_edges = get_surface_edges( @mouse_surface )
          pm = get_surface_mesh( @mouse_surface )
          for i in ( 1..pm.count_polygons )
            triangle = pm.polygon_points_at( i )
            triangle.map! { |pt| pt.transform( tr ) }
            @mouse_triangles << triangle
          end
        end
      elsif !@surface.empty? &&
            picked.is_a?( Sketchup::Edge ) &&
            @edges.include?( picked )
        @mouse_surface.clear
        @mouse_triangles.clear
        #Sketchup.status_text = 'Pick plane edge...'
        @mouse_edges = [ picked ]
        @mouse_segments = picked.vertices.map { |v| v.position.transform( tr ) }
      else
        @mouse_surface.clear
        @mouse_edges.clear 
        @mouse_triangles.clear
        @mouse_segments.clear
        #Sketchup.status_text = 'Nothing picked!'
      end
      
      view.tooltip = "#{picked.inspect} - #{@mouse_triangles.length}"
      
      view.invalidate
    end
    
    # @since 2.0.0
    def onLButtonUp( flags, x, y, view )
      # Pick Surface
      unless @mouse_triangles.empty?
        @edges = @mouse_edges.dup
        @surface = @mouse_surface.dup
        @triangles = @mouse_triangles.dup
        @edges = get_surface_edges( @surface )
        @mouse_edges.clear
      end
      # Pick Edges for plane
      unless @mouse_edges.empty?
        @picked_edges.concat( @mouse_edges )
        @picked_edges.uniq!
        @segments.concat( @mouse_segments )
      end
      update_UI()
      view.invalidate
    end
    
     # @since 2.0.0
    def onReturn( view )
      if @picked_edges.empty?
        UI.beep
        return false
      end
      # Transform vertices and smooth new autofolded edges.
      # Calculate target plane based on picked point-cloud.
      plane_points = @picked_edges.map { |e|
        e.vertices.map { |v| v.position }
      }.flatten
      if plane_points.length < 3
        UI.messagebox( 'At least three vertices is required to define the target plane.' )
        return false
      end
      plane = Geom.fit_plane_to_points( plane_points )
      # Adjust surface edges to plane - skipping edges picked for plane.
      picked_vertices = @picked_edges.map { |e| e.vertices }.flatten.uniq
      edges = get_surface_edges( @surface ) - @picked_edges
      vertices = edges.map { |e| e.vertices }.flatten.uniq - picked_vertices
      adjust_vertices = []
      vectors = []
      vertices.each { |vertex|
        line = [ vertex.position, Z_AXIS ]
        point = Geom.intersect_line_plane( line, plane )
        next unless point
        adjust_vertices << vertex
        vectors << vertex.position.vector_to( point )
      }
      if adjust_vertices.empty?
        UI.messagebox( 'Target plane did not intersect picked surface.' )
        return false
      end
      view.model.start_operation( 'Move To Plane', true )
      entities = @surface[0].parent.entities
      entities.transform_by_vectors( adjust_vertices, vectors )
      view.model.commit_operation
      @surface.clear
      @triangles.clear
      @picked_edges.clear
      view.invalidate
    end
    
    # @since 2.0.0
    def draw( view )
      
      unless @mouse_segments.empty?
        view.line_stipple = ''
        view.line_width = 3
        view.drawing_color = [255,0,0]
        view.draw( GL_LINES, @mouse_segments )
      end
      
      unless @mouse_triangles.empty?
        view.line_stipple = ''
        view.line_width = 1
        view.drawing_color = [255,128,0]
        for triangle in @mouse_triangles
          view.draw( GL_LINE_LOOP, triangle )
        end
        view.drawing_color = [255,128,0,64]
        view.draw( GL_TRIANGLES, @mouse_triangles.flatten )
      end
      
      unless @segments.empty?
        view.line_stipple = ''
        view.line_width = 5
        view.drawing_color = [255,0,128]
        view.draw( GL_LINES, @segments )
      end
      
      unless @triangles.empty?
        view.line_stipple = ''
        view.line_width = 1
        view.drawing_color = [0,128,255]
        for triangle in @triangles
          view.draw( GL_LINE_LOOP, triangle )
        end
        view.drawing_color = [0,128,255,64]
        view.draw( GL_TRIANGLES, @triangles.flatten )
      end
      
    end
    
    # @since 2.0.0
    def update_UI
      if @surface.empty?
        Sketchup.status_text = 'Pick the surface you wish to adjust.'
      else
        Sketchup.status_text = 'Pick edges to define a target plane. Picked edges are not adjusted. Press return to commit.'
      end
    end
    
    # @since 2.0.0
    def get_surface( face )
      return nil unless face.is_a?( Sketchup::Face )
      surface = { face => face } # Use hash for speedy lookup
      stack = [ face ]
      until stack.empty?
        face = stack.shift
        edges = face.edges.select { |e| e.soft? }
        for edge in edges
          for face in edge.faces
            next if surface.key?( face )
            stack << face
            surface[ face ] = face
          end
        end
      end
      surface.keys
    end
    
    # @since 2.0.0
    def is_part_of_surface?( entity )
      if entity.is_a?( Sketchup::Edge )
        entity.soft?
      elsif entity.is_a?( Sketchup::Face )
        entity.edges.any? { |e| e.soft? }
      else
        false
      end
    end
    
    def get_surface_edges( surface )
      surface.map { |face|
        face.edges.select { |e| !e.soft? }
      }.flatten
    end
    
    # @since 2.0.0
    def get_surface_mesh( surface )
      mesh = Geom::PolygonMesh.new
      for face in surface
        pm = face.mesh
        for i in ( 1..pm.count_polygons )
          triangle = pm.polygon_points_at( i )
          mesh.add_polygon( triangle )
        end
      end
      mesh
    end
    
    # @param [Sketchup::PickHelper] ph
    # @param [Sketchup::Entity] entity
    #
    # @since 2.0.0
    def get_pickhelper_transformation( ph, entity )
      for i in ( 0...ph.count )
        path = ph.path_at( i )
        next unless path.include?( entity )
        return ph.transformation_at( i )
      end
      Geom::Transformation.new # (?) nil
    end
    
  end # class PlaneTool
  
  
  # @since 2.0.0
  def self.magnet_tool
    Sketchup.active_model.select_tool( MagnetTool.new )
  end
  
  # @since 2.0.0
  class MagnetTool
    
    # @since 2.0.0
    def initialize
      @mouse_target = nil         # Face under the mouse cursor.
      @mouse_transformation = nil # For generating global co-ordinates.
      @mouse_hit_points = []      # Projected from source face to target plane.
      @mouse_projections = []     # Segments for visualizing projection.
      @mouse_triangles = []       # Array of triangle points for GL_TRIANGLE
      @mouse_vertices = {}        # Hash[ Vertex ] = [ LocalVector, GlobalPoint ]
      
      @picked_faces = {}  # Hash[ Face ] = Transformation
      @hit_points = []    # Projected points.
      @projections = []   # Projection segments. ( GL_LINES )
      @faces = []         # Array of triangles. ( GL_TRIANGLE )
      @vertices = {}      # Hash[ Vertex ] = [ LocalVector, GlobalPoint ]
      
      @adjust_vertex = nil  # Vertex being adjusted.
      @adjust_pt = nil      # New local position for vertex.
      @snap_points = []     # Snapping point for adjusting vertices.
    end
    
    # @since 2.0.0
    def activate
      update_UI()
    end
    
    # @since 2.0.0
    def deactivate( view )
      view.invalidate
    end
    
    # @since 2.0.0
    def resume( view )
      update_UI()
      view.invalidate
    end
    
    # @since 2.0.0
    def onMouseMove( flags, x, y, view )
      ph = view.pick_helper
      ph.init( x, y, 10 )
      
      # Find picked point.
      picked_point = nil
      picked_vertex = nil
      for vertex, data in @vertices
        vector, point = data
        next unless ph.test_point( point )
        picked_point = point
        picked_vertex = vertex
        break
      end
      
      # Adjust point when left mouse button is pressed down.
      adjusting_vertex = @adjust_vertex && flags & MK_LBUTTON == MK_LBUTTON
      if adjusting_vertex
        # Adjust a point by moving the mouse up and down along the Z axis of
        # the point being adjusted.
        ray = view.pickray( x, y )
        line = [ @adjust_pt, Z_AXIS ]
        pt1, pt2 = Geom::closest_points( line, ray )
        
        # Snap to nearby ray hits.
        current_snap = nil
        current_distance = nil
        for point in @snap_points
          aperture = view.pixels_to_model( 15, point )
          distance = pt1.distance( point )
          next if distance > aperture
          if current_distance
            next if distance > current_distance
          end
          current_distance = distance
          current_snap = point
          pt1 = point
        end
        
        # Update points.
        vector = @adjust_vertex.position.vector_to( pt1 )
        @vertices[ @adjust_vertex ] = [ vector, pt1 ]
        @adjust_pt = pt1
        update_polygons()
      else
        # Select point to adjust.
        @adjust_pt = picked_point
        @adjust_vertex = picked_vertex
        @snap_points.clear
      end

      # Find points to snap to.
      if @adjust_pt
        # Avoid doing too many raytest - only ray new rays when the adjusting
        # point it going further than it previously did.
        bb = Geom::BoundingBox.new
        bb.add( @snap_points ) unless @snap_points.empty?
        z = @adjust_pt.z
        if @snap_points.empty? || z < bb.min.z || z > bb.max.z
          ray_up   = [ @adjust_pt, Z_AXIS ]
          ray_down = [ @adjust_pt, Z_AXIS.reverse ]
          pt_up   = view.model.raytest( ray_up )
          pt_down = view.model.raytest( ray_down )
          @snap_points << pt_up[0].to_a if pt_up
          @snap_points << pt_down[0].to_a if pt_down
          @snap_points.uniq!
        end
      end

      if adjusting_vertex
        view.invalidate
        return false
      end
      
      # Pick faces to magnetize.
      ph.do_pick( x, y )
      face = ph.picked_face
      tr = get_pickhelper_transformation( ph, face )
      
      @mouse_target = face
      @mouse_transformation = tr
      @mouse_projections.clear
      @mouse_hit_points.clear
      @mouse_triangles.clear
      @mouse_vertices.clear
      
      # If point is being adjusted - don't pick a face to magnetize.
      if @adjust_pt
        @mouse_target = nil
        view.invalidate
        return
      end
      
      # Project the face vertices upwards until they hit geometry.
      if face && face.vertices.size < 100 # (!) Fixed limit!!
        offsets = {} # Cache for mapping PolygonMesh points to adjustment vectors.
        for vertex in face.vertices
          pt = vertex.position.transform!( tr )
          ray = [ pt, Z_AXIS ]
          result = view.model.raytest( ray )
          next unless result
          hit_pt, path = result
          @mouse_projections << pt
          @mouse_projections << hit_pt
          @mouse_hit_points << hit_pt
          vector = pt.vector_to( hit_pt )
          if vector.valid?
            @mouse_vertices[vertex] = [ vector, hit_pt ] # Vector, Global Point
            offsets[vertex.position.to_a] = vector
          end
        end
        # Extract the PolygonMesh to be used with GL_TRIANGLE.
        pm = face.mesh
        for i in ( 1..pm.count_polygons )
          pts = pm.polygon_points_at( i )
          pts.each { |pt|
            vector = offsets[ pt.to_a ]
            pt.offset!( vector ) if vector
            pt.transform!( @mouse_transformation )
            @mouse_triangles << pt
          }
        end
      
      end
      
      view.invalidate
    end
    
    # @since 2.0.0
    def onLButtonUp( flags, x, y, view )
      # If mouse hovers over a face, add it to the stack of magnetized faces.
      unless @mouse_vertices.empty?
        @vertices.merge!( @mouse_vertices )
        @faces << @mouse_triangles.dup
        @picked_faces[ @mouse_target ] = @mouse_transformation
      end
      @snap_points.clear
      view.invalidate
    end
    
    # @since 2.0.0
    def onReturn( view )
      if @vertices.empty?
        UI.beep
      else
        # Sort vertices by Entities
        contexts = {}
        for vertex, data in @vertices
          vector, global_position = data
          entities = vertex.parent.entities
          contexts[ entities ] ||= [ [], [] ]
          contexts[ entities ][0] << vertex
          contexts[ entities ][1] << vector
        end
        # Transform vertices and smooth new autofolded edges.
        view.model.start_operation( 'Magnet', true )
        for entities, data in contexts
          vertices, vectors = data
          original_entities = entities.to_a
          entities.transform_by_vectors( vertices, vectors )
          new_entities = entities.to_a - original_entities
          for e in new_entities
            next unless e.is_a?( Sketchup::Edge )
            e.soft = true
            e.smooth = true
          end
        end
        view.model.commit_operation
        @adjust_vertex = nil
        @adjust_point = nil
        @picked_faces.clear
        @vertices.clear
        @faces.clear
        view.invalidate
      end
    end
    
    # @since 2.0.0
    def onSetCursor
      if @adjust_pt
        cursor_id = TT::Cursor.get_id( :scale_n_s )
        UI.set_cursor( cursor_id )
      end
    end
    
    # @since 2.0.0
    def draw( view )
      
      unless @mouse_triangles.empty?
        view.drawing_color = [255,128,0,64]
        view.draw( GL_TRIANGLES, @mouse_triangles )
      end
      
      if @mouse_target && @mouse_target.valid?
        triangles = []
        pm = @mouse_target.mesh
        for i in ( 1..pm.count_polygons )
          pts = pm.polygon_points_at( i )
          pts.each { |pt| triangles << pt.transform!( @mouse_transformation ) }
        end
        view.drawing_color = [128,255,0,64]
        view.draw( GL_TRIANGLES, triangles )
      end
      
      unless @mouse_projections.empty?
        view.line_stipple = '_'
        view.line_width = 1
        view.drawing_color = [0,128,255]
        view.draw( GL_LINES, @mouse_projections )
      end
      
      unless @mouse_hit_points.empty?
        view.line_stipple = ''
        view.line_width = 2
        view.draw_points( @mouse_hit_points, 6, 4, [0,128,255] )
      end
      
      unless @vertices.empty?
        view.line_stipple = ''
        view.line_width = 2
        view.draw_points( @vertices.values, 6, 4, [0,128,255] )
      end
      
      view.draw2d( GL_LINES, [-10,-10,-10], [-20,-20,-20] )
      
      unless @faces.empty?
        view.drawing_color = [0,128,255,64]
        for triangles in @faces
          view.draw( GL_TRIANGLES, triangles )
        end
      end
      
      if @adjust_pt
        # Highlight point under mouse cursor.
        pt2d = view.screen_coords( @adjust_pt )
        circle = TT::Geom3d.circle( pt2d, Z_AXIS, 10, 16 )
        view.line_stipple = ''
        view.line_width = 2
        view.drawing_color = [255,0,0]
        view.draw2d( GL_LINE_LOOP, circle )
        
        # Snapping points.
        unless @snap_points.empty?
          size = view.pixels_to_model( 200, @adjust_pt )
          bb = Geom::BoundingBox.new
          bb.add( @snap_points )
          pt1 = @adjust_pt.offset( Z_AXIS, bb.max.z + size )
          pt2 = @adjust_pt.offset( Z_AXIS.reverse, bb.min.z + size )
          
          view.line_stipple = '-'
          view.line_width = 1
          view.drawing_color = [255,0,0]
          view.draw( GL_LINES, [pt1, pt2] )
          
          view.line_stipple = ''
          view.line_width = 2
          view.draw_points( @snap_points, 8, 3, [255,0,0] )
        end
        
        # Cursor point.
        view.draw_points( [@adjust_pt], 8, 4, [255,0,0] )
      end

    end
    
    # @since 2.0.0
    def update_UI
      Sketchup.status_text = 'Click a face to magnetize it. Click and drag a point to adjust it. Press Return to commit.'
    end
    
    # Regenerates the triangle cache for previewing the adjusted mesh.
    # Needs to be called when the content of @vertices is modified.
    # 
    # @since 2.0.0
    def update_polygons
      @faces.clear
      for face, transformation in @picked_faces
        pm = face.mesh
        # Map PolygonMesh point index to vertex.
        indexes = {}
        for vertex in face.vertices
          index = pm.point_index( vertex.position )
          indexes[ index ] = vertex
        end
        # Rebuild modified PolygonMesh.
        for i in ( 1..pm.count_polygons )
          triangle = []
          polygon = pm.polygon_at( i )
          polygon.each { |point_index|
            # Look up what vertex the position refer to.
            index = point_index.abs
            vertex = indexes[ index ]
            if @vertices.key?( vertex )
              triangle << @vertices[ vertex ][1]
            else
              triangle << vertex.position
            end
          }
          @faces << triangle
        end
      end
    end
    
    # @param [Sketchup::PickHelper] ph
    # @param [Sketchup::Entity] entity
    #
    # @since 2.0.0
    def get_pickhelper_transformation( ph, entity )
      for i in ( 0...ph.count )
        path = ph.path_at( i )
        next unless path.include?( entity )
        return ph.transformation_at( i )
      end
      Geom::Transformation.new # (?) nil
    end
  
  end # class MagnetTool
    
  
  # @since 2.0.0
  def self.project_tool
    Sketchup.active_model.select_tool( ProjectDownTool.new )
  end
  
  # @since 2.0.0
  class ProjectDownTool
    
    # @since 2.0.0
    def initialize
      @entity = nil
      @transformation = nil
      
      @segments = []
      @projections = []
      @hit_points = []     
      
      @mouse_face = nil
      @mouse_tr = Geom::Transformation.new
    end
    
    # @since 2.0.0
    def activate
      update_UI()
    end
    
    # @since 2.0.0
    def deactivate( view )
      view.invalidate
    end
    
    # @since 2.0.0
    def resume( view )
      update_UI()
      view.invalidate
    end
    
    # @since 2.0.0
    def onMouseMove( flags, x, y, view )
      ph = view.pick_helper
      ph.do_pick( x, y )
      
      # Look for potential target face.
      @mouse_face = ph.picked_face
      @mouse_tr = get_pickhelper_transformation( ph, @mouse_face )
      
      # Look for entities to project.
      @entity = ph.picked_edge || ph.picked_face
      @transformation = get_pickhelper_transformation( ph, @entity )
      
      # Project entities to target face.
      @segments.clear
      @projections.clear
      @hit_points.clear
      #status = "Entity: #{@entity}"
      if @target_face
        for edge in get_edges( @entity )
          pt1, pt2 = edge.vertices.map { |v| v.position.transform!( @transformation ) }
          ray1 = [ pt1, Z_AXIS.reverse ]
          ray2 = [ pt2, Z_AXIS.reverse ]
          target1 = Geom.intersect_line_plane( ray1, @target_face.plane )
          target2 = Geom.intersect_line_plane( ray2, @target_face.plane )
          # Validate results.
          if target1
            @projections.concat( [ pt1, target1 ] )
            @hit_points << target1
            #status += "Target1: #{@target_face}"
          end
          if target2
            @projections.concat( [ pt2, target2 ] )
            @hit_points << target2
            #status += " - Target2: #{@target_face}"
          end
          if target1 && target2
            @segments.concat( [ target1, target2 ] )
          end
        end
      end
      #Sketchup.status_text = status
      
      view.tooltip = @entity.typename if @entity
      view.invalidate
    end
    
    # @since 2.0.0
    def onLButtonUp( flags, x, y, view )
      if @target_face && !@segments.empty?
        entities = @target_face.parent.entities
        tr = @target_transformation.inverse
        entities.model.start_operation( 'Project Down', true )
        for i in ( 0...@segments.size-1 )
          segment = @segments[i,2]
          local_pts = segment.map { |pt| pt.transform( tr ) }
          g = entities.add_group
          g.entities.add_line( local_pts )
          g.explode # Triggering SketchUp's auto-merge feature.
        end
        entities.model.commit_operation
      else
        # Pick target face. ( Plane and entities )
        @target_face = @mouse_face
        @target_transformation = @mouse_tr
      end
      @segments.clear
      view.invalidate
    end
    
    # @since 2.0.0
    def draw( view )
      # Source entities being projected.
      if @entity
        view.line_stipple = ''
        view.line_width = 5
        view.drawing_color = [255,128,0]
        if @entity.is_a?( Sketchup::Edge )
          pts = @entity.vertices.map { |v| v.position.transform!( @transformation ) }
          view.draw( GL_LINES, pts )
        elsif @entity.is_a?( Sketchup::Face )
          for loop in @entity.loops
            pts = loop.vertices.map { |v| v.position.transform!( @transformation ) }
            view.draw( GL_LINE_LOOP, pts )
          end
        end
      end
      
      # Target Face.
      if @target_face && @target_face.valid?
        triangles = []
        pm = @target_face.mesh
        for i in ( 1..pm.count_polygons )
          pts = pm.polygon_points_at( i )
          pts.each { |pt| triangles << pt.transform!( @target_transformation ) }
        end
        view.drawing_color = [0,128,255,64]
        view.draw( GL_TRIANGLES, triangles )
      end
      
      # Projection rays.
      unless @projections.empty?
        view.line_stipple = '_'
        view.line_width = 1
        view.drawing_color = [255,0,128]
        view.draw( GL_LINES, @projections )
      end
      
      # Projected segment.
      unless @segments.empty?
        view.line_stipple = ''
        view.line_width = 2
        view.drawing_color = [0,128,255]
        view.draw( GL_LINES, @segments )
      end
      
      # Projection intersection with target plane.
      unless @hit_points.empty?
        view.line_stipple = ''
        view.line_width = 2
        view.draw_points( @hit_points, 6, 4, [255,0,0] )
      end
    end
    
    # @since 2.0.0
    def update_UI
      Sketchup.status_text = 'Pick a face to set target plane and context. Pick edges to project edges to plane.'
    end
    
    # @since 2.0.0
    def ray_transformation( path )
      stack = path.dup
      tr = Geom::Transformation.new
      for i in ( 0...path.size-1 )
        tr = tr * path[i].transformation
      end unless path.empty?
      tr
    end
    
    # @since 2.0.0
    def ray_find_face( model, ray )
      result = model.raytest( ray )
      return nil unless result
      vector = ray[1]
      pt, path = result
      until path.last.is_a?( Sketchup::Face )
        ray = [ pt, vector ]
        result = model.raytest( ray )
        return nil unless result
        pt, path = result
      end
      result
    end
    
    # @param [Sketchup::PickHelper] ph
    # @param [Sketchup::Entity] entity
    #
    # @since 2.0.0
    def get_pickhelper_transformation( ph, entity )
      for i in ( 0...ph.count )
        path = ph.path_at( i )
        next unless path.include?( entity )
        return ph.transformation_at( i )
      end
      Geom::Transformation.new # (?) nil
    end
    
    # @since 2.0.0
    def get_edges( entity )
      edges = []
      if entity.is_a?( Sketchup::Edge )
        edges << entity
      elsif entity.is_a?( Sketchup::Face )
        edges == entity.edges
      end
      edges
    end
    
  end # class ProjectDownTool
  
  
  # @todo Filter target by layer.
  #
  # @todo Colour faces by elevation.
  #
  # @since 2.0.0
  def self.extrude_up
    model = Sketchup.active_model
    selection = model.selection
    
    # Verify Selection.
    if selection.empty?
      return UI.messagebox( 'Select a group or component with faces to extrude.' )
    elsif selection.length == 1
      entity = selection[0]
      if TT::Instance.is?( entity )
        definition = TT::Instance.definition( entity )
        entities = definition.entities
        transformation = entity.transformation
      else
        return UI.messagebox( 'Select a group or component with faces to extrude.' )
      end
    end
    
    # Key: Z Elevation
    # Value: Array Faces
    faces = {}
    
    # Key: Sketchup::Vertex
    # Value: Geom::Point3d (Global position)
    rays = {}
    
    # Collect faces to extrude.
    source_faces = entities.select { |e| e.is_a?( Sketchup::Face ) }
    total_faces = source_faces.size
    
    # Correction for when a group or component is the current context.
    model_transform = model.edit_transform.inverse
    transform_to_global = transformation
    
    # Raytrace vertices up.
    time_start = Time.now
    Sketchup.status_text = 'Raytracing...'
    i = 0 # Index of current face.
    for face in source_faces
      i += 1
      next unless face.valid?
      
      j = 0 # Index of current vertex.
      vertex_count = face.vertices.size
      
      # Find the minimum raytraced height for all vertices in face. This is the
      # height which the face will be extruded to.
      elevation = nil
      for vertex in face.vertices
        # Output progress info to UI.
        # (!) Use TT::Progressbar - avoid too many updates.
        j += 1
        Sketchup.status_text = "Raytracing... ( Face #{i} of #{total_faces} - Vertex #{j} of #{vertex_count} )"
        TT::SketchUp.refresh
        
        # Raytrace vertices - but cache the result so it only is raytraced
        # one time per vertex.
        unless pt_target = rays[ vertex ]
          pt_source = vertex.position.transform!( transform_to_global )
          #pt_source = vertex.position.transform!( transformation )
          #pt_source.transform!( model_transform )
          
          # <debug>
          #model.entities.add_cpoint( pt_source )
          # </debug>
          ray = [ pt_source, Z_AXIS ]
          result = model.raytest( ray, true ) # SU8 M1
          if result.nil?
            # Ensure result of non-hit trace is cached - store a ground level
            # point - which will be ignored when retreived.
            # <debug>
            #model.entities.add_cline( pt_source, pt_source.offset( Z_AXIS, 200.m ) )
            # </debug>
            rays[ vertex ] = ORIGIN
            next
          end
          pt_target, path = result
          # <debug>
          #model.entities.add_cline( pt_source, pt_target ) 
          #model.entities.add_cpoint( pt_target )
          # </debug>
          rays[ vertex ] = pt_target
        end
        
        # Ignore elevation on ground.
        # (?) Or maybe not - some elevations, at water edge should be at zero.
        #     Look into changing this when layer filter is implemented.
        z = pt_target.z
        if elevation.nil? || z < elevation
          elevation = z if z > 0.0
        end
      end
      # Store the face with in the stack for the appropriate elevation.
      # If no elevation was found then the face will be ignored.
      next unless elevation && elevation > 0.0
      faces[ elevation ] ||= []
      faces[ elevation ] << face
    end
    
    # Sort by height - highest first. This is because the highest need to be
    # extruded first in order to ensure an extrusion doesn't stop to short
    # because it's being limited by a short neighbouring extrusion.
    sorted_faces = faces.sort { |a,b| b[0] <=> a[0] }
    
    # Extrude!
    time_start_extrude = Time.now
    i = 0 # Index of current face.
    Sketchup.status_text = 'Extruding...'
    model.start_operation( 'Extrude Up', true )
    for elevation, entities in sorted_faces
      next if elevation == 0.0
      for face in entities
        i += 1
        next unless face.valid?
        
        # Output progress info to UI.
        Sketchup.status_text = "Extruding... ( Face #{i} of #{total_faces} )"
        TT::SketchUp.refresh
        
        # Extrude the face to calcualted elevation. Ensure normal is facing the
        # correct direction - Z_AXIS.
        if face.normal.samedirection?( Z_AXIS.reverse )
          face.reverse!
        end
        face.pushpull( elevation )
      end
    end
    model.commit_operation
    Sketchup.status_text = 'Done!'
    
    # Performance stats.
    raytraced_time  = TT::format_time( time_start_extrude - time_start )
    extrude_time    = TT::format_time( Time.now - time_start_extrude )
    total_time      = TT::format_time( Time.now - time_start )
    puts "\n=== Extrude Up ==="
    puts "> Faces: #{sorted_faces.size}"
    puts "> Raytracing: #{raytraced_time}"
    puts "> Extruding: #{extrude_time}"
    puts "Total: #{total_time}\n\n"
  end
  
  # @since 2.0.0
  def self.contour_tool
    Sketchup.active_model.select_tool( ContourTool.new )
  end
  
  # @todo Filter target by layer.
  #
  # @since 2.0.0
  class ContourTool
    
    # @since 2.0.0
    def initialize
      # Picked entities.
      @edge = nil
      @z = nil # Local
      @transformation = nil
      
      # Mouse interaction.
      @mouse_edge = nil
      @mouse_z = nil
      @mouse_transformation = nil
      @raytrace_pts = nil
      
      # Segments from picked Z level and projected segments.
      @segments = nil
      @segments_2d = nil
      
      # Points of user interaction with drawn segments.
      @selected_point = nil
      @start_point = nil
      @mouse_point = nil
      
      # Array of segments the user has drawn.
      @connects = []
      
      # Array of open ends from curves on picked Z level.
      @end_points = []
      
      # Segment modification.
      @inject_point = nil
      
      # Input point helper.
      @ip = Sketchup::InputPoint.new
    end
    
    # @since 2.0.0
    def activate
      default_status()
    end
    
    # @since 2.0.0
    def deactivate( view )
      view.invalidate
    end
    
    # @since 2.0.0
    def resume( view )
      view.invalidate
      default_status()
    end
    
    # @since 2.0.0
    def onMouseMove( flags, x, y, view )
      left_button = ( flags & MK_LBUTTON ) == MK_LBUTTON
      
      @mouse_edge = nil
      
      ph = view.pick_helper
      
      # Mouse hovers over a uncommited segment. End points or new injected
      # points will be highlighted.
      @inject_mouse = nil
      for i in ( 0...@connects.size )
        segment = @connects[i]
        result = ph.pick_segment( segment, x, y, 10 )
        next unless result
        index = result.abs
        if result < 0
          line = segment[ index - 1, 2 ]
          ray = view.pickray( x, y )
          pt1, pt2 = Geom.closest_points( line, ray )
          @inject_mouse = pt1
          view.tooltip = "Click + drag to insert point to segment"
        else
          @inject_mouse = segment[ index ]
          view.tooltip = "Click + drag to modify point"
        end
        return view.invalidate
      end unless left_button
      
      # User is modifying a segment. Moves a new or existing point.
      if @inject_point
        plane = [ORIGIN,Z_AXIS]
        ray = view.pickray( x, y )
        pt = Geom.intersect_line_plane( ray, plane )
        @inject_point.set!( pt ) if pt
        @inject_mouse = @inject_point.clone
        return view.invalidate
      end
      
      # Check if mouse hovers over end point. Highlight it.
      # If a new segment is being drawn, snap to the point.
      ph.init( x, y, 20 )
      for pt in @end_points
        next unless ph.test_point( pt )
        if @start_point
          # Segment is being drawn, snap to point.
          @mouse_point = pt
          @end_point = pt
          view.tooltip = "Release to connect to point"
        else
          # Highlight the point the mouse hovers over.
          @selected_point = pt
          view.tooltip = "Click + drag to draw contour from point"
        end
        return view.invalidate
      end
      
      # New segment is being drawn, but the mouse is not close enough to any
      # end point. Check if it can snap to an existing edge - otherwise ensure
      # is is being drawn on ground plane.
      if @start_point
        @ip.pick( view, x, y )
        if @ip.edge
          # (!?) Ensure point is at ground level?
          @mouse_point = @ip.position
        else
          plane = [ORIGIN,Z_AXIS]
          ray = view.pickray( x, y )
          @mouse_point = Geom.intersect_line_plane( ray, plane )
          @ip.clear
        end
        @end_point = nil
        @selected_point = nil
        return view.invalidate
      end
      
      # Check if mouse hovers over an edge - indicate to the user what edge and
      # Z level is under the mouse.
      ph.do_pick( x, y )
      if @mouse_edge = ph.picked_edge
        @mouse_transformation = get_pickhelper_transformation( ph, @mouse_edge )
        z = @mouse_edge.vertices[0].position.z
        if @mouse_edge.vertices.all? { |v| v.position.z == z }
          @mouse_z = z
        end
        z = @mouse_edge.vertices[0].position.transform(@mouse_transformation).z
        # Check if the pick will be raytraced
        if result = raytrace_pick( view, @mouse_edge, @mouse_transformation )
          edge, transformation, z = result
          pt1, pt2 = edge.vertices.map { |v| v.position.transform( transformation ) }
          pt3 = pt1.offset( Z_AXIS.reverse, z )
          pt4 = pt2.offset( Z_AXIS.reverse, z )
          @raytrace_pts = [ pt1,pt3, pt2,pt4 ]
        else
          @raytrace_pts = nil
        end
        view.tooltip = "Z Elevation: #{z}\nClick to set as current"
      else
        @mouse_edge = nil
        @mouse_z = nil
        @mouse_transformation = nil
      end
      view.invalidate
    end
    
    # @since 2.0.0
    def onLButtonDown( flags, x, y, view )
      ph = view.pick_helper
      
      # Check for interaction with new connecting segments.
      # Clicking on a point will move it, clicking on a segment
      # will insert a new point.
      for i in ( 0...@connects.size )
        # See if a segment was picked.
        segment = @connects[i]
        result = ph.pick_segment( segment, x, y, 10 )
        next unless result
        # Determine if a point or edge was clicked.
        index = result.abs
        if result < 0
          # Edge was clicked, insert new point.
          pt1, pt2 = segment[ index - 1, 2 ]
          pt = Geom::linear_combination( 0.5, pt1, 0.5, pt2 )
          @inject_point = pt
          segment.insert( index, @inject_point )
        else
          # Point was clicked, move existing point.
          @inject_point = segment[ index ]
        end
        
        return view.invalidate
      end
      
      # Check if an end point was clicked. This will initiate the drawing
      # function. The user can then make a new virtual segment that can be
      # edited until the user commit the change.
      ph.init( x, y, 20 )
      for pt in @end_points
        next unless ph.test_point( pt )
        @start_point = pt
        return view.invalidate
      end
      
      # Check if the user has picked an edge - in which case a new Z height is
      # chosen. All edges in that entities-context will then be projected down
      # to ground level.
      #
      # If the edge is at ground level - Z = 0 - a ray will be traced
      # to find the overhead geometry. This is to allow the user to pick a
      # Z height from the projected ground plane.
      if @mouse_edge && @mouse_edge.vertices.all? { |v| v.position.z == 0 }
        if result = raytrace_pick( view, @mouse_edge, @mouse_transformation )
          @edge, @transformation, @z = result
          local_z = @edge.start.position.z
          find_curves_on_elevation( local_z, @edge.parent.entities, @transformation )
        end
        return view.invalidate
      elsif @edge = @mouse_edge
        # Find all edges on Z height and project down to ground.
        @transformation = @mouse_transformation
        @z = @mouse_z
        find_curves_on_elevation( @z, @edge.parent.entities, @transformation )
        return view.invalidate
      end
      
      # Select faces picked in the current context.
      ph.do_pick( x, y )
      #face = ph.best_picked
      if face = ph.best_picked and face.is_a?( Sketchup::Face )
        entities = face.parent.entities
        if view.model.active_entities == entities
          view.model.selection.clear
          view.model.selection.add( face )
        end
      end
      
      view.invalidate
    end
    
    
    # @since 2.0.0
    def onLButtonUp( flags, x, y, view )
      # User create a new segment.
      if @start_point && @mouse_point
        @connects << [ @start_point, @mouse_point ]
      end
      
      # Reset states.
      @start_point = nil
      @end_point = nil
      @mouse_point = nil
      @selected_point = nil
      @ip.clear
      @inject_point = nil
      @inject_mouse = nil
      
      view.invalidate
      default_status()
    end

    # @since 2.0.0
    def onLButtonDoubleClick( flags, x, y, view )
      puts 'onLButtonDoubleClick'
      
      # Double click triggers various actions based on what is clicked.
      ph = view.pick_helper
      ph.do_pick( x, y )

      if picked = ph.picked_edge
        puts '> Auto-Merge'
        # Double clicking edges will attempt to trigger SketchUp's auto-merge
        # feature. Useful for closed edge loops which hasn't merged with the
        # face it lies on.
        transformation = get_pickhelper_transformation( ph, picked )
        #pts = picked.vertices.map { |v| v.position.transform( transformation.inverse ) }
        #if pts.all? { |pt| pt.z == 0 }
          view.model.start_operation( 'Trigger Auto-Merge', true )
          entities = picked.parent.entities
          points = picked.vertices.map { |v| v.position }
          g = entities.add_group
          e = g.entities.add_line( points )
          g.explode
          @mouse_edge = nil
          @edge = nil
          @segments = nil
          view.model.commit_operation
        #end
      elsif picked = ph.picked_face
        puts '> Connect Contours'
        # Double clicking a face will commit the drawn segments. The new
        # geometry will be drawn in the same context as the clicked face.
        transformation = get_pickhelper_transformation( ph, picked )
        entities = picked.parent.entities
        view.model.start_operation( 'Connect Contours', true )
        for segment in @connects
          local_segment = segment.map { |pt|
            pt.transform( transformation.inverse )
          }
          entities.add_curve( local_segment )
        end
        view.model.commit_operation
        puts "> #{@connects.size} connected"
        @connects.clear
      end
      true
    end
    
    # @since 2.0.0
    def onCancel( reason, view )
      #puts "onCancel #{reason}"
      
      # Cancel drawing of new segment.
      if @start_point || @mouse_point
        @start_point = nil
        @mouse_point = nil
        return view.invalidate
      end
      
      # Cancel editing of new segment
      #if @inject_mouse
      #  segment = @connects.find { |path| path.include?( @inject_mouse ) }
      #  segment.delete( @inject_mouse )
      #  @inject_mouse = nil
      #  return view.invalidate
      #end
      
      # Clear drawn segments
      @connects.clear
      view.invalidate
      default_status()
    end
    
    # @todo Allow user to set elevation step amount.
    #
    # @since 2.0.0
    def onKeyUp( key, repeat, flags, view )
      #puts "onKeyUp: #{key} - (#{flags})"
      case key
      when 107: # Numpad +
        change_elevation( 500.mm )
        view.invalidate
      when 109: # Numpad -
        change_elevation( -500.mm )
        view.invalidate
      #when 13: # Return (flag: numpad 49436, normal 49180)
        #puts '> Return'
        # Triggers after onReturn
      #when 27: # ESC
        #puts '> ESC'
        # Triggers before onCancel( 0 )
      end
      default_status()
    end
    
    # @since 2.0.0
    def draw( view )
      # User hovers over edge - highlight this.
      if @mouse_edge && @mouse_z && @mouse_transformation
        segment = @mouse_edge.vertices.map { |v|
          v.position.transform( @mouse_transformation )
        }
        view.line_stipple = ''
        view.line_width = 5
        view.drawing_color = [255,128,0]
        view.draw( GL_LINES, segment )
        
        if @raytrace_pts
          view.line_stipple = '-'
          view.line_width = 1
          view.drawing_color = [92,92,92]
          view.draw( GL_LINES, @raytrace_pts )
          
          pt1, pt2, pt3, pt4 = @raytrace_pts
          view.line_stipple = ''
          view.line_width = 5
          view.drawing_color = [255,128,0,64]
          view.draw( GL_LINES, [pt1,pt3] )
        end
      end
      
      #if @edge && @z && @transformation
      #  segment = @edge.vertices.map { |v|
      #    v.position.transform( @transformation )
      #  }
      #  view.line_stipple = ''
      #  view.line_width = 5
      #  view.drawing_color = [0,128,0]
      #  view.draw( GL_LINES, segment )
      #end      
      
      # All the new un-commited segments the user has drawn.
      unless @connects.empty?
        view.line_stipple = ''
        view.line_width = 2
        view.drawing_color = [128,0,255]
        for segment in @connects
          view.draw( GL_LINE_STRIP, segment )
          view.draw_points( segment, 6, 1, [128,0,255] )
        end
      end
      
      # New segment being drawn.
      if @start_point && @mouse_point
        view.line_stipple = ''
        view.line_width = 2
        view.drawing_color = [0,92,255]
        view.draw( GL_LINES, [@start_point, @mouse_point] )
      end
      
      # All the edges from the picked Z level.
      if @segments
        view.line_stipple = ''
        view.line_width = 4
        view.drawing_color = [0,128,0,128]
        view.draw( GL_LINES, @segments )
        
        view.drawing_color = [255,128,0]
        view.draw( GL_LINES, @segments_2d )
        
        view.line_width = 2
        view.draw_points( @end_points, 10, 1, [255,0,0] )
        view.draw_points( @start_point, 10, 2, [255,0,0] ) if @start_point
        view.draw_points( @end_point, 10, 2, [255,0,0] ) if @end_point
        view.draw_points( @selected_point, 10, 2, [255,0,0] ) if @selected_point
      end
      
      # User modifies a segment.
      if @inject_mouse
        view.line_width = 2
        view.draw_points( @inject_mouse, 10, 4, [128,0,255] )
      end
      
      # User draw new segment, snapping to existing geometry.
      if @ip.display?
       @ip.draw( view  )
      end
    end
    
    # @since 2.0.0
    def default_status
      status( 'Click + drag end points to connect. Click edges to set Z elevation. Doubleclick face to commit segments.' )
    end
    
    # @param [String] text
    #
    # @since 2.0.0
    def status( text )
      Sketchup.status_text = text
      Sketchup.vcb_label = 'Z Elevation'
      Sketchup.vcb_value = global_elevation()
    end
    
    # @since 2.0.0
    def global_elevation
      return nil unless @z
      pt = Geom::Point3d.new( 0, 0, @z )
      pt.transform( @transformation )
      pt.z
    end
    
    # @param [Length] step
    #
    # @since 2.0.0
    def change_elevation( step )
      return nil unless @edge
      entities = @edge.parent.entities
      @z += step
      find_curves_on_elevation( @z, entities, @transformation )
    end
    
    # @param [Sketchup::View] view
    # @param [Sketchup::Edge] edge
    # @param [Geom::Transformation] transformation
    #
    # @return [Array<edge,transformation,z>]
    # @since 2.0.0
    def raytrace_pick( view, edge, transformation )
      # Source points.
      pt1 = edge.start.position.transform( transformation )
      pt2 = edge.end.position.transform( transformation )
      # Raytrace up to find elevation.
      ray = [ pt1, Z_AXIS ]
      result = view.model.raytest( ray, false ) # (!) SU8 M1
      return nil unless result
      # Ensure entity found is a level edge.
      hit_pt, path = result
      e = path.pop
      return nil unless e.is_a?( Sketchup::Edge ) && e.start.position.z == e.end.position.z
      # Calculate transformation
      tr = Geom::Transformation.new
      until path.empty?
        i = path.pop
        tr = tr * i.transformation
      end
      # Find the exact edge.
      v1 = e.vertices.find { |v|
        pt = v.position.transform( tr )
        pt.z = 0
        #pt.distance( pt1 ) < 0.001
        pt == pt1
      }
      return nil unless v1
      picked_edge = v1.edges.find { |neighbour_edge|
        pt = neighbour_edge.other_vertex( v1 ).position.transform( tr )
        pt.z = 0
        #pt.distance( pt2 ) < 0.001
        pt == pt2
      }
      return nil unless picked_edge
      # Find global Z elevation.
      z = picked_edge.start.position.transform( tr ).z
      [ picked_edge, tr, z ]
    end
    
    # @param [Sketchup::PickHelper] ph
    # @param [Sketchup::Entity] entity
    #
    # @since 2.0.0
    def get_pickhelper_transformation( ph, entity )
      for i in ( 0...ph.count )
        path = ph.path_at( i )
        next unless path.include?( entity )
        return ph.transformation_at( i )
      end
      Geom::Transformation.new # (?) nil
    end
    
    # @param [Length] z
    # @param [Sketchup::Entities] entities
    # @param [Geom::Transformation] transformation
    #
    # @since 2.0.0
    def find_curves_on_elevation( z, entities, transformation )
      @segments = []
      @segments_2d = []
      @end_points = []
      
      for e in entities
        next unless e.is_a?( Sketchup::Edge )
        next unless e.vertices.all? { |v| v.position.z == z }
        
        pt1 = e.start.position.transform( transformation )
        pt2 = e.end.position.transform( transformation )
        @segments << pt1
        @segments << pt2
        
        pt1_2d = pt1.clone
        pt2_2d = pt2.clone
        pt1_2d.z = 0
        pt2_2d.z = 0
        @segments_2d << pt1_2d
        @segments_2d << pt2_2d
        
        @end_points << pt1_2d if e.start.edges.size == 1
        @end_points << pt2_2d if e.end.edges.size == 1
      end
      nil
    end
    
    # @param [Sketchup::View] view
    #
    # @since 2.0.0
    def connect_contours( view )
      view.model.start_operation( 'Connect Contours', true )
      for segment in @connects
        view.model.active_entities.add_curve( segment )
      end
      view.model.commit_operation
      @connects.clear
    end
    
  end # class
  
  
  ##############################################################################
  
  
  #
  # ===== GENERATE BUILDINGS ===== #
  #
  def self.generate_buildings
    model = Sketchup.active_model
    sel = model.selection
    
    # Ensure a component or group is selected.
    # (?) Allow multiple?
    # (?) Allow edge selection?
    unless sel.length == 1 && TT::Instance.is?( sel.first )
      UI.messagebox( 'Select only one Group or Component.' )
      return false
    end
    
    # Prompt user for processing rules.
    # (!) Use TT::GUI::Inputbox
    prompts = ['Layer Filter: ', 'Pushpull to: ', 'Tolerance: ', 'Group: ']
    #defaults = ['5003,5014,5081', 'Lowest Point Above']
    # 5001,5003,5014,5041,5080,5081,5082
    d_filter    = @settings[:gb_filter]
    d_low_point = @settings[:gb_low_pt]
    d_epsilon   = @settings[:gb_epsilon]
    d_group     = @settings[:gb_group]
    defaults = [d_filter, d_low_point, d_epsilon, d_group]
    list = ['', 'Lowest Point Above|Highest Point Above', '', 'Yes|No']
    result = UI.inputbox(prompts, defaults, list, 'Generate Buildings')
    return if result == false
    
    # Process user input
    filter, to_lowest, epsilon, group = result
    @settings[:gb_filter] = filter
    @settings[:gb_low_pt] = to_lowest
    @settings[:gb_epsilon] = epsilon
    @settings[:gb_group] = group
    filter = filter.split(',').map{|f|f.strip}.join('|') # Convert , to | and remove whitespace
    to_lowest = (to_lowest == 'Lowest Point Above')
    layers = model.layers.select { |layer| layer.name.match(filter) }
    group = (group=='Yes')
    
    # References to the source instance and entities.
    source = sel.first
    entities = TT::Instance.definition( source ).entities
    
    TT::Model.start_operation('Generate Buildings')
    
    # Time the whole process.
    total_progress = TT::Progressbar.new()
    
    # Create destination group for the building geometry.
    target = model.active_entities.add_group	
    target.transformation = source.transformation
    
    # Table of 3D points projected to 2D points. Used to determine heights.
    points = {}
    
    # Recreate all edges in source projected down to the ground plane in target.
    TT::debug 'Flattening...'
    edges = entities.select { |e|
      e.is_a?(Sketchup::Edge) && layers.include?(e.layer)
    }
    progress = TT::Progressbar.new( edges, 'Flattening' )
    for edge in edges
      p1 = edge.start.position#.extend( TT::Point3d_Ex )
      p2 = edge.end.position#.extend( TT::Point3d_Ex )
      p1.z = 0
      p2.z = 0
      
      # Point3d can not be used in hashes. Two Point3d object with the same
      # position returns different hash codes. Instead they are converted into
      # arrays.
      points[ p1.to_a ] = edge.start.position
      points[ p2.to_a ] = edge.end.position
      
      new_edge = target.entities.add_line(p1, p2)
      
      progress.next
    end # for entity in entities
    TT::debug "Flattening took #{progress.elapsed_time(true)}"
    
    # Intersect all the edges so they split each other.
    progress = TT::Progressbar.new()
    Sketchup.status_text = 'Intersecting...'
    tr = Geom::Transformation.new
    target.entities.intersect_with( true, tr, target.entities, tr, true, target.entities.to_a )
    TT::debug "Intersecting took #{progress.elapsed_time(true)}"
    
    # Find small caps and close them.
    if epsilon > 0
      progress = TT::Progressbar.new()
      Sketchup.status_text = 'Closing gaps...'
      TT::debug 'Closing gaps...'
      result = TT::Edges::Gaps.close_all( target.entities, epsilon, true, true )
      TT::debug "#{result} gaps closed in #{progress.elapsed_time(true)}"
    end
    
    # Intersect again to ensure the new edges split the old one.
    progress = TT::Progressbar.new()
    Sketchup.status_text = 'Intersecting...'
    TT::debug 'Intersecting...'
    tmp = target.entities.intersect_with( true, tr, target.entities, tr, true, target.entities.to_a )
    TT::debug "Intersect result type: #{tmp.class}"
    TT::debug "Intersect result size: #{tmp.size}" if tmp.is_a?( Array )
    TT::debug "Intersecting took #{progress.elapsed_time(true)}"
    
    # Repair co-linear edges.
    progress = TT::Progressbar.new()
    Sketchup.status_text = 'Repairing Edges...'
    TT::debug 'Repairing Edges...'
    edges = target.entities.select { |e| e.is_a?(Sketchup::Edge) }
    result = TT::Edges::repair_splits( edges, true )
    TT::debug "#{result} edges repaired in #{progress.elapsed_time(true)}"
    
    # Find Faces
    TT::debug 'Finding faces...'
    edges = target.entities.select { |e| e.is_a?(Sketchup::Edge) }
    progress = TT::Progressbar.new( edges, 'Finding Faces' )
    for edge in edges
      edge.find_faces
      progress.next
    end
    TT::debug "Find faces took #{progress.elapsed_time(true)}"
    
    # Extrude faces up to an appropriate point above. This point is either the
    # lowest or highest point in the set of edges that created the face.
    buildings = 0
    faces = target.entities.select { |e| e.is_a?(Sketchup::Face) }
    progress = TT::Progressbar.new( faces, 'Generating buildings', 2 )
    for face in faces
      # Some times we might get references to deleted entities. This appear to 
      # be related to .pushpull. Doesn't seem to happen when faces are grouped.
      if face.deleted?
        TT::debug 'Deleted Face!'
        next
      end
      
      # User feedback
      progress.next
      
      # Skip small edges
      if face.area < TT.m2(0.5)
        face.erase!
        next
      end
      # <debug>
      #if face.area < TT.m2(5.0)
        #TT::debug sprintf('Area: %.2f²', TT.to_m2(face.area))
        #face.material = 'red'
        #face.back_material = 'red'
      #end
      # </debug>
      
      # Look up the original 3d positions for the vertices in the face. This
      # will give a sample of 3d points that relate to the 2d set of vertices
      # in the face. This set is used to calculate a heigh which the faces is
      # extruded to.
      #
      # Some times plans might have stray edges that drop down to ground level
      # or below. These are ignored.
      points3d = []
      face.vertices.each { |v|
        pt = points[ v.position.to_a ]
        points3d << pt if pt && pt.z > 0
      }
      
      # Determine the height of the building using the set of 3d points that
      # generated it.
      if to_lowest
        min = points3d.min { |a,b| a.z <=> b.z }
        next if min.nil? # Why are we getting nil ?
        height = min.z
      else
        max = points3d.max { |a,b| a.z <=> b.z }
        next if max.nil? # Why are we getting nil ?
        height = max.z
      end
      
      next if height.nil? || height <= 0.0
      
      # (i) Weird gremlings appear when grouping entities that are not in the
      # current context (model.active_entities).
      # In order to work around this, recreate the face in the new group.
      #g = target.entities.add_group( face ) if group # !! DO NOT USE
      if group
        g = target.entities.add_group
        # Recreate face (!) Add to TT_Lib2
        pts = face.outer_loop.vertices
        begin
          f = g.entities.add_face( pts ) 
        rescue ArgumentError => e
          # Very small faces might cause add_face to raise an ArgumentError
          # saying that the points are not planar. These faces are ignored.
          # (A result of this, any ArgumentError failure to add_face will
          # make the face to be ignored)
          TT::debug '=== Recreate Face ==='
          TT::debug e.message
          TT::debug "Area: #{face.area}"
          TT::debug pts
          TT::debug pts.map { |v| v.position }
          next
        end
        # Remove inner loops
        for loop in face.loops
          next if loop.outer?
          hole = g.entities.add_face( loop.vertices )
          hole.erase! #if hole.valid? # (?) hole might refer to a deletec face???
        end
        # Extrude volume
        f = g.entities.find { |e| e.is_a?( Sketchup::Face ) } if f.deleted?
        f.reverse! unless f.normal.samedirection?( Z_AXIS )
        f.pushpull(height)
        face.erase!
      else
        # Extrude volume
        face.reverse! unless face.normal.samedirection?( Z_AXIS )
        face.pushpull(height, true)
      end
      buildings += 1
    end # for entity in target.entities
    TT::debug "Extrude took #{progress.elapsed_time(true)}"
    
    model.commit_operation
    str = "Buildings generated in #{total_progress.elapsed_time(true)}\n(#{buildings} volumes)"
    TT::debug str
    Sketchup.status_text = str
  end
  
  
  ##############################################################################
  
  
  def self.fill_solid_holes
    model = Sketchup.active_model
    selection = model.selection
    # Ensure that the running SketchUp version support solids.
    unless Sketchup::Group.method_defined?( :manifold? )
      UI.messagebox( 'This function require SketchUp 8 or newer.' )
      return false
    end
    # Get all solids in selection.
    solids = selection.select { |entity|
      TT::Instance.is?( entity ) && entity.manifold?
    }
    if solids.empty?
      UI.messagebox( 'Select one of more solids.' )
      return false
    end
    # Close all holes in solids.
    TT::Model.start_operation( 'Fill Solid Holes' )
    for solid in solids
      definition = TT::Instance.definition( solid )
      for entity in definition.entities
        next unless entity.is_a?( Sketchup::Face )
        holes = []
        for loop in entity.loops
          next if loop.outer?
          faces = loop.edges.map { |edge| edge.faces }
          faces.flatten!
          faces -= [entity] # Remove current face.
          holes.concat( faces )
          for face in faces
            holes.concat( face.edges )
          end
        end
        definition.entities.erase_entities( holes )
      end
    end
    # Done! :)
    model.commit_operation
  end
  
  
  ##############################################################################
  
  
  def self.merge_solid_buildings
    model = Sketchup.active_model
    selection = model.selection
    entities = model.active_entities
    # Ensure that the running SketchUp version support solids.
    unless Sketchup::Group.method_defined?( :manifold? )
      UI.messagebox( 'This function require SketchUp 8 or newer.' )
      return false
    end
    # Check if a single instance is selected - then the content is processed.
    if selection.length == 1 && TT::Instance.is?( selection[0] )
      definition = TT::Instance.definition( selection[0] )
      entities = definition.entities
      selection = definition.entities
    end
    # Ensure the selection contain only solids.
    unless selection.all? { |entity|
      TT::Instance.is?( entity ) && entity.manifold?
    }
      UI.messagebox( 'Select a set of solids.' )
      return false
    end
    TT::Model.start_operation( 'Merge Solid Buildings' )
    original_entities = entities.to_a
    # Explode everything.
    for instance in selection.to_a
      instance.explode
    end
    exploded_entities = entities.to_a - original_entities
    # Clean up bottom and internal faces.
    # * Get faces on ground - facing down.
    ground = Z_AXIS.reverse
    ground_faces = exploded_entities.select { |entity|
      entity.is_a?( Sketchup::Face ) &&
      entity.normal.samedirection?( ground ) &&
      entity.vertices.all? { |vertex| vertex.position.z == 0.0 }
    }
    # * Get edges on ground.
    ground_edges = ground_faces.map { |face| face.edges }
    ground_edges.flatten!
    ground_edges.uniq!
    # * Find internal edges.
    internal = []
    for face in ground_faces
      for loop in face.loops
        if loop.outer?
          for edge in loop.edges
            internal << edge if edge.faces.size > 2
          end
        else
          internal.concat( loop.edges )
        end
      end
    end
    # * Find connected vertical faces and edges.
    for edge in internal.dup # Array.to_a returns self !
      # Add connected faces (subtract ground_faces )
      connected = edge.faces - ground_faces
      # Add connected edges (subtract ground_edges )
      edges = edge.vertices.map { |vertex| vertex.edges }
      edges.flatten!
      edges -= ground_edges
      edges << edge
      # Append...
      internal.concat( connected )
    end
    # * Erase faces and edges not belonging to an border edge.
    entities.erase_entities( internal )
    # Done! :)
    model.commit_operation
  end
  
  
  ##############################################################################
  
  
  def self.select_non_solids
    model = Sketchup.active_model
    non_solids = model.selection.select { |entity|
      TT::Instance.is?( entity ) && !entity.manifold?
    }
    model.selection.clear
    model.selection.add( non_solids )
  end
  
  
  ##############################################################################
  
  def self.grid_divide_ui
    Sketchup.active_model.select_tool( GridDivideTool.new )
  end
  
  # @since 2.0.0
  class GridDivideTool
    
    # @since 2.0.0
    def initialize
      @settings = TT::Settings.new( PLUGIN_ID )
      @settings.set_default( :grid_size, 10.m ) 
      
      @bounds = Geom::BoundingBox.new
      @plane = []
      @grid_segments = []
    end
    
    # @since 2.0.0
    def enableVCB?
      true
    end
    
    # @since 2.0.0
    def activate
      calculate_boundingbox()
      calculate_grid()
      update_UI()
      Sketchup.active_model.active_view.invalidate
    end
    
    # @since 2.0.0
    def deactivate( view )
      view.invalidate
    end
    
    # @since 2.0.0
    def resume( view )
      update_UI()
      view.invalidate
    end
    
    # @since 2.0.0
    def onUserText( text, view )
      size = text.to_l
      @settings[ :grid_size ] = size
      calculate_grid()
    rescue ArgumentError
      UI.beep
    ensure
      update_UI()
      view.invalidate
    end
    
    # @since 2.0.0
    def onLButtonDoubleClick( flags, x, y, view )
      intersect_grid_edges()
    end
    
    # @since 2.0.0
    def onReturn( view )
      intersect_grid_edges()
    end
    
    # @since 2.0.0
    def draw( view )
      
      unless @grid_segments.empty?
        view.line_stipple = ''
        view.line_width = 2
        view.drawing_color = [255,0,0]
        view.draw( GL_LINES, @grid_segments )
        
        view.drawing_color = [255,0,0,64]
        view.draw( GL_QUADS, @plane )
      end
      
    end
    
    # @since 2.0.0
    def update_UI
      Sketchup.status_text = "Spesify grid size and press Return or double-click to commit."
      Sketchup.vcb_label = 'Grid Size'
      Sketchup.vcb_value = @settings[ :grid_size ].to_s
    end
    
    # @since 2.0.0
    def calculate_boundingbox
      @bounds.clear
      for e in Sketchup.active_model.active_entities
        next unless e.is_a?( Sketchup::Edge )
        @bounds.add( e.vertices.map! { |v| v.position } )
      end
      min_x = @bounds.corner( TT::BB_LEFT_FRONT_BOTTOM ).x
      max_x = @bounds.corner( TT::BB_RIGHT_FRONT_BOTTOM ).x
      min_y = @bounds.corner( TT::BB_LEFT_FRONT_BOTTOM ).y
      max_y = @bounds.corner( TT::BB_LEFT_BACK_BOTTOM ).y
      @plane = [
        Geom::Point3d.new( min_x, min_y, 0 ),
        Geom::Point3d.new( max_x, min_y, 0 ),
        Geom::Point3d.new( max_x, max_y, 0 ),
        Geom::Point3d.new( min_x, max_y, 0 )
      ]
      @bounds
    end
    
    # @since 2.0.0
    def calculate_grid
      @grid_segments.clear
      
      grid_size = @settings[ :grid_size ]
      
      min_x = @bounds.corner( TT::BB_LEFT_FRONT_BOTTOM ).x
      max_x = @bounds.corner( TT::BB_RIGHT_FRONT_BOTTOM ).x
      min_y = @bounds.corner( TT::BB_LEFT_FRONT_BOTTOM ).y
      max_y = @bounds.corner( TT::BB_LEFT_BACK_BOTTOM ).y
      
      steps = ( (max_x - min_x) / grid_size ).to_i
      ( 0..steps).each { |i|
        x = min_x + (grid_size * i)
        @grid_segments << Geom::Point3d.new( x, min_y, 0 )
        @grid_segments << Geom::Point3d.new( x, max_y, 0 )
      }
      
      steps = ( (max_y - min_y) / grid_size ).to_i
      ( 0..steps).each { |i|
        y = min_y + (grid_size * i)
        @grid_segments << Geom::Point3d.new( min_x, y, 0 )
        @grid_segments << Geom::Point3d.new( max_x, y, 0 )
      }
      @grid_segments
    end
    
    # @since 2.0.0
    def intersect_plane_edges( plane, edges )
      new_edges = []
      edges.each { |e|
        p1 = e.start.position
        p2 = e.end.position
        pt = Geom.intersect_line_plane( e.line, plane )
        next unless pt
        next unless TT::Point3d.between?( p1, p2, pt, false )
        e.explode_curve
        edge = e.parent.entities.add_line( pt, p2 )
        new_edges << edge
      }
      new_edges
    end
    
    # @since 2.0.0
    def intersect_grid_edges
      TT::Model.start_operation('Edge Grid Split')
      
      grid_size = @settings[ :grid_size ]
      
      min_x = @bounds.corner( TT::BB_LEFT_FRONT_BOTTOM ).x
      max_x = @bounds.corner( TT::BB_RIGHT_FRONT_BOTTOM ).x
      min_y = @bounds.corner( TT::BB_LEFT_FRONT_BOTTOM ).y
      max_y = @bounds.corner( TT::BB_LEFT_BACK_BOTTOM ).y
      
      model = Sketchup.active_model
      edges = model.active_entities.select { |e| e.is_a?( Sketchup::Edge ) }
      
      steps = ( (max_x - min_x) / grid_size ).to_i
      steps.times { |i|
        x = min_x + (grid_size * i)
        #model.active_entities.add_cline( [x,0,0], Y_AXIS )
        plane = [ [x,0,0], X_AXIS ]
        new_edges = intersect_plane_edges( plane, edges )
        edges.concat( new_edges )
      }
      
      steps = ( (max_y - min_y) / grid_size ).to_i
      steps.times { |i|
        y = min_y + (grid_size * i)
        #model.active_entities.add_cline( [0,y,0], X_AXIS )
        plane = [ [0,y,0], Y_AXIS ]
        new_edges = intersect_plane_edges( plane, edges )
        edges.concat( new_edges )
      }
      
      model.commit_operation
      model.select_tool( nil )
    end
    
  end # class GridDivideTool

  
  ##############################################################################
  
  
  # Assumes the selected edges is the road width and generates 2:1 road profiles.
  def self.make_road_profile
    model = Sketchup.active_model
    TT::Model.start_operation('Make Road Profile')
    
    model.selection.each { |e|
      next unless e.is_a?(Sketchup::Edge)
      
      pts = []
      pts << e.start.position
      pts << pts.last.offset(Z_AXIS.reverse, e.length)
      pts << pts.last.offset(e.line[1].reverse, e.length * 2)
      model.active_entities.add_face(pts.reverse!)
      
      pts = []
      pts << e.end.position
      pts << pts.last.offset(Z_AXIS.reverse, e.length)
      pts << pts.last.offset(e.line[1], e.length * 2)
      model.active_entities.add_face(pts)
    }
    
    model.commit_operation
  end
  
  
  ##############################################################################
  
  
  # @since 1.3.0
  def self.move_to_z
    Sketchup.active_model.select_tool( MoveToZTool.new )
  end
  
  # @since 1.3.0
  class MoveToZTool
    
    def activate
      @height = @height = average_z( Sketchup.active_model.selection )
      update_ui()
    end
    
    def enableVCB?
      true
    end
    
    def resume( view )
      update_ui()
    end
 
    def onLButtonDown( flags, x, y, view )
      ph = view.pick_helper
      ph.do_pick( x, y )
      picked = ph.best_picked
      view.model.selection.clear
      if picked
        view.model.selection.add( picked )
        @height = average_z( [ picked ] )
      else
        @height = nil
      end
      update_ui()
    end
    
    def onUserText( text, view )
      begin
        height = text.to_l
      rescue
        height = nil
      end
      @height = height
      update_ui
      if height
        vertices = vertices_from_entities( view.model.selection )
        vectors = []
        entities = []
        for vertex in vertices
          old_pt = vertex.position
          new_pt = vertex.position
          new_pt.z = height
          vector = old_pt.vector_to( new_pt )
          if vector.valid?
            vectors << vector
            entities << vertex
          end
        end
        TT::Model.start_operation( 'Move to Z' )
        view.model.active_entities.transform_by_vectors( entities, vectors )
        view.model.commit_operation
      end
    end
    
    def update_ui
      Sketchup.vcb_label = 'Height '
      Sketchup.vcb_value = @height
    end
    
    private
    
    def vertices_from_entities( entities )
      vertices = []
      for entity in entities
        next unless entity.respond_to?( :vertices )
        vertices.concat( entity.vertices )
      end
      vertices.uniq
    end
    
    def average_z( entities )
      total = 0.0
      vertices = vertices_from_entities( entities )
      for vertex in vertices
        total += vertex.position.z
      end
      ( total / vertices.size ).to_l
    end
    
  end # class MoveToZTool
  
  
  ##############################################################################
  
  
  # Flattens the selected entities
  def self.flatten_selection
    model = Sketchup.active_model
    TT::Model.start_operation('Flatten Entities')
    stats = self.flatten_entities(model.selection)
    model.commit_operation
    puts "Flattened #{stats} vertices"
    Sketchup.set_status_text("Flattened #{stats} vertices")
  end
  
  def self.flatten_entities(ents)
    stats = 0
    
    # Collect vertices and explode any curves. Curve causes problems when you
    # transform its vertices.
    # (!) Support CLines
    progress = TT::Progressbar.new( ents, 'Collecting vertices' )
    vertices = []
    ents.each { |e|
      progress.next
      if e.is_a?(Sketchup::ComponentInstance) || e.is_a?(Sketchup::Group)
        stats += self.flatten_entities( TT::Instance.definition(e).entities )
        # Move instance to z0
        p = e.transformation.origin.clone
        p.z = 0
        v = e.transformation.origin.vector_to(p)
        e.transform!( Geom::Transformation.new(v) )
      end
      
      vertices << e if e.is_a?(Sketchup::ConstructionPoint)
      vertices << e.vertices if e.respond_to?(:vertices)
      e.explode_curve if e.is_a?(Sketchup::Edge)
    }
    #puts "> #{vertices.length}"
    vertices.flatten!
    vertices.uniq!
    
    entities = []
    vectors = []
    
    # Move all vertices to Z level 0.
    point = nil
    progress = TT::Progressbar.new( vertices, 'Flatten' )
    vertices.each { |v|
       progress.next
      point = v.position
      next if point.z == 0
      entities << v
      point.z = 0
      vectors << v.position.vector_to(point) 
    }
    if ents.is_a?(Sketchup::Selection)
      ents.model.active_entities.transform_by_vectors(entities, vectors)
    else
      ents.transform_by_vectors(entities, vectors)
    end
    
    return entities.length + stats
  end
  
  
  ##############################################################################
  
  
  # Crops selected groups/components to the selected face.
  # Face must be perpendicular to Z_AXIS.
  def self.crop_selection
    model = Sketchup.active_model
    sel = model.selection
    
    faces = sel.select{|e|e.is_a?(Sketchup::Face)}
    if faces.length != 1
      UI.messagebox('Select only one Face')
      return
    end
    
    face = faces[0]
    unless face.normal.parallel?(Z_AXIS)
      UI.messagebox('Face must lie flat on the ground plane.')
      return
    end
    
    sources = self.get_gc(sel)
    if sources.empty?
      UI.messagebox('Select at least one group or component.')
      return
    end
    
    t = Time.now
    Sketchup.status_text = 'Please wait - Cropping...'
    puts 'Cropping...'
    TT::Model.start_operation('Crop Selection to Boundary')
    for source in sources
      self.crop( source, face, source.transformation )
    end # for
    model.commit_operation
    puts "Done! (#{Time.now - t})"
  end
  
  
  # Make groups/comps uniqe when intersecting.
  # (!) Makes all Groups/Components unique.
  # (!) Ignores faces.
  def self.crop(instance, face, transformation)
    #puts ' '
    #puts '=== CROP ==='
    model = Sketchup.active_model
    
    # Ensure the instance is unique. Remember the original definition
    # so that if there are no changes it can be restored.
    # (!) Or do a pre-test and make uniqe on demand.
    original_definition = TT::Instance.definition(instance)
    instance.make_unique
    definition = TT::Instance.definition(instance)
    
    #
    tr = transformation.inverse
    entities = definition.entities
    boundary = face.vertices.map { |v| v.position }
    
    
    # Cut planes
    cut_planes = []
    for be in face.edges.to_a
      bp1, bp2 = be.vertices.map { |v| v.position }
      plane = [ bp1, be.line[1].axes.x ]
      cut_planes << [bp1, bp2, plane]
    end
    
    
    # Intersect
    splits = 0
    edges = entities.select { |e| e.is_a?(Sketchup::Edge) }
    progress = TT::Progressbar.new( edges, 'Intersecting edges' ) # (!) Inaccurate!
    until edges.empty?
      progress.next
      e = edges.shift
      
      # Get global position
      p1, p2 = e.vertices.map { |v| v.position.transform(transformation) }
      line = [p1, p2]
      
      for cut_plane in cut_planes
        bp1, bp2, plane = cut_plane
      
        # Try and intersect
        intersect = Geom.intersect_line_plane( line, plane )
        next if intersect.nil?
        
        # <debug>
        #model.entities.add_cpoint( p1 )
        #model.entities.add_cpoint( p2 )
        #model.entities.add_cline( p1, p2 )
        # </debug>
        
        # Verify the intersection lies within the edges
        next unless TT::Point3d.between?( p1, p2, intersect )
        next unless TT::Point3d.between?( bp1, bp2, intersect.project_to_plane(face.plane) )
        
        # <debug>
        #e.material = 'orange'
        #model.entities.add_cpoint( intersect )
        # </debug>
        
        # Split edge
        splits += 1
        i = intersect.transform(tr) # Local coords
        new_edge = entities.add_line(i, e.end.position)
        
        # Ensure a new edge really was made.
        next if new_edge.nil?
        next if new_edge == e
        
        # Ensure the new edge is processed.
        edges << new_edge
      end
    end # until
    
    # Crop
    progress = TT::Progressbar.new( entities, 'Detecting edges outside boundary' )
    outside = []
    for e in entities
      progress.next
      if e.is_a?( Sketchup::ConstructionPoint )
        point = e.position.transform(transformation).project_to_plane(face.plane)
        if face.classify_point(point) > 4
          outside << e
        end
      elsif e.is_a?( Sketchup::Edge )
        # Project the edge vertices to the crop face, offsetting the start
        # vertex by a small amount to test if the edge lies over the face.
        pts = e.vertices.map { |v| v.position.transform(transformation) }
        p1, p2 = pts.map! { |pt| pt.project_to_plane(face.plane) }
        v = p1.vector_to(p2)
        next unless v.valid? # (i) Incase of perpendicular edges.
        tp1 = p1.offset( v, 0.1 )
        tp2 = p2.offset( v.reverse!, 0.1 )
        if face.classify_point(tp1) > 4 || face.classify_point(tp2) > 4
          outside << e
        end
      end
    end # for
    Sketchup.status_text = 'Erasing edges...'
    entities.erase_entities(outside)
    
    # Recurse
    gc = self.get_gc(entities)
    for e in gc
      self.crop( e, face, transformation * e.transformation )
    end # for
    
    # Restore definition if no intersects
    #instance.definition = original_definition if splits == 0
    
    nil
  end #def
  
  
  def self.get_gc(entities)
    entities.select{ |e|
      e.is_a?(Sketchup::Group) ||
      e.is_a?(Sketchup::ComponentInstance)
    }
  end
  
  
  ### DEBUG ### ----------------------------------------------------------------
  
  # TT::Plugins::ArchitectTools.reload
  def self.reload
    load __FILE__
  end
  
end # module


#-------------------------------------------------------------------------------
file_loaded( __FILE__ )
#-------------------------------------------------------------------------------