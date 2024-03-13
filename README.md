# otawa-project
Meta-repository of the OTAWA project. Fork of https://sourcesup.renater.fr/projects/otawa/.

## Cloning
In order to clone this repository, you need to enable submodules:

```sh
git clone https://github.com/statinf-otawa/otawa-project --recurse-submodules
```

## External dependencies
See below.

## Docker
You can get a base version of OTAWA with ARM/PPC/RISCV/Tricore support using Docker:

```
docker build . -t otawa_base
```

Or directly pull it from [Github's Container Repository](https://github.com/orgs/statinf-otawa/packages)

```
docker pull ghcr.io/statinf-otawa/otawa-base
```

## Building
Provided you have the correct dependencies, this script should get you a running OTAWA install with ARM plugins:

```sh
# Set our install path. Example: $HOME/otawa-install
# You should add $OTAWA_INSTALL_DIR/bin to your $PATH!
export OTAWA_INSTALL_DIR=$HOME/otawa-install

# We start with OTAWA itself
# Build elm first, the alternative standard C library for OTAWA
cd elm; mkdir build ; cd build
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR ..
make install -j4
cd ../..
# Now build gel and gel++, to open and analyse binary files
cd gel
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR .
make install
cd ..
cd gelpp ; mkdir build ; cd build
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR ..
make install
cd ../..
# Now build OTAWA
cd otawa ; mkdir build ; cd build
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR ..
make install
cd ../..

# Then, we need to build the support for our architecture
cd archs
# Build GLISS2 first: GLISS2 is the software that lets us generate ISA from NMP projects
cd gliss2
make; cd ..
# Now, build the architectures (you can skip those you are not interested in)
# This will transform each NMP project into a C library
cd armv5t; make; cd ..
cd armv7t; make WITH_FAST_STATE=1; cd .. # FAST_STATE is used to generate used_regs which we need for otawa-arm
cd aarch64-armv8v9 ; make ; cd ..
cd mips; make; cd ..
cd ppc; make WITH_DYNLIB=1; cd ..
cd riscv; make WITH_DYNLIB=1; cd ..
cd tms; make; cd ..

# Now, we should build the plugins that use these generated C libraries and incorporate them into OTAWA
cd otawa-arm
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
cd ..
cd otawa-aarch64
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
cd ..
cd otawa-ppc
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
cd ..
cd otawa-riscv
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR -DOTAWA_CONFIG=$OTAWA_INSTALL_DIR/bin/otawa-config . && make install
cd ..

cd .. # Back to the project root
# Now, we build the ILP solver lp_solve5 and its otawa plugin
cd lp_solve5; cmake .; make; cd ..
cd otawa-lp_solve5
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR . && make install
cd ..

# Obviews does not depend on the above nor does it require building
# make install copies the script
cd obviews
cmake .
make install
cd ..

# Add dcache library
cd otawa-clp ; mkdir build ; cd build
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR ..
make install
cd ../../otawa-dcache ; mkdir build ; cd build
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR ..
make install

# Add xilinx board support
cd ../../archs/otawa-xilinx
cmake -DCMAKE_INSTALL_PREFIX=$OTAWA_INSTALL_DIR .
make install


# What we did not build: some obsolete architectures. Also, FrontC and Orange remain for loop bound identification. Thot for a custom documentation format used throughout. Some of the repositories also have documentation that is available with make doxygen
```

## Original documentation
For the original documentation of the OTAWA project, see https://www.tracesgroup.net/otawa/. In particular, from [this page](https://www.tracesgroup.net/otawa/?page_id=419)

> OTAWA v2 is embedding a new installation that supports OTAWA installation and third-party plug-in installation from web repository, called `otawa-install.py`. Note `otawa-install.py` should only work only for Linux but we hope to quickly adapt it to Mac and Windows.
> 
> Before running `otawa-install.py`, the following dependencies must/may be available:
> 
> - Python 3 (required)
> - GNU C++ (required)
> - OCaml (required)
> - Flex, Bison (required)
> - libxml2-dev, libxslt1-dev (required)
> - cmake, git (required)
> - GraphViz (for graph output)
> 
> Using `otawa-install.py` is relatively easy. First download it in the directory that will contain the installation of OTAWA (say, `OTAWA_HOME`).
> 
>     $ cd OTAWA_HOME
>     $ ./otawa-install.py
>     The packages will be installed in /home/casse/tmp/otawa: [yes/NO]: yes
> 
> This will take a while to install the minimum set of libraries and tools for OTAWA. Be patient…
> 
> After that, recall to use the otawa-install.py command in OTAWA_HOME/bin/otawa-install.py to install some plug-in.
> 
> To get the list of plugins, just type:
> 
> ```
> OTAWA_HOME/bin/otawa-install.py -l
> ```
> 
> Note that OTAWA is first delivered alone (no instruction set, no micro-architecture except trivial ones, no ILP solver). You have to use `otawa-install.py` to install them.
