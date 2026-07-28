-- Buzzing project build/management tasks
-- xmake equivalent of justfile

-- Cross-platform pnpm command (local upvalue accessible inside on_run sandbox)
local _pnpm_cmd
if is_host("windows") then
    _pnpm_cmd = "cmd.exe /c pnpm "
else
    _pnpm_cmd = "pnpm "
end

-- Task: db reset
task("dr")
    set_menu {
        usage = "xmake dr",
        description = "Reset database"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend/base")
        os.exec("cargo loco db reset")
    end)

-- Task: db migrate
task("dm")
    set_menu {
        usage = "xmake dm",
        description = "Run database migrations"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend/base")
        os.exec("cargo loco db migrate")
    end)

-- Task: db entities
task("de")
    set_menu {
        usage = "xmake de",
        description = "Generate entities from database schema"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend/base")
        os.exec("cargo loco db entities")
    end)

-- Task: server dev mode
task("sd")
    set_menu {
        usage = "xmake sd",
        description = "Start server in dev mode (reads frontend/dist from filesystem)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend")
        os.exec("cargo run -p app --no-default-features")
    end)

-- Task: server production mode
task("ss")
    set_menu {
        usage = "xmake ss",
        description = "Start server in production mode (embeds frontend assets)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend/base")
        os.exec("cargo loco start")
    end)

-- Task: server release build
task("sr")
    set_menu {
        usage = "xmake sr",
        description = "Build server release (embeds frontend assets)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend")
        os.exec("cargo build --release -p app --features base/embed")
    end)

-- Task: client start (macOS)
task("csm")
    set_menu {
        usage = "xmake csm",
        description = "Run Flutter client on macOS"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        os.exec("flutter run -d macos")
    end)

-- Task: client start (Windows)
task("csw")
    set_menu {
        usage = "xmake csw",
        description = "Run Flutter client on Windows"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        os.exec("flutter run -d windows")
    end)

-- Task: client build (macOS)
task("cbm")
    set_menu {
        usage = "xmake cbm",
        description = "Build Flutter client for macOS"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        os.exec("flutter build macos")
    end)

-- Task: generate protobuf idl for client
task("cidl")
    set_menu {
        usage = "xmake cidl",
        description = "Generate Protobuf IDL for Flutter client"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        local ok = os.exec("python3 util.py -c idl -t dart -s ../proto -o ./lib/models/idl/")
        if not ok then
            os.exec("python util.py -c idl -t dart -s ../proto -o ./lib/models/idl/")
        end
    end)

-- Task: build client SDK (debug)
task("clib")
    set_menu {
        usage = "xmake clib",
        description = "Build client SDK in debug mode"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        local ok = os.exec("python3 util.py -c lib -t debug -i ../sdk")
        if not ok then
            os.exec("python util.py -c lib -t debug -i ../sdk")
        end
    end)

-- Task: build client SDK (release)
task("cdeploy")
    set_menu {
        usage = "xmake cdeploy",
        description = "Build client SDK in release mode"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        local ok = os.exec("python3 util.py -c lib -t release -i ../sdk")
        if not ok then
            os.exec("python util.py -c lib -t release -i ../sdk")
        end
    end)

-- Task: build client (full)
task("cbuild")
    set_menu {
        usage = "xmake cbuild",
        description = "Build client (full build, not recommended)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        local ok = os.exec("python3 util.py -c build")
        if not ok then
            os.exec("python util.py -c build")
        end
    end)

-- Task: generate JSON serialization code
task("cjson")
    set_menu {
        usage = "xmake cjson",
        description = "Run build_runner for JSON serialization"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        os.exec("dart run build_runner build")
    end)

-- Task: generate i18n code
task("client_gen_slang")
    set_menu {
        usage = "xmake client_gen_slang",
        description = "Generate i18n/localization code"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing")
        os.exec("dart run slang")
    end)

-- Task: init user data
task("init_data")
    set_menu {
        usage = "xmake init_data",
        description = "Initialize user data (accounts, tenants, departments)"
    }
    on_run(function ()
        os.setenv("NODE_TLS_REJECT_UNAUTHORIZED", "0")
        os.cd(os.scriptdir() .. "/utils")
        os.exec("node init.js")
    end)

-- Task: init test data
task("init_data_test")
    set_menu {
        usage = "xmake init_data_test",
        description = "Initialize with test tenant data"
    }
    on_run(function ()
        os.setenv("NODE_TLS_REJECT_UNAUTHORIZED", "0")
        os.cd(os.scriptdir() .. "/utils")
        os.exec("node init.js -s ./init_test.json")
    end)

-- Task: fix CocoaPods (macOS only)
task("client_macos_fix_pod")
    set_menu {
        usage = "xmake client_macos_fix_pod",
        description = "Fix CocoaPods versions for macOS client"
    }
    on_run(function ()
        if os.host() ~= "macosx" then
            print("This task is only available on macOS")
            return
        end
        os.setenv("LANG", "en_US.UTF-8")
        os.setenv("LC_ALL", "en_US.UTF-8")
        os.cd(os.scriptdir() .. "/buzzing/macos")
        os.exec("pod install --repo-update")
    end)

-- Task: SDK integration test
task("sdk_test")
    set_menu {
        usage = "xmake sdk_test",
        description = "Run SDK integration tests (compile Rust + run dart tests)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/buzzing/sdk_test")
        os.exec("bash run.sh")
    end)

-- Task: backend business test
task("backend_test")
    set_menu {
        usage = "xmake backend_test",
        description = "Run backend business tests (requires server running)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend_test")
        os.exec("npm run test:business")
    end)

-- Task: backend smoke test
task("backend_test_smoke")
    set_menu {
        usage = "xmake backend_test_smoke",
        description = "Run backend smoke tests (connectivity + login flow)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/backend_test")
        os.exec("npm run test:smoke")
    end)

-- Task: install protoc dart plugin
task("install_protoc_dart")
    set_menu {
        usage = "xmake install_protoc_dart",
        description = "Install protoc-gen-dart plugin"
    }
    on_run(function ()
        os.exec("dart pub global activate protoc_plugin")
    end)

-- Task: frontend dev server
task("fw")
    set_menu {
        usage = "xmake fw",
        description = "Start frontend dev server (http://localhost:5173)"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/frontend")
        os.exec(_pnpm_cmd .. "dev")
    end)

-- Task: frontend build
task("fb")
    set_menu {
        usage = "xmake fb",
        description = "Build frontend for production"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/frontend")
        os.exec(_pnpm_cmd .. "build")
    end)

-- Task: frontend install deps
task("fi")
    set_menu {
        usage = "xmake fi",
        description = "Install frontend dependencies"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/frontend")
        os.exec(_pnpm_cmd .. "install")
    end)

-- Task: frontend build
task("fd")
    set_menu {
        usage = "xmake fd",
        description = "Start frontend dev"
    }
    on_run(function ()
        os.cd(os.scriptdir() .. "/frontend")
        os.exec(_pnpm_cmd .. "dev")
    end)
