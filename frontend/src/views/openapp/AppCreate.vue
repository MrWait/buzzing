<template>
  <div class="app-create">
    <header class="page-header">
      <router-link :to="{ name: 'AppList' }" class="back-link">&larr; 返回</router-link>
      <h1>创建应用</h1>
    </header>
    <form class="create-form" @submit.prevent="onSubmit">
      <div class="form-group">
        <label>应用名称 <span class="required">*</span></label>
        <input v-model="form.name" placeholder="输入应用名称" required />
      </div>
      <div class="form-group">
        <label>应用描述</label>
        <textarea v-model="form.description" placeholder="简要描述你的应用" rows="3"></textarea>
      </div>
      <div class="form-actions">
        <router-link :to="{ name: 'AppList' }" class="btn-cancel">取消</router-link>
        <button type="submit" class="btn-primary" :disabled="submitting">
          {{ submitting ? '创建中...' : '创建' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useOpenAppStore } from '@/stores/openapp'

const router = useRouter()
const store = useOpenAppStore()

const form = reactive({
  name: '',
  description: '',
})
const submitting = ref(false)

async function onSubmit() {
  if (!form.name.trim()) return
  submitting.value = true
  try {
    const data = {
      name: form.name.trim(),
      ...(form.description.trim() ? { description: form.description.trim() } : {}),
    }
    const app = await store.createApp(data)
    router.push({ name: 'AppDetail', params: { id: app.app_id } })
  } catch (e) {
    console.error('create app failed', e)
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.app-create {
  padding: 24px;
  max-width: 600px;
  margin: 0 auto;
}
.page-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 32px;
}
.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}
.back-link {
  color: #1a73e8;
  text-decoration: none;
  font-size: 14px;
}
.create-form {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 24px;
}
.form-group {
  margin-bottom: 20px;
}
.form-group label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 6px;
  color: #333;
}
.required {
  color: #d32f2f;
}
.form-group input,
.form-group textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  box-sizing: border-box;
}
.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.15);
}
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 32px;
}
.btn-cancel {
  padding: 8px 20px;
  border: 1px solid #ddd;
  border-radius: 6px;
  color: #666;
  text-decoration: none;
  font-size: 14px;
}
.btn-primary {
  padding: 8px 20px;
  border: none;
  border-radius: 6px;
  background: #1a73e8;
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}
.btn-primary:hover {
  background: #1557b0;
}
.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
