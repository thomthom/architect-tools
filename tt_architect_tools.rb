#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
begin
  require 'TT_Lib2/core.rb'
rescue LoadError => e
  module TT
    if @lib2_update.nil?
      url = 'http://www.thomthom.net/software/sketchup/tt_lib2/errors/not-installed'
      options = {
        :dialog_title => 'TT_Lib² Not Installed',
        :scrollable => false, :resizable => false, :left => 200, :top => 200
      }
      w = UI::WebDialog.new( options )
      w.set_size( 500, 300 )
      w.set_url( "#{url}?plugin=#{File.basename( __FILE__ )}" )
      w.show
      @lib2_update = w
    end
  end
end


#-------------------------------------------------------------------------------

module TT
 module Plugins
  module ArchitectTools
  
  ### CONSTANTS ### ------------------------------------------------------------
  
  # Plugin information
  PLUGIN_ID       = 'TT_ArchitectTools'.freeze
  PLUGIN_NAME     = 'Architect Tools'.freeze
  PLUGIN_VERSION  = '2.0.0'.freeze
  
  # Version information
  RELEASE_DATE    = '03 Jan 13'.freeze
  
  # Resource paths
  PATH_ROOT   = File.dirname( __FILE__ ).freeze
  PATH        = File.join( PATH_ROOT, 'TT_ArchitectTools' ).freeze
  PATH_ICONS  = File.join( PATH, 'Icons' ).freeze

  
  ### LIB FREDO UPDATER ### ----------------------------------------------------
  
  def self.register_plugin_for_LibFredo6
    {
      :name => PLUGIN_NAME,
      :author => 'thomthom',
      :version => PLUGIN_VERSION.to_s,
      :date => RELEASE_DATE,   
      :description => 'Tools for generating buildings, roads, terrain and etc from siteplans.',
      :link_info => 'http://sketchucation.com/forums/viewtopic.php?t=30512'
    }
  end
  
  
  ### EXTENSION ### ------------------------------------------------------------
  
  if defined?( TT::Lib ) && TT::Lib.compatible?('2.7.0', 'Architect Tools')
    loader = File.join( PATH, 'core.rb' )
    ex = SketchupExtension.new( PLUGIN_NAME, loader )
    ex.description = self.register_plugin_for_LibFredo6[:description]
    ex.version = PLUGIN_VERSION
    ex.copyright = 'Thomas Thomassen © 2010-2013'
    ex.creator = 'Thomas Thomassen (thomas@thomthom.net)'
    Sketchup.register_extension( ex, true )
  end
  
  end # module ArchitectTools
 end # module Plugins
end # module TT

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------