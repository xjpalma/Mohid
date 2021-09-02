#!/usr/bin/env bash
#==============================================================================
#title        : install_req.sh
#description  : This script is an attempt to compile all the necessary libraries
#               to compile MOHID in a machine with Ubuntu or CentOS linux distro
#               and Intel compiler. For more information consult
#               http://wiki.mohid.com and http://forum.mohid.com
#author       : Jorge Palma (jorgempalma@tecnico.ulisboa.pt)
#created      : 20180712
#updated      : 20210521
#usage        : bash install_req.sh
#notes        :
#==============================================================================

CURDIR=$(pwd)

### Make the changes to fit your setup ###

# install libraries path
INSTALL_DIR=$HOME/apps_intel

# have you root permissions? yes or no (uncomment what is best for you)
#sudo=sudo     ## yes
sudo= ## no

# environment script
ENV=$CURDIR/env.sh

# default path to compiler
export CC=/opt/intel/bin/icc
export CXX=/opt/intel/bin/icpc
export FC=/opt/intel/bin/ifort
export F77=/opt/intel/bin/ifort
compilervars=/opt/intel/bin/compilervars.sh
mpivars=/opt/intel/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.sh

# intel flags compiler
export CFLAGS='-O3 -xHost -ip'
export CXXFLAGS='-O3 -xHost -ip'
export FCFLAGS='-O3 -xHost -ip'
export FFLAGS='-O3 -xHost -ip'

# libraries to install
zlib='zlib-1.2.11'
hdf5='hdf5-1.8.17'
netcdf='netcdf-4.4.1.1'
netcdff='netcdf-fortran-4.4.4'
proj='proj-4.9.3'
proj4fortran='proj4-fortran'
iphreeqc='iphreeqc-3.3.11-12535'
phreeqcrm='phreeqcrm-3.3.11-12535'
mpi=mpich
mpi_version='4.0a2'
#openmpi='openmpi-2.0.1'

####################################################
###### -Don't touch anything below this line- ######
####################################################
set -e

# echo colors ##
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
OK=${GREEN}OK${NC}
NOK=${RED}NOK${NC}
ERROR=${RED}ERROR${NC}
WARNING=${RED}warning${NC}

if [ ! -f $ENV ]; then
  ## intel compiler environment
  echo ". ${compilervars} intel64 -platform linux" >>$ENV
  echo ". ${mpivars} -ofi_internal=1 release" >>$ENV
  echo >>$ENV
fi

#### FUNCTIONS ####

#
# source environment variables
#
SOURCE_ENV() {
  . $ENV
}

PAUSE() {
  read -rp "$*"
}

#
# program help
#
HELP() {
  echo
  echo "auto install mohid library"
  echo "Usage: $0 [-option]"
  echo "    -h|-help                : Show this help"
  echo "    -req                    : install compile requirements"
  echo "    -zlib                   : install zlib library"
  echo "    -hdf5                   : install hdf5 library"
  echo "    -nc                     : install netcdf and netcdff library"
  echo "    -ncf                    : install netcdf fortran library"
  echo "    -proj4                  : install proj4 library"
  echo "    -proj4f                 : install proj4-fortran wrapper library"
  echo "    -phqc                   : install iphreeqc library               (optional)"
  echo "    -phqcrm                 : install phreeqcrm library              (optional)"
  echo "    -mpich                  : install mpich                          (optional)"
  #echo "    -openmpi                : install open-mpi"
  echo "    -rm                     : remove tmp install dir (~/.mohid)"
  echo
}

#
# install requirements
#
OPT_REQ() {
  echo
  echo " #### Install requirements ####"
  #PAUSE 'Press [Enter] key to continue...'
  if ! exist="$(type -p "wget")" || [ -z "$exist" ]; then
    $sudo $PACKMANAG install wget
  fi
  ## to install netcdf library
  if ! exist="$(type -p "m4")" || [ -z "$exist" ]; then
    $sudo $PACKMANAG install m4
  fi
  ## to install proj4-fortran library
  if ! exist="$(type -p "git")" || [ -z "$exist" ]; then
    $sudo $PACKMANAG install git
  fi
  if ! exist="$(type -p "autoconf")" || [ -z "$exist" ]; then
    $sudo $PACKMANAG install autoconf
  fi
  if ! exist="$(type -p "automake")" || [ -z "$exist" ]; then
    $sudo $PACKMANAG install automake
  fi

  if ! exist="$(type -p "gcc")" || [ -z "$exist" ]; then
    $sudo $PACKMANAG install gcc gcc-c++ gcc-gfortran
  fi
  echo -e "${GREEN} All basic requirements are installed${NC}"
  echo
}

## install mpich ##
OPT_MPICH(){
       echo
    echo " #### Install $mpich ####"
    #PAUSE 'Press [Enter] key to continue...'
    mpiv="$mpi-$mpi_version"
    RM_DIR $DIRINSTALL/$mpiv
    if [ ! -e $TMPDIRINSTALL/$mpiv.tar.gz ]; then
      wget "http://www.mpich.org/static/downloads/$mpi_version/$mpiv.tar.gz"
    fi
    tar -xf "$mpiv.tar.gz"
    cd $mpiv || exit 1
    CC=$CC CXX=$CXX F77=$F77 FC=$FC  \
    ./configure --prefix=$DIRINSTALL/$mpiv \
                --enable-fast=O3 --disable-error-checking --without-timing --without-mpit-pvars --with-device=ch4:ofi || exit 1
                ##--with-pm=smpd --with-pmi=smpd
    make || exit 1
    $sudo make install || exit 1
    echo "############ $mpi-$mpi_version ############" >> ~/.bashrc
    echo "MPICH=$DIRINSTALL/$mpiv" >> ~/.bashrc
    echo 'export MPIRUN=$MPICH/bin/mpirun' >> ~/.bashrc
    echo 'export PATH=$PATH:$MPICH/bin:$MPICH/lib:$MPICH/include' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MPICH/lib' >> ~/.bashrc
    echo >> ~/.bashrc
}

#
# install openmpi
#
OPT_OPENMPI() {
  echo
  echo " #### Install $openmpi ####"
  #PAUSE 'Press [Enter] key to continue...'
  RM_DIR $INSTALL_DIR/$openmpi
  wget "https://www.open-mpi.org/software/ompi/v2.0/downloads/$openmpi.tar.gz"
  tar -xf "$openmpi.tar.gz"
  cd $openmpi || exit
  CC=$CC CXX=$CXX F77=$F77 FC=$FC ./configure --prefix=$INSTALL_DIR/$openmpi
  make
  $sudo make install
  echo "############ $openmpi ############" >>$ENV
  echo "OPENMPI=$INSTALL_DIR/$openmpi" >>$ENV
  echo 'export MPIRUN=$OPENMPI/bin/mpirun' >>$ENV
  echo 'export PATH=$PATH:$OPENMPI/bin:$OPENMPI/lib:$OPENMPI/include' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OPENMPI/lib' >>$ENV
  echo >>$ENV
}

#
# install zlib library
#
OPT_ZLIB() {
  echo
  echo " #### Install $zlib ####"
  #PAUSE 'Press [Enter] key to continue...'
  RM_DIR $INSTALL_DIR/$zlib
  if [ ! -e $SOURCE_DIR/$zlib.tar.gz ]; then
    wget "http://zlib.net/$zlib.tar.gz"
  fi
  tar -xf "$zlib.tar.gz"
  cd $zlib
  ./configure --prefix=$INSTALL_DIR/$zlib || exit 1
  make || exit 1
  $sudo make install || exit 1
  echo "###### $zlib #########" >>$ENV
  echo "ZLIB=$INSTALL_DIR/$zlib" >>$ENV
  echo 'export PATH=$PATH:$ZLIB/lib:$ZLIB/include' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ZLIB/lib' >>$ENV
  echo >>$ENV
}

#
# install hdf5 library
#
OPT_HDF5() {
  echo
  echo " #### Install $hdf5 ####"
  echo -e " see ${GREEN}https://software.intel.com/en-us/articles/performance-tools-for-software-developers-building-hdf5-with-intel-compilers${NC}"
  PAUSE "Press [Enter] key to continue..."
  RM_DIR $INSTALL_DIR/$hdf5
  if [ ! -e $SOURCE_DIR/$hdf5.tar.gz ]; then
    wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/$hdf5/src/$hdf5.tar.gz"
  fi
  tar -xf "$hdf5.tar.gz"
  cd $hdf5 || exit 1
  CC=$CC FC=$FC ./configure --with-zlib=$INSTALL_DIR/$zlib --prefix=$INSTALL_DIR/$hdf5 --enable-fortran --enable-fortran2003 || exit 1
  make || exit 1
  #make check || exit 1
  $sudo make install || exit 1
  echo "####### $hdf5 #######" >>$ENV
  echo "HDF5=$INSTALL_DIR/$hdf5" >>$ENV
  echo 'export PATH=$PATH:$HDF5/bin:$HDF5/lib:$HDF5/include' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HDF5/lib' >>$ENV
  echo >>$ENV
}

#
# install netcdf C library
#
OPT_NC() {
  RM_DIR $INSTALL_DIR/$netcdf
  export CPPFLAGS="-I$INSTALL_DIR/$hdf5/include -I$INSTALL_DIR/$zlib/include"
  export LDFLAGS="-L$INSTALL_DIR/$hdf5/lib -L$INSTALL_DIR/$zlib/lib"
  if [ ! -e $SOURCE_DIR/$netcdf.tar.gz ]; then
    wget "ftp://ftp.unidata.ucar.edu/pub/netcdf/$netcdf.tar.gz"
  fi
  tar -xf "$netcdf.tar.gz"
  cd $netcdf || exit 1
  CC=$CC CFLAGS=$CFLAGS FC=$FC ./configure --prefix=$INSTALL_DIR/$netcdf || exit 1
  make || exit 1
  $sudo make install || exit 1
  echo
  echo "########## $netcdf #######" >>$ENV
  echo "export NETCDF=$INSTALL_DIR/${netcdf}" >>$ENV
  echo 'export PATH=$PATH:$NETCDF/bin:$NETCDF/lib:$NETCDF/include' >>$ENV
  echo >>$ENV
  echo 'export NETCDF_ROOT=$NETCDF' >>$ENV
  echo 'export NETCDF4_ROOT=$NETCDF' >>$ENV
  echo 'export NETCDF_LIB=$NETCDF/lib' >>$ENV
  echo 'export NETCDF_INC=$NETCDF/include' >>$ENV
  echo >>$ENV
  echo 'export NETCDF_GF_ROOT=$NETCDF' >>$ENV
  echo 'export NETCDF4_GF_ROOT=$NETCDF' >>$ENV
  echo 'export NETCDF_GF_LIB=$NETCDF/lib' >>$ENV
  echo 'export NETCDF_GF_INC=$NETCDF/include' >>$ENV
  echo >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NETCDF_LIB' >>$ENV
  echo >>$ENV
  echo 'export CPPFLAGS="$CPPFLAGS -I$NETCDF_INC"' >>$ENV
  echo 'export LDFLAGS="$LDFLAGS -L$NETCDF_LIB"' >>$ENV
  echo >>$ENV
}

#
# install netcdf fortran library
#
OPT_NCF() {
  export CPPFLAGS="-I$INSTALL_DIR/$hdf5/include -I$INSTALL_DIR/$zlib/include"
  export LDFLAGS="-L$INSTALL_DIR/$hdf5/lib -L$INSTALL_DIR/$zlib/lib"
  export NETCDF=$INSTALL_DIR/${netcdf}
  export PATH=$PATH:$NETCDF/bin:$NETCDF/lib:$NETCDF/include
  export NETCDF_ROOT=$NETCDF
  export NETCDF4_ROOT=$NETCDF
  export NETCDF_LIB=$NETCDF/lib
  export NETCDF_INC=$NETCDF/include
  export NETCDF_GF_ROOT=$NETCDF
  export NETCDF4_GF_ROOT=$NETCDF
  export NETCDF_GF_LIB=$NETCDF/lib
  export NETCDF_GF_INC=$NETCDF/include
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NETCDF_LIB
  export CPPFLAGS="$CPPFLAGS -I$NETCDF_INC"
  export LDFLAGS="$LDFLAGS -L$NETCDF_LIB"
  if [ ! -e $SOURCE_DIR/$netcdff.tar.gz ]; then
    wget "ftp://ftp.unidata.ucar.edu/pub/netcdf/$netcdff.tar.gz"
  fi
  tar -xf "$netcdff.tar.gz"
  cd $netcdff || exit
  CC=$CC FC=$FC ./configure --prefix=$INSTALL_DIR/$netcdf || exit 1
  make || exit 1
  $sudo make install || exit 1
}

#
# install proj4 library
#
OPT_PROJ4() {
  cd $SOURCE_DIR || exit 1
  echo
  echo " #### Install $proj ####"
  #PAUSE 'Press [Enter] key to continue...'
  RM_DIR $INSTALL_DIR/$proj
  if [ ! -e $SOURCE_DIR/$proj.tar.gz ]; then
    wget "http://download.osgeo.org/proj/$proj.tar.gz"
  fi
  tar -xf "$proj.tar.gz"
  cd $proj || exit 1
  ./configure --prefix=$INSTALL_DIR/$proj CC=$CC FC=$FC || exit 1
  make || exit 1
  $sudo make install || exit 1
  ## must create libproj4.so for proj4-fortran install process
  $sudo ln -sf $INSTALL_DIR/$proj/lib/libproj.so $INSTALL_DIR/$proj/lib/libproj4.so
  echo "############ $proj ############" >>$ENV
  echo "PROJ4=$INSTALL_DIR/$proj" >>$ENV
  echo 'export PATH=$PATH:$PROJ4/bin:$PROJ4/lib:$PROJ4/include' >>$ENV
  echo 'export PROJ_PREFIX=$PROJ4/lib' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PROJ4/lib' >>$ENV
  echo >>$ENV
}

#
# install proj4-fortran library
#
OPT_PROJ4F() {
  cd $SOURCE_DIR || exit 1
  echo
  echo " #### Install $proj4fortran ####"
  #PAUSE 'Press [Enter] key to continue...'
  if [ ! -d $SOURCE_DIR/$proj4fortran ]; then
    git clone https://github.com/mhagdorn/proj4-fortran.git
  fi
  cd $proj4fortran || exit 1
  git checkout 2865227446959983dbda81d52f999921d8b84ad5
  ./bootstrap
  [ -f configure.in ] && mv configure.in configure.ac
  CC=$CC CFLAGS="$CFLAGS -DIFORT" FC=$FC FFLAGS=$FFLAGS FCFLAGS=$FCFLAGS ./configure --with-proj4=$INSTALL_DIR/$proj --prefix=$INSTALL_DIR/$proj4fortran || exit 1
  ## IF error, add -DIFORT or -D<COMPILER_TAG> in the compile expression
  echo
  echo -e " ${RED}If error occur, you need to specify which F90 compiler you use e.g. for INTEL compiler add -DIFORT; For GNU compiler add -Df2cFortran. See cfortran.h ${NC}"
  echo -e " ${RED}cd $SOURCE_DIR/$proj4fortran; Copy compile command, add correct compiler flag and run it. After that, run \"make; make install\"${NC}"
  echo -e " ${RED}After that, you must close and reopen your session in another shell to load new env variables added in .bashrc ${NC}"
  echo
  PAUSE 'Press [Enter] key to continue...'
  echo "############ $proj4fortran ############" >>$ENV
  echo "PROJ4FORTRAN=$INSTALL_DIR/$proj4fortran" >>$ENV
  echo 'export PATH=$PATH:$PROJ4FORTRAN/lib:$PROJ4FORTRAN/include' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PROJ4FORTRAN/lib' >>$ENV
  echo >>$ENV
  make || exit 1
  $sudo make install || exit 1
}

#
# install iphreeqc library (https://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc)
#
OPT_IPHC() {
  cd $SOURCE_DIR || exit
  echo
  echo " #### Install $iphreeqc ####"
  #PAUSE 'Press [Enter] key to continue...'
  RM_DIR $INSTALL_DIR/$iphreeqc
  wget "ftp://brrftp.cr.usgs.gov/pub/charlton/iphreeqc/$iphreeqc.tar.gz"
  tar -xf "$iphreeqc.tar.gz"
  cd $iphreeqc || exit
  ## The module IPhreeqc has been revised when using Fortran.
  ## IPhreeqc is now a Fortran “module”. The old IPhreeqc.f.inc and IPhreeqc.f90.inc files are no longer used to define the interfaces for the subroutines of IPhreeqc.
  ## The include files (.inc) are now replaced with “USE” statements (USE IPhreeqc). In addition, an interface file (IPhreeqc_interface.F90) must be included in the user’s Fortran project.
  ## IPhreeqc now uses ISO_C_BINDING, which is available in the Fortran 2003 standard. Use of this standard removes some ambiguities in argument types when calling C.
  ##
  ## In Fortran, you will need to include the source file IPhreeqc_interface.F90 in your project files. This file defines the IPhreeqc Fortran module.
  ## This is the preferred method to use IPhreeqc from a Fortran program.
  CC=$CC FC=$FC ./configure --prefix=$INSTALL_DIR/$iphreeqc --enable-fortran-module=yes --enable-fortran-test=yes
  make
  make check
  $sudo make install
  echo "############ $iphreeqc ############" >>$ENV
  echo "IPHREEQC=$INSTALL_DIR/$iphreeqc" >>$ENV
  echo 'export PATH=$PATH:$IPHREEQC/lib:$IPHREEQC/include' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$IPHREEQC/lib' >>$ENV
  echo >>$ENV
}

#
# install phreeqcrm library (https://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc)
#
OPT_PHCRM() {
  echo
  echo " #### Install $phreeqcrm ####"
  #PAUSE 'Press [Enter] key to continue...'
  RM_DIR $INSTALL_DIR/$phreeqcrm
  wget "ftp://brrftp.cr.usgs.gov/pub/charlton/phreeqcrm/$phreeqcrm.tar.gz"
  tar -xf "$phreeqcrm.tar.gz"
  cd $phreeqcrm || exit
  CC=$CC FC=$FC ./configure --prefix=$INSTALL_DIR/$phreeqcrm
  make
  $sudo make install
  echo "############ $phreeqcrm ############" >>$ENV
  echo "PHREEQCRM=$INSTALL_DIR/$phreeqcrm" >>$ENV
  echo 'export PATH=$PATH:$PHREEQCRM/lib:$PHREEQCRM/include' >>$ENV
  echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PHREEQCRM/lib' >>$ENV
  echo >>$ENV
}

#
# remove install directory
#
OPT_RM() {
  $sudo rm -rf $SOURCE_DIR
  echo " $SOURCE_DIR removed with success"
  echo
}

#
# remove install directory if exist
#
RM_DIR() {
  LINK_OR_DIR=$1
  if [ -d "$LINK_OR_DIR" ]; then
    read -r -p " Install dir $LINK_OR_DIR already exist. Are you sure you want to continue? [y/N] " response
    case "$response" in
    [yY])
      $sudo rm -rf "$LINK_OR_DIR"
      ;;
    *)
      exit 0
      ;;
    esac
  fi
}

# ----------- Main -------------- ##

# create install and source directory ##
SOURCE_DIR=~/.mohid
if [ ! -d "$INSTALL_DIR" ]; then
  $sudo mkdir -p $INSTALL_DIR
fi
if [ ! -d "$SOURCE_DIR" ]; then
  mkdir -p $SOURCE_DIR
fi

##
OS=$(cat /etc/*-release)
case $OS in
*Ubuntu*)
  PACKMANAG=apt
  ;;
*CentOS*)
  PACKMANAG=yum
  ;;
*)
  echo
  echo " This script only work for Ubuntu and CentOS Linux distribuition"
  echo " Maybe you can manually adapt for your linux distribution..."
  echo
  exit 1
  ;;
esac

# install options ##
if [ $# -lt 1 ]; then
  HELP
  exit 0
fi

cd $SOURCE_DIR || exit 1

SOURCE_ENV

case $1 in
-h | -help | --help)
  HELP
  ;;
-req)
  OPT_REQ
  exit 0
  ;;
-zlib)
  OPT_ZLIB
  ;;
-hdf5)
  OPT_HDF5
  ;;
-nc)
  OPT_NC
  ;;
-ncf)
  OPT_NCF
  ;;
-proj4)
  OPT_PROJ4
  ;;
-proj4f)
  OPT_PROJ4F
  ;;
-phqc)
  OPT_IPHC
  ;;
-phqcrm)
  OPT_PHCRM
  ;;
-mpich)
  OPT_MPICH
  ;;
-openmpi)
  OPT_OPENMPI
  ;;
-rm)
  OPT_RM
  exit 0
  ;;
*)
  echo
  echo -e " ${ERROR}: unrecognized command line option $1. Use  $0 -h  for help."
  exit 0
  ;;
esac

exit 0
