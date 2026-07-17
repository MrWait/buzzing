<template>
  <div v-if="open" class="member-panel" @mousedown.stop @click.stop>
    <div class="mp-arrow"></div>
    <h3 class="mp-title">成员管理</h3>

    <div class="add-row">
      <input
        v-model="newUserId"
        placeholder="用户 ID"
        @keydown.enter="addMember"
      />
      <select v-model.number="newRole">
        <option :value="ROLE_VIEWER">阅读者</option>
        <option :value="ROLE_COMMENTER">评论者</option>
        <option :value="ROLE_EDITOR">编辑者</option>
      </select>
      <button class="btn-primary" :disabled="!newUserId || submitting" @click="addMember">
        添加
      </button>
    </div>

    <div v-if="errMsg" class="err">{{ errMsg }}</div>

    <ul v-if="!loading" class="member-list">
      <li v-for="m in members" :key="m.user_id" class="member-row">
        <div class="member-info">
          <img v-if="m.avatar" :src="m.avatar" class="avatar" />
          <div v-else class="avatar avatar-fallback">{{ initials(m.name) }}</div>
          <div>
            <div class="name">{{ m.name }}</div>
            <div class="uid">{{ m.user_id }}</div>
          </div>
        </div>
        <div class="member-actions">
          <select
            v-if="m.role !== ROLE_OWNER"
            :value="m.role"
            @change="onRoleChange(m.user_id, ($event.target as HTMLSelectElement).value)"
          >
            <option :value="ROLE_VIEWER">阅读者</option>
            <option :value="ROLE_COMMENTER">评论者</option>
            <option :value="ROLE_EDITOR">编辑者</option>
          </select>
          <span v-else class="owner-tag">所有者</span>
          <button
            v-if="m.role !== ROLE_OWNER"
            class="btn-remove"
            @click="removeMember(m.user_id)"
          >
            移除
          </button>
        </div>
      </li>
    </ul>
    <div v-else class="loading">加载中…</div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { membersApi, type MemberDto } from '@/services/office/members'
import {
  ROLE_COMMENTER,
  ROLE_EDITOR,
  ROLE_OWNER,
  ROLE_VIEWER,
} from '@/composables/usePermission'

const props = defineProps<{ open: boolean; docId: string }>()

const members = ref<MemberDto[]>([])
const loading = ref(false)
const submitting = ref(false)
const errMsg = ref<string | null>(null)
const newUserId = ref('')
const newRole = ref<number>(ROLE_VIEWER)

async function refresh() {
  loading.value = true
  errMsg.value = null
  try {
    members.value = await membersApi.list(props.docId)
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    loading.value = false
  }
}

watch(
  () => [props.open, props.docId],
  ([open]) => {
    if (open) refresh()
  },
)
onMounted(() => {
  if (props.open) refresh()
})

async function addMember() {
  if (!newUserId.value || submitting.value) return
  submitting.value = true
  errMsg.value = null
  try {
    await membersApi.add(props.docId, newUserId.value.trim(), newRole.value)
    newUserId.value = ''
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  } finally {
    submitting.value = false
  }
}

async function onRoleChange(userId: string, value: string) {
  const role = Number(value)
  try {
    await membersApi.update(props.docId, userId, role)
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  }
}

async function removeMember(userId: string) {
  if (!confirm('确定要移除该成员吗？')) return
  try {
    await membersApi.remove(props.docId, userId)
    await refresh()
  } catch (e) {
    errMsg.value = e instanceof Error ? e.message : String(e)
  }
}

function initials(name: string) {
  return (name || '?').trim().slice(0, 2).toUpperCase()
}
</script>

<style scoped>
.member-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 200;
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 16px;
  min-width: 480px;
  max-width: 520px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}
.mp-arrow {
  position: absolute;
  top: -6px;
  right: 20px;
  width: 10px;
  height: 10px;
  background: #fff;
  border-left: 1px solid #e0e0e0;
  border-top: 1px solid #e0e0e0;
  transform: rotate(45deg);
}
.mp-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
}
.add-row {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.add-row input {
  flex: 1;
  padding: 8px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
}
.add-row input:focus {
  border-color: #1565c0;
}
.add-row select {
  padding: 8px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 14px;
  background: #fff;
}
.err {
  color: #d32f2f;
  font-size: 12px;
  margin-bottom: 8px;
}
.loading {
  padding: 16px;
  text-align: center;
  color: #888;
  font-size: 13px;
}
.member-list {
  list-style: none;
  padding: 0;
  margin: 0;
  max-height: 340px;
  overflow-y: auto;
}
.member-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}
.member-info {
  display: flex;
  align-items: center;
  gap: 10px;
}
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}
.avatar-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e3f2fd;
  color: #1565c0;
  font-size: 12px;
  font-weight: 600;
}
.name {
  font-size: 14px;
  color: #333;
}
.uid {
  font-size: 11px;
  color: #999;
}
.member-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.member-actions select {
  padding: 4px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 4px;
  font-size: 13px;
  background: #fff;
}
.owner-tag {
  padding: 4px 8px;
  background: #ede7f6;
  color: #5e35b1;
  border-radius: 4px;
  font-size: 12px;
}
.member-actions button,
.btn-primary {
  padding: 6px 16px;
  border: none;
  border-radius: 4px;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-primary {
  background: #1565c0;
  color: #fff;
}
.btn-primary:hover:not(:disabled) {
  background: #0d47a1;
}
.btn-primary:disabled {
  background: #90caf9;
  cursor: not-allowed;
}
.btn-remove {
  background: transparent;
  color: #d32f2f;
}
.btn-remove:hover {
  background: #ffebee;
}
</style>
