document.oncontextmenu = function(e) { e.preventDefault(); return false; };
document.onkeydown = function(e) {
    if (e.ctrlKey && e.shiftKey && e.key === "I") {
        return false;
    }
    if (e.key === "F12") {
        return false;
    }
};

(function() {
  const headerDiv = document.getElementById('header');
  function initHamburgerMenu() {
    const hamburger = document.querySelector('.hamburger-menu');
    const nav = document.querySelector('.header-nav');
    if (!hamburger || !nav) return;
    hamburger.addEventListener('click', () => {
      hamburger.classList.toggle('active');
      nav.classList.toggle('active');
    });
    document.addEventListener('click', (e) => {
      if (!hamburger.contains(e.target) && !nav.contains(e.target)) {
        hamburger.classList.remove('active');
        nav.classList.remove('active');
      }
    });
  }
  if (headerDiv) {
    fetch('header.html')
      .then(res => res.text())
      .then(html => {
        headerDiv.innerHTML = html;
        initHamburgerMenu();
      });
  } else {
    initHamburgerMenu();
  }
})();

//eval(atob("cGFydGljbGVzSlMoInBhcnRpY2xlcy1qcyIsIHtwYXJ0aWNsZXM6IHtudW1iZXI6IHt2YWx1ZTogODAsIGRlbnNpdHk6IHtlbmFibGU6IHRydWUsIHZhbHVlX2FyZWE6IDgwMH19LCBjb2xvcjoge3ZhbHVlOiAiI2ZmZmZmZiJ9LCBzaGFwZToge3R5cGU6ICJjaXJjbGUifSwgb3BhY2l0eToge3ZhbHVlOiAwLjUsIHJhbmRvbTogdHJ1ZX0sIHNpemU6IHt2YWx1ZTogMywgcmFuZG9tOiB0cnVlfSwgbW92ZToge2VuYWJsZTogdHJ1ZSwgc3BlZWQ6IDEsIGRpcmVjdGlvbjogIm5vbmUiLCByYW5kb206IHRydWUsIG91dF9tb2RlOiAib3V0In19fSk7"));
