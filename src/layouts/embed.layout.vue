<script lang="ts" setup>
// Minimal layout for embedded tools (no menu, no header)
</script>

<template>
  <div class="embed-wrapper">
    <div class="embed-content">
      <slot />
    </div>
  </div>
  
</template>

<style scoped lang="less">
.embed-wrapper {
  min-height: 100vh;
  width: 100%;
  margin: 0;
  padding: 0;
  background-color: #0f1115; /* dark background */
  color: #e5e7eb; /* light text for contrast */
  display: flex;
  align-items: flex-start;
  justify-content: center;
}

.embed-content {
  width: 100%;
  max-width: 900px;
  padding: 20px 16px 40px;
}
</style>

