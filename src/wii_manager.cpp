#include "wii_manager.h"
#include "godot_cpp/core/object.hpp"
#include "godot_cpp/core/property_info.hpp"

using namespace godot;

void WiiManager::_bind_methods() {
	ClassDB::bind_static_method("WiiManager", D_METHOD("get_available_devices"), &WiiManager::get_available_devices);
	ClassDB::bind_static_method("WiiManager", D_METHOD("get_connected_devices"), &WiiManager::get_connected_devices);

	ADD_SIGNAL(MethodInfo("device_found", PropertyInfo(Variant::STRING, "device_name")));

	ClassDB::bind_method(D_METHOD("connect_to_device", "device"), &WiiManager::connect_to_device);
}

WiiManager::WiiManager() {
}

WiiManager::~WiiManager() {
}

void WiiManager::connect_to_device(String dev) {
}

Array WiiManager::get_available_devices() {
}

Array WiiManager::get_connected_devices() {
}