AC_DEFUN([PDNS_WITH_SYSTEM_MBEDTLS],[
  AC_ARG_WITH([mbedtls],
    [AS_HELP_STRING([--with-mbedtls], [use mbed TLS @<:@default=yes@:>@])]
  )
  AC_ARG_WITH([system-mbedtls],
    [AS_HELP_STRING([--with-system-mbedtls], [use system mbed TLS @<:@default=no@:>@])],
    [],
    [with_system_mbedtls=no],
  )

  AC_MSG_CHECKING([if we should build with mbedtls])
  AS_IF([test "x$with_mbedtls" != "xno"],[
    AC_MSG_RESULT([yes])
    have_mbedtls=yes
    MBEDTLS_SUBDIR=mbedtls
    MBEDTLS_CFLAGS=-I\$\(top_srcdir\)/ext/$MBEDTLS_SUBDIR/include/
    MBEDTLS_LIBS="-L\$(top_builddir)/ext/$MBEDTLS_SUBDIR/library/ -lmbedtls"
    AS_IF([test "x$with_system_mbedtls" = "xyes"],[
      OLD_LIBS=$LIBS
      LIBS=""
      AC_SEARCH_LIBS([mbedtls_sha1], [mbedcrypto],[
        MBEDTLS_LIBS=$LIBS
        have_system_mbedtls=yes
        have_mbedtls_v2=yes
      ],[
        have_mbedtls_v2=no
        AC_SEARCH_LIBS([sha1_hmac], [mbedtls polarssl],[
          MBEDTLS_LIBS=$LIBS
          AC_MSG_CHECKING([for mbed TLS/PolarSSL version >= 1.3.0])
          AC_COMPILE_IFELSE([
            AC_LANG_PROGRAM(
              [[#include <polarssl/version.h>]],
              [[
                #if POLARSSL_VERSION_NUMBER < 0x01030000
                #error invalid version
                #endif
              ]]
            )],
            [have_system_mbedtls=yes],
            [have_system_mbedtls=no]
          )
          AC_MSG_RESULT([$have_system_mbedtls])
          ],
          [have_system_mbedtls=no]
        )
      ])
      LIBS=$OLD_LIBS
    ],[
      have_system_mbedtls=no
      have_mbedtls_v2=yes
    ])

    AS_IF([test "x$have_system_mbedtls" = "xyes"],[
      MBEDTLS_CFLAGS=
      MBEDTLS_SUBDIR=
      AC_DEFINE([MBEDTLS_SYSTEM], [1], [Defined if system mbed TLS is used])
    ],[
      AS_IF([test "x$with_system_mbedtls" = "xyes"],[
        AC_MSG_ERROR([use of system mbed TLS requested but not found])
      ])
    ])
  ],[
    AC_MSG_RESULT([no])
    have_system_mbedtls=no
    have_mbedtls_v2=no
    have_mbedtls=no
    MBEDTLS_SUBDIR=
    MBEDTLS_CFLAGS=
    MBEDTLS_LIBS=
    AS_IF([test "x$with_system_mbedtls" = "xyes"],[
      AC_MSG_ERROR([use of system mbed TLS requested but mbed TLS disabled])
    ])
  ])

  AS_IF([test "x$have_mbedtls_v2" = "xyes"],[
    AC_DEFINE([HAVE_MBEDTLS2], [1], [Defined if mbed TLS version 2.x.x is used])
  ])

  AS_IF([test "x$have_mbedtls" = "xyes"],[
    AC_DEFINE([HAVE_MBEDTLS], [1], [Defined if mbed TLS is used])
	AM_CONDITIONAL([MBEDTLS], [true])
  ],[
	AM_CONDITIONAL([MBEDTLS], [false])
  ])

  AC_SUBST(MBEDTLS_CFLAGS)
  AC_SUBST(MBEDTLS_LIBS)
  AC_SUBST(MBEDTLS_SUBDIR)
]
)
