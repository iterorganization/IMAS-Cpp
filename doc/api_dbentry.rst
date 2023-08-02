Data entry (``IdsNs::IDS``) API
===============================

..
    Since IdsNs::IDS is generated, no docs can be generated. Manually document
    class and members.

.. cpp:namespace:: IdsNs

.. cpp:class:: IDS

    Class modeling Data Entries.

    Existing Data entries can be opened (see :cpp:func:`open` and
    :cpp:func:`openEnv`) and new ones created (see :cpp:func:`open` and
    :cpp:func:`createEnv`).

    All available IDSs are member classes in the scope of this class, e.g.
    :cpp:expr:`IdsNs::IDS::core_profiles`.

    .. cpp:function:: IDS()

        Constructor to use with :ref:`Data entry URIs`. Use :cpp:func:`open`
        afterwards to open or create the Data Entry.

    .. cpp:function:: IDS(int shot, int run, int refShot, int refRun)

        Constructor when not using :ref:`Data entry URIs`. Use
        :cpp:func:`openEnv` or :cpp:func:`createEnv` afterwards to open or
        create the Data Entry.

        :param shot: Shot number.
        :param run: Run number.
        :param refShot: Legacy parameter, value is ignored.
        :param refRun: Legacy parameter, value is ignored.

    .. cpp:function:: int open(const char *uri, int mode)

        Open or create the Data Entry at the provided URI.

        :param uri: :ref:`Data entry URI <Data entry URIs>`
        :param mode: One of :cpp:expr:`OPEN_PULSE`,
            :cpp:expr:`FORCE_OPEN_PULSE`, :cpp:expr:`CREATE_PULSE` or
            :cpp:expr:`FORCE_CREATE_PULSE`.
        :returns: Status code: ``0`` on success, ``<0`` on failure.
        :example: See :ref:`Open an existing IMAS Database Entry`.

    .. cpp:function:: int openEnv(const char *user, const char *tokamak, const char *version, const char *option)

        Open the Data Entry defined by ``shot``, ``run`` (see
        :cpp:func:`IDS::IDS() <void IDS::IDS(int,int,int,int)>`)
        and the provided parameters.

        :param user: User name
        :param tokamak: Tokamak name, also known as Database name
        :param version: Major version of the data dictionary, e.g. ``"3"``
        :param option: Options to pass to the backend
        :returns: Status code: ``0`` on success, ``<0`` on failure
        :example: See :ref:`Open an existing IMAS Database Entry`.

    .. cpp:function:: int createEnv(const char *user, const char *tokamak, const char *version, const char *option)

        Create the Data Entry defined by ``shot``, ``run`` (see
        :cpp:func:`IDS::IDS() <void IDS::IDS(int,int,int,int)>`)
        and the provided parameters.

        :param user: User name
        :param tokamak: Tokamak name, also known as Database name
        :param version: Major version of the data dictionary, e.g. ``"3"``
        :param option: Options to pass to the backend
        :returns: Status code: ``0`` on success, ``<0`` on failure

    .. cpp:function:: void setBackend(BACKEND inBackend)

        Use the specified backend instead of the default one. Must be set before
        a call to :cpp:func:`openEnv` or :cpp:func:`createEnv`.

        :param inBackend: The backend to use
    
    .. cpp:function:: int getPulseCtx()

        Get the pulse context ID opened/created by this Data Entry.

        :returns: Pulse context ID.

        .. seealso::
            :cpp:expr:`Ids::setPulseCtx()`
