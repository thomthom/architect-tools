#-----------------------------------------------------------------------------
# Compatible: SketchUp 7 (PC)
#             (other versions untested)
#-----------------------------------------------------------------------------
#
# CHANGELOG
# 1.2.0 - 14.01.2011
#		 * Generate Buildings improvements.
#
# 1.1.0 - 30.09.2010
#		 * Grid Divide.
#
# 1.0.2 - 01.09.2010
#		 * Initial release.
#
#-----------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-----------------------------------------------------------------------------

require 'sketchup.rb'
require 'TT_Lib2/core.rb'

TT::Lib.compatible?('2.5.0', 'TT Plan Tools')

#-----------------------------------------------------------------------------

module TT::Plugins::PlanTools
  
  ### CONSTANTS ### --------------------------------------------------------
  
  VERSION = '1.2.0'.freeze
  PREF_KEY = 'TT_Plan'.freeze
  
  
  ### MODULE VARIABLES ### -------------------------------------------------
  
  # Preference
  @settings = TT::Settings.new(PREF_KEY)
  @settings.set_default( :gb_filter, '5003,5014,5081' ) # 5001,5003,5014,5041,5080,5081,5082
  @settings.set_default( :gb_low_pt, 'Lowest Point Above' )
  @settings.set_default( :gb_epsilon, 100.mm )
  @settings.set_default( :gb_group,   'No' )
  
  
  ### MENU & TOOLBARS ### --------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    m = TT.menu('Plugins').add_submenu('Plan Tools')
    m.add_item('Generate Buildings')            { self.generate_buildings }
    m.add_separator
    m.add_item('Make 2:1 Road Profile')         { self.make_road_profile }
    m.add_separator
    m.add_item('Flatten Selection')             { self.flatten_selection }
    m.add_item('Crop Selection to Boundary')    { self.crop_selection }
    m.add_separator
    m.add_item('Grid Divide')                   { self.grid_divide_ui }
  end
  
  
  ### MAIN SCRIPT ### ------------------------------------------------------
  
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
  
  
  def self.grid_divide_ui
    options = {
      :title => 'Grid Divide',
      :pref_key => PREF_KEY,
      :modal => true,
      :accept_label => 'Divide'
    }
    i = TT::GUI::Inputbox.new(options)
    i.add_control( {
      :key   => :size,
      :label => 'Grid Size',
      :value => 10.m
    } )
    i.prompt { |results|
      if results
        self.grid_divide( results[:size] )
      end
    }
  end
  
  def self.grid_divide(grid_size = 10.m)
    model = Sketchup.active_model
    sel = model.selection
    
    bb = TT::Selection.bounds
    edges = sel.select { |e| e.is_a?( Sketchup::Edge ) }
    
    return if edges.empty?
    
    TT::Model.start_operation('Grid Split')
    
    min_x = bb.corner( TT::BB_LEFT_FRONT_BOTTOM ).x
    max_x = bb.corner( TT::BB_RIGHT_FRONT_BOTTOM ).x
    steps = ( (max_x - min_x) / grid_size ).to_i
    steps.times { |i|
      x = min_x + (grid_size * i)
      #model.active_entities.add_cline( [x,0,0], Y_AXIS )
      plane = [ [x,0,0], X_AXIS ]
      new_edges = self.intersect_plane_edges(plane, edges)
      edges.concat( new_edges )
    }
    
    min_y = bb.corner( TT::BB_LEFT_FRONT_BOTTOM ).y
    max_y = bb.corner( TT::BB_LEFT_BACK_BOTTOM ).y
    steps = ( (max_y - min_y) / grid_size ).to_i
    steps.times { |i|
      y = min_y + (grid_size * i)
      #model.active_entities.add_cline( [0,y,0], X_AXIS )
      plane = [ [0,y,0], Y_AXIS ]
      new_edges = self.intersect_plane_edges(plane, edges)
      edges.concat( new_edges )
    }
    
    model.commit_operation
  end
  
  def self.intersect_plane_edges(plane, edges)
    new_edges = []
    edges.each { |e|
      p1 = e.start.position
      p2 = e.end.position
      pt = Geom.intersect_line_plane( e.line, plane )
      next unless TT::Point3d.between?( p1, p2, pt, false )
      #e.parent.entities.add_cpoint( pt )
      e.explode_curve
      edge = e.parent.entities.add_line( pt, p2 )
      new_edges << edge
    }
    new_edges
  end
  
  
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
    until edges.empty?
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
    outside = []
    for e in entities
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
        tp1 = p1.offset( v, 0.1 )
        tp2 = p2.offset( v.reverse!, 0.1 )
        if face.classify_point(tp1) > 4 || face.classify_point(tp2) > 4
          outside << e
        end
      end
    end # for
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
  
  
  ### DEBUG ### ------------------------------------------------------------  
  
  def self.reload
    load __FILE__
  end
  
end # module

#-----------------------------------------------------------------------------
file_loaded( __FILE__ )
#-----------------------------------------------------------------------------