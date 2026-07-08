#include "register_types.h"

#include "godot_cpp/core/class_db.hpp"
#include "wii_device.h"
#include "wii_manager.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_gdwiidev(ModuleInitializationLevel p_level) {
	if(p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	GDREGISTER_RUNTIME_CLASS(WiiManager);
	GDREGISTER_RUNTIME_CLASS(WiiDevice);
}

void uninitialize_gdwiidev(ModuleInitializationLevel p_level) {
	if(p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT gdwiidev_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_gdwiidev);
	init_obj.register_terminator(uninitialize_gdwiidev);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

	return init_obj.init();
}
}