const axios = require('axios');
const { readFileSync } = require('fs');
const source = require('./init.json');
// const source = require('./test.json');
const jsonbig = require('json-bigint');
const proto = require('./proto.js');
const protobuf = require('protobufjs')


axios.defaults.baseURL = 'http://127.0.0.1:5150';
axios.defaults.transformResponse = [
  function (data) {
    const json = jsonbig({storeAsString: true})
    const res = json.parse(data)
    return res
  }
]

const PBAccount = proto.lookup('entity.Account')
async function account_login(account) {
  var result = await axios({
    url: '/api/accounts/login',
    method: 'POST',
    json: true,
    headers: {
      "content-type": "application/json",
    },
    data: {
      "phone": account.phone,
      "password": account.password
    }
  }).then(res => {
    console.log('login ok: ', res.data)
    account.users = res.data.users
    account.id = res.data.id
    return true;
  }).catch(error => {
    console.log('login error: ', error)
    return false
  })
  console.log("login got ", result)
  return result
}

async function account_register(account) {
  var result = await axios({
    url: '/api/accounts/register',
    method: 'POST',
    json: true,
    headers: {
      "content-type": "application/json",
    },
    data: {
      "phone": account.phone,
      "password": account.password,
      "name": account.name
    }
  }).then(res => {
    console.log('register ok: ', res.data)
    return true
  }).catch(error => {
    console.log('register error: ', error)
    return false
  })
  console.log("register got ", result)
  return result
}

async function tenant_create(account, name) {
  console.log("create tenant with account: ", account)
  var result = await axios({
    url: '/api/tenants/create',
    method: 'POST',
    json: true,
    headers: {
      "content-type": "application/json",
      "authorization":"Bearer "+ account.users[0].token
    },
    data: {
      "name": name
    }
  }).then(res => {
    console.log('create tenant ok: ', res.data)
    return true
  }).catch(error => {
    console.log('create tenant error')
    return false
  })
  console.log("create tenant got ", result)
  return result
}

async function tenant_join(user, id, dept_id) {
  var result = await axios({
    url: '/api/tenants/join',
    method: 'POST',
    json: true,
    headers: {
      "content-type": "application/json",
      "authorization":"Bearer "+user.token
    },
    data: {
      "id": id,
      "dept_id":  dept_id
    }
  }).then(res => {
    console.log('tenant join ok: ', res.data)
    return true
  }).catch(error => {
    console.log('tenant join error: ',  error)
    return false
  })
  console.log("tenant join got ", result)
  return result
}

async function dept_get(user, dept_id, depts) {
  var result = await axios({
    url: '/api/depts/'+ dept_id,
    method: 'GET',
    json: true,
    headers: {
      "content-type": "application/json",
      "authorization":"Bearer "+user.token
    }
  }).then(res => {
    console.log('get dept ok: ', res.data)
    depts[res.data.id] = res.data
    return true
  }).catch(error => {
    console.log('get dept error', error)
    return false
  })
  console.log("get dept got ", result)
  return result
}

async function main() {
  // load data
  console.log(source)

  accounts = {}

  // init accounts
  for(i in source.accounts) {
    console.log("i: ", i)
    account = source.accounts[i]
    console.log(account)

    accounts[i] = account

    // check exists
    var ret = await account_login(account)
    // register
    if(!ret) {
      console.log("login error, try regiser")
      ret = await account_register(account)

      if(ret) {
        // login
        ret = await account_login(account)
        if(!ret) {
          console.log("login error return false")
        }
      } else {
        console.log("register error return false")
      }
    }
  }

  // init tenant
  oid = source.tenants.owner_id
  console.log("accounts: ", accounts)
  console.log("oid: ", oid)
  var main_account = accounts[oid]
  console.log("main_account: ", main_account)
  // check exists
  var main_tenant
  var main_user
  var match = false
  while(!match) {
    for (id in main_account.users) {
      user = main_account.users[id]
      console.log("check user: ", user)
      if(user.tenant_id != 0 && user.tenant != undefined) {
        main_user = user
        main_tenant = main_user.tenant
        match = true
        console.log("tenant matched")
      }
    }
    if (match) {
      break;
    }
    // create
    console.log("tenant not matched, try create")
    ret = await tenant_create(main_account, source.tenants.name)
    if (!ret) {
      console.log("create tenant error")
      return
    } else {
      console.log("create tenant ok, relogin")
      await account_login(accounts[oid])
    }
  }

  console.log("main user: ", main_user)
  console.log("main tenant: ",main_tenant)

  // init dept
  var root_dept_id = main_tenant.root_dept
  var depts = {}
  ret = await dept_get(main_user, main_tenant.root_department_id, depts)

  console.log("depts: ", depts)
  var sub_user_ids = new Set()
  for (i in depts.users) {
    sub_user_ids.add(depts.users[i].id)
  }

  // join other user
  for(i in accounts) {
    account =  accounts[i]
    if(account.id == main_account.id) {
      console.log("main account, continue")
      continue
    }
    match = false
    console.log("check account join tenant: ", account)
    for(i in account.users) {
      user = account.users[i]
      if(user.tenant_id == main_tenant.id) {
        console.log("user already join tenant")
        match = true
        break
      }
    }

    if (!match){
      // join tenant
      console.log(main_tenant.root_department_id, account.users[0])
      let ret = await tenant_join(account.users[0], main_tenant.id, main_tenant.root_department_id)
      console.log("tenant join return: ", ret)
    }
  }
}

main();
