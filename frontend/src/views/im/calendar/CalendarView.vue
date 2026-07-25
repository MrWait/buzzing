<template>
  <div class="calendar-view">
    <div class="panel-header">
      <h3>日历</h3>
    </div>
    <div class="panel-body">
      <p class="placeholder">日历功能开发中</p>
    </div>
  </div>
</template>

<style scoped>
.calendar-view {
  display: flex;
  flex-direction: column;
  height: 100%;
}
.panel-header {
  padding: 16px 20px 12px;
  border-bottom: 1px solid #e8e8e8;
}
.panel-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}
.panel-body {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.placeholder {
  color: #999;
  font-size: 14px;
}
</style>
