<template>
  <div class="login-card">
    <h2>Buzzing</h2>
    <form @submit.prevent="handleLogin">
      <div class="field">
        <label>手机号</label>
        <input v-model="phone" type="text" placeholder="请输入手机号" required />
      </div>
      <div class="field">
        <label>密码</label>
        <input v-model="password" type="password" placeholder="请输入密码" required />
      </div>
      <p v-if="error" class="error">{{ error }}</p>
      <button type="submit" class="btn-login" :disabled="loading">
        {{ loading ? '登录中...' : '登录' }}
      </button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const phone = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(phone.value, password.value)
    const redirect = (route.query.redirect as string) || '/hub'
    if (auth.loginUsers.length === 1) {
      const lu = auth.loginUsers[0]
      auth.selectIdentity(lu)
      router.push(redirect)
    } else {
      router.push({ name: 'TenantSelect', query: { redirect } })
    }
  } catch {
    error.value = '登录失败，请检查账号密码'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-card {
  width: 360px;
  padding: 32px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}
.login-card h2 {
  text-align: center;
  margin-bottom: 24px;
  font-weight: 600;
}
.field {
  margin-bottom: 16px;
}
.field label {
  display: block;
  margin-bottom: 4px;
  font-size: 14px;
  color: #333;
}
.field input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}
.error {
  color: #e53935;
  font-size: 13px;
  margin-bottom: 8px;
}
.btn-login {
  width: 100%;
  padding: 10px;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
}
.btn-login:disabled {
  opacity: 0.6;
}
</style>
