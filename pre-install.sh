#!/bin/sh

CUR_DIR=$(pwd)
echo $CUR_DIR
export CUR_DIR

##################################
#  useful function
##################################
byaccCheck(){
  echo "### check byacc ###"

  type yacc > /dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "****install byacc****"
    tar -xzvf byacc.tar.gz
    cd byacc-20180609/
    ./configure
    make
    if [ $? -ne 0 ]; then
      echo "Error in make"
      exit 1
    fi
    echo "输入root密码"
    su root -c "make install"
    cd ..
  fi

  yacc -V > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error in checking byacc version after installation"
    exit 1
  fi
}

edCheck(){
  echo "### check ed ###"

  type ed > /dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "****install ed****"
    tar -xzvf ed_1.10.tar.gz
    cd ed-1.10/
    ./configure
    make
    if [ $? -ne 0 ]; then
      echo "Error in make"
      exit 1
    fi
    echo "输入root密码"
    su root -c "make install"
    cd ..
  fi

  ed -V > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error in checking ed version after installation"
    exit 1
  fi
}

paxCheck(){
  echo "### check pax ###"

  type pax > /dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "****install pax****"
    if [ ${OSArch} = "x86_64" ];then
    echo "输入root密码"
    su root -c "dpkg -i pax_1%3a20151013-1_amd64.deb"
      if [ $? -ne 0 ]; then
        echo "Error in installing byacc"
        exit 1 
      fi
    fi

    if [ ${OSArch} = "aarch64" ];then
    echo "输入root密码"
    su root -c "dpkg -i pax_20151013-1kord_arm64.deb"
      if [ $? -ne 0 ]; then
        echo "Error in installing byacc"
        exit 1 
      fi
    fi
  fi

  type pax > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error in checking pax version after installation"
    exit 1
  fi
}

gettextCheck(){
  echo "### check gettext ###"

  type msgfmt > /dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "****install gettext****"
    tar -xzvf gettext-0.19.8.1.tar.gz
    cd gettext-0.19.8.1/
    ./configure
    make
    if [ $? -ne 0 ]; then
      echo "Error in make"
      exit 1
    fi
    echo "输入root密码"
    su root -c "make install"
    cd ..
  fi

  gettext -V > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error in checking gettext version after installation"
    exit 1
  fi
}

lsbCheck(){
  echo "### check lsb ###"

  dpkg -l lsb > /dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "****install lsb****"
    echo "输入root密码"
    su root -c "dpkg --force-depends -i lsb_9.20160110ubuntu0.2_all.deb"
    if [ $? -ne 0 ]; then
      echo "Error in installing lsb"
      exit 1
    fi
  fi

  dpkg -l lsb > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error in checking lsb version after installation"
    exit 1
  fi
}


toolsInstall()
{
  echo "*****install patched-bash*****"
  if [ ! -d "$CUR_DIR/bash-4.3/" ];then
    tar -xzvf bash-4.3-master.tar.gz
    cd bash-4.3/
    ./configure
    make
    if [ $? -ne 0 ]; then
      echo "Error in make"
      exit 1
    fi
    echo "输入root密码"
    su root -c "make install"
    cd ..
  fi

  echo "*****install patched-coreutils*****"
  if [ ! -d "$CUR_DIR/coreutils-8.25/" ];then
    tar -xzvf coreutils-8.25-master.tar.gz
    cd coreutils-8.25/
    ./configure
    make
    if [ $? -ne 0 ]; then
      echo "Error in make"
      exit 1
    fi
    echo "输入root密码"
    su root -c "make install"  
    cd ..
  fi

  echo "*****install patched-diffutils*****" 
  if [ ! -d "$CUR_DIR/diffutils-3.3/" ];then
    tar -xzvf diffutils-3.3-master.tar.gz
    cd diffutils-3.3/
    ./configure
    make
    if [ $? -ne 0 ]; then
      echo "Error in make"
      exit 1
    fi
    echo "输入root密码"
    su root -c "make install"
    cd ..
  fi
}


##################################
#  check version
##################################
Distributor=$(lsb_release -a|grep 'Distributor ID:'|awk {'print $3'})

OSArch=$(uname -m)
echo "OS Architecture: $OSArch"

byaccCheck

paxCheck

gettextCheck

if [ ${Distributor} = "Kylin" ];then
  edCheck
fi

if [ ${Distributor} = "Ubuntu" ];then
  lsbCheck
fi


##################################
#  install lsb-test-core
##################################
echo "### unpack lsb-test-core ###"

tar -xzvf lsb-test-core-5.0.1.tar.gz 

echo "------------------------"
echo "begin installation"
echo "------------------------"

cd lsb-test-core-5.0.1/
echo "输入root密码"
su root -c "sh install.sh"
cd ..

#TET_ROOT=/home/tet
read TET_ROOT < lsb-test-core-5.0.1/tmp.txt

if [ ! $TET_ROOT ];then
  echo "error in TET_root"
  exit 1
fi 

export TET_ROOT
###################################
#  modify test configure
###################################
echo "------------------------------------------"
echo "begin config"
echo "------------------------------------------"

#解压修该文件至/home/tet/目录
echo "输入root密码"
su root -c "tar -xzvf modify.tar.gz -C $TET_ROOT/"

echo "输入root密码"
su root -c "chown -R vsx0.vsxg0 $TET_ROOT/modify"

cd $TET_ROOT/modify/
echo "输入vsx0用户密码"
su vsx0 -c "sh modify.sh"
cd $CUR_DIR/

echo "Change STACKSIZE......"
if [ ${OSArch} = "x86_64" ];then 
  STCKSIZE=$(awk -F "\t" '$1 ~ /PTHREAD_STACK_MIN/ {print $2}' /usr/include/x86_64-linux-gnu/bits/local_lim.h)
  if [ ${STCKSIZE} -ne "16384" ];then
    sed -i "s/VSTH_VALID_STACKSIZE=16384/VSTH_VALID_STACKSIZE=${STCKSIZE}/g" $TET_ROOT/test_sets/scripts/vsthlite/parameterisations.sh
  fi
fi

if [ ${OSArch} = "aarch64" ];then
  STCKSIZE=$(awk -F "\t" '$1 ~ /PTHREAD_STACK_MIN/ {print $2}' /usr/include/aarch64-linux-gnu/bits/local_lim.h)
  if [ ${STCKSIZE} -ne "16384" ];then
    sed -i "s/VSTH_VALID_STACKSIZE=16384/VSTH_VALID_STACKSIZE=${STCKSIZE}/g" $TET_ROOT/test_sets/scripts/vsthlite/parameterisations.sh
  fi
fi

###################################
#  modify system configure
###################################
echo "-----------------------------------------"
echo "notice: we will modify some system config"
echo "-----------------------------------------"

toolsInstall

echo "run configure.sh......"
chmod u+x configure.sh
echo "输入root密码"
su root -c "sh configure.sh"

printf "\n\nYou should now login as the vsx0 user and run $TET_ROOT/setup.sh\n"
echo "Note that additional test suites can be installed by unpacking the"
echo "test suite tarball in $TET_ROOT/test_sets as the vsx0 user and re-running"
echo "$TET_ROOT/setup.sh (this will be ../setup.sh from the home directory)."


