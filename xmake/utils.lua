function out_c_path()
    return path.join("build", os.host(), os.arch(), get_config('mode'))
end
function out_c_dir(sourcefile)
    return path.join("build", os.host(), os.arch(), get_config('mode'), path.basename(sourcefile)..".c")
end