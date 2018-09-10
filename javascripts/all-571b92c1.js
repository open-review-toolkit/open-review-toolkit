// This is where it all goes :)

$(document).ready(function() {
  // Hook up annotator events to GA.
  // https://groups.google.com/a/list.hypothes.is/d/msgid/dev/29f8f881-3245-4153-b877-a8c952e17d37%40list.hypothes.is?utm_medium=email&utm_source=footer.
  // Interval checks every 500ms for annotator variable. Cancels interval if
  // found or timeout cancels it after 10 seconds.
  //
  var interval = window.setInterval(attachToAnnotatorEvents, 500);
  function attachToAnnotatorEvents() {
    if (window.annotator && typeof window.annotator !== "undefined" && window.annotator.hasOwnProperty('on')) {
      window.clearInterval(interval);
      function logEvent(type, annotation) {
        window.ga('send', 'event', 'Annotation', type);
      }
      window.annotator.on('annotationCreated', logEvent.bind(null, 'created'));
      window.annotator.on('annotationUpdated', logEvent.bind(null, 'updated'));

      $('button[name="sidebar-toggle"], button[name="highlight-visibility"]').on('click', function(ev) {
        window.ga('send', 'event', 'Annotation', ev.currentTarget.name + '-click');
      });
    }
  }
  window.setTimeout(function() {
    window.clearInterval(interval);
  }, 1000 * 10);

  $('#page-wrapper').append("<span id='page_end'></span>");
  $.scrollDepth({
    userTiming: false,
    pixelDepth: false,
    elements: ['#page_end'],
  });

  // Modal for citation link clicks.
  $(document).on('click', '.citation, .footnote-ref', function(ev) {
    ev.preventDefault();
    var modal = $('#citation_modal');
    var citation = $(ev.currentTarget);
    modal.find('.modal-body').html(citation.data('ref-html'));
    modal.modal('show');
  });

  function openImageModal(image) {
    var modal = $('#image_modal');
    if (image.attr('id')) {
      window.location.hash = image.attr('id');
    }
    var caption = image.siblings('.caption, figcaption');
    modal.find('.modal-body').html(image.clone().addClass('img-responsive'));
    modal.find('.modal-footer').html(caption.clone());
    modal.modal('show');
  }

  (function() {
    var image = $('img[id="' + window.location.hash.replace(/^#/, '') + '"]:first');
    if (image.length > 0) {
      openImageModal(image);
    }
  })();


  // Modal for larger images on image click.
  $(document).on('click', '.book-html .figure img, .book-html figure img', function(ev) {
    var image = $(ev.target);
    openImageModal(image);
  });

  // Keyboard shortcuts for navigating to previous and next page.
  $(document).on('keyup', function(ev) {
    var targetsToIgnore = /textarea|input|select/i
    if ((ev.keyCode === 37 || ev.keyCode === 39) && !targetsToIgnore.test(ev.target.nodeName)) {
      if (ev.keyCode === 37 && $('.pager .previous a').length > 0) {
        // left: go to previous
        location.href = $('.pager .previous a').attr('href');
      }
      else if (ev.keyCode === 39 && $('.pager .next a').length > 0) {
        // right: go to next
        location.href = $('.pager .next a').attr('href');
      }
    }
  });

  // Check if hypothes.is window is expanded.
  var annotator_frame = $('.annotator-frame');
  function isHypothesisOpen() {
    if (annotator_frame.length === 0) {
      annotator_frame = $('.annotator-frame');
    }
    return annotator_frame.length > 0 && !annotator_frame.hasClass('annotator-collapsed');
  }

  // Toggle body class if hypothes.is is open or closed.
  var body = $('body');
  setInterval(function() {
    body.toggleClass('hypothesis-open', isHypothesisOpen());
  }, 200);

  $('i[data-toggle="collapse"]').click(function(ev) {
    // Prevent click within link to cause new page load.
    ev.preventDefault();
  });

  // Remove alert if user already closed it this session.
  $('.alert[data-alert-name]').each(function(i, el) {
    var $el = $(el);
    var re = new RegExp("(?:(?:^|.*;\\s*)" + $el.data('alert-name') + "_closed" +"\\s*\\=\\s*([^;]*).*$)|^.*$");
    var closed = document.cookie.replace(re, "$1")
    if (closed) {
      $el.remove();
    }
  });
  // Hide all email asks if they've already submitted their email address.
  if (document.cookie.replace(/(?:(?:^|.*;\s*)submittedEmail\s*\=\s*([^;]*).*$)|^.*$/, "$1") === "true") {
    $('.email-cta').not('.always-show').addClass('hide');
  }

  $(document).on('click', '.close-bottom-cta', function(ev) {
    ev.preventDefault();
    $(ev.currentTarget).closest('.email-cta').addClass('hide');
  });

  // Enforce required for browsers that don't.
  $(document).on('submit', 'form', function(ev) {
    var form = $(ev.currentTarget);
    var required = form.find('[required]');
    var has_all_required = true;
    if (required.length === 0) { return true; }

    required.each(function(index, el) {
      if ($(el).val() === "") {
        has_all_required = false;
      }
    });
    if (!has_all_required) {
      ev.preventDefault();
    }
  });

  // Stash cookie with alert name if alert is closed.
  $('.alert[data-alert-name]').on('close.bs.alert', function(ev) {
    var target = $(ev.target);
    document.cookie = target.data('alert-name') + "_closed=true; path=/";
  });

});
