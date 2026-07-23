<template>
  <div class="im-home" :class="{ 'mobile-mode': isMobile }">
    <!-- 左侧: 会话列表 -->
    <aside class="im-sidebar" :class="{ 'panel-hidden': isMobile && chatId }">
      <FeedPanel />
    </aside>
    <!-- 中间: 聊天面板 -->
    <main class="im-main" :class="{ 'panel-show': isMobile && chatId }">
      <router-view v-if="chatId" />
      <div v-else class="im-empty">
        <div class="empty-text">选择一个会话开始聊天</div>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useImStore } from '@/stores/im'
import FeedPanel from './feed/FeedPanel.vue'

const route = useRoute()
const im = useImStore()

const chatId = computed(() => {
  const id = route.params.chatId
  return id ? Number(id) : null
})

const isMobile = ref(window.innerWidth < 768)
function onResize() {
  isMobile.value = window.innerWidth < 768
}

onMounted(() => {
  window.addEventListener('resize', onResize)
  im.connectWs()
  im.loadFeeds()
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
})
</script>

<style scoped>
.im-home {
  display: flex;
  height: 100%;
  overflow: hidden;
}

.im-sidebar {
  width: 300px;
  min-width: 300px;
  border-right: 1px solid #e0e0e0;
  display: flex;
  flex-direction: column;
  background: #f8f9fa;
}

.im-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.im-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 14px;
}

@media (max-width: 767px) {
  .im-home {
    position: relative;
  }
  .im-sidebar {
    width: 100%;
    min-width: 0;
    position: absolute;
    inset: 0;
    z-index: 1;
    transition: opacity 0.2s;
  }
  .im-sidebar.panel-hidden {
    opacity: 0;
    pointer-events: none;
  }
  .im-main {
    position: absolute;
    inset: 0;
    z-index: 0;
  }
}
</style>
