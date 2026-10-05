(() => {
  const controls = document.querySelector('.finding-controls');
  const buttons = [...document.querySelectorAll('[data-filter]')];
  const findings = [...document.querySelectorAll('[data-metrics]')];
  const count = document.querySelector('#finding-count');
  if (!controls || !count) return;
  controls.hidden = false;
  function filter(metric) {
    let visible = 0;
    for (const finding of findings) {
      const show = metric === 'all' || finding.dataset.metrics.split(' ').includes(metric);
      finding.hidden = !show;
      if (show) visible++;
    }
    for (const button of buttons) button.setAttribute('aria-pressed', String(button.dataset.filter === metric));
    count.textContent = `${visible} of ${findings.length} findings`;
  }
  for (const button of buttons) button.addEventListener('click', () => filter(button.dataset.filter));
  for (const link of document.querySelectorAll('[data-show-metric]')) {
    link.addEventListener('click', () => filter(link.dataset.showMetric));
  }
  filter('all');
})();
