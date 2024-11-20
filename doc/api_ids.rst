IDS (``IdsNs::Ids``) API
========================

.. highlight:: c++

..
    Since IdsNs::Ids is not generated, so docs could be generated with autodoc.
    However, this proved a bit tricky, so choosing to document manual instead.

.. cpp:namespace:: IdsNs

.. cpp:class:: Ids

    Abstract base class for all IDS classes. All methods defined here are
    available on all concrete IDS objects.

    .. cpp:function:: std::string serialize(int protocol=DEFAULT_SERIALIZER_PROTOCOL)

        Serialize the contents of this IDS into binary data.

        There are currently two different serialization protocols. The ASCII protocol
        serializes the data though the ASCII backend. This is a simpler human readable
        protocol, but it's also less efficient than the (newer) Flexbuffers protocol.
        The latter is the default and should be preferred.

        The ID of the used serializer protocol is kept in the header of the serialized
        buffer, such that specifying the protocol is not necessary when deserializing.

        :param protocol: Which serialization protocol to use. Available options
            are: 

            - :cpp:expr:`ASCII_SERIALIZER_PROTOCOL`
            - :cpp:expr:`FLEXBUFFERS_SERIALIZER_PROTOCOL`
            - :cpp:expr:`DEFAULT_SERIALIZER_PROTOCOL`
        :returns: Binary representation of this IDS.
        :example:
            .. code-block:: c++

                IdsNs::IDS::pf_active ids;
                // populate the IDS
                // ...
                auto binary_data = ids.serialize();

                // move the binary data around, for example to another process using
                // memory communication, then deserialize

                IdsNs::IDS::pf_active ids2;
                ids2.deserialize(binary_data);

    .. cpp:function:: int deserialize(std::string &data)

        Deserialize the provided binary data into this IDS.

        :param data: data representing a serialized IDS.
        :returns: Status code: ``0`` on success, ``<0`` on failure.
        :example: See :cpp:func:`serialize`.

    .. cpp:function:: void setPulseCtx(int pulseCtx)

        Set the pulse context used for database operations (:cpp:func:`get`,
        :cpp:func:`getSlice`, :cpp:func:`put`, :cpp:func:`putSlice`).

        :param pulseCtx: Pulse context ID obtained through
            :cpp:expr:`IDS::getPulseCtx()`.
        :example: .. literalinclude:: code_samples//dbentry_put

    .. cpp:function:: int get(int occurrence=0)

        Read the contents of the an IDS into memory.

        This method fetches the IDS in its entirety, with all time slices it may
        contain. See :cpp:func:`getSlice` for reading a specific time slice.

        Empty fields within the IDS in the Data Entry are returned with the
        default values indicated in :ref:`Default values`.

        :param occurrence: Which occurrence of the IDS to read.
        :returns: Status code: ``0`` on success, ``<0`` on failure.
        :example: .. literalinclude:: code_samples/dbentry_get

    .. cpp:function:: int getSlice(double inTime, char interpolMode)

        Same as :cpp:func:`int Ids::getSlice(int, double, char)`, but with
        :code:`occurrence = 0`.

    .. cpp:function:: int getSlice(int occurrence, double inTime, char interpolMode)

        Read a single time slice from an IDS in this Database Entry.

        This method fetches the IDS object with all constant/static data filled.
        The dynamic data is interpolated on the requested time slice. This means
        that the size of the time dimension in the returned data is 1.

        :param occurrence: Which occurrence of the IDS to read.
        :param inTime: Requested time slice.
        :param interpolMode: Interpolation method to use, see :ref:`Load a
            single \`time slice\` of an IDS`.
        :returns: Status code: ``0`` on success, ``<0`` on failure.
        :example: .. literalinclude:: code_samples/dbentry_getslice

    .. cpp:function:: int getSample(int occurrence, double tmin, double tmax, const std::vector<double> &dtime, int interpolMode)
        
        Read a range of time slices from an IDS in this Database Entry.

        This method has three different modes, depending on the provided arguments:

        1.  No interpolation. This method is selected when :param:`dtime` is an empty 
            vector (dtime.size() == 0) and:param:`interpolMode` is 0.

            This mode returns an IDS object with all constant/static data filled. The
            dynamic data is retrieved for the provided time range [tmin, tmax].

        2.  Interpolate dynamic data on a uniform time base. This method is selected
            when :param:`dtime` and :param:`interpolMode` are provided.
            :param:`dtime` must be a std::vector<double> of size 1.

            This mode will generate an IDS with a homogeneous time vector ``[tmin, tmin
            + dtime, tmin + 2*dtime, ...`` up to ``tmax``. The chosen interpolation
            method will have no effect on the time vector, but may have an impact on the
            other dynamic values. The returned IDS always has
            ``ids_properties.homogeneous_time = 1``.

        3.  Interpolate dynamic data on an explicit time base. This method is selected
            when :param:`dtime` and :param:`interpolMode` are provided.
            :param:`dtime` must be a std::vector<double> of size larger than 1.

            This mode will generate an IDS with a homogeneous time vector equal to
            :param:`dtime`. :param:`tmin` and :param:`tmax` are ignored in this mode.
            The chosen interpolation method will have no effect on the time vector, but
            may have an impact on the other dynamic values. 
            The returned IDS always has ``ids_properties.homogeneous_time = 1``.

            :param occurrence: Which occurrence of the IDS to read.
            :param tmin: Lower bound of the requested time range
            :param tmax: Upper bound of the requested time range, must be larger than or
                equal to :param:`tmin`
            :param dtime: Interval to use when interpolating, must be a std::vector<double>
                containing an explicit time base to interpolate.
            :param interpolMode: Interpolation method to use. Available options:

                - :const: CLOSEST_INTERP
                - :const: PREVIOUS_INTERP
                - :const: LINEAR_INTERP

            :returns: The loaded IDS.

    .. cpp:function:: int getSample(double tmin, double tmax, const std::vector<double> &dtime, int interpolMode)

        Same as :cpp:func:`int Ids::getSample(int, double, double, std::vector<double>, int)`, but with
        :code:`occurrence = 0`.

    .. cpp:function:: int put(int occurrence=0)

        Write the contents of an IDS to the Database Entry.

        The IDS is written entirely, with all time slices it may contain.

        The IDS object can have none or many empty fields, empty fields are
        ignored and remain empty in the data entry. Some fields are required to
        be filled before calling this method, see :ref:`Mandatory and
        recommended IDS attributes`.

        .. caution::
            The put method deletes any previously existing data within the
            target IDS occurrence in the Database Entry.

        :param occurrence: Which occurrence of the IDS to write to.
        :returns: Status code: ``0`` on success, ``<0`` on failure.
        :example: .. literalinclude:: code_samples/dbentry_put

    .. cpp:function:: int putSlice(int occurrence=0)

        Append a time slice of the provided IDS to the Database Entry.

        Time slices must be appended in strictly increasing time order, since
        the Access Layer is not reordering time arrays. Doing otherwise will
        result in non-monotonic time arrays, which will create confusion and
        make subsequent :cpp:func:`getSlice` commands to fail.

        Although being put progressively time slice by time slice, the final IDS
        must be compliant with the data dictionary. A typical error when
        constructing IDS variables time slice by time slice is to change the
        size of the IDS fields during the time loop, which is not allowed but
        for the children of an array of structure which has time as its
        coordinate.

        The :cpp:func:`putSlice` command is appending data, so does not modify
        previously existing data within the target IDS occurrence in the Data
        Entry.

        It is possible possible to append several time slices to a node of the
        IDS in one :cpp:func:`putSlice` call, however the user must ensure that
        the size of the time dimension of the node remains consistent with the
        size of its timebase.

        :param occurrence: Which occurrence of the IDS to write to.
        :returns: Status code: ``0`` on success, ``<0`` on failure.
        :example: .. literalinclude:: code_samples/dbentry_put_slice



    .. cpp:function:: bool isDefined()

        Verifies if given IDS is 'defined' by checking if its field `ids_properties.homogeneous_time` is set

        :returns: Boolean value :code:`true` if `ids_properties.homogeneous_time` is set, :code:`false` otherwise
        :example:
            .. code-block:: c++

                IdsNs::IDS::core_profiles ids;
                bool isDefined = false;


                isDefined = ids.isDefined(); // false

                ids.ids_properties.homogeneous_time = IDS_TIME_MODE_HETEROGENEOUS; 

                isDefined = ids.isDefined(); // true


    .. cpp:function:: void validate()

        Validate the cooordinate consistency of the ids.

        The method can throw ValidationException. 
        Nothing is thrown if the coordinates are valids.

        :example: .. literalinclude:: code_samples/ids_validate


