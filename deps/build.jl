using BinaryProvider

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

libpath = joinpath(@__DIR__, "usr/darknet-master")

products = Product[
    LibraryProduct(libpath,"libdarknet", :libdarknet)
    ]

# Download binaries from hosted location
bin_prefix = "https://github.com/ianshmean/bins/raw/master/3rdparty/Darknet"
download_info = Dict()                 
if ENV["DARKNET_GPU"] == 1
    if ENV["DARKNET_CUDNN"] == 1
        if ENV["DARKNET_CUDNN_HALF"] == 1    
            #GPU CUDNN & CUDNN_HALF
            download_info = Dict(
                MacOS(:x86_64)  => ("$bin_prefix/darknet-AlexeyAB-YOLOv3-MacOS.10.14.3-[GPU-CUDNN-CUDNN_HALF].tar.gz", "177c43bf864910e5e5549ef77fd65d7899c73a40e564dbc010cccd31af3f5feb")                  
            )
        else
            #GPU,CUDNN
        end
    else
        #GPU
    end
else
    if ENV["DARKNET_OPENMP"] == 1
        #CPU, OPENMP
    else
        #CPU
        download_info = Dict(
            MacOS(:x86_64)  => ("$bin_prefix/darknet-AlexeyAB-YOLOv3-MacOS.10.14.3-[CPU].tar.gz", "c9d79e1918c785149d39920608b4efb22fc910895ab6baf9aa5f7f43169a37fe"),                     
        )
    end
end

# First, check to see if we're all satisfied
@show satisfied(products[1]; verbose=true)
if any(!satisfied(p; verbose=false) for p in products)
    try
        # Download and install binaries
        url, tarball_hash = choose_download(download_info)
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    catch e
        if typeof(e) <: ArgumentError || typeof(e) <: MethodError
            error("Your platform $(Sys.MACHINE) is not supported by this package!")
        else
            rethrow(e)
        end
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
