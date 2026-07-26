
export function featureFlags() {
  return {
    task: 'T15',
    showInsights: import.meta.env.VITE_FEATURE_SHOW_INSIGHTS === 'true',
    valueRedacted: true,
  };
}
