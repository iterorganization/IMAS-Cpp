Plugins API
===========

.. cpp:function:: al_status_t al_register_plugin(const char *plugin_name)

    Register an Access Layer plugin.

    Plugins extend the functionality of the Access Layer. Plugins must be
    registered before they can be activated with :func:`al_bind_plugin()`.

    The environment variable ``IMAS_AL_PLUGINS`` indicates the folder where the
    compiled plugin(s) are located. If this environment variable is unset, or no
    shared library with the name ``<plugin_name>_plugin.so`` can be found, an
    exception status is returned.

    :param plugin_name: Name of the plugin to register

    .. rubric:: Example

    .. code-block:: cpp

        al_status_t status = al_register_plugin("debug");
        if (status.code != 0) {
            std::cerr << status.message << std::endl;
            exit(1);
        }


.. cpp:function:: al_status_t al_unregister_plugin(const char *plugin_name)

    Unregister a previously registered Access Layer plugin.

    :param plugin_name: Name of the plugin to unregister


.. cpp:function:: al_status_t al_bind_plugin(const char* fieldPath, const char* pluginName)

    Activate an Access Layer plugin.

    Plugins are inactive until activated with bind_plugin. After activation,
    plugins can modify the data on the path(s) they are activated on during a
    :expr:`IdsNs::Ids.put()`, :expr:`IdsNs::Ids.put_slice()`,
    :expr:`IdsNs::Ids.get()` or :expr:`IdsNs::Ids.get_slice()`.

    :param fieldPath: The path that the plugin is allowed to operate on:
        ``<ids_name>:<occurrence>/<path_in_ids>``.
    :param pluginName: Name of the plugin. The plugin must have been registered
        with a call to :func:`al_register_plugin()`.

    .. rubric:: Example
    
    .. code-block:: cpp

        al_status_t status = al_register_plugin("debug");
        if (status.code != 0) {
            std::cerr << status.message << std::endl;
            exit(1);
        }
        al_bind_plugin("magnetics:0/ids_properties/version_put/access_layer", "debug");
        al_bind_plugin("magnetics:0/flux_loop", "debug");


.. cpp:function:: al_status_t al_unbind_plugin(const char* fieldPath, const char* pluginName)

    Unbind a plugin on a previously bound path.

    Arguments are the same as for :func:`al_bind_plugin()`.


.. cpp:function:: al_status_t al_setvalue_parameter_plugin(const char* parameter_name, int datatype, int dim, int *size, void *data, const char* pluginName)

    Set a plugin parameter value.

    See the documentation of your specific plugin for more details.

    :param parameter_name: Name of the parameter to set
    :param datatype: Type of data (one of :expr:`CHAR_DATA`,
        :expr:`INTEGER_DATA`, :expr:`DOUBLE_DATA` or :expr:`COMPLEX_DATA`)
    :param dim: Dimension of the data
    :param size: Pointer to array specifying the shape of the array (must have
        ``dim`` elements)
    :param data: Pointer to the data
    :param pluginName: Name of the plugin, the plugin must be registered (see
        :func:`al_register_plugin()`)


.. cpp:function:: al_status_t al_setvalue_int_scalar_parameter_plugin(const char* parameter_name, int parameter_value, const char* pluginName)

    Convenience method to set a plugin parameter value to a scalar integer.

    See the documentation of your specific plugin for more details.

    :param parameter_name: Name of the parameter to set
    :param parameter_value: Value to set the parameter to
    :param pluginName: Name of the plugin, the plugin must be registered (see
        :func:`al_register_plugin()`)


.. cpp:function:: al_status_t al_setvalue_double_scalar_parameter_plugin(const char* parameter_name, double parameter_value, const char* pluginName)

    Convenience method to set a plugin parameter value to a scalar double.

    See the documentation of your specific plugin for more details.

    :param parameter_name: Name of the parameter to set
    :param parameter_value: Value to set the parameter to
    :param pluginName: Name of the plugin, the plugin must be registered (see
        :func:`al_register_plugin()`)
