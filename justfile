dr:
    cd backend/base && cargo loco db reset

dm:
    cd backend/base && cargo loco db migrate

de:
    cd backend/base && cargo loco db entities

ss:
    cd backend/base && cargo loco start

csm:
    cd buzzing && flutter run -d macos

csw:
    cd buzzing && flutter run -d windows

cbm:
    cd buzzing && flutter build macos

cidl:
    cd buzzing && python3 util.py -c idl -t dart -s ../proto -o ./lib/models/idl/
clib:
    cd buzzing && python3 util.py -c lib -t debug -i ../sdk

cdeploy:
    cd buzzing && python3 util.py -c lib -t release -i ../sdk

cbuild:
    cd buzzing && python3 util.py -c build

cjson:
    cd buzzing && flutter packages pub run build_runner build

init_data:
    cd utils && NODE_TLS_REJECT_UNAUTHORIZED=0 node init.js

client_macos_fix_pod:
    cd buzzing/macos && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && pod install --repo-update

client_gen_slang:
    cd buzzing && dart run slang

client_gen_pb:
    cd buzzing && python3
