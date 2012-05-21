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
  timer = UI.start_timer( 0, false ) {
    UI.stop_timer( timer )
    filename = File.basename( __FILE__ )
    message = "#{filename} require TT_Lib² to be installed.\n"
    message << "\n"
    message << "Would you like to open a webpage where you can download TT_Lib²?"
    result = UI.messagebox( message, MB_YESNO )
    if result == 6 # YES
      UI.openURL( 'http://www.thomthom.net/software/tt_lib2/' )
    end
  }
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
  RELEASE_DATE    = '21 May 12'.freeze
  
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
      :link_info => 'http://forums.sketchucation.com/viewtopic.php?f=323&t=30512'
    }
  end
  
  
  ### EXTENSION ### ------------------------------------------------------------
  
  if defined?( TT::Lib ) && TT::Lib.compatible?('2.7.0', 'Architect Tools')
    loader = File.join( PATH, 'core.rb' )
    ex = SketchupExtension.new( PLUGIN_NAME, loader )
    ex.description = self.register_plugin_for_LibFredo6[:description]
    ex.version = PLUGIN_VERSION
    ex.copyright = 'Thomas Thomassen © 2010-2012'
    ex.creator = 'Thomas Thomassen (thomas@thomthom.net)'
    Sketchup.register_extension( ex, true )
  end
  
  end # module ArchitectTools
 end # module Plugins
end # module TT

#-------------------------------------------------------------------------------
file_loaded( __FILE__ )
#-------------------------------------------------------------------------------