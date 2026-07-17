<template>
  <div class="hub-layout">
    <header class="topbar">
      <span class="logo">Buzzing</span>
      <TopRightBar />
    </header>
    <div class="main">
      <RouterView />
    </div>
  </div>
</template>

<script setup lang="ts">
import TopRightBar from '@/components/TopRightBar.vue'
</script>

<style scoped>
.hub-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
}
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 48px;
  padding: 0 16px;
  background: #1a1a2e;
  color: #fff;
}
.logo {
  font-weight: 600;
  font-size: 16px;
}
.main {
  flex: 1;
  overflow: auto;
}
</style>
