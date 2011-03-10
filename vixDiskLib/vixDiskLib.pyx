
from exceptions import Exception
from common cimport *
import logging

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

import numpy as np
# "cimport" is used to import special compile-time information
# about the numpy module (this is stored in a file numpy.pxd which is
# currently part of the Cython distribution).
cimport numpy as np

class VixDiskLibError(Exception):
    pass

cdef extern from "Python.h":
    ctypedef int Py_intptr_t
    void Py_INCREF(object)
    void Py_DECREF(object)
    object PyCObject_FromVoidPtrAndDesc( void* cobj, void* desc, void (*destr)(void *, void *))

cdef extern from "numpy/arrayobject.h":
    cdef object PyArray_SimpleNewFromData(int nd,
                                          np.npy_intp *dims,
                                          int typenum,
                                          void *data)
    cdef object PyArray_ZEROS(int nd,
                              np.npy_intp *dims,
                              int typenum,
                              int fortran)
    cdef object PyArray_SimpleNew(int nd,
                                  np.npy_intp *dims,
                                  int typenum)
    cdef object PyArray_Arange(double start,
                               double stop,
                               double step,
                               int typenum)


cdef extern from "vixDiskLib.h":
    ctypedef uint64 VixError
    ctypedef uint64 VixDiskLibSectorType

    cdef uint32 VIXDISKLIB_SECTOR_SIZE = 512
    ctypedef enum VIXDISKLIB_OPEN_FLAGS:
        VIXDISKLIB_FLAG_OPEN_UNBUFFERED  = 1, # disable host disk caching
        VIXDISKLIB_FLAG_OPEN_SINGLE_LINK = 2, # don't open parent disk(s)
        VIXDISKLIB_FLAG_OPEN_READ_ONLY   = 4 # open read-only

    # * The error codes are returned by all public VIX routines.
    cdef enum:
        VIX_OK                                       = 0,
     
        # General errors 
        VIX_E_FAIL                                   = 1,
        VIX_E_OUT_OF_MEMORY                          = 2,
        VIX_E_INVALID_ARG                            = 3,
        VIX_E_FILE_NOT_FOUND                         = 4,
        VIX_E_OBJECT_IS_BUSY                         = 5,
        VIX_E_NOT_SUPPORTED                          = 6,
        VIX_E_FILE_ERROR                             = 7,
        VIX_E_DISK_FULL                              = 8,
        VIX_E_INCORRECT_FILE_TYPE                    = 9,
        VIX_E_CANCELLED                              = 10,
        VIX_E_FILE_READ_ONLY                         = 11,
        VIX_E_FILE_ALREADY_EXISTS                    = 12,
        VIX_E_FILE_ACCESS_ERROR                      = 13,
        VIX_E_REQUIRES_LARGE_FILES                   = 14,
        VIX_E_FILE_ALREADY_LOCKED                    = 15,
        VIX_E_VMDB                                   = 16,
        VIX_E_NOT_SUPPORTED_ON_REMOTE_OBJECT         = 20,
        VIX_E_FILE_TOO_BIG                           = 21,
        VIX_E_FILE_NAME_INVALID                      = 22,
        VIX_E_ALREADY_EXISTS                         = 23,
        VIX_E_BUFFER_TOOSMALL                        = 24,
        VIX_E_OBJECT_NOT_FOUND                       = 25,
        VIX_E_HOST_NOT_CONNECTED                     = 26,
        VIX_E_INVALID_UTF8_STRING                    = 27,
        VIX_E_OPERATION_ALREADY_IN_PROGRESS          = 31,
        VIX_E_UNFINISHED_JOB                         = 29,
        VIX_E_NEED_KEY                               = 30,
        VIX_E_LICENSE                                = 32,
        VIX_E_VM_HOST_DISCONNECTED                   = 34,
        VIX_E_AUTHENTICATION_FAIL                    = 35,
    
        # Handle Errors 
        VIX_E_INVALID_HANDLE                         = 1000,
        VIX_E_NOT_SUPPORTED_ON_HANDLE_TYPE           = 1001,
        VIX_E_TOO_MANY_HANDLES                       = 1002,
    
        # XML errors 
        VIX_E_NOT_FOUND                              = 2000,
        VIX_E_TYPE_MISMATCH                          = 2001,
        VIX_E_INVALID_XML                            = 2002,
    
        # VM Control Errors 
        VIX_E_TIMEOUT_WAITING_FOR_TOOLS              = 3000,
        VIX_E_UNRECOGNIZED_COMMAND                   = 3001,
        VIX_E_OP_NOT_SUPPORTED_ON_GUEST              = 3003,
        VIX_E_PROGRAM_NOT_STARTED                    = 3004,
        VIX_E_CANNOT_START_READ_ONLY_VM              = 3005,
        VIX_E_VM_NOT_RUNNING                         = 3006,
        VIX_E_VM_IS_RUNNING                          = 3007,
        VIX_E_CANNOT_CONNECT_TO_VM                   = 3008,
        VIX_E_POWEROP_SCRIPTS_NOT_AVAILABLE          = 3009,
        VIX_E_NO_GUEST_OS_INSTALLED                  = 3010,
        VIX_E_VM_INSUFFICIENT_HOST_MEMORY            = 3011,
        VIX_E_SUSPEND_ERROR                          = 3012,
        VIX_E_VM_NOT_ENOUGH_CPUS                     = 3013,
        VIX_E_HOST_USER_PERMISSIONS                  = 3014,
        VIX_E_GUEST_USER_PERMISSIONS                 = 3015,
        VIX_E_TOOLS_NOT_RUNNING                      = 3016,
        VIX_E_GUEST_OPERATIONS_PROHIBITED            = 3017,
        VIX_E_ANON_GUEST_OPERATIONS_PROHIBITED       = 3018,
        VIX_E_ROOT_GUEST_OPERATIONS_PROHIBITED       = 3019,
        VIX_E_MISSING_ANON_GUEST_ACCOUNT             = 3023,
        VIX_E_CANNOT_AUTHENTICATE_WITH_GUEST         = 3024,
        VIX_E_UNRECOGNIZED_COMMAND_IN_GUEST          = 3025,
        VIX_E_CONSOLE_GUEST_OPERATIONS_PROHIBITED    = 3026,
        VIX_E_MUST_BE_CONSOLE_USER                   = 3027,
        VIX_E_VMX_MSG_DIALOG_AND_NO_UI               = 3028,
        VIX_E_NOT_ALLOWED_DURING_VM_RECORDING        = 3029,
        VIX_E_NOT_ALLOWED_DURING_VM_REPLAY           = 3030,
        VIX_E_OPERATION_NOT_ALLOWED_FOR_LOGIN_TYPE   = 3031,
        VIX_E_LOGIN_TYPE_NOT_SUPPORTED               = 3032,
        VIX_E_EMPTY_PASSWORD_NOT_ALLOWED_IN_GUEST    = 3033,
        VIX_E_INTERACTIVE_SESSION_NOT_PRESENT        = 3034,
        VIX_E_INTERACTIVE_SESSION_USER_MISMATCH      = 3035,
        VIX_E_UNABLE_TO_REPLAY_VM                    = 3039,
        VIX_E_CANNOT_POWER_ON_VM                     = 3041,
        VIX_E_NO_DISPLAY_SERVER                      = 3043,
        VIX_E_VM_NOT_RECORDING                       = 3044,
        VIX_E_VM_NOT_REPLAYING                       = 3045,
    
        # VM Errors  
        VIX_E_VM_NOT_FOUND                           = 4000,
        VIX_E_NOT_SUPPORTED_FOR_VM_VERSION           = 4001,
        VIX_E_CANNOT_READ_VM_CONFIG                  = 4002,
        VIX_E_TEMPLATE_VM                            = 4003,
        VIX_E_VM_ALREADY_LOADED                      = 4004,
        VIX_E_VM_ALREADY_UP_TO_DATE                  = 4006,
   
        # Property Errors 
        VIX_E_UNRECOGNIZED_PROPERTY                  = 6000,
        VIX_E_INVALID_PROPERTY_VALUE                 = 6001,
        VIX_E_READ_ONLY_PROPERTY                     = 6002,
        VIX_E_MISSING_REQUIRED_PROPERTY              = 6003,
        VIX_E_INVALID_SERIALIZED_DATA                = 6004,
    
        # Completion Errors 
        VIX_E_BAD_VM_INDEX                           = 8000,
    
        # Message errors 
        VIX_E_INVALID_MESSAGE_HEADER                 = 10000,
        VIX_E_INVALID_MESSAGE_BODY                   = 10001,
    
        # Snapshot errors 
        VIX_E_SNAPSHOT_INVAL                         = 13000,
        VIX_E_SNAPSHOT_DUMPER                        = 13001,
        VIX_E_SNAPSHOT_DISKLIB                       = 13002,
        VIX_E_SNAPSHOT_NOTFOUND                      = 13003,
        VIX_E_SNAPSHOT_EXISTS                        = 13004,
        VIX_E_SNAPSHOT_VERSION                       = 13005,
        VIX_E_SNAPSHOT_NOPERM                        = 13006,
        VIX_E_SNAPSHOT_CONFIG                        = 13007,
        VIX_E_SNAPSHOT_NOCHANGE                      = 13008,
        VIX_E_SNAPSHOT_CHECKPOINT                    = 13009,
        VIX_E_SNAPSHOT_LOCKED                        = 13010,
        VIX_E_SNAPSHOT_INCONSISTENT                  = 13011,
        VIX_E_SNAPSHOT_NAMETOOLONG                   = 13012,
        VIX_E_SNAPSHOT_VIXFILE                       = 13013,
        VIX_E_SNAPSHOT_DISKLOCKED                    = 13014,
        VIX_E_SNAPSHOT_DUPLICATEDDISK                = 13015,
        VIX_E_SNAPSHOT_INDEPENDENTDISK               = 13016,
        VIX_E_SNAPSHOT_NONUNIQUE_NAME                = 13017,
        VIX_E_SNAPSHOT_MEMORY_ON_INDEPENDENT_DISK    = 13018,
        VIX_E_SNAPSHOT_MAXSNAPSHOTS                  = 13019,
        VIX_E_SNAPSHOT_MIN_FREE_SPACE                = 13020,
    
        # Host Errors 
        VIX_E_HOST_DISK_INVALID_VALUE                = 14003,
        VIX_E_HOST_DISK_SECTORSIZE                   = 14004,
        VIX_E_HOST_FILE_ERROR_EOF                    = 14005,
        VIX_E_HOST_NETBLKDEV_HANDSHAKE               = 14006,
        VIX_E_HOST_SOCKET_CREATION_ERROR             = 14007,
        VIX_E_HOST_SERVER_NOT_FOUND                  = 14008,
        VIX_E_HOST_NETWORK_CONN_REFUSED              = 14009,
        VIX_E_HOST_TCP_SOCKET_ERROR                  = 14010,
        VIX_E_HOST_TCP_CONN_LOST                     = 14011,
        VIX_E_HOST_NBD_HASHFILE_VOLUME               = 14012,
        VIX_E_HOST_NBD_HASHFILE_INIT                 = 14013,
       
        # Disklib errors 
        VIX_E_DISK_INVAL                             = 16000,
        VIX_E_DISK_NOINIT                            = 16001,
        VIX_E_DISK_NOIO                              = 16002,
        VIX_E_DISK_PARTIALCHAIN                      = 16003,
        VIX_E_DISK_NEEDSREPAIR                       = 16006,
        VIX_E_DISK_OUTOFRANGE                        = 16007,
        VIX_E_DISK_CID_MISMATCH                      = 16008,
        VIX_E_DISK_CANTSHRINK                        = 16009,
        VIX_E_DISK_PARTMISMATCH                      = 16010,
        VIX_E_DISK_UNSUPPORTEDDISKVERSION            = 16011,
        VIX_E_DISK_OPENPARENT                        = 16012,
        VIX_E_DISK_NOTSUPPORTED                      = 16013,
        VIX_E_DISK_NEEDKEY                           = 16014,
        VIX_E_DISK_NOKEYOVERRIDE                     = 16015,
        VIX_E_DISK_NOTENCRYPTED                      = 16016,
        VIX_E_DISK_NOKEY                             = 16017,
        VIX_E_DISK_INVALIDPARTITIONTABLE             = 16018,
        VIX_E_DISK_NOTNORMAL                         = 16019,
        VIX_E_DISK_NOTENCDESC                        = 16020,
        VIX_E_DISK_NEEDVMFS                          = 16022,
        VIX_E_DISK_RAWTOOBIG                         = 16024,
        VIX_E_DISK_TOOMANYOPENFILES                  = 16027,
        VIX_E_DISK_TOOMANYREDO                       = 16028,
        VIX_E_DISK_RAWTOOSMALL                       = 16029,
        VIX_E_DISK_INVALIDCHAIN                      = 16030,
        VIX_E_DISK_KEY_NOTFOUND                      = 16052, # metadata key is not found
        VIX_E_DISK_SUBSYSTEM_INIT_FAIL               = 16053,
        VIX_E_DISK_INVALID_CONNECTION                = 16054,
        VIX_E_DISK_ENCODING                          = 16061,
        VIX_E_DISK_CANTREPAIR                        = 16062,
        VIX_E_DISK_INVALIDDISK                       = 16063,
        VIX_E_DISK_NOLICENSE                         = 16064,
        VIX_E_DISK_NODEVICE                          = 16065,
        VIX_E_DISK_UNSUPPORTEDDEVICE                 = 16066,
    
        # Crypto Library Errors 
        VIX_E_CRYPTO_UNKNOWN_ALGORITHM               = 17000,
        VIX_E_CRYPTO_BAD_BUFFER_SIZE                 = 17001,
        VIX_E_CRYPTO_INVALID_OPERATION               = 17002,
        VIX_E_CRYPTO_RANDOM_DEVICE                   = 17003,
        VIX_E_CRYPTO_NEED_PASSWORD                   = 17004,
        VIX_E_CRYPTO_BAD_PASSWORD                    = 17005,
        VIX_E_CRYPTO_NOT_IN_DICTIONARY               = 17006,
        VIX_E_CRYPTO_NO_CRYPTO                       = 17007,
        VIX_E_CRYPTO_ERROR                           = 17008,
        VIX_E_CRYPTO_BAD_FORMAT                      = 17009,
        VIX_E_CRYPTO_LOCKED                          = 17010,
        VIX_E_CRYPTO_EMPTY                           = 17011,
        VIX_E_CRYPTO_KEYSAFE_LOCATOR                 = 17012,
    
        # Remoting Errors. 
        VIX_E_CANNOT_CONNECT_TO_HOST                 = 18000,
        VIX_E_NOT_FOR_REMOTE_HOST                    = 18001,
        VIX_E_INVALID_HOSTNAME_SPECIFICATION         = 18002,
        
        # Screen Capture Errors. 
        VIX_E_SCREEN_CAPTURE_ERROR                   = 19000,
        VIX_E_SCREEN_CAPTURE_BAD_FORMAT              = 19001,
        VIX_E_SCREEN_CAPTURE_COMPRESSION_FAIL        = 19002,
        VIX_E_SCREEN_CAPTURE_LARGE_DATA              = 19003,
    
        # Guest Errors 
        VIX_E_GUEST_VOLUMES_NOT_FROZEN               = 20000,
        VIX_E_NOT_A_FILE                             = 20001,
        VIX_E_NOT_A_DIRECTORY                        = 20002,
        VIX_E_NO_SUCH_PROCESS                        = 20003,
        VIX_E_FILE_NAME_TOO_LONG                     = 20004,
    
        # Tools install errors 
        VIX_E_TOOLS_INSTALL_NO_IMAGE                 = 21000,
        VIX_E_TOOLS_INSTALL_IMAGE_INACCESIBLE        = 21001,
        VIX_E_TOOLS_INSTALL_NO_DEVICE                = 21002,
        VIX_E_TOOLS_INSTALL_DEVICE_NOT_CONNECTED     = 21003,
        VIX_E_TOOLS_INSTALL_CANCELLED                = 21004,
        VIX_E_TOOLS_INSTALL_INIT_FAILED              = 21005,
        VIX_E_TOOLS_INSTALL_AUTO_NOT_SUPPORTED       = 21006,
        VIX_E_TOOLS_INSTALL_GUEST_NOT_READY          = 21007,
        VIX_E_TOOLS_INSTALL_SIG_CHECK_FAILED         = 21008,
        VIX_E_TOOLS_INSTALL_ERROR                    = 21009,
        VIX_E_TOOLS_INSTALL_ALREADY_UP_TO_DATE       = 21010,
        VIX_E_TOOLS_INSTALL_IN_PROGRESS              = 21011,
    
        # Wrapper Errors 
        VIX_E_WRAPPER_WORKSTATION_NOT_INSTALLED      = 22001,
        VIX_E_WRAPPER_VERSION_NOT_FOUND              = 22002,
        VIX_E_WRAPPER_SERVICEPROVIDER_NOT_FOUND      = 22003,
        VIX_E_WRAPPER_PLAYER_NOT_INSTALLED           = 22004,
    
        # FuseMnt errors
        VIX_E_MNTAPI_MOUNTPT_NOT_FOUND               = 24000,
        VIX_E_MNTAPI_MOUNTPT_IN_USE                  = 24001,
        VIX_E_MNTAPI_DISK_NOT_FOUND                  = 24002,
        VIX_E_MNTAPI_DISK_NOT_MOUNTED                = 24003,
        VIX_E_MNTAPI_DISK_IS_MOUNTED                 = 24004,
        VIX_E_MNTAPI_DISK_NOT_SAFE                   = 24005,
        VIX_E_MNTAPI_DISK_CANT_OPEN                  = 24006,
        VIX_E_MNTAPI_CANT_READ_PARTS                 = 24007,
        VIX_E_MNTAPI_UMOUNT_APP_NOT_FOUND            = 24008,
        VIX_E_MNTAPI_UMOUNT                          = 24009,
        VIX_E_MNTAPI_NO_MOUNTABLE_PARTITONS          = 24010,
        VIX_E_MNTAPI_PARTITION_RANGE                 = 24011,
        VIX_E_MNTAPI_PERM                            = 24012,
        VIX_E_MNTAPI_DICT                            = 24013,
        VIX_E_MNTAPI_DICT_LOCKED                     = 24014,
        VIX_E_MNTAPI_OPEN_HANDLES                    = 24015,
        VIX_E_MNTAPI_CANT_MAKE_VAR_DIR               = 24016,
        VIX_E_MNTAPI_NO_ROOT                         = 24017,
        VIX_E_MNTAPI_LOOP_FAILED                     = 24018,
        VIX_E_MNTAPI_DAEMON                          = 24019,
        VIX_E_MNTAPI_INTERNAL                        = 24020,
        VIX_E_MNTAPI_SYSTEM                          = 24021,
        VIX_E_MNTAPI_NO_CONNECTION_DETAILS           = 24022,
        # FuseMnt errors: Do not exceed 24299 
    
        # VixMntapi errors
        VIX_E_MNTAPI_INCOMPATIBLE_VERSION            = 24300,
        VIX_E_MNTAPI_OS_ERROR                        = 24301,
        VIX_E_MNTAPI_DRIVE_LETTER_IN_USE             = 24302,
        VIX_E_MNTAPI_DRIVE_LETTER_ALREADY_ASSIGNED   = 24303,
        VIX_E_MNTAPI_VOLUME_NOT_MOUNTED              = 24304,
        VIX_E_MNTAPI_VOLUME_ALREADY_MOUNTED          = 24305,
        VIX_E_MNTAPI_FORMAT_FAILURE                  = 24306,
        VIX_E_MNTAPI_NO_DRIVER                       = 24307,
        VIX_E_MNTAPI_ALREADY_OPENED                  = 24308,
        VIX_E_MNTAPI_ITEM_NOT_FOUND                  = 24309,
        VIX_E_MNTAPI_UNSUPPROTED_BOOT_LOADER         = 24310,
        VIX_E_MNTAPI_UNSUPPROTED_OS                  = 24311,
        VIX_E_MNTAPI_CODECONVERSION                  = 24312,
        VIX_E_MNTAPI_REGWRITE_ERROR                  = 24313,
        VIX_E_MNTAPI_UNSUPPORTED_FT_VOLUME           = 24314,
        VIX_E_MNTAPI_PARTITION_NOT_FOUND             = 24315,
        VIX_E_MNTAPI_PUTFILE_ERROR                   = 24316,
        VIX_E_MNTAPI_GETFILE_ERROR                   = 24317,
        VIX_E_MNTAPI_REG_NOT_OPENED                  = 24318,
        VIX_E_MNTAPI_REGDELKEY_ERROR                 = 24319,
        VIX_E_MNTAPI_CREATE_PARTITIONTABLE_ERROR     = 24320,
        VIX_E_MNTAPI_OPEN_FAILURE                    = 24321,
        VIX_E_MNTAPI_VOLUME_NOT_WRITABLE             = 24322,

    # Geometry
    ctypedef struct VixDiskLibGeometry:
        uint32 cylinders
        uint32 heads
        uint32 sectors

    # Disk types
    ctypedef enum VixDiskLibDiskType:
        VIXDISKLIB_DISK_MONOLITHIC_SPARSE         = 1,   # monolithic file, sparse
        VIXDISKLIB_DISK_MONOLITHIC_FLAT           = 2,   # monolithic file,
                                                        # all space pre-allocated
        VIXDISKLIB_DISK_SPLIT_SPARSE              = 3,   # disk split into 2GB extents,
                                                        # sparse
        VIXDISKLIB_DISK_SPLIT_FLAT                = 4,   # disk split into 2GB extents,
                                                        # pre-allocated
        VIXDISKLIB_DISK_VMFS_FLAT                 = 5,   # ESX 3.0 and above flat disks
        VIXDISKLIB_DISK_STREAM_OPTIMIZED          = 6,   # compressed monolithic sparse
        VIXDISKLIB_DISK_VMFS_THIN                 = 7,   # ESX 3.0 and above thin provisioned
        VIXDISKLIB_DISK_VMFS_SPARSE               = 8,   # ESX 3.0 and above sparse disks
        VIXDISKLIB_DISK_UNKNOWN                   = 256  # unknown type
    
    # Disk adapter types
    ctypedef enum VixDiskLibAdapterType:
        VIXDISKLIB_ADAPTER_IDE                    = 1,
        VIXDISKLIB_ADAPTER_SCSI_BUSLOGIC          = 2,
        VIXDISKLIB_ADAPTER_SCSI_LSILOGIC          = 3,
        VIXDISKLIB_ADAPTER_UNKNOWN                = 256
    
    # Create Params
    ctypedef struct VixDiskLibCreateParams:
        VixDiskLibDiskType           diskType
        VixDiskLibAdapterType        adapterType
        uint16                       hwVersion
        VixDiskLibSectorType         capacity
    
    # Credential Type - SessionId not yet supported
    ctypedef enum VixDiskLibCredType:
        VIXDISKLIB_CRED_UID                      = 1, # use userid password
        VIXDISKLIB_CRED_SESSIONID                = 2, # http session id
        VIXDISKLIB_CRED_TICKETID                 = 3, # vim ticket id
        VIXDISKLIB_CRED_SSPI                     = 4, # Windows only - use current thread credentials.
        VIXDISKLIB_CRED_UNKNOWN                  = 256
    
    # VixDiskLibConnectParams - Connection setup parameters.
    # 
    # vmxSpec is required for opening a virtual disk on a datastore through
    # the Virtual Center or ESX server.
    # vmxSpec is of the form:
    # <vmxPathName>?dcPath=<dcpath>&dsName=<dsname>
    # where
    # vmxPathName is the fullpath for the VMX file,
    # dcpath is the inventory path of the datacenter and
    # dsname is the datastore name.
    # # Inventory path for the datacenter can be read off the Virtual Center
    # client's inventory tree.
    # 
    # Example VM spec:
    # "MyVm/MyVm.vmx?dcPath=Path/to/MyDatacenter&dsName=storage1"
    
    ctypedef struct VixDiskLibUidPasswdCreds:
        char *userName # User id and password on the
        char *password # VC/ESX host.

    ctypedef struct VixDiskLibSessionIdCreds:
        char *cookie
        char *userName
        char *key
        
    ctypedef struct VixDiskLibTicketIdCreds
    ctypedef union VixDiskLibCreds:
        VixDiskLibUidPasswdCreds uid
        VixDiskLibSessionIdCreds sessionId

    ctypedef struct VixDiskLibConnectParams:
        char *vmxSpec     # URL like spec of the VM.
        char *serverName  # Name or IP address of VC / ESX.
        VixDiskLibCredType credType
        VixDiskLibCreds creds
        uint32 port

    ctypedef struct VixDiskLibInfo:
        VixDiskLibGeometry   biosGeo      # BIOS geometry for booting and partitioning
        VixDiskLibGeometry   physGeo      # physical geometry
        VixDiskLibSectorType capacity     # total capacity in sectors
        VixDiskLibAdapterType adapterType # adapter type
        int numLinks                      # number of links (i.e. base disk + redo logs)
        char *parentFileNameHint          # parent file for a redo log
    
    ctypedef extern struct VixDiskLibHandleStruct
    
    ctypedef VixDiskLibHandleStruct *VixDiskLibHandle
    
    struct VixDiskLibConnectParam
    ctypedef VixDiskLibConnectParam *VixDiskLibConnection
    
    ctypedef void (*VixDiskLibGenericLogFunc)(char *fmt, va_list args)
    
    
    # Prototype for the progress function called by VixDiskLib.
    #
    # @param progressData [in] User supplied opaque pointer.
    # @param percentCompleted [in] Completion percent.
    # @return VixDiskLib ignores the return value.
    #    This function may be called with the same percentage completion
    #    multiple times.
    ctypedef bint (*VixDiskLibProgressFunc)(void *progressData,
                                           int percentCompleted)
    
    # Initializes VixDiskLib.
    # @param majorVersion [in] Required major version number for client.
    # @param minorVersion [in] Required minor version number for client.
    # @param log [in] Callback for Log entries.
    # @param warn [in] Callback for warnings.
    # @param panic [in] Callback for panic.
    # @param libDir [in] Directory location where dependent libs are located.
    # @param configFile [in] Configuration file path in local encoding.
    #          configuration files are of the format
    #                name = "value"
    #          each name/value pair on a separate line. For a detailed
    #          description of allowed values, refer to the VixDiskLib
    #          documentation.
    #
    # @return VIX_OK on success, suitable VIX error code otherwise.
    VixError VixDiskLib_InitEx(uint32 majorVersion,
                      uint32 minorVersion,
                      VixDiskLibGenericLogFunc *log,
                      VixDiskLibGenericLogFunc *warn,
                      VixDiskLibGenericLogFunc *panic,
                      char* libDir,
                      char* configFile)
    
    # Initializes VixDiskLib - deprecated, please use VixDiskLib_InitEx.
    # @param majorVersion [in] Required major version number for client.
    # @param minorVersion [in] Required minor version number for client.
    # @param log [in] Callback for Log entries.
    # @param warn [in] Callback for warnings.
    # @param panic [in] Callback for panic.
    # @param libDir [in] Directory location where dependent libs are located.
    # @return VIX_OK on success, suitable VIX error code otherwise.
    VixError VixDiskLib_Init(uint32 majorVersion,
                    uint32 minorVersion,
                    VixDiskLibGenericLogFunc *log,
                    VixDiskLibGenericLogFunc *warn,
                    VixDiskLibGenericLogFunc *panic,
                    char* libDir)
    
    # Cleans up VixDiskLib.
    void VixDiskLib_Exit()
    
    # Get a list of transport modes known to VixDiskLib. This list is also the
    # default used if VixDiskLib_ConnectEx is called with transportModes set
    # to NULL.
    # 
    # The string is a list of transport modes separated by colons. For
    # example: "file:san:hotadd:nbd". See VixDiskLib_ConnectEx for more details.
    # 
    # @return Returns a string that is a list of plugins. The caller must not
    #         free the string.
    char * VixDiskLib_ListTransportModes()
    
    
    # Perform a cleanup after an unclean shutdown of an application using
    # VixDiskLib. 
    # 
    # When using VixDiskLib_ConnectEx, some state might have not been cleaned
    # up if the resulting connection was not shut down cleanly. Use
    # VixDiskLib_Cleanup to remove this extra state.
    # 
    # @param connection [in] Hostname and login credentials to connect to
    #       a host managing virtual machines that were accessed and need 
    #       cleanup. While VixDiskLib_Cleanup can be invoked for local
    #       connections as well, it is a no-op in that case. Also, the
    #       vmxSpec property of connectParams should be set to NULL.
    # @param numCleanedUp [out] Number of virtual machines that were 
    #       successfully cleaned up. -- Can be NULL.
    # @param numRemaining [out] Number of virutal machines that still
    #       require cleaning up. -- Can be NULL.
    # @return VIX_OK if all virtual machines were successfully cleaned
    #       up or if no virtual machines required cleanup. VIX error
    #       code otherwise and numRemaning can be used to check for 
    #       the number of virtual machines requiring cleanup.
    VixError VixDiskLib_Cleanup(VixDiskLibConnectParams *connectParams,
                       uint32 *numCleanedUp, uint32 *numRemaining)
    
    # Connects to a local / remote server.
    # @param connectParams [in] NULL if maniuplating local disks.
    #             For remote case this includes esx hostName and
    #             user credentials.
    # @param connection [out] Returned handle to a connection.
    # @return VIX_OK if success suitable VIX error code otherwise.
    VixError VixDiskLib_Connect(VixDiskLibConnectParams *connectParams, VixDiskLibConnection *connection)
    
    # Create a transport context to access disks belonging to a
    # particular snapshot of a particular virtual machine. Using this
    # transport context will enable callers to open virtual disks using
    # the most efficient data acces protocol available for managed
    # virtual machines, hence getting better I/O performance.
    # 
    # If this call is used instead of VixDiskLib_Connect, the additional
    # information passed in will be used in order to optimize the I/O
    # access path, to maximize I/O throughput.
    # 
    # Note: For local virtual machines/disks, this call is equivalent
    #       to VixDiskLib_Connect.
    # 
    # @param connectParams [in] NULL if maniuplating local disks.
    #             For remote case this includes esx hostName and
    #             user credentials.
    # @param readOnly [in] Should be set to TRUE if no write access is needed 
    #             for the disks to be accessed through this connection. In
    #             some cases, a more efficient I/O path can be used for
    #             read-only access.
    # @param snapshotRef [in] A managed object reference to the specific
    #             snapshot of the virtual machine whose disks will be
    #             accessed with this connection.  Specifying this
    #             property is only meaningful if the vmxSpec property in
    #             connectParams is set as well.
    # @param transportModes [in] An optional list of transport modes that
    #             can be used for this connection, separated by
    #             colons. If NULL is specified, VixDiskLib's default
    #             setting of "file:san:hotadd:nbd" is used. If a disk is
    #             opened through this connection, VixDiskLib will start
    #             with the first entry of the list and attempt to use
    #             this transport mode to gain access to the virtual
    #             disk. If this does not work, the next item in the list
    #             will be used until either the disk was successfully
    #             opened or the end of the list is reached.
    # @param connection [out] Returned handle to a connection.
    # @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_ConnectEx(VixDiskLibConnectParams *connectParams,
                         bint readOnly,
                         char *snapshotRef,
                         char *transportModes,
                         VixDiskLibConnection *connection)
    
    #  Breaks an existing connection.
    #  @param connection [in] Valid handle to a (local/remote) connection.
    #  @return VIX_OK if success suitable VIX error code otherwise.
    VixError VixDiskLib_Disconnect(VixDiskLibConnection connection)
    
    #  Creates a local disk. Remote disk creation is not supported.
    #  @param connection [in] A valid connection.
    #  @param path [in] VMDK file name given as absolute path
    #                   e.g. "c:\\My Virtual Machines\\MailServer\SystemDisk.vmdk".
    #  @param createParams [in] Specification for the new disk (type, capacity ...).
    #  @param progressFunc [in] Callback to report progress.
    #  @param progressCallbackData [in] Callback data pointer.
    #  @return VIX_OK if success suitable VIX error code otherwise.
    VixError VixDiskLib_Create(VixDiskLibConnection connection,
                      char *path,
                      VixDiskLibCreateParams *createParams,
                      VixDiskLibProgressFunc progressFunc,
                      void *progressCallbackData)
    
    #  Creates a redo log from a parent disk.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param childPath [in] Redo log file name given as absolute path
    #                   e.g. "c:\\My Virtual Machines\\MailServer\SystemDisk_s0001.vmdk".
    #  @param diskType [in] Either VIXDISKLIB_DISK_MONOLITHIC_SPARSE or
    #                       VIXDISKLIB_DISK_SPLIT_SPARSE.
    #  @param progressFunc [in] Callback to report progress.
    #  @param progressCallbackData [in] Callback data pointer.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_CreateChild(VixDiskLibHandle diskHandle,
                           char *childPath,
                           VixDiskLibDiskType diskType,
                           VixDiskLibProgressFunc progressFunc,
                           void *progressCallbackData)
    
    #  Opens a local or remote virtual disk.
    #  @param connection [in] A valid connection.
    #  @param path [in] VMDK file name given as absolute path
    #                         e.g. "[storage1] MailServer/SystemDisk.vmdk"
    #  @param flags [in, optional] Bitwise or'ed  combination of
    #              VIXDISKLIB_FLAG_OPEN_UNBUFFERED
    #              VIXDISKLIB_FLAG_OPEN_SINGLE_LINK
    #              VIXDISKLIB_FLAG_OPEN_READ_ONLY.
    #  @param diskHandle [out] Handle to opened disk, NULL if disk was not opened.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Open(VixDiskLibConnection connection,
                    char *path,
                    uint32 flags,
                    VixDiskLibHandle *diskHandle)
    
    #  Retrieves information about a disk.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param info [out] Disk information filled up.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_GetInfo(VixDiskLibHandle diskHandle,
                       VixDiskLibInfo **info)
    
    #  Frees memory allocated in VixDiskLib_GetInfo.
    #  @param info [in] Disk information to be freed.
    void VixDiskLib_FreeInfo(VixDiskLibInfo *info)
    
    #  Returns a pointer to a static string identifying the transport mode that
    #  is used to access the virtual disk's data.
    # 
    #  If a disk was opened through a connection obtained by VixDiskLib_Connect,
    #  the return value will be "file" for a local disk and "nbd" or "nbdssl" for
    #  a managed disk. 
    # 
    #  The pointer to this string is static and must not be deallocated by the 
    #  caller.
    # 
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @return Returns a pointer to a static string identifying the transport
    #          mode used to access the disk's data.
    
    char * VixDiskLib_GetTransportMode(VixDiskLibHandle diskHandle)
    
    #  Closes the disk.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Close(VixDiskLibHandle diskHandle)
    
    #  Reads a sector range.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param startSector [in] Absolute offset.
    #  @param numSectors [in] Number of sectors to read.
    #  @param readBuffer [out] Buffer to read into.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Read(VixDiskLibHandle diskHandle,
                    VixDiskLibSectorType startSector,
                    VixDiskLibSectorType numSectors,
                    uint8 *readBuffer)
    
    #  Writes a sector range.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param startSector [in] Absolute offset.
    #  @param numSectors [in] Number of sectors to write.
    #  @param writeBuffer [in] Buffer to write.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Write(VixDiskLibHandle diskHandle,
                     VixDiskLibSectorType startSector,
                     VixDiskLibSectorType numSectors,
                     uint8 *writeBuffer)
    
    #  Retrieves the value of a metadata entry corresponding to the supplied key.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param key [in] Key name.
    #  @param buf [out, optional] Placeholder for key's value in the metadata store,
    #             can be NULL.
    #  @param bufLen [in] Size of the buffer.
    #  @param requiredLen [out, optional] Size of buffer required for the value (including
    #                 end of string character)
    #  @return VIX_OK if success, VIX_E_DISK_BUFFER_TOO_SMALL if too small a buffer
    #              and other errors as applicable.
    VixError VixDiskLib_ReadMetadata(VixDiskLibHandle diskHandle,
                            char *key,
                            char *buf,
                            size_t bufLen,
                            size_t *requiredLen)
    
    #  Creates or modifies a metadata table entry.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param key [in] Key name.
    #  @param val [in] Key's value.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_WriteMetadata(VixDiskLibHandle diskHandle,
                             char *key,
                             char *val)
    
    #  Retrieves the list of keys in the metadata table.
    #  Key names are returned as list of null-terminated strings,
    #  followed by an additional NULL character.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param keys [out, optional]  Keynames buffer, can be NULL.
    #  @param maxLen [in] Size of the keynames buffer.
    #  @param requiredLen [out, optional] Space required for the keys including the double
    #     end-of-string  characters.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_GetMetadataKeys(VixDiskLibHandle diskHandle,
                               char *keys,
                               size_t maxLen,
                               size_t *requiredLen)
    
    #  Deletes all extents of the specified disk link. If the path refers to a
    #  parent disk, the child (redo log) will be orphaned.
    #  Unlinking the child does not affect the parent.
    #  @param connection [in] A valid connection.
    #  @param path [in] Path to the disk to be deleted.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    
    VixError VixDiskLib_Unlink(VixDiskLibConnection connection,
                      char *path)
    
    #  Grows an existing disk, only local disks are grown.
    #  @pre The specified disk is not open.
    #  @param connection [in] A valid connection.
    #  @param path [in] Path to the disk to be grown.
    #  @param capacity [in] Target size for the disk.
    #  @param updateGeometry [in] Should vixDiskLib update the geometry?
    #  @param progressFunc [in] Callback to report progress (called on the same thread).
    #  @param progressCallbackData [in] Opaque pointer passed along with the percent
    #                    complete.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Grow(VixDiskLibConnection connection,
                    char *path,
                    VixDiskLibSectorType capacity,
                    bint updateGeometry,
                    VixDiskLibProgressFunc progressFunc,
                    void *progressCallbackData)
    #  Shrinks an existing disk, only local disks are shrunk.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param progressFunc [in] Callback to report progress (called on the same thread).
    #  @param progressCallbackData [in] Opaque pointer passed along with the percent
    #                    complete.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Shrink(VixDiskLibHandle diskHandle,
                      VixDiskLibProgressFunc progressFunc,
                      void *progressCallbackData)
    
    #  Defragments an existing disk.
    #  @param diskHandle [in] Handle to an open virtual disk.
    #  @param progressFunc [in] Callback to report progress (called on the same thread).
    #  @param progressCallbackData [in] Opaque pointer passed along with the percent
    #                    complete.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Defragment(VixDiskLibHandle diskHandle,
                          VixDiskLibProgressFunc progressFunc,
                          void *progressCallbackData)
    
    #  Renames a virtual disk.
    #  @param srcFileName [in] Virtual disk file to rename.
    #  @param dstFileName [in] New name for the virtual disk.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Rename(char *srcFileName,
                      char *dstFileName)
    
    #  Copies a disk with proper conversion.
    #  @param dstConnection [in] A valid connection to access the destination disk.
    #  @param dstPath [in] Absolute path for the (new) destination disk.
    #  @param srcConnection [in] A valid connection to access the source disk.
    #  @param srcPath [in] Absolute path for the source disk.
    #  @param vixCreateParams [in] creationParameters (disktype, hardware type...).
    #                    If the destination is remote, createParams is currently
    #                    ignored and disk with default size and adapter type is
    #                    created.
    #  @param progressFunc [in] Callback to report progress (called on the same thread).
    #  @param progressCallbackData [in] Opaque pointer passed along with the percent
    #                    complete.
    #  @param overWrite [in] TRUE if Clone should overwrite an existing file.
    #  @return VIX_OK if success, suitable VIX error code otherwise (network errors like
    #                    file already exists
    #                    handshake failure, ...
    #                    are all combined into a generic connect message).
    VixError VixDiskLib_Clone(VixDiskLibConnection dstConnection,
                     char *dstPath,
                     VixDiskLibConnection srcConnection,
                     char *srcPath,
                     VixDiskLibCreateParams *vixCreateParams,
                     VixDiskLibProgressFunc progressFunc,
                     void *progressCallbackData,
                     bint overWrite)
    
    #  Returns the textual description of an error.
    #  @param err [in] A VIX error code.
    #  @param locale [in] Language locale - not currently supported and must be NULL.
    #  @return The error message string. This should only be deallocated
    #          by VixDiskLib_FreeErrorText.
    #          Returns NULL if there is an error in retrieving text.
    char * VixDiskLib_GetErrorText(VixError err, char *locale)
    
    #  Free the error message returned by VixDiskLib_GetErrorText.
    #  @param errMsg [in] Message string returned by VixDiskLib_GetErrorText.
    #     It is OK to call this function with NULL.
    #  @return None.
    void VixDiskLib_FreeErrorText(char* errMsg)
    
    #  Attaches the child disk chain to the parent disk chain. Parent handle is
    #  invalid after attaching and child represents the combined disk chain.
    #  @param parent [in] Handle to the disk to be attached.
    #  @param child [in] Handle to the disk to attach.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_Attach(VixDiskLibHandle parent, VixDiskLibHandle child)
    
    #  Compute the space (in bytes) required to copy a disk chain.
    #  @param diskHandle [in] Handle to the disk to be copied.
    #  @param cloneDiskType [in] Type of the (to be) newly created disk. 
    #    If cloneDiskType is VIXDISKLIB_DISK_UNKNOWN, the source disk
    #    type is assumed.
    #  @param spaceNeeded [out] Place holder for space needed in bytes.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_SpaceNeededForClone(VixDiskLibHandle diskHandle,
                                   VixDiskLibDiskType cloneDiskType,
                                   uint64* spaceNeeded)
    
    #  Check a sparse disk for internal consistency.
    #  @param filename [in] Path to disk to be checked.
    #  @param repair [in] TRUE if repair should be attempted, false otherwise.
    #  @return VIX_OK if success, suitable VIX error code otherwise.  Note
    #     this refers to the success of the call, not the consistency of
    #     the disk being checked.
    VixError VixDiskLib_CheckRepair(VixDiskLibConnection connection,
                           char *filename,
                           bint repair)
    
    #  Return the details for the connection.
    #  @param connection [in] A VixDiskLib connection.
    #  @param connectParams [out] Details of the connection.
    #  @return VIX_OK if success, suitable VIX error code otherwise.
    VixError VixDiskLib_GetConnectParams(VixDiskLibConnection connection,
                                VixDiskLibConnectParams** connectParams)
    
    #  Free the connection details structure allocated during
    #  VixDiskLib_GetConnectParams.
    #  @param connectParams [out] Connection details to be free'ed.
    #  @return None.
    void VixDiskLib_FreeConnectParams(VixDiskLibConnectParams* connectParams)

# Add some default callbacks (from the sample application in the VDDK)
cdef void LogFunc(char *fmt, va_list args):
    cdef char buff[256]
    vsprintf(&buff[0], fmt, args);
    cdef int endofline = strlen(buff)
    buff[endofline -2] = 0
    log.debug(buff)

cdef void WarnFunc(char *fmt, va_list args):
    cdef char buff[256]
    vsprintf(&buff[0], fmt, args);
    buff[255] = 0
    log.warn(buff)

cdef void PanicFunc(char *fmt, va_list args):
    cdef char buff[256]
    vsprintf(&buff[0], fmt, args);
    buff[255] = 0
    log.error(buff)

DTYPE  = np.uint8
ctypedef np.uint8_t DTYPE_t

VixDiskLibSectorSize = VIXDISKLIB_SECTOR_SIZE

class VixDiskOpenFlags:
    UNBUFFERED = VIXDISKLIB_FLAG_OPEN_UNBUFFERED
    SINGLE_LINK = VIXDISKLIB_FLAG_OPEN_SINGLE_LINK
    READ_ONLY = VIXDISKLIB_FLAG_OPEN_READ_ONLY

class VDDKError(Exception):
    pass

cdef class VixDiskLib(object):
    cdef VixDiskLibHandle handle
    cdef np.ndarray buff
    cdef VixDiskLibConnectParams params
    cdef VixDiskLibConnection conn
    cdef hostname
    cdef username
    cdef info
    cdef connected
    cdef opened
    
    def __init__(self, vmxSpec, hostname, username, password):
        self.params.vmxSpec = vmxSpec
        self.params.serverName = strdup(hostname)
        self.params.credType = VIXDISKLIB_CRED_UID
        self.params.creds.uid.userName = strdup(username)
        self.params.creds.uid.password = strdup(password)
        self.params.port = 902
        
        self.hostname = hostname
        self.username = username
        self.buff = np.zeros(VIXDISKLIB_SECTOR_SIZE, dtype=DTYPE)
        
        self.info = ""
        
        # state
        self.connected = False
        self.opened = False
        
        vixError = VixDiskLib_InitEx(1, 0, <VixDiskLibGenericLogFunc*>&LogFunc, <VixDiskLibGenericLogFunc*>&WarnFunc, <VixDiskLibGenericLogFunc*>&PanicFunc, NULL, NULL)
        if vixError != VIX_OK:
            self._logError("Error initializing the vixDiskLib library", vixError)
                
    def __del__(self):
        if self.opened:
            self.close()
        if self.connected:
            self.disconnect()
        VixDiskLib_Exit()
            
    cdef _logError(self, msg, error_num):
        cdef char *error = VixDiskLib_GetErrorText(error_num, NULL)
        ex = VixDiskLibError(error)
        VixDiskLib_FreeErrorText(error)
        raise ex
    
    def connect(self, snapshotRef, readonly = False):
        log.debug("Connecting to %s as %s" % (self.hostname, self.username))
        
        vixError = VixDiskLib_ConnectEx(&(self.params), readonly, snapshotRef, NULL, &(self.conn))
        if vixError != VIX_OK:
            self._logError("Error connecting to %s" % self.params.serverName, vixError)
        self.connected = True
        
    def disconnect(self):
        log.debug("Disconnecting from %s" % self.hostname)
        if self.connected is False:
            raise VDDKError("Need to connect to the esx server before calling disconnect")
        if self.opened:
            self.close()
        VixDiskLib_Disconnect(self.conn)
        self.connected = False
    
    def open(self, path, flags=[VIXDISKLIB_FLAG_OPEN_READ_ONLY]):
        if self.connected is False:
            raise VDDKError("Need to connect to the esx server before calling open")
        
        _flag = 0
        for flag in flags:
            _flag |= flag
            
        vixError = VixDiskLib_Open(self.conn, path, _flag, &(self.handle))
        if vixError != VIX_OK:
            self._logError("Error opening %s" % path, vixError)
        self.opened = True
        
    def getMetadata(self):
        cdef size_t requiredLen
        cdef np.ndarray buffer = np.ndarray(1024, dtype=np.uint8)
        cdef np.ndarray val
        metadata = {}
       
        # it will fail the first time, but will give us the required length...
        vixError = VixDiskLib_GetMetadataKeys(self.handle, NULL, 0, &requiredLen)
        if vixError != VIX_OK and vixError != VIX_E_BUFFER_TOOSMALL:
            self._logError("Error getting metadata", vixError)
            
        vixError = VixDiskLib_GetMetadataKeys(self.handle, <char *>buffer.data, requiredLen, NULL)
        if vixError != VIX_OK:
            self._logError("Error getting metadata", vixError)
        
        cdef char *key = <char *>buffer.data
        while key[0]:
            vixError = VixDiskLib_ReadMetadata(self.handle, key, NULL, 0, &requiredLen);
            if vixError != VIX_OK and vixError != VIX_E_BUFFER_TOOSMALL:
                self._logError("Error getting metadata", vixError)
            
            val = np.ndarray(requiredLen, dtype=np.uint8)
            vixError = VixDiskLib_ReadMetadata(self.handle, key, <char *>val.data, requiredLen, NULL);
            if vixError != VIX_OK:
                self._logError("Error getting metadata", vixError)
            #print "%s = %s" % (key, val.tostring())
            metadata[key] = val.tostring()[:-1]
            key += (1 + strlen(key));
        return metadata
        
    def getInfo(self):
        if self.opened is False:
            raise VDDKError("Need to open a disk before calling getInfo")
        
        cdef VixDiskLibInfo *info
        vixError = VixDiskLib_GetInfo(self.handle, &info)
        if vixError != VIX_OK:
            self._logError("Error getting info from: %s" % self.hostname, vixError)
            
        biosGeo = {"cylinders":info.biosGeo.cylinders, "heads":info.biosGeo.heads, "sectors": info.biosGeo.sectors}
        physGeo = {"cylinders":info.physGeo.cylinders, "heads":info.physGeo.heads, "sectors": info.physGeo.sectors}
        pyinfo = { 'bios': biosGeo, 'physGeo': physGeo, 'capacity': info.capacity }
    
        VixDiskLib_FreeInfo(info)
        return pyinfo
    
    def getTransportModes(self):
        modes = VixDiskLib_ListTransportModes()
        return modes
        
    def read(self, start, bufsize=1):
        bsize = bufsize * VIXDISKLIB_SECTOR_SIZE
        if self.buff.size != bsize:
            self.buff.resize(bsize)
            
        vixError = VixDiskLib_Read(self.handle, start*bufsize, bufsize, <uint8 *>self.buff.data)
        if vixError != VIX_OK:
            self._logError("Error reading the disk on: %s" % self.hostname, vixError)
        return self.buff
    
    def close(self):
        if self.opened is False:
            raise VDDKError("Need to open a disk before closing it")
        vixError = VixDiskLib_Close(self.handle)
        if vixError != VIX_OK:
            self._logError("Error closing the disk", vixError)
        self.opened = False
        
# ----------------------------------------------------------------------
# vim: set filetype=python expandtab shiftwidth=4:
# [X]Emacs local variables declaration - place us into python mode
# Local Variables:
# mode:python
# py-indent-offset:4
# End:




