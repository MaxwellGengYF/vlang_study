set_xmakever('2.9.2')
add_rules('mode.release', 'mode.debug')
-- disable ccache in-case error
set_policy('build.ccache', false)

option('v_path')
set_showmenu(true)
set_default(false)
after_check(function(option)
    if not option:enabled() then
        utils.error('Illegal vlang path.')
    end
end)
option_end()

option('vlang_check_env')
set_showmenu(false)
set_default(false)
after_check(function(option)
    if not is_arch('x64', 'x86_64', 'arm64') then
        option:set_value(false)
        utils.error('Illegal environment. Please check your compiler, architecture or platform.')
        return
    end
    if not (is_mode('debug') or is_mode('release') or is_mode('releasedbg')) then
        option:set_value(false)
        utils.error("Illegal mode. set mode to 'release', 'debug' or 'releasedbg'.")
        return
    end
    option:set_value(true)
end)
option_end()

includes('xmake/xmake_func.lua')
target('codegen_v')
set_kind('object')
set_policy('build.across_targets_in_parallel', false)
add_files('src/*.v')
add_rules('codegen_v_rule')
target_end()

target('compile_v')
_config_project({
    project_kind = 'binary'
})
on_config(function(target)
    local _, cc = target:tool("cc")
        if (cc == "clang" or cc == "clangxx") then
            target:add('defines', 'CUSTOM_DEFINE_no_bool')
        end
end)
on_load(function(target)
    local v_path = get_config('v_path')
    local thirdparty = path.join(v_path, 'thirdparty')
    local dirs = {'libgc/include'}
    for _, v in ipairs(dirs) do
        target:add('includedirs', path.join(thirdparty, v), {
            public = true
        })
    end
    target:add('files', path.join(thirdparty, 'libgc/gc.c'))
    if is_plat('windows') then
        target:add('syslinks', 'Ole32', 'Advapi32', 'User32')
    elseif is_plat('linux') then
        target:add('syslinks', 'uuid')
    else
        target:add('frameworks', 'CoreFoundation')
    end
end)

add_rules('compile_v_rule', 'c.build')
add_deps('codegen_v')
add_files('src/*.v')
target_end()
