#ifndef SFFV2_H
#define SFFV2_H

#include <Godot.hpp>

class SffV2 : public SffHandler {
  public:
    bool read(String filename);
};

#endif
