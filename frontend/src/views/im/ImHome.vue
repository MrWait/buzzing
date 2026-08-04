<template>
  <div class="im-home">
    <NavSidebar :active="activeTab" @update:active="onSwitchTab" @create-chat="onCreateChat" @open-search="showSearch = true" />
    <FeedPanel v-if="activeTab === 'chat'" />
    <main
      class="im-main"
      :class="{ 'with-feed': activeTab === 'chat' }"
    >
      <!-- Chat mode: two-panel layout -->
      <template v-if="activeTab === 'chat'">
        <router-view v-if="chatId" />
        <div v-else class="im-empty">
          <div class="empty-text">选择一个会话开始聊天</div>
        </div>
      </template>
      <!-- Calendar mode -->
      <CalendarView v-else-if="activeTab === 'calendar'" />
      <!-- Contacts mode -->
      <ContactsView v-else-if="activeTab === 'contacts'" @select-user="onSelectUser" />
    </main>
    <GlobalSearch :visible="showSearch" @close="showSearch = false" />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useImStore } from '@/stores/im'
import NavSidebar from './components/NavSidebar.vue'
import FeedPanel from './feed/FeedPanel.vue'
import CalendarView from './calendar/CalendarView.vue'
import ContactsView from './contacts/ContactsView.vue'
import GlobalSearch from './components/GlobalSearch.vue'
import type { UserInfo } from '@/services/im/contacts'

const route = useRoute()
const im = useImStore()

const chatId = computed(() => {
  const id = route.params.chatId
  return id ? Number(id) : null
})

const activeTab = ref('chat')
const showSearch = ref(false)

watch(
  () => route.path,
  (path) => {
    if (path.startsWith('/im/feed') || path.startsWith('/im/chat')) {
      activeTab.value = 'chat'
    } else if (path.startsWith('/im/calendar')) {
      activeTab.value = 'calendar'
    } else if (path.startsWith('/im/contacts')) {
      activeTab.value = 'contacts'
    }
  },
  { immediate: true },
)

function onSwitchTab(tab: string) {
  activeTab.value = tab
}

function onSelectUser(user: UserInfo) {
  console.log('[im] select user:', user)
}

function onCreateChat() {
  // TODO: 弹出创建会话对话框
  console.log('[im] create chat')
}

onMounted(() => {
  im.connectWs()
  im.loadFeeds()
  im.loadFeedTopList()
})
</script>

<style scoped>
.im-home {
  display: flex;
  height: 100%;
  overflow: hidden;
}
.im-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f6f8;
}
.im-main.with-feed {
  /* 当有 FeedPanel 时，main 作为聊天面板 */
}
.im-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 14px;
  background: #f5f6f8;
}
</style>
