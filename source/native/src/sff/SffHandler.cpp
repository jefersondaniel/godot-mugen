#include "SffHandler.hpp"
#include "plugins/SffV1/SffV1.hpp"
#include "plugins/SffV2/SffV2.hpp"
#include <Godot.hpp>

using namespace std;

SffHandler * select_sff_plugin_reader(String filename) {
  #ifdef ADD_SFF_PLUGIN
  #undef ADD_SFF_PLUGIN
  #endif

  #define ADD_SFF_PLUGIN(SFF_PLUGIN_CLASS, SFF_PLUGIN_DESCRIPTION) \
    { SFF_PLUGIN_CLASS * pointer = new SFF_PLUGIN_CLASS; \
      if(pointer->read(filename) == true) return pointer; \
      else delete pointer; }

    ADD_SFF_PLUGIN(SffV2,"Sff v 2.0 - (Mugen 1.0 RC and following)")
    ADD_SFF_PLUGIN(SffV1,"Sff v 1.0 - (All Mugen versions including olders)")

  #undef ADD_SFF_PLUGIN

      return NULL;
}
