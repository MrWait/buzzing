<template>
  <div class="not-found">
    <h2>404</h2>
    <p>页面不存在</p>
    <RouterLink to="/">返回首页</RouterLink>
  </div>
</template>

<style scoped>
.not-found {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  color: #666;
}
.not-found h2 {
  font-size: 64px;
  margin-bottom: 8px;
  color: #999;
}
</style>
