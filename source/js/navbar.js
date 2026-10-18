// Mobile menu toggle. Bootstrap 5's CSS hides `.collapse` until it has `.show`; this replaces Bootstrap's JS
// (and jQuery), which the site loaded only for this.
document.querySelectorAll('.navbar-toggler').forEach(function (toggler) {
  toggler.addEventListener('click', function () {
    const menu = document.getElementById(toggler.getAttribute('aria-controls'));
    const open = menu.classList.toggle('show');
    toggler.classList.toggle('collapsed', !open);
    toggler.setAttribute('aria-expanded', open);
  });
});
