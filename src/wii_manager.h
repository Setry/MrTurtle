#ifndef _WII_MANAGER_H_
#define _WII_MANAGER_H_

#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/variant/array.hpp"
#include "wii_device.h"
#include <vector>

namespace godot {

class WiiManager: public RefCounted {
	GDCLASS(WiiManager, RefCounted)

  private:
	std::vector<WiiDevice> devices;

  protected:
	static void
	_bind_methods();

  public:
	WiiManager();
	~WiiManager();

	void connect_to_device(String dev);

	static Array get_available_devices();
	static Array get_connected_devices();
};

}

#endif