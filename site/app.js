(() => {
  const controls = document.querySelector('.finding-controls');
  const buttons = [...document.querySelectorAll('[data-filter]')];
  const findings = [...document.querySelectorAll('[data-metrics]')];
  const count = document.querySelector('#finding-count');
  const archive = document.querySelector('.archive-findings');
  const archiveCount = document.querySelector('.archive-count');
  let activeMetric = 'all';

  function filter(metric) {
    activeMetric = metric;
    let recent = 0;
    let earlier = 0;
    for (const finding of findings) {
      const show = metric === 'all' || finding.dataset.metrics.split(' ').includes(metric);
      finding.hidden = !show;
      if (show) {
        if (archive && archive.contains(finding)) earlier++;
        else recent++;
      }
    }
    for (const button of buttons) {
      button.setAttribute('aria-pressed', String(button.dataset.filter === metric));
    }
    if (count) count.textContent = `${recent} recent · ${earlier} earlier findings`;
    if (archiveCount) archiveCount.textContent = `${earlier} earlier findings ${metric === 'all' ? 'in this history' : 'match this metric'}.`;
  }

  function revealAnchor(hash, scroll = false) {
    if (!hash || hash === '#') return;
    let id;
    try { id = decodeURIComponent(hash.slice(1)); }
    catch { return; }
    const target = document.getElementById(id);
    if (!target) return;
    const finding = target.closest('[data-metrics]');
    if (finding && finding.hidden && activeMetric !== 'all') filter('all');
    for (let element = target; element; element = element.parentElement) {
      if (element.tagName === 'DETAILS') element.open = true;
    }
    if (scroll) requestAnimationFrame(() => target.scrollIntoView({ block: 'start' }));
  }

  if (controls && count) {
    controls.hidden = false;
    for (const button of buttons) {
      button.addEventListener('click', () => filter(button.dataset.filter));
    }
    filter('all');
  }
  document.addEventListener('click', event => {
    const link = event.target.closest('a[href^="#"]');
    if (!link) return;
    if (link.dataset.showMetric) filter(link.dataset.showMetric);
    revealAnchor(link.getAttribute('href'));
  });
  window.addEventListener('hashchange', () => revealAnchor(window.location.hash, true));
  revealAnchor(window.location.hash, true);
})();
