#ifndef SFF_HANDLER_HPP
#define SFF_HANDLER_HPP

#include <Godot.hpp>
#include <vector>
#include "SffStructs.hpp"

using namespace std;

class SffHandler {
  public:
    vector<SffData> sffdata;
    vector<SffPal> paldata;
  public:
    virtual bool read(String filename) = 0;
};

SffHandler * select_sff_plugin_reader(String filename);

#endif
