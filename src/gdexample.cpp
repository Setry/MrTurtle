#include "gdexample.h"
#include "godot_cpp/classes/wrapped.hpp"
#include "godot_cpp/core/object.hpp"
#include "godot_cpp/variant/string.hpp"
#include "godot_cpp/variant/utility_functions.hpp"
#include "godot_cpp/variant/variant.hpp"
#include <cstdlib>
#include <godot_cpp/core/class_db.hpp>
#include <dlfcn.h>
#include <poll.h>

#include <xwiimote.h>

using namespace godot;

static char *get_dev(int num)
{
	struct xwii_monitor *mon;
	char *ent;
	int i = 0;

	mon = xwii_monitor_new(false, false);
	if (!mon) {
		UtilityFunctions::print("Cannot create monitor");
		return NULL;
	}

	while ((ent = xwii_monitor_poll(mon))) {
		if (++i == num)
			break;
		free(ent);
	}

	xwii_monitor_unref(mon);

	if (!ent)
		UtilityFunctions::print("Cannot find device with number: ", num);

	return ent;
}

void GDExample::_bind_methods() {
	ADD_SIGNAL(MethodInfo("board_received", PropertyInfo(Variant::VECTOR4I, "values")));
	ADD_SIGNAL(MethodInfo("ir_received", PropertyInfo(Variant::ARRAY, "points")));
	ClassDB::bind_method(D_METHOD("get_is_remote"), &GDExample::get_is_remote);
	ClassDB::bind_method(D_METHOD("get_is_board"), &GDExample::get_is_board);
	ClassDB::bind_method(D_METHOD("connect_to_device", "device"), &GDExample::connect_to_device);
	ClassDB::bind_static_method("GDExample", D_METHOD("get_devices"), &GDExample::get_devices);
}

GDExample::GDExample() {

	/*if(!dlopen("libxwiimote.so.2.0.0", RTLD_NOW | RTLD_GLOBAL)) {
		UtilityFunctions::print("Everything failed, sad :(");
	}

	UtilityFunctions::print("It didn't fail I guess?");*/

	//void *iface = dlsym(nullptr, "xwii_iface_new");
	//UtilityFunctions::print(iface != nullptr ? "NOT NULL" :"NULL");
}

GDExample::~GDExample() {
	xwii_iface_unref(iface);
}

void GDExample::_process(double delta) {
	if(iface == nullptr) return;

	int ret = poll(fds, 1, 0);
	if(ret == 0) {
		// UtilityFunctions::print("No events");
		return;
	}

	if(ret < 0) {
		UtilityFunctions::print("Poll Error");
		return;
	}

	struct xwii_event event;
	ret = xwii_iface_dispatch(iface, &event, sizeof(event));
	if(ret == -EAGAIN) {
		return;
	}
	
	if(ret) {
		UtilityFunctions::print("Dispatch error");
		return;
	}

	switch(event.type) {
		case XWII_EVENT_BALANCE_BOARD:
		{
			if(!is_board) return;
			
			emit_signal("board_received", Vector4i(event.v.abs[0].x, event.v.abs[1].x, event.v.abs[2].x, event.v.abs[3].x));
			break;
		}
		case XWII_EVENT_IR:
		{
			if(!is_remote) return;

			PackedVector2Array arr;

			for(int i = 0; i < 4; i++) {
				if(!xwii_event_ir_is_valid(&event.v.abs[i])) continue;

				double x = (double) event.v.abs[i].x / 1024;
				double y = (double) event.v.abs[i].y / 768;
				arr.append(Vector2(x, y));
			}

			emit_signal("ir_received", arr);
			break;
		}
	}

	//time_passed += delta;
	//Vector2 new_position = Vector2(10.0 + (10.0 * sin(time_passed * 2.0)), 10.0 + (10.0 * cos(time_passed * 1.5)));
	//set_position(new_position);
}

bool GDExample::get_is_remote() {
	return is_remote;
}

bool GDExample::get_is_board() {
	return is_board;
}

void GDExample::connect_to_device(String dev) {
	int ret = xwii_iface_new(&iface, dev.ascii());
	if(ret) {
		UtilityFunctions::print("error", ret);
		UtilityFunctions::print("oopsie, it died");
	}else {
		UtilityFunctions::print("Yay!");
	}

	ret = xwii_iface_open(iface, xwii_iface_available(iface) | XWII_IFACE_WRITABLE);
	if(ret) {
		UtilityFunctions::print("open failed");
	}

	if(xwii_iface_watch(iface, true)) {
		UtilityFunctions::print("watch failed");
	}

	fds[0].fd = xwii_iface_get_fd(iface);
	fds[0].events = POLLIN;

	if(xwii_iface_available(iface) & XWII_IFACE_IR) {
		is_remote = true;
	}

	if(xwii_iface_available(iface) & XWII_IFACE_BALANCE_BOARD) {
		is_board = true;
	}

	UtilityFunctions::print("Do stuff!", fds[0].fd);
}

Array GDExample::get_devices() {
	struct xwii_monitor *mon;
	char *ent;

	mon = xwii_monitor_new(false, false);
	if (!mon) {
		UtilityFunctions::print("Cannot create monitor");
		return Array();
	}

	Array arr;
	while ((ent = xwii_monitor_poll(mon))) {
		arr.push_back(String(ent));
		std::free(ent);
	}

	xwii_monitor_unref(mon);
	return arr;
}
