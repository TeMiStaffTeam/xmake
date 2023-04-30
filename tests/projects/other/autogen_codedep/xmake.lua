add_rules("mode.debug", "mode.release")
set_policy("build.across_targets_in_parallel", false)

rule("autogen")
    set_extensions(".in")
    before_buildcmd_file(function (target, batchcmds, sourcefile, opt)

        -- add objectfile
        local sourcefile_cx = path.join(target:autogendir(), "rules", "autogen", path.basename(sourcefile) .. ".cpp")
        local objectfile = target:objectfile(sourcefile_cx)
        table.insert(target:objectfiles(), objectfile)

        -- add commands
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.autogen %s", sourcefile)
        batchcmds:mkdir(path.directory(sourcefile_cx))
        batchcmds:vrunv(target:dep("autogen"):targetfile(), {sourcefile, sourcefile_cx})
        batchcmds:compile(sourcefile_cx, objectfile)

        -- add deps
        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)

target("autogen")
    set_default(false)
    set_kind("binary")
    set_plat(os.host())
    set_arch(os.arch())
    add_files("src/autogen.cpp")
    set_languages("c++11")

target("test")
    set_kind("binary")
    add_deps("autogen")
    add_rules("autogen")
    add_files("src/main.cpp")
    add_files("src/*.in")

