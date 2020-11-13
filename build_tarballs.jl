# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "libint_compiler"
version = v"2.7.0"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/evaleev/libint.git", "3bf3a07b58650fe2ed4cd3dc6517d741562e1249")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libint/
./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} --enable-shared=yes --enable-static=no --enable-1body=1 --enable-eri=1
make -j`nproc` export
cp libint-2.7.0-beta.3.tgz ../
cd ..
tar -xzvf libint-2.7.0-beta.3.tgz 
cd libint-2.7.0-beta.3
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -DLIBINT2_BUILD_SHARED_AND_STATIC_LIBS=ON ..
cmake --build . --target install -- -j${nproc}    
exit
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc)
]


# The products that we will ensure are always built
products = [
    LibraryProduct("libint2", :Libint2)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="GMP_jll", uuid="781609d7-10c4-51f6-84f2-b8444358ff6d"))
    Dependency(PackageSpec(name="Eigen_jll", uuid="bc6bbf8a-a594-5541-9c57-10b0d0312c70"))
    Dependency(PackageSpec(name="boost_jll", uuid="28df3c45-c428-5900-9ff8-a3135698ca75"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version = v"7.1.0")
