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

    .. note::
        **Changed public return contract.** The database operations of this
        class (:cpp:func:`get`, :cpp:func:`getSlice`, :cpp:func:`getSample`,
        :cpp:func:`put`, :cpp:func:`putSlice`, :cpp:func:`deleteAll`,
        :cpp:func:`partialGet`) now
        return a three-way status code: ``0`` success; ``>0`` completed
        with refused paths; ``<0`` failure. A positive status is returned
        when the operation completes after at least one tolerated refusal
        of a multiversion shim; the skipped paths are recorded, see
        :cpp:func:`getSkippedPaths`.

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
        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_READ`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            read completes after at least one tolerated refusal; the
            skipped paths are recorded, see :cpp:func:`getSkippedPaths`.
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
        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_READ`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            read completes after at least one tolerated refusal; the
            skipped paths are recorded, see :cpp:func:`getSkippedPaths`.
        :example: .. literalinclude:: code_samples/dbentry_getslice

    .. cpp:function:: int getSample(int occurrence, double tmin, double tmax, const std::vector<double> &dtime, int interpolMode)
        
        Read a range of time slices from an IDS in this Database Entry.

        This method has three different modes, depending on the provided arguments:

        1.  No interpolation. This method is selected when `dtime` is an empty 
            vector (dtime.size() == 0) and `interpolMode` is 0.

            This mode returns an IDS object with all constant/static data filled. The
            dynamic data is retrieved for the provided time range [tmin, tmax].

        2.  Interpolate dynamic data on a uniform time base. This method is selected
            when `dtime` and `interpolMode` are provided.
            `dtime` must be a std::vector<double> of size 1.

            This mode will generate an IDS with a homogeneous time vector ``[tmin, tmin
            + dtime, tmin + 2*dtime, ...`` up to ``tmax``. The chosen interpolation
            method will have no effect on the time vector, but may have an impact on the
            other dynamic values. The returned IDS always has
            ``ids_properties.homogeneous_time = 1``.

        3.  Interpolate dynamic data on an explicit time base. This method is selected
            when `dtime` and `interpolMode` are provided.
            `dtime` must be a std::vector<double> of size larger than 1.

            This mode will generate an IDS with a homogeneous time vector equal to
            `dtime`. `tmin` and `tmax` are ignored in this mode.
            The chosen interpolation method will have no effect on the time vector, but
            may have an impact on the other dynamic values. 
            The returned IDS always has ``ids_properties.homogeneous_time = 1``.

        :param occurrence: Which occurrence of the IDS to read.
        :param tmin: Lower bound of the requested time range
        :param tmax: Upper bound of the requested time range, must be larger than or
            equal to `tmin`
        :param dtime: Interval to use when interpolating, must be a std::vector<double>
            containing an explicit time base to interpolate.
        :param interpolMode: Interpolation method to use. Available options:

            - :const: CLOSEST_INTERP
            - :const: PREVIOUS_INTERP
            - :const: LINEAR_INTERP

        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_READ`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            read completes after at least one tolerated refusal; the
            skipped paths are recorded, see :cpp:func:`getSkippedPaths`.

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

        .. caution::
            Refused writes are best effort. When the operation returns
            :cpp:expr:`PARTIAL_PUT`, the refused fields were not written,
            and no rollback of the data that was written is performed.

        :param occurrence: Which occurrence of the IDS to write to.
        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_PUT`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            write completes after at least one tolerated refusal, which
            may be a refused write or a refused delete; the skipped
            paths are recorded, see :cpp:func:`getSkippedPaths`.
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

        .. caution::
            Refused writes are best effort. When the operation returns
            :cpp:expr:`PARTIAL_PUT`, the refused fields were not written,
            and no rollback is performed: data already written, including
            any array-of-structures resize, remains on disk.

        :param occurrence: Which occurrence of the IDS to write to.
        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_PUT`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            write completes after at least one tolerated refusal, which
            may be a refused write or a refused delete; the skipped
            paths are recorded, see :cpp:func:`getSkippedPaths`.
        :example: .. literalinclude:: code_samples/dbentry_put_slice

    .. cpp:function:: int deleteAll(int occurrence)

        Delete the entire contents of an IDS occurrence from the Database
        Entry.

        .. caution::
            Refused deletes are best effort. When the operation returns
            :cpp:expr:`PARTIAL_PUT`, the refused fields were not deleted,
            and no rollback of the data already deleted is performed.

        :param occurrence: Which occurrence of the IDS to delete.
        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_PUT`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            delete completes after at least one tolerated refusal; the
            skipped paths are recorded, see :cpp:func:`getSkippedPaths`.

    .. cpp:function:: int deleteAll()

        Delete the entire contents of occurrence ``0`` of this IDS from the
        Database Entry. Equivalent to :cpp:expr:`deleteAll(0)`.

        :returns: As for :cpp:func:`deleteAll(int occurrence)`.

    .. cpp:function:: int partialGet(int occurrence, const std::string &includes, const std::string &excludes, bool debug=false)

        Read the partial contents of an IDS into memory.

        This method fetches partially the IDS according to "includes" and "excludes" queries.

        Returned data have paths included in a set of paths defined by the "includes" 
        queries minus the paths explicitly removed by the "excludes" queries. 
        A IDS field is returned only if its path matches at least one
        include query and does not match any exclude query.

        Empty fields within the IDS in the Data Entry are returned with the
        default values indicated in :ref:`Default values`.

        :param occurrence: Which occurrence of the IDS to read.
        :returns: Status code: ``0`` success; ``>0``
            (:cpp:expr:`PARTIAL_READ`) completed with refused paths;
            ``<0`` failure. The positive status is returned when the
            read completes after at least one tolerated refusal; the
            skipped paths are recorded, see :cpp:func:`getSkippedPaths`.
        :example: .. literalinclude:: code_samples/dbentry_partial_get

    .. cpp:function:: int partialGet(const std::string &includes, const std::string &excludes, bool debug=false)

        Same as :cpp:func:`int Ids::partialGet(int, std::string, std::string)`, but with
        :code:`occurrence = 0`.

    .. cpp:function:: const std::vector< SkippedPath >& getSkippedPaths() const

        Return the skipped paths recorded by the root operation that just
        completed on this IDS.

        A skipped path is one field the traversal left unset because of a
        tolerated refusal: a multiversion shim declined to serve the field
        with a status in the refusal band, and the traversal carried on
        past it instead of failing the whole operation.

        The record is reset at the start of each root operation
        (:cpp:func:`get`, :cpp:func:`getSlice`, :cpp:func:`getSample`,
        :cpp:func:`put`, :cpp:func:`putSlice`, :cpp:func:`deleteAll`), and
        :cpp:func:`partialGet` resets it before configuring its filtering
        plugin, and the :cpp:func:`get` it delegates to also clears it before
        traversal. It therefore never exposes skipped paths from an earlier
        operation, including when plugin setup fails. It is empty when the
        operation completed without any tolerated refusal.

        Refused writes and deletes are best effort: a
        :cpp:expr:`PARTIAL_PUT` means the refused fields were not written,
        and no rollback of the data that was written is performed.

        :returns: The skipped paths recorded by the last root operation.

    .. cpp:function:: size_t getSkippedPathCount() const

        Return the number of skipped paths recorded by the root operation
        that just completed on this IDS. See :cpp:func:`getSkippedPaths`.

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


.. cpp:struct:: SkippedPath

    One field the traversal left unset because of a tolerated refusal,
    recorded with the path, the status code and the refusal message.

    .. cpp:enum:: Operation

        The kind of operation the field was being served for when the
        refusal was recorded.

        .. cpp:enumerator:: Read

            The field was being read.

        .. cpp:enumerator:: Write

            The field was being written.

        .. cpp:enumerator:: Delete

            The field was being deleted.

    .. cpp:var:: Operation operation

        The operation the skipped field was being served for.

    .. cpp:var:: std::string path

        The path of the skipped field, relative to the enclosing
        traversal context. It is intentionally relative: the complete,
        unambiguous Data Dictionary path of the field is preserved in
        :cpp:var:`SkippedPath::message`.

    .. cpp:var:: std::string message

        The refusal message returned by the shim. Because
        :cpp:var:`SkippedPath::path` is intentionally relative to the
        enclosing traversal context, the message preserves the
        unambiguous full Data Dictionary path of the skipped field.

    .. cpp:var:: int code

        The status code returned by the shim for the refusal, within the
        refusal band (``-1000..-1099``).

