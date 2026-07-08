#ifndef _WII_DEVICE_H_
#define _WII_DEVICE_H_

#include "gdextension_interface.h"
#include "godot_cpp/classes/ref_counted.hpp"
#include "godot_cpp/variant/array.hpp"
#include "xwiimote.h"
#include <sys/poll.h>
#include <vector>

namespace godot {

class WiiDevice: public RefCounted {
	GDCLASS(WiiDevice, RefCounted)

  public:
	enum WiiDeviceInterface {
		INTERFACE_CORE,
		INTERFACE_ACCEL,
		INTERFACE_IR,
		INTERFACE_MOTION_PLUS,
		INTERFACE_NUNCHUK,
		INTERFACE_CLASSIC_CONTROLLER,
		INTERFACE_BALANCE_BOARD,
		INTERFACE_PRO_CONTROLLER,
		INTERFACE_DRUMS,
		INTERFACE_GUITAR,
	};

  private:
	std::vector<WiiDeviceInterface> available_interfaces;
	xwii_iface *iface = nullptr;
	pollfd fds[1] = {0};

  protected:
	static void _bind_methods();

	void poll();

  public:
	WiiDevice();
	~WiiDevice();
};

}

#endif