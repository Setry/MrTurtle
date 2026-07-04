#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include "godot_cpp/variant/array.hpp"
#include "xwiimote.h"
#include <godot_cpp/classes/sprite2d.hpp>
#include <sys/poll.h>

namespace godot {

class GDExample : public Sprite2D {
	GDCLASS(GDExample, Sprite2D)

private:
	bool is_remote = false;
	bool is_board = false;
	xwii_iface *iface = nullptr;
	pollfd fds[1] = {0};

protected:
	static void _bind_methods();
	
	public:
	GDExample();
	~GDExample();
	
	void _process(double delta) override;
	
	void connect_to_device(String dev);
	
	bool get_is_remote();
	bool get_is_board();

	static Array get_devices();
};

}

#endif