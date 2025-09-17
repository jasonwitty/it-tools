<script setup lang="ts">
import { RouterView, useRoute } from 'vue-router';
import { NGlobalStyle, NMessageProvider, NNotificationProvider, darkTheme } from 'naive-ui';
import { darkThemeOverrides, lightThemeOverrides } from './themes';
import { layouts } from './layouts';
import { useStyleStore } from './stores/style.store';

const route = useRoute();
const layout = computed(() => {
  const isTool = Boolean(route?.meta?.isTool);
  const isEmbed = ['1', 'true', 'yes'].includes(String(route?.query?.embed ?? '').toLowerCase());
  if (isTool && isEmbed)
    return layouts.embedLayout;
  return route?.meta?.layout ?? layouts.base;
});
const styleStore = useStyleStore();

const theme = computed(() => {
  const isEmbed = ['1', 'true', 'yes'].includes(String(route?.query?.embed ?? '').toLowerCase());
  // Force dark theme in embed mode regardless of user preference
  if (isEmbed)
    return darkTheme;
  return styleStore.isDarkTheme ? darkTheme : null;
});
const themeOverrides = computed(() => {
  const isEmbed = ['1', 'true', 'yes'].includes(String(route?.query?.embed ?? '').toLowerCase());
  if (isEmbed)
    return darkThemeOverrides;
  return styleStore.isDarkTheme ? darkThemeOverrides : lightThemeOverrides;
});

const { locale } = useI18n();

syncRef(
  locale,
  useStorage('locale', locale),
);
</script>

<template>
  <n-config-provider :theme="theme" :theme-overrides="themeOverrides">
    <NGlobalStyle />
    <NMessageProvider placement="bottom">
      <NNotificationProvider placement="bottom-right">
        <component :is="layout">
          <RouterView />
        </component>
      </NNotificationProvider>
    </NMessageProvider>
  </n-config-provider>
</template>

<style>
body {
  min-height: 100%;
  margin: 0;
  padding: 0;
}

html {
  height: 100%;
  margin: 0;
  padding: 0;
}

* {
  box-sizing: border-box;
}
</style>
