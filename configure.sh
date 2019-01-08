#!/bin/sh

replaceSendmail()
{
#  Distributor=$(lsb_release -a|grep 'Distributor ID:'|awk {'print $3'})
  OSArch=$(uname -m)

#  if [ ${Distributor} = "Ubuntu" ];then
  if [ ${OSArch} = "x86_64" ];then
    sed -i 's/POSIX_CHOWN_RESTRICTED\t0/POSIX_CHOWN_RESTRICTED\t1/g' /usr/include/x86_64-linux-gnu/bits/posix_opt.h
  fi

#  elif [ ${Distributor} = "Kylin" ];then
  if [ ${OSArch} = "aarch64" ];then
    sed -i 's/POSIX_CHOWN_RESTRICTED\t0/POSIX_CHOWN_RESTRICTED\t1/g' /usr/include/aarch64-linux-gnu/bits/posix_opt.h
    cp sendmail.postfix /usr/lib/
    ln -s /usr/lib/sendmail.postfix /usr/lib/sendmail
    ln -s /usr/lib/sendmail.postfix /usr/sbin/sendmail
    ln -s /lib/ld-linux-aarch64.so.1 /lib/ld-lsb.so.3
  fi
}


addDeclaration()
{
  sed -i '/extern float wcstof /i\\/*start YYJ*\/\nextern double __wcstod_internal (const wchar_t *__restrict __nptr,\n\t\t\twchar_t **__restrict__endptr, int __base) __THROW;\n\/*end YYJ*\/\n' /usr/include/wchar.h

  sed -i '/extern float wcstof /i\\/*start YYJ*\/\nextern float __wcstof_internal (const wchar_t *__restrict __nptr,\n\t\t\twchar_t  **__restrict __endptr, int __base) __THROW;\n\/*end YYJ*\/\n' /usr/include/wchar.h

  sed -i '/extern float wcstof /i\\/*start YYJ*\/\nextern long double __wcstold_internal (const wchar_t *__restrict __nptr,\n\t\t\twchar_t **__restrict __endptr, int __base) __THROW;\n\/*end YYJ*\/\n' /usr/include/wchar.h

  sed -i '/extern long int wcstol /i\\/*start YYJ*\/\nextern   long int __wcstol_internal (const wchar_t *__restrict__nptr,\n\t\t\twchar_t **__restrict __endptr, int __base, int __base2) __THROW;\n\/*end YYJ*\/\n' /usr/include/wchar.h

  sed -i '/extern double strtod /i\\/*start YYJ*\/\nextern double __strtod_internal (const char *__restrict __nptr,\n\t\t\tchar ** __restrict __endptr, int __base) __THROW __nonnull ((1));\n\/*end YYJ*\/\n' /usr/include/stdlib.h
}

######################################################################################################################################

#setup locale
printf "Create locales... "
localedef -c -f $TET_ROOT/test_sets/tset/LI18NUX2K.L1/base/nl_langinfo/UTF-8 -i $TET_ROOT/test_sets/SRC/subsets/li18nux2000-level1/li18nux_psldefs/LTP_1 LTP_1.utf8 2>/dev/null

printf "LTP_IL1.UTF-8 "
localedef -c -f $TET_ROOT/test_sets/tset/LI18NUX2K.L1/base/nl_langinfo/UTF-8 -i $TET_ROOT/test_sets/tset/LI18NUX2K.L1/base/nl_langinfo/LTP_IL1 LTP_IL1.UTF-8 > /dev/null 2>&1

printf "LTP_IL2.UTF-8 "
localedef -c -f $TET_ROOT/test_sets/tset/LI18NUX2K.L1/base/nl_langinfo/UTF-8 -i $TET_ROOT/test_sets/tset/LI18NUX2K.L1/base/nl_langinfo/LTP_IL2 LTP_IL2.UTF-8 > /dev/null 2>&1

printf "Done.\n"

############################################################################################

replaceSendmail

addDeclaration

#make user 'vsx0' has write permission of the locale directory
chmod a+w /usr/lib/locale/locale-archive

