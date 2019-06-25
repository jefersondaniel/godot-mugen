#ifndef SFFV1_HPP
#define SFFV1_HPP

#include <Godot.hpp>

using namespace std;

class SffV1 : public SffHandler {
  public:
    bool read(String filename);
};

#endif
